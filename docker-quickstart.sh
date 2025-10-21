#!/bin/bash

# Quick Start Script for ComfyUI Docker
# This script helps you get started quickly with ComfyUI Docker

set -e

echo "===================================="
echo "ComfyUI Docker Quick Start"
echo "===================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

echo "✅ Docker is installed"

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available. Please install Docker Compose."
    exit 1
fi

echo "✅ Docker Compose is available"

# Check for NVIDIA GPU
if command -v nvidia-smi &> /dev/null; then
    echo "✅ NVIDIA GPU detected"
    nvidia-smi --query-gpu=name --format=csv,noheader
else
    echo "⚠️  No NVIDIA GPU detected. ComfyUI will run in CPU mode (slow)."
fi

echo ""
echo "Creating necessary directories..."

# Create directories
mkdir -p models/checkpoints models/vae models/loras models/controlnet \
    models/clip_vision models/embeddings models/upscale_models \
    input output custom_nodes

echo "✅ Directories created"
echo ""

# Check if models exist
if [ -z "$(ls -A models/checkpoints)" ]; then
    echo "⚠️  No models found in models/checkpoints/"
    echo ""
    echo "You need to download at least one Stable Diffusion model."
    echo "Example: Stable Diffusion 1.5"
    echo "Download from: https://huggingface.co/Comfy-Org/stable-diffusion-v1-5-archive/blob/main/v1-5-pruned-emaonly-fp16.safetensors"
    echo ""
    echo "Place the downloaded model in: ./models/checkpoints/"
    echo ""
    read -p "Press Enter to continue anyway, or Ctrl+C to exit and download models first..."
fi

# Ask user about configuration
echo ""
echo "Do you want to use external model paths? (e.g., models on another drive)"
read -p "(y/N): " use_external

if [[ "$use_external" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Please edit docker-compose.override.yml to configure your paths."
    echo "Example for Windows WSL2: /mnt/d/AI/models"
    echo "Example for Linux: /home/user/AI/models"
    echo ""
    
    if [ ! -f docker-compose.override.yml ]; then
        cp docker-compose.external-paths.example.yml docker-compose.override.yml
        echo "✅ Created docker-compose.override.yml from template"
        echo "Please edit this file with your paths before proceeding."
        read -p "Press Enter when ready..."
    fi
fi

echo ""
echo "Building Docker image (this may take a few minutes)..."
docker compose build

echo ""
echo "✅ Build complete!"
echo ""
echo "Starting ComfyUI..."
docker compose up -d

echo ""
echo "✅ ComfyUI is starting!"
echo ""
echo "===================================="
echo "Access ComfyUI at: http://localhost:8188"
echo "===================================="
echo ""
echo "View logs: docker compose logs -f"
echo "Stop ComfyUI: docker compose down"
echo ""
echo "Waiting for ComfyUI to be ready..."

# Wait for service to be ready
sleep 5
for i in {1..30}; do
    if curl -s http://localhost:8188 > /dev/null 2>&1; then
        echo ""
        echo "✅ ComfyUI is ready!"
        echo "Open your browser to: http://localhost:8188"
        break
    fi
    echo -n "."
    sleep 2
done

echo ""
echo "For more information, see DOCKER_README.md"
