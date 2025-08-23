#!/bin/bash

# Simple deployment script
echo "Starting deployment..."

# Build the Docker image
docker build -t devops-app .

# Stop and remove existing container if running
docker stop devops-container || true
docker rm devops-container || true

# Run new container
docker run -d -p 8080:8080 --name devops-container devops-app

echo "Deployment completed successfully!"
