#!/bin/bash
# Bash script to build and run the Docker container
# Usage: ./docker-build.sh

echo "Building Realms Governance UI Docker image..."

# Build the Docker image
docker build -t realms-governance-ui .

if [ $? -eq 0 ]; then
    echo ""
    echo "Build successful!"
    echo ""
    echo "To run the container, use one of these commands:"
    echo "  docker run -p 3000:3000 realms-governance-ui"
    echo "  OR"
    echo "  docker-compose up"
else
    echo ""
    echo "Build failed!"
    exit 1
fi

