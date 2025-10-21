# ComfyUI Docker Setup Guide for Windows WSL2

This guide will walk you through setting up ComfyUI Docker on Windows with WSL2 and GPU support.

## Prerequisites Installation

### 1. Install WSL2

Open PowerShell as Administrator and run:

```powershell
wsl --install
```

This will install Ubuntu by default. Restart your computer when prompted.

After restart, open Ubuntu from the Start menu and create a username and password.

### 2. Install Docker Desktop

1. Download [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)
2. Install Docker Desktop
3. Start Docker Desktop
4. Go to Settings → General
5. Enable "Use the WSL 2 based engine"
6. Go to Settings → Resources → WSL Integration
7. Enable integration with your Ubuntu distribution
8. Click "Apply & Restart"

### 3. Install NVIDIA Drivers (Windows)

1. Download the latest [NVIDIA drivers for Windows](https://www.nvidia.com/download/index.aspx)
2. Install the drivers
3. Restart your computer

**Note**: You do NOT need to install NVIDIA drivers inside WSL2. Windows drivers are automatically accessible.

### 4. Install NVIDIA Container Toolkit (WSL2)

Open Ubuntu (WSL2) terminal and run:

```bash
# Configure the production repository
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Update package list
sudo apt-get update

# Install the NVIDIA Container Toolkit
sudo apt-get install -y nvidia-container-toolkit

# Configure Docker to use NVIDIA runtime
sudo nvidia-ctk runtime configure --runtime=docker
```

### 5. Verify GPU Access

In WSL2 terminal, test GPU access:

```bash
# Check NVIDIA driver
nvidia-smi

# Test Docker GPU access
docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu24.04 nvidia-smi
```

If both commands show your GPU information, you're ready!

## Installing ComfyUI Docker

### Option 1: Fresh Install in WSL2 Linux Filesystem (Recommended)

For best performance, install in the Linux filesystem:

```bash
# Navigate to your home directory
cd ~

# Clone the repository
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI

# Run the quick start script
./docker-quickstart.sh
```

### Option 2: Install on Windows Drive (Accessible from Windows Explorer)

If you want to easily access files from Windows Explorer:

```bash
# Navigate to your Windows D: drive (adjust as needed)
cd /mnt/d

# Create a directory for ComfyUI
mkdir -p AI/ComfyUI
cd AI/ComfyUI

# Clone the repository
git clone https://github.com/comfyanonymous/ComfyUI.git .

# Run the quick start script
./docker-quickstart.sh
```

**Note**: Accessing Windows filesystem (`/mnt/c/`, `/mnt/d/`, etc.) is slower than native Linux filesystem. For best performance, use Option 1.

## Setting Up Model Paths

### Scenario 1: Models on Windows Drive (e.g., D:\AI\models)

If you have models stored on your Windows drive and want to use them:

```bash
cd ~/ComfyUI  # or wherever you installed

# Copy the external paths example
cp docker-compose.external-paths.example.yml docker-compose.override.yml

# Edit the file (use nano, vim, or code from WSL)
nano docker-compose.override.yml
```

Edit the paths to match your Windows drive:

```yaml
services:
  comfyui:
    environment:
      - COMFYUI_MODELS_PATH=/data/models
      - COMFYUI_INPUT_PATH=/data/input
      - COMFYUI_OUTPUT_PATH=/data/output
    volumes:
      # D: drive is /mnt/d in WSL2
      - /mnt/d/AI/models:/data/models
      - /mnt/d/AI/input:/data/input
      - /mnt/d/AI/output:/data/output
```

Your Windows model directory should have this structure:
```
D:\AI\models\
├── checkpoints\        # Your SD model files (.safetensors, .ckpt)
├── vae\               # VAE files
├── loras\             # LoRA files
├── controlnet\        # ControlNet models
└── ... other model types
```

### Scenario 2: Share Models with Automatic1111

If you have Automatic1111 installed and want to share models:

```yaml
services:
  comfyui:
    environment:
      - COMFYUI_MODELS_PATH=/data/stable-diffusion-webui/models
    volumes:
      # Point to your A1111 installation
      - /mnt/d/stable-diffusion-webui/models:/data/stable-diffusion-webui/models
```

ComfyUI will map A1111's model locations automatically.

## Starting ComfyUI

### Using the Quick Start Script

```bash
./docker-quickstart.sh
```

### Using Docker Compose

```bash
# Build the image
docker compose build

# Start ComfyUI
docker compose up -d

# View logs
docker compose logs -f

# Stop ComfyUI
docker compose down
```

### Using Makefile

```bash
# Show help
make help

# Build and start
make build
make up

# View logs
make logs

# Stop
make down
```

## Accessing ComfyUI

Once started, open your web browser (on Windows) and navigate to:

```
http://localhost:8188
```

You can also access it from other devices on your network using your PC's IP address:

```
http://YOUR_PC_IP:8188
```

## Managing Files

### From Windows

If you installed on a Windows drive (Option 2), you can access files directly from Windows Explorer:

- Models: `D:\AI\models\` (or wherever you specified)
- Input: `D:\AI\input\`
- Output: `D:\AI\output\`

### From WSL2

Access your ComfyUI directory:

```bash
cd ~/ComfyUI  # or your installation path

# View output images
ls -lh output/

# Copy files from Windows to input
cp /mnt/d/Pictures/myimage.png input/
```

## Performance Tips

### 1. Use Linux Filesystem for Best Performance

Installing ComfyUI in WSL2's native Linux filesystem (`~/`) is faster than Windows drives (`/mnt/c/`, `/mnt/d/`).

### 2. Store Models on Fast Drive

Use SSD for models. If possible, avoid external USB drives.

### 3. Adjust VRAM Settings

In `.env` file or docker-compose.yml:

```bash
# For GPUs with 8GB+ VRAM
COMFYUI_VRAM_MODE=highvram

# For GPUs with 6GB or less
COMFYUI_VRAM_MODE=lowvram
```

### 4. Use Fast Mode

```bash
COMFYUI_EXTRA_ARGS=--fast
```

## Troubleshooting

### GPU Not Detected

```bash
# Verify NVIDIA driver in WSL2
nvidia-smi

# Check Docker GPU access
docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu24.04 nvidia-smi

# Restart Docker Desktop
```

### Permission Issues

```bash
# Fix permissions on mounted directories
sudo chown -R 1000:1000 models/ input/ output/
```

### Slow Performance from Windows Drive

If accessing models from `/mnt/d/` is slow:

1. Copy frequently-used models to Linux filesystem
2. Use `.env` to point to local Linux paths
3. Consider using Windows native Docker (without WSL2) if you must use Windows paths

### Container Won't Start

```bash
# View detailed logs
docker compose logs

# Check container status
docker ps -a

# Remove and recreate
docker compose down
docker compose up -d
```

### Out of Memory Errors

```bash
# Increase shared memory in docker-compose.yml
shm_size: '16gb'

# Or use lowvram mode
COMFYUI_VRAM_MODE=lowvram
```

## Updating ComfyUI

```bash
# Navigate to ComfyUI directory
cd ~/ComfyUI

# Pull latest changes
git pull

# Rebuild Docker image
docker compose build --no-cache

# Restart
docker compose down
docker compose up -d
```

## Uninstalling

```bash
# Stop and remove containers
docker compose down

# Remove images
docker rmi comfyui:latest

# Remove the directory
cd ~
rm -rf ComfyUI

# (Optional) Remove all Docker data
docker system prune -a
```

## Advanced Configuration

### Using Environment File

Create a `.env` file for easy configuration:

```bash
cp .env.example .env
nano .env
```

Edit values:

```bash
COMFYUI_PORT=8188
COMFYUI_MODELS_PATH=/mnt/d/AI/models
COMFYUI_INPUT_PATH=/mnt/d/AI/input
COMFYUI_OUTPUT_PATH=/mnt/d/AI/output
COMFYUI_VRAM_MODE=highvram
COMFYUI_PREVIEW_METHOD=auto
```

### Running Multiple Instances

To run multiple ComfyUI instances:

```bash
# First instance (default)
docker compose up -d

# Second instance on different port
COMFYUI_PORT=8189 docker compose -p comfyui2 up -d
```

### Backup Your Configuration

Important files to backup:

```bash
# Configuration files
.env
docker-compose.override.yml
extra_model_paths.yaml

# User data
user/
custom_nodes/
```

## Getting Help

- ComfyUI Documentation: [DOCKER_README.md](DOCKER_README.md)
- ComfyUI GitHub: https://github.com/comfyanonymous/ComfyUI
- ComfyUI Discord: https://www.comfy.org/discord
- Docker Desktop Documentation: https://docs.docker.com/desktop/
- WSL2 Documentation: https://docs.microsoft.com/en-us/windows/wsl/

## Support

If you encounter issues specific to this Docker implementation, please check:

1. Docker logs: `docker compose logs -f`
2. Test script: `./test-docker-implementation.sh`
3. This guide's troubleshooting section
4. Open an issue on GitHub with logs and system information
