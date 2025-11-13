#!/usr/bin/env ruby

require 'optparse'
require 'open-uri'
require 'nokogiri'
require 'fileutils'

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
    end.reject { |r| r[:title].nil? || r[:link].nil? }
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

# Main
download = false
OptionParser.new do |opts|
  opts.banner = "Usage: pdf_searcher.rb [options] QUERY"
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
  puts "Please provide a search query."
  exit 1
end

begin
  searcher = PDFSearcher.new(query)
  results = searcher.search
  results.each do |r|
    puts "#{r[:title]}: #{r[:link]}"
  end
  if download
    downloader = PDFDownloader.new(results)
    downloader.download
  end
rescue => e
  puts "Error: #{e.message}"
end