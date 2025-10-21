# ComfyUI Docker - Offline Usage Guide

This guide explains the internet requirements for building and running ComfyUI Docker, and how to use it completely offline.

## TL;DR

- **First Build**: Requires internet to download dependencies
- **Runtime**: **100% offline**, no internet needed
- **Portability**: Save and load image on any machine without internet

## Internet Requirements Explained

### Initial Build Phase (Requires Internet)

When you first run `docker build` or `docker-compose build`, the following requires internet:

1. **Docker Base Image** (~2GB)
   - Downloads NVIDIA CUDA 12.8 runtime from Docker Hub
   - One-time download, cached locally

2. **System Packages** (~200MB)
   - Ubuntu packages (python, ffmpeg, etc.)
   - Downloaded from Ubuntu repositories
   - Cached in Docker layers

3. **Python Dependencies** (~3-4GB)
   - PyTorch with CUDA 12.8 support
   - ComfyUI requirements (transformers, numpy, etc.)
   - Downloaded from PyPI and PyTorch repository
   - Bundled into the image permanently

**Total Download**: ~5-6GB on first build

**After Build**: All dependencies are **permanently bundled** in the image. No internet needed for any future operations.

### Runtime Phase (No Internet Required)

Once the image is built:

✅ **Completely offline operation**
- Container starts instantly without any downloads
- All Python packages already installed
- ComfyUI core works offline (as designed)
- No hidden dependencies on external services

✅ **Offline features verified:**
- Model loading (local files only)
- Image generation
- Workflow execution
- API server
- Web UI

⚠️ **Optional features that may need internet:**
- API nodes (if explicitly enabled and used)
- Custom nodes that download models (if you add them)
- Frontend updates (if you use `--front-end-version` with latest)

**Our Docker image disables automatic downloads** by setting:
```bash
HF_HUB_OFFLINE=1
TRANSFORMERS_OFFLINE=1
HF_DATASETS_OFFLINE=1
```

## Portable Usage

### Scenario 1: Build Once, Use Anywhere

```bash
# Machine A (with internet) - Build the image
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
docker-compose build

# Test it works
docker-compose up -d

# Save the image to a file
docker save comfyui:latest | gzip > comfyui-docker.tar.gz

# Copy comfyui-docker.tar.gz to Machine B (USB drive, network, etc.)
```

```bash
# Machine B (NO internet required)
# Load the image
gunzip -c comfyui-docker.tar.gz | docker load

# Copy docker-compose.yml and related files
# Run immediately
docker-compose up -d
```

### Scenario 2: Transfer Between PCs

Perfect for:
- Moving between home and office
- Sharing with team members
- Deploying to air-gapped systems
- Backup and disaster recovery

```bash
# Export everything needed
mkdir comfyui-portable
cd comfyui-portable

# 1. Save the Docker image
docker save comfyui:latest | gzip > comfyui-image.tar.gz

# 2. Copy configuration files
cp /path/to/ComfyUI/docker-compose.yml .
cp /path/to/ComfyUI/.env.example .

# 3. Optionally copy models (or mount from separate location)
# cp -r /path/to/models ./models

# Transfer entire comfyui-portable folder to new PC
```

```bash
# On new PC (offline)
cd comfyui-portable

# Load image
gunzip -c comfyui-image.tar.gz | docker load

# Start
docker-compose up -d
```

## Building on Offline Machines

### Option 1: Use Pre-Built Image (Recommended)

Build on a machine with internet, save, and transfer (see above).

### Option 2: Docker Build Cache (Advanced)

If you need to rebuild on offline machines:

```bash
# On online machine - build with exportable cache
docker buildx create --use
docker buildx build --cache-to type=local,dest=/tmp/buildcache .

# Transfer /tmp/buildcache directory to offline machine

# On offline machine - build using cache
docker buildx create --use
docker buildx build --cache-from type=local,src=/tmp/buildcache .
```

### Option 3: Pre-download Dependencies

For air-gapped environments, you can pre-download all requirements:

```bash
# On online machine
pip download -r requirements.txt -d ./pip-packages
pip download torch torchvision torchaudio \
  --index-url https://download.pytorch.org/whl/cu128 \
  -d ./pip-packages

# Modify Dockerfile to use local packages:
# COPY pip-packages /tmp/pip-packages
# RUN pip install --no-index --find-links /tmp/pip-packages -r requirements.txt
```

## Verification

### Verify Offline Runtime

Test that your container works without internet:

```bash
# Start container
docker-compose up -d

# Disable network (Linux)
docker network disconnect bridge comfyui

# Try using ComfyUI - should work normally
# Access http://localhost:8188

# Re-enable network if needed
docker network connect bridge comfyui
```

### Verify No Downloads Occur

Check container logs for any download attempts:

```bash
docker-compose logs | grep -i "download\|fetch\|http"
# Should see no unexpected downloads
```

### Test Image Portability

```bash
# Save and reload on same machine to verify
docker save comfyui:latest | gzip > test.tar.gz
docker rmi comfyui:latest
gunzip -c test.tar.gz | docker load
docker-compose up -d
# Should work identically
```

## Size Considerations

**Docker Image Size**: ~8-12GB (compressed ~5-6GB)
- CUDA runtime: ~2GB
- Python + packages: ~3-4GB
- ComfyUI code: ~100MB
- System libraries: ~500MB

**Transfer Time Estimates**:
- USB 3.0: ~2-3 minutes
- Gigabit Network: ~5-8 minutes
- 100Mbps Network: ~40-50 minutes

**Storage Requirements**:
- Docker image: ~12GB
- Models (separate): 2-20GB depending on your collection
- Generated images: varies
- Total recommended: 50GB+ free space

## FAQ

**Q: Do I need internet every time I start the container?**
A: No! Only for the initial build. After that, 100% offline.

**Q: What if I want to update ComfyUI?**
A: Requires internet to pull latest code and rebuild. Or get updated image from someone who did.

**Q: Can I use this in an air-gapped environment?**
A: Yes! Build elsewhere, transfer the image file, load and run offline.

**Q: Will custom nodes work offline?**
A: Depends on the node. Our base image works offline. Custom nodes that download models may need internet.

**Q: What about downloading models from HuggingFace?**
A: ComfyUI expects you to provide models locally. Our Docker follows this pattern.

**Q: Why does the build need internet?**
A: Docker images must download base layers and dependencies. This is standard Docker behavior. Once built, everything is bundled.

**Q: Can I build completely offline?**
A: Not directly. You need internet for the first build. You can transfer the built image to offline machines.

**Q: Does the web UI need internet?**
A: No, it's served from the container. Access via http://localhost:8188

## Best Practices

1. **Build Once**: Create the image on a fast internet connection
2. **Save Image**: Archive the image for future use
3. **Test Offline**: Verify everything works without network before deploying
4. **Document Versions**: Tag images with versions for tracking
5. **Separate Data**: Keep models/images separate from container
6. **Regular Backups**: Save updated images when you update ComfyUI

## Troubleshooting

**Build fails with "couldn't connect"**
- You need internet for the initial build
- Check your internet connection
- Check Docker can access the internet
- Try: `docker run --rm curlimages/curl:latest curl -I https://google.com`

**Container tries to download something at runtime**
- This should NOT happen with our configuration
- Check logs: `docker-compose logs`
- Report as an issue if you see unexpected downloads

**Image is too large to transfer**
- Compress it: `docker save comfyui:latest | gzip -9 > image.tar.gz`
- Use efficient transfer: `rsync`, `scp`, or split into chunks
- Consider removing unnecessary layers if you customized the Dockerfile

## Summary

✅ **One-time build requires internet** - unavoidable with Docker
✅ **Runtime is 100% offline** - works without any network
✅ **Fully portable** - save, transfer, load anywhere
✅ **Self-contained** - all dependencies bundled
✅ **Production ready** - suitable for air-gapped deployments

The Docker build process requires internet, but this is a one-time cost. After building, you have a completely portable, offline-capable image that maintains ComfyUI's core principle of working without internet dependencies.
