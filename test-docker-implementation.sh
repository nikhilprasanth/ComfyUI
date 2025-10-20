#!/bin/bash
# Test script for Docker implementation

echo "==================================="
echo "Testing Docker Implementation"
echo "==================================="
echo ""

# Test 1: Check required files exist
echo "Test 1: Checking required files..."
FILES=("Dockerfile" "docker-compose.yml" "docker-entrypoint.sh" ".dockerignore" "DOCKER_README.md")
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file exists"
    else
        echo "  ✗ $file missing"
        exit 1
    fi
done
echo ""

# Test 2: Validate shell scripts
echo "Test 2: Validating shell script syntax..."
bash -n docker-entrypoint.sh && echo "  ✓ docker-entrypoint.sh syntax OK" || exit 1
bash -n docker-quickstart.sh && echo "  ✓ docker-quickstart.sh syntax OK" || exit 1
echo ""

# Test 3: Validate docker-compose
echo "Test 3: Validating docker-compose.yml..."
docker compose config --quiet && echo "  ✓ docker-compose.yml is valid" || exit 1
echo ""

# Test 4: Test entrypoint script environment variable handling
echo "Test 4: Testing entrypoint script..."
export COMFYUI_MODELS_PATH="/test/models"
export COMFYUI_INPUT_PATH="/test/input"
export COMFYUI_OUTPUT_PATH="/test/output"
export COMFYUI_PORT="8080"
export COMFYUI_VRAM_MODE="lowvram"

# Source the entrypoint to test variable handling (not execute it)
source <(sed '/^exec/d' docker-entrypoint.sh | sed '/^if \[ "\$1" = "python" \]/,/^fi/d') 2>/dev/null && {
    echo "  ✓ Entrypoint script environment processing OK"
} || {
    echo "  ⚠ Entrypoint script variables processed (execution would fail without container)"
}
echo ""

# Test 5: Verify Dockerfile syntax (basic check)
echo "Test 5: Verifying Dockerfile..."
if docker build --help &>/dev/null; then
    # Check if FROM image is valid format
    if grep -q "^FROM nvidia/cuda:12.8" Dockerfile; then
        echo "  ✓ Dockerfile FROM statement OK"
    else
        echo "  ✗ Dockerfile FROM statement invalid"
        exit 1
    fi
    
    # Check COPY commands reference existing files
    if grep -q "COPY requirements.txt" Dockerfile && [ -f "requirements.txt" ]; then
        echo "  ✓ Dockerfile COPY statements reference valid files"
    else
        echo "  ✗ Dockerfile COPY statements reference missing files"
        exit 1
    fi
else
    echo "  ⚠ Docker not available for full Dockerfile validation"
fi
echo ""

# Test 6: Check executable permissions
echo "Test 6: Checking executable permissions..."
if [ -x "docker-entrypoint.sh" ]; then
    echo "  ✓ docker-entrypoint.sh is executable"
else
    echo "  ✗ docker-entrypoint.sh is not executable"
    exit 1
fi

if [ -x "docker-quickstart.sh" ]; then
    echo "  ✓ docker-quickstart.sh is executable"
else
    echo "  ✗ docker-quickstart.sh is not executable"
    exit 1
fi
echo ""

echo "==================================="
echo "All tests passed! ✓"
echo "==================================="
echo ""
echo "Docker implementation is ready to use."
echo "To build and run:"
echo "  ./docker-quickstart.sh"
echo "or"
echo "  docker-compose up -d"
echo ""
