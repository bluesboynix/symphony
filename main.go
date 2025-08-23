package main

import (
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"time"
)

// PageData holds data for the HTML template
type PageData struct {
	Title     string
	Message   string
	Timestamp string
	Hostname  string
}

// MessageResponse for API responses
type MessageResponse struct {
	Message   string `json:"message"`
	Timestamp string `json:"timestamp"`
}

func main() {
	// Get hostname for display
	hostname, err := os.Hostname()
	if err != nil {
		hostname = "unknown"
	}

	// Define HTTP handlers
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Parse template
		tmpl := template.Must(template.ParseFiles("templates/index.html"))
		
		// Prepare data
		data := PageData{
			Title:     "DevOps Go + HTMX App",
			Message:   "Welcome to our DevOps project!",
			Timestamp: time.Now().Format("2006-01-02 15:04:05"),
			Hostname:  hostname,
		}
		
		// Execute template
		tmpl.Execute(w, data)
	})

	// API endpoint for HTMX
	http.HandleFunc("/api/message", func(w http.ResponseWriter, r *http.Request) {
		name := r.URL.Query().Get("name")
		if name == "" {
			name = "Guest"
		}

		// Set response headers
		w.Header().Set("Content-Type", "application/json")
		
		// Create response
		response := MessageResponse{
			Message:   fmt.Sprintf("Hello, %s! This is a response from the Go server.", name),
			Timestamp: time.Now().Format("2006-01-02 15:04:05"),
		}
		
		// Convert to JSON
		json.NewEncoder(w).Encode(response)
	})

	// Health check endpoint
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, "OK")
	})

	// Static files
	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	
	log.Printf("Server starting on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
