FROM golang:1.24-alpine

WORKDIR /app

# Copy go mod and sum files
COPY go.mod ./

# Download all dependencies
RUN go mod download

# Copy source code
COPY *.go ./
COPY templates/ ./templates/

# Build the application
RUN go build -o /devops-app

# Expose port
EXPOSE 8080

# Command to run the application
CMD ["/devops-app"]
