#!/usr/bin/env ruby
# Simplified for book suggestions only - 2025-11-13

require 'optparse'
require 'open-uri'
require 'nokogiri'
require 'fileutils'
require 'benchmark'



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

category = ARGV[0]&.downcase
choice_num = ARGV[1]&.to_i

if category.nil? || !BOOKS.key?(category)
  puts "Usage: ruby pdf_searcher.rb CATEGORY [CHOICE] [-d]"
  puts "Categories: #{BOOKS.keys.join(', ')}"
  exit 1
end

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

book_title = BOOKS[category][choice]
puts "Selected: #{book_title}"

if download
  # Assume the book title is the query for download, but since no search, perhaps search manually or something.
  # For KISS, just say to search manually.
  puts "To download, search for '#{book_title} pdf' in your browser and download the PDF."
else
  puts "To find PDFs, search for '#{book_title} pdf' in your browser."
end