#!/usr/bin/env ruby
# Ruby PDF searcher with web search - 2025-11-13

require 'optparse'
require 'open-uri'
require 'nokogiri'
require 'fileutils'
require 'benchmark'

class PDFSearcher
  USER_AGENTS = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
  ]

  def initialize(query)
    @query = query
  end

  def search
    search_url = "https://search.brave.com/search?q=#{URI.encode_www_form_component(@query)}"
    ua = USER_AGENTS.sample
    headers = {
      'User-Agent' => ua,
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Accept-Language' => 'en-US,en;q=0.5',
      'Accept-Encoding' => 'gzip, deflate',
      'Connection' => 'keep-alive',
      'Upgrade-Insecure-Requests' => '1',
      'Referer' => 'https://search.brave.com/',
    }
    doc = Nokogiri::HTML(URI.open(search_url, headers))
    results = doc.css('a[class*="heading-serpresult"]').map do |a|
      link = a['href']
      title = a.text.strip
      if link&.end_with?('.pdf') && !title.empty?
        { title: title, link: link }
      end
    end.compact.first(10)
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
  opts.banner = "Usage: pdf_searcher.rb QUERY [options]"
  opts.on("-d", "--download", "Download the found PDFs") do
    download = true
  end
  opts.on("-h", "--help", "Show this help") do
    puts opts
    exit
  end
end.parse!

query = ARGV.join(' ')

if query.empty?
  puts "Usage: ruby pdf_searcher.rb QUERY [-d]"
  exit 1
end

searcher = PDFSearcher.new(query)
results = nil
time = Benchmark.measure do
  results = searcher.search
end
puts "Search took #{time.real.round(2)} seconds"
if results.empty?
  puts "No PDFs found."
  exit
end

results.each_with_index do |r, index|
  puts "#{index + 1}. #{r[:title]}: #{r[:link]}"
end

if download
  if results.size == 1
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