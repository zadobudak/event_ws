# Dockerfile for ROS/Event Camera Development Environment
# This is a placeholder - customize as needed for your project

# Base image - you can change this to your preferred ROS image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    python3-dev \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Install GUI dependencies (for X11/Wayland forwarding)
RUN apt-get update && apt-get install -y \
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
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Create a non-root user (optional, for security)
# RUN useradd -m -s /bin/bash developer
# USER developer

# Default command
CMD ["/bin/bash"]

# TODO: Add ROS installation when needed
# TODO: Add event camera dependencies when needed
# TODO: Add your specific project requirements
