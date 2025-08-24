# Stage 1: Build
FROM golang:1.24-alpine AS builder
WORKDIR /app

# Copy go.mod and go.sum
COPY go.mod go.sum ./
RUN go mod download

# Copy source
COPY *.go ./
COPY templates ./templates
COPY static ./static

# Build binary
RUN go build -o symphony

# Stage 2: Minimal image
FROM alpine:latest
WORKDIR /app

# Copy from builder
COPY --from=builder /app/symphony /symphony
COPY --from=builder /app/templates ./templates
COPY --from=builder /app/static ./static

EXPOSE 8080
CMD ["/symphony"]

