# Use Go 1.24 Alpine image
FROM golang:1.24-alpine

# Set working directory
WORKDIR /app

# Copy go.mod and go.sum for dependency resolution
COPY go.mod ./
COPY go.sum ./

# Download dependencies
RUN go mod download

# Copy application source code
COPY *.go ./
COPY templates/ ./templates/
COPY static/ ./static/

# Build the Go application with the project name 'symphony'
RUN go build -o /symphony

# Expose application port
EXPOSE 8080

# Run the built binary
CMD ["/symphony"]

