#!/bin/bash

# Build and Run Script for Custom Docker Image
# This script will be used when you have a custom Dockerfile

set -e

# Configuration
IMAGE_NAME="event_camera_dev"
CONTAINER_NAME="event_camera_container"
PROJECT_DIR="$(dirname "$(dirname "$0")")"  # Go up one level from docker/ folder

echo "🔨 Docker Build and Run Script"
echo "📁 Project: $(basename "$PROJECT_DIR")"
echo "🐳 Image: $IMAGE_NAME"
echo "📦 Container: $CONTAINER_NAME"
echo

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if Dockerfile exists
if [[ ! -f "Dockerfile" ]]; then
    echo "❌ Dockerfile not found in current directory."
    echo "   Please run this script from the docker/ folder."
    exit 1
fi

# Build the image
echo "🔨 Building Docker image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" .

if [[ $? -eq 0 ]]; then
    echo "✅ Image built successfully!"
else
    echo "❌ Failed to build image"
    exit 1
fi

# Check for existing container
if docker ps --format "table {{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
    echo "⚠️  Container '$CONTAINER_NAME' is already running!"
    echo
    echo "Options:"
    echo "1. Stop and remove existing container"
    echo "2. Attach to existing container"
    echo "3. Use different container name"
    echo "4. Exit"
    echo
    read -p "Choose an option (1-4): " choice
    
    case $choice in
        1)
            echo "🔄 Stopping and removing existing container..."
            docker stop "$CONTAINER_NAME" 2>/dev/null || true
            docker rm "$CONTAINER_NAME" 2>/dev/null || true
            echo "✅ Container removed"
            ;;
        2)
            echo "🔗 Attaching to existing container..."
            docker exec -it "$CONTAINER_NAME" /bin/bash
            exit 0
            ;;
        3)
            read -p "Enter new container name: " CONTAINER_NAME
            echo "📝 Using container name: $CONTAINER_NAME"
            ;;
        4)
            echo "👋 Exiting..."
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Exiting..."
            exit 1
            ;;
    esac
fi

# Detect display type for GUI forwarding
if [[ -n "$WAYLAND_DISPLAY" ]]; then
    echo "✅ Detected Wayland display: $WAYLAND_DISPLAY"
    DISPLAY_ARGS="-e WAYLAND_DISPLAY=$WAYLAND_DISPLAY -v /run/user/$(id -u):/run/user/$(id -u):rw"
elif [[ -n "$DISPLAY" ]]; then
    echo "✅ Detected X11 display: $DISPLAY"
    DISPLAY_ARGS="-e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:rw"
    if [[ -f "$HOME/.Xauthority" ]]; then
        DISPLAY_ARGS="$DISPLAY_ARGS -v $HOME/.Xauthority:/root/.Xauthority:rw"
    fi
else
    echo "⚠️  No display detected. GUI forwarding will not be available."
    DISPLAY_ARGS=""
fi

echo
echo "🚀 Running container with custom image..."
echo "   Container name: $CONTAINER_NAME"
echo "   Project mounted at: /workspace"
echo "   Image: $IMAGE_NAME"
echo

# Run the container
docker run -it --rm \
    --name "$CONTAINER_NAME" \
    -v "$PROJECT_DIR:/workspace:rw" \
    -w /workspace \
    --privileged \
    --network host \
    $DISPLAY_ARGS \
    "$IMAGE_NAME"

echo
echo "✅ Container exited"
echo "💡 Your custom image '$IMAGE_NAME' is now available for future use"
