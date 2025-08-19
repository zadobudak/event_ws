#!/bin/bash

# Docker GUI Runner Script
# Supports both X11 and Wayland display forwarding
# Mounts current project directory as volume

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONTAINER_NAME="dev_gui_container"
IMAGE_NAME="ubuntu:22.04"  # Change this to your preferred base image
PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect display type
detect_display() {
    if [[ -n "$WAYLAND_DISPLAY" ]]; then
        echo "wayland"
    elif [[ -n "$DISPLAY" ]]; then
        echo "x11"
    else
        echo "none"
    fi
}

# Function to setup X11 forwarding
setup_x11() {
    print_status "Setting up X11 forwarding..."
    
    if [[ ! -d "/tmp/.X11-unix" ]]; then
        print_error "X11 socket directory not found. X11 forwarding may not work."
        return 1
    fi
    
    # Allow X11 connections from localhost
    xhost +local:docker 2>/dev/null || {
        print_warning "Could not run xhost. X11 forwarding may not work."
        return 1
    }
    
    X11_ARGS="-e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:rw"
    
    # Check for Xauthority file
    if [[ -f "$HOME/.Xauthority" ]]; then
        X11_ARGS="$X11_ARGS -v $HOME/.Xauthority:/root/.Xauthority:rw"
        print_success "Xauthority file found and will be mounted"
    else
        print_warning "No .Xauthority file found. X11 forwarding may not work properly."
    fi
    
    echo "$X11_ARGS"
}

# Function to setup Wayland forwarding
setup_wayland() {
    print_status "Setting up Wayland forwarding..."
    
    if [[ -z "$WAYLAND_DISPLAY" ]]; then
        print_error "WAYLAND_DISPLAY not set. Wayland forwarding may not work."
        return 1
    fi
    
    # For Wayland, we need to share the wayland socket
    WAYLAND_SOCKET_DIR="/run/user/$(id -u)"
    
    if [[ ! -d "$WAYLAND_SOCKET_DIR" ]]; then
        print_error "Wayland socket directory not found: $WAYLAND_SOCKET_DIR"
        return 1
    fi
    
    # Find wayland socket
    WAYLAND_SOCKET=$(find "$WAYLAND_SOCKET_DIR" -name "wayland-*" 2>/dev/null | head -n 1)
    
    if [[ -z "$WAYLAND_SOCKET" ]]; then
        print_warning "Wayland socket not found. Wayland forwarding may not work."
        return 1
    fi
    
    WAYLAND_ARGS="-e WAYLAND_DISPLAY=$WAYLAND_DISPLAY -v $WAYLAND_SOCKET_DIR:$WAYLAND_SOCKET_DIR:rw"
    print_success "Wayland socket found: $WAYLAND_SOCKET"
    
    echo "$WAYLAND_ARGS"
}

# Function to check if container is already running
check_container() {
    if docker ps --format "table {{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
        print_warning "Container '$CONTAINER_NAME' is already running!"
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
                print_status "Stopping and removing existing container..."
                docker stop "$CONTAINER_NAME" 2>/dev/null || true
                docker rm "$CONTAINER_NAME" 2>/dev/null || true
                print_success "Container removed"
                ;;
            2)
                print_status "Attaching to existing container..."
                docker exec -it "$CONTAINER_NAME" /bin/bash
                exit 0
                ;;
            3)
                read -p "Enter new container name: " CONTAINER_NAME
                print_status "Using container name: $CONTAINER_NAME"
                ;;
            4)
                print_status "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option. Exiting..."
                exit 1
                ;;
        esac
    fi
}

# Function to install GUI dependencies in container
install_gui_deps() {
    print_status "Installing GUI dependencies in container..."
    
    # Update package list
    docker exec "$CONTAINER_NAME" apt-get update
    
    # Install basic GUI tools and development packages
    docker exec "$CONTAINER_NAME" apt-get install -y \
        x11-apps \
        x11-utils \
        x11-xserver-utils \
        mesa-utils \
        libgl1-mesa-glx \
        libgl1-mesa-dri \
        xvfb \
        dbus-x11 \
        gnome-terminal \
        firefox \
        gedit \
        vim \
        build-essential \
        cmake \
        git \
        curl \
        wget \
        python3 \
        python3-pip
    
    print_success "GUI dependencies installed"
}

# Function to setup display environment in container
setup_container_display() {
    local display_type=$1
    
    print_status "Setting up display environment in container..."
    
    if [[ "$display_type" == "x11" ]]; then
        # For X11, set DISPLAY and install x11-apps
        docker exec "$CONTAINER_NAME" bash -c "
            echo 'export DISPLAY=:0' >> ~/.bashrc
            echo 'export DISPLAY=:0' >> ~/.profile
        "
    elif [[ "$display_type" == "wayland" ]]; then
        # For Wayland, set WAYLAND_DISPLAY
        docker exec "$CONTAINER_NAME" bash -c "
            echo 'export WAYLAND_DISPLAY=$WAYLAND_DISPLAY' >> ~/.bashrc
            echo 'export WAYLAND_DISPLAY=$WAYLAND_DISPLAY' >> ~/.profile
        "
    fi
    
    print_success "Display environment configured in container"
}

# Main execution
main() {
    print_status "Docker GUI Runner Script"
    print_status "Project: $PROJECT_NAME"
    print_status "Project Directory: $PROJECT_DIR"
    echo
    
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    # Check if project directory exists
    if [[ ! -d "$PROJECT_DIR" ]]; then
        print_error "Project directory does not exist: $PROJECT_DIR"
        exit 1
    fi
    
    # Check for existing container
    check_container
    
    # Detect display type
    DISPLAY_TYPE=$(detect_display)
    print_status "Detected display type: $DISPLAY_TYPE"
    
    # Setup display forwarding based on type
    if [[ "$DISPLAY_TYPE" == "x11" ]]; then
        DISPLAY_ARGS=$(setup_x11)
    elif [[ "$DISPLAY_TYPE" == "wayland" ]]; then
        DISPLAY_ARGS=$(setup_wayland)
    else
        print_warning "No display detected. GUI forwarding will not be available."
        DISPLAY_ARGS=""
    fi
    
    # Build docker run command
    DOCKER_CMD="docker run -it --rm"
    DOCKER_CMD="$DOCKER_CMD --name $CONTAINER_NAME"
    DOCKER_CMD="$DOCKER_CMD -v $PROJECT_DIR:/workspace:rw"
    DOCKER_CMD="$DOCKER_CMD -w /workspace"
    DOCKER_CMD="$DOCKER_CMD --privileged"
    DOCKER_CMD="$DOCKER_CMD --network host"
    
    if [[ -n "$DISPLAY_ARGS" ]]; then
        DOCKER_CMD="$DOCKER_CMD $DISPLAY_ARGS"
    fi
    
    DOCKER_CMD="$DOCKER_CMD $IMAGE_NAME /bin/bash"
    
    print_status "Running Docker container with GUI support..."
    print_status "Command: $DOCKER_CMD"
    echo
    
    # Run the container
    eval "$DOCKER_CMD" || {
        print_error "Failed to run Docker container"
        exit 1
    }
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  --help, -h    Show this help message"
        echo "  --install     Install GUI dependencies after container starts"
        echo
        echo "This script runs a Docker container with:"
        echo "- GUI forwarding support (X11 or Wayland)"
        echo "- Current project directory mounted as /workspace"
        echo "- Network access and privileged mode"
        echo
        echo "Environment:"
        echo "- Container name: $CONTAINER_NAME"
        echo "- Base image: $IMAGE_NAME"
        echo "- Project directory: $PROJECT_DIR"
        exit 0
        ;;
    --install)
        INSTALL_DEPS=true
        ;;
esac

# Run main function
main "$@"
