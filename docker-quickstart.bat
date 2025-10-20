@echo off
REM Quick Start Script for ComfyUI Docker on Windows
REM Run this from PowerShell or CMD in the ComfyUI directory

echo ====================================
echo ComfyUI Docker Quick Start (Windows)
echo ====================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not installed or not in PATH
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

echo ✓ Docker is installed
echo.

REM Check if Docker is running
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not running
    echo Please start Docker Desktop
    pause
    exit /b 1
)

echo ✓ Docker is running
echo.

REM Check for NVIDIA GPU (in WSL2, this needs to be checked differently)
nvidia-smi >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: nvidia-smi not found. GPU support may not be available.
    echo Make sure you have:
    echo   1. NVIDIA drivers installed on Windows
    echo   2. Docker Desktop configured for WSL2
    echo   3. NVIDIA Container Toolkit installed in WSL2
    echo.
) else (
    echo ✓ NVIDIA GPU detected
    nvidia-smi --query-gpu=name --format=csv,noheader
    echo.
)

echo Creating necessary directories...

REM Create directories
if not exist "models\checkpoints" mkdir models\checkpoints
if not exist "models\vae" mkdir models\vae
if not exist "models\loras" mkdir models\loras
if not exist "models\controlnet" mkdir models\controlnet
if not exist "models\clip_vision" mkdir models\clip_vision
if not exist "models\embeddings" mkdir models\embeddings
if not exist "models\upscale_models" mkdir models\upscale_models
if not exist "input" mkdir input
if not exist "output" mkdir output
if not exist "custom_nodes" mkdir custom_nodes

echo ✓ Directories created
echo.

REM Check if models exist
dir /b models\checkpoints\*.safetensors >nul 2>&1
if %errorlevel% neq 0 (
    dir /b models\checkpoints\*.ckpt >nul 2>&1
    if %errorlevel% neq 0 (
        echo WARNING: No models found in models\checkpoints\
        echo.
        echo You need to download at least one Stable Diffusion model.
        echo Example: Stable Diffusion 1.5
        echo Download from: https://huggingface.co/Comfy-Org/stable-diffusion-v1-5-archive
        echo.
        echo Place the downloaded model in: .\models\checkpoints\
        echo.
        pause
    )
)

echo Building Docker image (this may take several minutes)...
echo.
docker compose build

if %errorlevel% neq 0 (
    echo ERROR: Failed to build Docker image
    pause
    exit /b 1
)

echo.
echo ✓ Build complete!
echo.
echo Starting ComfyUI...
docker compose up -d

if %errorlevel% neq 0 (
    echo ERROR: Failed to start ComfyUI
    pause
    exit /b 1
)

echo.
echo ✓ ComfyUI is starting!
echo.
echo ====================================
echo Access ComfyUI at: http://localhost:8188
echo ====================================
echo.
echo View logs: docker compose logs -f
echo Stop ComfyUI: docker compose down
echo.
echo Waiting for ComfyUI to be ready...

REM Wait for service to be ready (simple approach for Windows)
timeout /t 10 /nobreak >nul

echo.
echo ✓ ComfyUI should be ready now!
echo Open your browser to: http://localhost:8188
echo.
echo For more information, see DOCKER_README.md
echo.
pause
