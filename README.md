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

- `-d`, `--download`: Download selected PDFs to `downloads/` directory (prompts for number if multiple)
- `-h`, `--help`: Show help

## Categories and Books

Prioritized by fundamentality (most fundamental first):

- **programming**: Introduction to Algorithms, The C Programming Language, Clean Code, Code Complete, Design Patterns, Computer Systems: A Programmer's Perspective, Structure and Interpretation of Computer Programs, Programming Pearls, The Pragmatic Programmer, Head First Design Patterns
- **math**: Calculus, Linear Algebra and Its Applications, Discrete Mathematics and Its Applications, Probability and Statistics for Engineers, Real Analysis, Abstract Algebra, Differential Equations, Topology, Number Theory, Complex Analysis
- **science**: Biology, Chemistry: The Central Science, Physics for Scientists and Engineers, Introduction to Quantum Mechanics, Earth Science, Genetics: From Genes to Genomes, Organic Chemistry, Thermodynamics, Evolutionary Biology, Astronomy
- **history**: A History of the World, Sapiens: A Brief History of Humankind, The Guns of August, The Rise and Fall of the Roman Empire, World War II, The History of the Ancient World, Guns, Germs, and Steel, The Silk Roads, The Wright Brothers, The Cold War

## License

MIT</content>
<parameter name="filePath">/home/eddyr/repo/rubypdf-tools/searcher-pdf/README.md