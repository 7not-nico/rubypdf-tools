#!/usr/bin/env ruby
# Updated for online use with args - 2025-11-13

require 'optparse'
require 'open-uri'
require 'nokogiri'
require 'fileutils'
require 'benchmark'

class PDFSearcher
  def initialize(query)
    @query = query
  end

  def search
    search_url = "https://duckduckgo.com/html/?q=#{URI.encode_www_form_component(@query)}+ext:pdf"
    doc = Nokogiri::HTML(URI.open(search_url, 'User-Agent' => 'Mozilla/5.0 (compatible; PDFSearcher/1.0)'))
    results = doc.css('.result').map do |result|
      title = result.at_css('h2.result__title a.result__a')&.text
      link_href = result.at_css('h2.result__title a.result__a')&.[]('href')
      real_link = nil
      if link_href
        uri = URI.parse(link_href)
        query_params = URI.decode_www_form(uri.query || '')
        uddg_param = query_params.find { |k, v| k == 'uddg' }&.last
        if uddg_param
          real_link = URI.decode_www_form_component(uddg_param)
        else
          real_link = link_href
        end
      end
      { title: title, link: real_link }
    end.reject { |r| r[:title].nil? || r[:link].nil? || !r[:link].end_with?('.pdf') }.first(10)
    results
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

# Academic book suggestions
BOOKS = {
  "programming" => [
    "The C Programming Language",
    "Clean Code",
    "Code Complete",
    "Introduction to Algorithms",
    "Design Patterns"
  ],
  "math" => [
    "Calculus",
    "Linear Algebra and Its Applications",
    "Discrete Mathematics",
    "Probability and Statistics",
    "Real Analysis"
  ],
  "science" => [
    "Introduction to Quantum Mechanics",
    "Biology",
    "Chemistry: The Central Science",
    "Physics for Scientists and Engineers",
    "Earth Science"
  ],
  "history" => [
    "A History of the World",
    "The Guns of August",
    "Sapiens: A Brief History of Humankind",
    "The Rise and Fall of the Roman Empire",
    "World War II"
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