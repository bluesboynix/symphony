# Stage 1: Build
FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY go.mod ./
COPY go.sum ./
RUN go mod download
COPY *.go ./templates ./static ./
RUN go build -o symphony

# Stage 2: Run
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/symphony /symphony
COPY --from=builder /app/templates ./templates
COPY --from=builder /app/static ./static
EXPOSE 8080
CMD ["/symphony"]
