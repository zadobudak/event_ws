#!/bin/bash

# Simple Wayland Docker GUI Runner
# For users running Wayland instead of X11

set -e

# Configuration
CONTAINER_NAME="wayland_dev_container"
IMAGE_NAME="ubuntu:22.04"  # Change this to your preferred base image
PROJECT_DIR="$(pwd)"

echo "🚀 Wayland Docker GUI Runner"
echo "📁 Project: $(basename "$PROJECT_DIR")"
echo "📍 Directory: $PROJECT_DIR"
echo

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if we're on Wayland
if [[ -z "$WAYLAND_DISPLAY" ]]; then
    echo "⚠️  WAYLAND_DISPLAY not set. This script is designed for Wayland users."
    echo "   If you're using X11, use the other script instead."
    exit 1
fi

echo "✅ Detected Wayland display: $WAYLAND_DISPLAY"

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

# Get user ID for socket sharing
USER_ID=$(id -u)
WAYLAND_SOCKET_DIR="/run/user/$USER_ID"

echo "🔍 Looking for Wayland socket in: $WAYLAND_SOCKET_DIR"

# Check if wayland socket directory exists
if [[ ! -d "$WAYLAND_SOCKET_DIR" ]]; then
    echo "❌ Wayland socket directory not found: $WAYLAND_SOCKET_DIR"
    echo "   This might mean Wayland is not properly configured."
    exit 1
fi

# Find wayland socket
WAYLAND_SOCKET=$(find "$WAYLAND_SOCKET_DIR" -name "wayland-*" 2>/dev/null | head -n 1)

if [[ -z "$WAYLAND_SOCKET" ]]; then
    echo "⚠️  Wayland socket not found. GUI forwarding may not work."
    echo "   Trying to continue anyway..."
else
    echo "✅ Found Wayland socket: $WAYLAND_SOCKET"
fi

echo
echo "🐳 Starting Docker container with Wayland GUI support..."
echo "   Container name: $CONTAINER_NAME"
echo "   Base image: $IMAGE_NAME"
echo "   Project mounted at: /workspace"
echo

# Run the container
docker run -it --rm \
    --name "$CONTAINER_NAME" \
    -v "$PROJECT_DIR:/workspace:rw" \
    -w /workspace \
    --privileged \
    --network host \
    -e WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
    -v "$WAYLAND_SOCKET_DIR:$WAYLAND_SOCKET_DIR:rw" \
    "$IMAGE_NAME" /bin/bash

echo
echo "✅ Container exited"
echo "💡 To install GUI tools inside the container, run:"
echo "   sudo apt update && sudo apt install -y firefox gedit gnome-terminal"
