# ComfyUI Docker Implementation

This Docker implementation is based on the ComfyUI portable version, designed for easy deployment and portability, especially targeting Windows users with WSL2. The image comes with CUDA 12.8 support by default.

## Features

- 🐳 **Portable**: Ready-to-go image that can be used across different PCs
- 🎯 **Configurable Paths**: Define input, output, and model locations via environment variables or volume mounts
- 🚀 **CUDA 12.8**: Pre-configured with CUDA 12.8 for optimal GPU performance
- 🔧 **Flexible Configuration**: Everything else is stored in the container for simplicity
- 📦 **WSL2 Optimized**: Perfect for Windows users running Docker through WSL2

## Prerequisites

### Windows (WSL2)
1. Install [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)
2. Enable WSL2 integration in Docker Desktop settings
3. Install [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) for GPU support

### Linux
1. Install Docker: `curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh`
2. Install [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)

### macOS
1. Install [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/)
2. Note: GPU acceleration is not available on macOS, container will run in CPU mode

## Quick Start

### Option 1: Using Docker Compose (Recommended)

1. Clone the repository or copy the Docker files:
```bash
git clone https://github.com/yourusername/ComfyUI.git
cd ComfyUI
```

2. Create directories for your models, input, and output:
```bash
mkdir -p models/checkpoints models/vae models/loras input output
```

3. Place your models in the appropriate directories:
   - Checkpoints: `./models/checkpoints/`
   - VAE models: `./models/vae/`
   - LoRA models: `./models/loras/`
   - Input images: `./input/`

4. Start ComfyUI:
```bash
docker-compose up -d
```

5. Access ComfyUI at: http://localhost:8188

6. View logs:
```bash
docker-compose logs -f
```

7. Stop ComfyUI:
```bash
docker-compose down
```

### Option 2: Using Docker Run

Build the image:
```bash
docker build -t comfyui:latest .
```

Run the container:
```bash
docker run -d \
  --name comfyui \
  --gpus all \
  -p 8188:8188 \
  -v $(pwd)/models:/app/models \
  -v $(pwd)/input:/app/input \
  -v $(pwd)/output:/app/output \
  --shm-size=8g \
  comfyui:latest
```

## Configuration

### Environment Variables

Configure ComfyUI behavior using environment variables:

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `COMFYUI_MODELS_PATH` | Path to models directory | `/app/models` | `/data/models` |
| `COMFYUI_INPUT_PATH` | Path to input directory | `/app/input` | `/data/input` |
| `COMFYUI_OUTPUT_PATH` | Path to output directory | `/app/output` | `/data/output` |
| `COMFYUI_PORT` | Port to listen on | `8188` | `8080` |
| `COMFYUI_PREVIEW_METHOD` | Preview method | `none` | `auto`, `taesd` |
| `COMFYUI_VRAM_MODE` | VRAM usage mode | `normalvram` | `highvram`, `lowvram` |
| `COMFYUI_EXTRA_ARGS` | Additional CLI arguments | - | `--fast --fp16-vae` |

### Using External Model Paths (Windows WSL2)

If you want to use models stored on your Windows drive (e.g., `D:\AI\models`):

1. Copy the example configuration:
```bash
cp docker-compose.external-paths.example.yml docker-compose.override.yml
```

2. Edit `docker-compose.override.yml` and adjust the paths:
```yaml
services:
  comfyui:
    environment:
      - COMFYUI_MODELS_PATH=/data/models
      - COMFYUI_INPUT_PATH=/data/input
      - COMFYUI_OUTPUT_PATH=/data/output
    volumes:
      # For Windows drive D:, use /mnt/d/
      - /mnt/d/AI/models:/data/models
      - /mnt/d/AI/input:/data/input
      - /mnt/d/AI/output:/data/output
```

3. Start ComfyUI:
```bash
docker-compose up -d
```

### Volume Mounts

The default docker-compose.yml mounts the following directories:

- `./models` → `/app/models` - Model files
- `./input` → `/app/input` - Input images
- `./output` → `/app/output` - Generated images

You can customize these mounts in `docker-compose.yml` or create a `docker-compose.override.yml` file.

## Directory Structure

Your ComfyUI directory should look like this:

```
ComfyUI/
├── models/
│   ├── checkpoints/        # Stable Diffusion checkpoints
│   ├── vae/               # VAE models
│   ├── loras/             # LoRA models
│   ├── controlnet/        # ControlNet models
│   ├── clip_vision/       # CLIP vision models
│   ├── embeddings/        # Textual inversion embeddings
│   └── upscale_models/    # Upscaler models
├── input/                 # Input images
├── output/                # Generated images
└── custom_nodes/          # (Optional) Custom nodes
```

## Sharing Models Between UIs

If you want to share models between ComfyUI and other UIs (like Automatic1111):

1. Use the external paths configuration (see above)
2. Point both UIs to the same model directory
3. ComfyUI will automatically detect and use the models

Example structure for shared models:
```
D:\AI\
├── models\
│   ├── Stable-diffusion\   # Shared checkpoints
│   ├── VAE\
│   ├── Lora\
│   └── ControlNet\
├── comfyui-input\
└── comfyui-output\
```

Then configure ComfyUI to use these paths via environment variables or `extra_model_paths.yaml`.

## Advanced Usage

### Custom Model Paths Configuration

For advanced model path configuration, you can create an `extra_model_paths.yaml` file:

```yaml
comfyui:
    base_path: /data/models
    is_default: true
    checkpoints: checkpoints/
    vae: vae/
    loras: loras/
    controlnet: controlnet/
    clip_vision: clip_vision/
    embeddings: embeddings/
    upscale_models: upscale_models/

# You can also configure paths for other UIs
a111:
    base_path: /data/stable-diffusion-webui
    checkpoints: models/Stable-diffusion
    vae: models/VAE
    loras: models/Lora
```

Mount this file:
```yaml
volumes:
  - ./extra_model_paths.yaml:/app/extra_model_paths.yaml
```

### Performance Tuning

#### High VRAM Mode (GPUs with 12GB+ VRAM)
```yaml
environment:
  - COMFYUI_VRAM_MODE=highvram
```

#### Low VRAM Mode (GPUs with 6GB or less VRAM)
```yaml
environment:
  - COMFYUI_VRAM_MODE=lowvram
```

#### Enable Fast Mode
```yaml
environment:
  - COMFYUI_EXTRA_ARGS=--fast
```

#### FP16 VAE (might cause black images on some models)
```yaml
environment:
  - COMFYUI_EXTRA_ARGS=--fp16-vae
```

### Increase Shared Memory

For large models, you might need to increase shared memory:

```yaml
shm_size: '16gb'
```

## Troubleshooting

### Container doesn't start
1. Check Docker logs: `docker-compose logs -f`
2. Ensure NVIDIA drivers are installed
3. Verify NVIDIA Container Toolkit is installed: `docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu24.04 nvidia-smi`

### Black images or CUDA out of memory
1. Try lowvram mode: `COMFYUI_VRAM_MODE=lowvram`
2. Increase shared memory: `shm_size: '16gb'`
3. Close other GPU-intensive applications

### Models not found
1. Check volume mounts in docker-compose.yml
2. Ensure models are in the correct subdirectories
3. Check container can access the mounted directories: `docker exec -it comfyui ls -la /app/models/checkpoints`

### Performance issues on WSL2
1. Ensure models are on a fast drive (SSD)
2. For WSL2, prefer storing models on the Linux filesystem (`~/`) rather than Windows filesystem (`/mnt/c/`)
3. If using Windows paths, use `/mnt/d/` for better performance than `/mnt/c/`

### Permission issues
If you encounter permission issues with mounted volumes:

```bash
# On Linux/WSL2
sudo chown -R 1000:1000 models/ input/ output/

# Or run container as root (not recommended)
docker-compose run --user root comfyui
```

## Building the Image

To build the image yourself:

```bash
docker build -t comfyui:latest .
```

To build with a specific CUDA version:

```bash
docker build --build-arg CUDA_VERSION=12.8.0 -t comfyui:cuda12.8 .
```

## Updating ComfyUI

To update to the latest version:

```bash
# Pull the latest code
git pull

# Rebuild the image
docker-compose build --no-cache

# Restart the container
docker-compose up -d
```

## Network Access

By default, ComfyUI is accessible at:
- Local: http://localhost:8188
- Network (within Docker network): http://comfyui:8188

To access from other devices on your network, use your machine's IP address:
- http://YOUR_IP:8188

## Maintenance

### View logs
```bash
docker-compose logs -f
```

### Restart container
```bash
docker-compose restart
```

### Clean up
```bash
# Stop and remove container
docker-compose down

# Remove image
docker rmi comfyui:latest

# Clean up Docker system (use with caution)
docker system prune -a
```

## Support

For issues specific to this Docker implementation, please open an issue on the GitHub repository.

For ComfyUI-specific questions, refer to the main [ComfyUI documentation](https://github.com/comfyanonymous/ComfyUI).

## License

This Docker implementation follows the same license as ComfyUI core.
