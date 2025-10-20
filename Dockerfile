# ComfyUI Docker Image with CUDA 12.8
# Based on portable version for easy deployment on Windows WSL2
FROM nvidia/cuda:12.8.0-runtime-ubuntu24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/opt/venv/bin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.12 \
    python3.12-venv \
    python3-pip \
    git \
    wget \
    curl \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python3.12 -m venv /opt/venv

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install PyTorch with CUDA 12.8 support and other dependencies
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128 && \
    pip install --no-cache-dir -r requirements.txt

# Copy ComfyUI application
COPY . .

# Create directories for models, input, output if they don't exist
RUN mkdir -p /app/models/checkpoints \
    /app/models/vae \
    /app/models/loras \
    /app/models/controlnet \
    /app/models/clip_vision \
    /app/models/embeddings \
    /app/models/upscale_models \
    /app/input \
    /app/output \
    /app/custom_nodes

# Create a non-root user for better security
RUN useradd -m -u 1000 comfyui && \
    chown -R comfyui:comfyui /app

USER comfyui

# Expose the default ComfyUI port
EXPOSE 8188

# Set entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
USER root
RUN chmod +x /docker-entrypoint.sh
USER comfyui

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
