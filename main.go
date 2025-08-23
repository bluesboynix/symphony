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

type PageData struct {
	Title     string
	Message   string
	Timestamp string
	Hostname  string
}

type MessageResponse struct {
	Message   string `json:"message"`
	Timestamp string `json:"timestamp"`
}

func main() {
	hostname, err := os.Hostname()
	if err != nil {
		hostname = "unknown"
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		tmpl, err := template.ParseFiles("templates/index.html")
		if err != nil {
			http.Error(w, "Template not found", http.StatusInternalServerError)
			log.Printf("Template parsing error: %v", err)
			return
		}

		data := PageData{
			Title:     "Symphony",
			Message:   "Welcome to Symphony!",
			Timestamp: time.Now().Format("2006-01-02 15:04:05"),
			Hostname:  hostname,
		}

		if err := tmpl.Execute(w, data); err != nil {
			http.Error(w, "Error rendering template", http.StatusInternalServerError)
			log.Printf("Template execution error: %v", err)
		}
	})

	http.HandleFunc("/api/message", func(w http.ResponseWriter, r *http.Request) {
		name := r.URL.Query().Get("name")
		if name == "" {
			name = "Guest"
		}

		response := MessageResponse{
			Message:   fmt.Sprintf("Hello, %s! This is a response from Symphony.", name),
			Timestamp: time.Now().Format("2006-01-02 15:04:05"),
		}

		w.Header().Set("Content-Type", "application/json")
		if err := json.NewEncoder(w).Encode(response); err != nil {
			http.Error(w, "JSON encoding error", http.StatusInternalServerError)
			log.Printf("JSON encoding error: %v", err)
		}
	})

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintln(w, "OK")
	})

	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Symphony server starting on port %s...", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}

