#!/bin/bash

# Simple deployment script
echo "Starting deployment..."

# Build the Docker image with the project name 'symphony'
docker build -t symphony .

# Stop and remove existing container if running
docker stop symphony-container || true
docker rm symphony-container || true

# Run new container
docker run -d -p 8080:8080 --name symphony-container symphony

echo "Deployment completed successfully!"

