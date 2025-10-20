# Makefile for ComfyUI Docker

.PHONY: help build up down restart logs shell clean test

# Default target
help:
	@echo "ComfyUI Docker - Available commands:"
	@echo ""
	@echo "  make build       - Build the Docker image"
	@echo "  make up          - Start ComfyUI in background"
	@echo "  make down        - Stop ComfyUI"
	@echo "  make restart     - Restart ComfyUI"
	@echo "  make logs        - View ComfyUI logs (follow)"
	@echo "  make shell       - Open a shell in the running container"
	@echo "  make test        - Run Docker implementation tests"
	@echo "  make clean       - Stop and remove containers, networks"
	@echo "  make clean-all   - Clean + remove images and volumes (WARNING: removes models!)"
	@echo ""
	@echo "Quick start: make build && make up"
	@echo "Then open: http://localhost:8188"

# Build the Docker image
build:
	@echo "Building ComfyUI Docker image..."
	docker compose build

# Start ComfyUI in background
up:
	@echo "Starting ComfyUI..."
	docker compose up -d
	@echo ""
	@echo "ComfyUI is starting..."
	@echo "Access at: http://localhost:8188"
	@echo "View logs: make logs"

# Stop ComfyUI
down:
	@echo "Stopping ComfyUI..."
	docker compose down

# Restart ComfyUI
restart: down up

# View logs
logs:
	docker compose logs -f

# Open shell in running container
shell:
	docker compose exec comfyui /bin/bash

# Run tests
test:
	@chmod +x test-docker-implementation.sh
	@./test-docker-implementation.sh

# Clean up (stop and remove containers)
clean:
	@echo "Cleaning up containers and networks..."
	docker compose down
	@echo "Done! Your models and data are preserved."

# Clean everything including images and volumes (WARNING!)
clean-all:
	@echo "WARNING: This will remove all data including models!"
	@echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
	@sleep 5
	docker compose down -v --rmi all
	@echo "Everything cleaned!"
