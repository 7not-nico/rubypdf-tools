# PDF Searcher

A simple Ruby script to search for PDFs online and download them.

## Usage

Run the script with a query:

```bash
ruby pdf_searcher.rb "calculus pdf"
```

It searches Brave for PDFs, lists results, use `-d` to download the first result.

## How It Works

See [HOW_IT_WORKS.md](HOW_IT_WORKS.md) for a detailed explanation of the script's functionality.

## Requirements

- Ruby
- Nokogiri gem (`gem install nokogiri`)

## Running Online

To run the script without installing Ruby locally, you can use an online Ruby compiler:

1. Go to [Replit Ruby](https://replit.com/languages/ruby)
2. Copy the code from [pdf_searcher.rb](https://raw.githubusercontent.com/7not-nico/rubypdf-tools/main/pdf_searcher.rb)
3. Paste it into the online editor
4. Install Nokogiri if needed: `gem install nokogiri`
5. Run with: `ruby pdf_searcher.rb "your query" -d`

## Feedback

To give feedback, report issues at https://github.com/sst/opencode/issues