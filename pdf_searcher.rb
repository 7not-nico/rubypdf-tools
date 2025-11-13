#!/usr/bin/env ruby
# Updated for online use with args - 2025-11-13 14:00 - 2025-11-13

require 'optparse'
require 'open-uri'
require 'nokogiri'
require 'fileutils'
require 'benchmark'
require 'net/http'
require 'json'

class PDFSearcher
  # Set your Bing Search API key here
  API_KEY = ENV['BING_API_KEY'] || 'YOUR_BING_API_KEY_HERE'

  def initialize(query)
    @query = query
  end

  def search
    return [] if API_KEY == 'YOUR_BING_API_KEY_HERE'

    url = "https://api.bing.microsoft.com/v7.0/search?q=#{URI.encode_www_form_component(@query)}+filetype:pdf&count=10"
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request['Ocp-Apim-Subscription-Key'] = API_KEY
    response = http.request(request)
    data = JSON.parse(response.body)
    results = data['webPages']['value']&.map do |item|
      title = item['name']
      link = item['url']
      { title: title, link: link }
    end || []
    results.reject { |r| r[:link].nil? || !r[:link].end_with?('.pdf') }.first(10)
  rescue => e
    puts "Search error: #{e.message}"
    []
  end
end

class PDFDownloader
  def initialize(results)
    @results = results
  end

  def download
    dir = 'downloads'
    FileUtils.mkdir_p(dir)
    @results.each do |r|
      next unless r[:link].end_with?('.pdf')
      filename = sanitize_filename(r[:title]) + '.pdf'
      filepath = File.join(dir, filename)
      begin
        URI.open(r[:link].gsub(' ', '%20')) do |file|
          File.open(filepath, 'wb') do |f|
            f.write(file.read)
          end
        end
        puts "Downloaded: #{filepath}"
      rescue => e
        puts "Error downloading #{r[:link]}: #{e.message}"
      end
    end
  end

  private

  def sanitize_filename(filename)
    filename.gsub(/[^0-9A-Za-z.\-]/, '_').gsub(/_{2,}/, '_').strip
  end
end

# Academic book suggestions (prioritized by fundamentality)
BOOKS = {
  "programming" => [
    "Introduction to Algorithms",
    "The C Programming Language",
    "Clean Code",
    "Code Complete",
    "Design Patterns",
    "Computer Systems: A Programmer's Perspective",
    "Structure and Interpretation of Computer Programs",
    "Programming Pearls",
    "The Pragmatic Programmer",
    "Head First Design Patterns"
  ],
  "math" => [
    "Calculus",
    "Linear Algebra and Its Applications",
    "Discrete Mathematics and Its Applications",
    "Probability and Statistics for Engineers",
    "Real Analysis",
    "Abstract Algebra",
    "Differential Equations",
    "Topology",
    "Number Theory",
    "Complex Analysis"
  ],
  "science" => [
    "Biology",
    "Chemistry: The Central Science",
    "Physics for Scientists and Engineers",
    "Introduction to Quantum Mechanics",
    "Earth Science",
    "Genetics: From Genes to Genomes",
    "Organic Chemistry",
    "Thermodynamics",
    "Evolutionary Biology",
    "Astronomy"
  ],
  "history" => [
    "A History of the World",
    "Sapiens: A Brief History of Humankind",
    "The Guns of August",
    "The Rise and Fall of the Roman Empire",
    "World War II",
    "The History of the Ancient World",
    "Guns, Germs, and Steel",
    "The Silk Roads",
    "The Wright Brothers",
    "The Cold War"
  ]
}

# Main
download = false
OptionParser.new do |opts|
  opts.banner = "Usage: pdf_searcher.rb CATEGORY [CHOICE] [options]\nCategories: #{BOOKS.keys.join(', ')}"
  opts.on("-d", "--download", "Download the found PDFs") do
    download = true
  end
  opts.on("-h", "--help", "Show this help") do
    puts opts
    exit
  end
end.parse!

category_or_query = ARGV.join(' ')

if category_or_query.empty?
  puts "Usage: ruby pdf_searcher.rb QUERY [-d]"
  puts "Or for suggestions: ruby pdf_searcher.rb CATEGORY [CHOICE] [-d]"
  puts "Categories: #{BOOKS.keys.join(', ')}"
  exit 1
end

category = category_or_query.downcase
if BOOKS.key?(category)
  choice_num = ARGV[1]&.to_i
  if choice_num.nil?
    puts "Suggested academic books in #{category}:"
    BOOKS[category].each_with_index do |book, index|
      puts "#{index + 1}. #{book}"
    end
    puts "Choose a book by number:"
    choice_input = STDIN.gets.chomp.to_i - 1
    if choice_input < 0 || choice_input >= BOOKS[category].size
      puts "Invalid choice."
      exit 1
    end
    choice = choice_input
  else
    choice = choice_num - 1
    if choice < 0 || choice >= BOOKS[category].size
      puts "Invalid choice number."
      exit 1
    end
  end
  query = BOOKS[category][choice]
else
  query = category_or_query
end

begin
  searcher = PDFSearcher.new(query)
  results = nil
  time = Benchmark.measure do
    results = searcher.search
  end
  puts "Search took #{time.real.round(2)} seconds"
  results.each_with_index do |r, index|
    puts "#{index + 1}. #{r[:title]}: #{r[:link]}"
  end
  if download
    if results.empty?
      puts "No PDFs found to download."
    elsif results.size == 1
      downloader = PDFDownloader.new([results[0]])
      downloader.download
    else
      puts "Enter the number to download (1-#{results.size}):"
      num = STDIN.gets.chomp.to_i - 1
      if num >= 0 && num < results.size
        downloader = PDFDownloader.new([results[num]])
        downloader.download
      else
        puts "Invalid number."
      end
    end
  end
rescue => e
  puts "Error: #{e.message}"
end