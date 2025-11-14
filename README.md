# PDF Searcher

A simple tool to search for PDFs online and download them. Available in Ruby (with book suggestions) and Go (direct search).

## Ruby Version

Run the Ruby script with a category for book suggestions:

```bash
ruby pdf_searcher.rb math
```

It lists books, choose one, use `-d` for download instructions.

Categories: programming, math, science, history

## Go Version

Run the Go program with any query to search for PDFs:

```bash
go run pdf_searcher.go "calculus pdf"
```

It lists found PDFs, enter a number to download one.

## Feedback

To give feedback, report issues at https://github.com/sst/opencode/issues