#!/bin/bash
set -e

# ComfyUI Docker Entrypoint Script
# This script allows users to configure ComfyUI paths via environment variables

echo "==================================="
echo "ComfyUI Docker Container Starting"
echo "==================================="

# Handle extra model paths configuration
if [ -n "$COMFYUI_MODELS_PATH" ] || [ -n "$COMFYUI_INPUT_PATH" ] || [ -n "$COMFYUI_OUTPUT_PATH" ]; then
    echo "Configuring custom paths..."
    
    # Create extra_model_paths.yaml if custom paths are specified
    if [ -n "$COMFYUI_MODELS_PATH" ]; then
        echo "Models path: $COMFYUI_MODELS_PATH"
        cat > /app/extra_model_paths.yaml << EOF
comfyui:
    base_path: $COMFYUI_MODELS_PATH
    is_default: true
    checkpoints: checkpoints/
    vae: vae/
    loras: loras/
    controlnet: controlnet/
    clip_vision: clip_vision/
    embeddings: embeddings/
    upscale_models: upscale_models/
    text_encoders: text_encoders/
    diffusion_models: diffusion_models/
EOF
    fi
fi

# Build command line arguments
CMD_ARGS=()

# Add listen address (default to all interfaces in container)
CMD_ARGS+=("--listen" "0.0.0.0")

# Add port
if [ -n "$COMFYUI_PORT" ]; then
    CMD_ARGS+=("--port" "$COMFYUI_PORT")
else
    CMD_ARGS+=("--port" "8188")
fi

# Add input directory if specified
if [ -n "$COMFYUI_INPUT_PATH" ]; then
    echo "Input path: $COMFYUI_INPUT_PATH"
    CMD_ARGS+=("--input-directory" "$COMFYUI_INPUT_PATH")
fi

# Add output directory if specified
if [ -n "$COMFYUI_OUTPUT_PATH" ]; then
    echo "Output path: $COMFYUI_OUTPUT_PATH"
    CMD_ARGS+=("--output-directory" "$COMFYUI_OUTPUT_PATH")
fi

# Add preview method if specified
if [ -n "$COMFYUI_PREVIEW_METHOD" ]; then
    echo "Preview method: $COMFYUI_PREVIEW_METHOD"
    CMD_ARGS+=("--preview-method" "$COMFYUI_PREVIEW_METHOD")
fi

# Add VRAM settings if specified
if [ -n "$COMFYUI_VRAM_MODE" ]; then
    echo "VRAM mode: $COMFYUI_VRAM_MODE"
    case "$COMFYUI_VRAM_MODE" in
        "highvram")
            CMD_ARGS+=("--highvram")
            ;;
        "normalvram")
            CMD_ARGS+=("--normalvram")
            ;;
        "lowvram")
            CMD_ARGS+=("--lowvram")
            ;;
        "novram")
            CMD_ARGS+=("--novram")
            ;;
        "cpu")
            CMD_ARGS+=("--cpu")
            ;;
    esac
fi

# Add any additional arguments from COMFYUI_EXTRA_ARGS
if [ -n "$COMFYUI_EXTRA_ARGS" ]; then
    echo "Extra arguments: $COMFYUI_EXTRA_ARGS"
    CMD_ARGS+=($COMFYUI_EXTRA_ARGS)
fi

# Print configuration summary
echo "==================================="
echo "Configuration Summary:"
echo "Listen: 0.0.0.0"
echo "Port: ${COMFYUI_PORT:-8188}"
echo "Models Path: ${COMFYUI_MODELS_PATH:-/app/models}"
echo "Input Path: ${COMFYUI_INPUT_PATH:-/app/input}"
echo "Output Path: ${COMFYUI_OUTPUT_PATH:-/app/output}"
echo "==================================="

# Execute the command passed to the container
if [ "$1" = "python" ] || [ "$1" = "python3" ]; then
    exec "$@" "${CMD_ARGS[@]}"
else
    exec "$@"
fi
