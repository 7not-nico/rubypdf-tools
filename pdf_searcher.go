package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"regexp"
	"strings"
	"time"
)

type PDFResult struct {
	Title string
	Link  string
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run pdf_searcher.go QUERY")
		os.Exit(1)
	}

	query := strings.Join(os.Args[1:], " ")
	results := searchPDFs(query)

	if len(results) == 0 {
		fmt.Println("No PDFs found.")
		return
	}

	fmt.Println("Found PDFs:")
	for i, r := range results {
		fmt.Printf("%d. %s: %s\n", i+1, r.Title, r.Link)
	}

	fmt.Print("Enter the number to download (or 0 to exit): ")
	var num int
	fmt.Scan(&num)
	if num > 0 && num <= len(results) {
		downloadPDF(results[num-1])
	}
}

func searchPDFs(query string) []PDFResult {
	url := "https://search.yahoo.com/search?q=" + strings.ReplaceAll(query, " ", "+") + "+filetype:pdf"
	client := &http.Client{Timeout: 10 * time.Second}
	req, _ := http.NewRequest("GET", url, nil)
	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
	req.Header.Set("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
	req.Header.Set("Accept-Language", "en-US,en;q=0.5")
	req.Header.Set("Connection", "keep-alive")
	req.Header.Set("Referer", "https://search.brave.com/")

	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("Search error:", err)
		return nil
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("Read error:", err)
		return nil
	}

	html := string(body)
	re := regexp.MustCompile(`<a[^>]*href="([^"]*)"[^>]*>([^<]*)</a>`)
	matches := re.FindAllStringSubmatch(html, -1)

	var results []PDFResult
	for _, match := range matches {
		link := match[1]
		title := strings.TrimSpace(match[2])
		if strings.HasSuffix(link, ".pdf") && title != "" {
			results = append(results, PDFResult{Title: title, Link: link})
			if len(results) >= 10 {
				break
			}
		}
	}
	return results
}

func downloadPDF(r PDFResult) {
	resp, err := http.Get(r.Link)
	if err != nil {
		fmt.Println("Download error:", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		fmt.Println("Download failed:", resp.Status)
		return
	}

	filename := sanitizeFilename(r.Title) + ".pdf"
	file, err := os.Create(filename)
	if err != nil {
		fmt.Println("File create error:", err)
		return
	}
	defer file.Close()

	_, err = io.Copy(file, resp.Body)
	if err != nil {
		fmt.Println("Copy error:", err)
		return
	}

	fmt.Println("Downloaded:", filename)
}

func sanitizeFilename(name string) string {
	reg := regexp.MustCompile(`[<>:"/\\|?*]`)
	return reg.ReplaceAllString(name, "_")
}
