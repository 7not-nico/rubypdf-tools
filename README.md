# Ruby PDF Searcher

A simple CLI tool to search for PDF books using DuckDuckGo and optionally download them.

## Features

- Interactive prompts for book category and selection of academic book suggestions
- Searches DuckDuckGo for PDFs
- Downloads PDFs to a local `downloads/` directory
- KISS principle: minimal, no redundancies

## Requirements

- Ruby
- Nokogiri gem (`gem install nokogiri`)

## Usage

### Run Online (Directly from GitHub)

For suggestions:
```bash
ruby <(curl -s https://raw.githubusercontent.com/7not-nico/rubypdf-tools/master/pdf_searcher.rb) programming 1
```

For free query:
```bash
ruby <(curl -s https://raw.githubusercontent.com/7not-nico/rubypdf-tools/master/pdf_searcher.rb) "the roses"
```

### Run Locally

1. Clone the repo:
   ```bash
   git clone https://github.com/7not-nico/rubypdf-tools.git
   cd rubypdf-tools
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Run the script:
   ```bash
   ruby pdf_searcher.rb "free query"
   # Or for suggestions: ruby pdf_searcher.rb programming 1
   # Or interactive: ruby pdf_searcher.rb programming
   # With download: add -d
   ```

The script accepts a free query or a category with optional choice number for academic book suggestions.

## Options

- `-d`, `--download`: Download found PDFs to `downloads/` directory
- `-h`, `--help`: Show help

## Categories and Books

- **programming**: The C Programming Language, Clean Code, Code Complete, Introduction to Algorithms, Design Patterns
- **math**: Calculus, Linear Algebra and Its Applications, Discrete Mathematics, Probability and Statistics, Real Analysis
- **science**: Introduction to Quantum Mechanics, Biology, Chemistry: The Central Science, Physics for Scientists and Engineers, Earth Science
- **history**: A History of the World, The Guns of August, Sapiens: A Brief History of Humankind, The Rise and Fall of the Roman Empire, World War II

## License

MIT</content>
<parameter name="filePath">/home/eddyr/repo/rubypdf-tools/searcher-pdf/README.md