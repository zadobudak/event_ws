# Docker GUI Runner Scripts

This repository contains scripts to run Docker containers with GUI forwarding support, allowing you to see GUI applications running inside Docker containers on your host system.

## Scripts Overview

### 1. `docker_gui_run.sh` - Universal GUI Runner
- **Purpose**: Comprehensive script that automatically detects and handles both X11 and Wayland
- **Features**: 
  - Auto-detects display type (X11 or Wayland)
  - Handles existing containers gracefully
  - Mounts current project directory as `/workspace`
  - Includes error handling and user-friendly prompts

### 2. `wayland_docker_gui.sh` - Wayland-Specific Runner
- **Purpose**: Simplified script specifically for Wayland users
- **Features**:
  - Optimized for Wayland display protocol
  - Cleaner, more focused implementation
  - Better error messages for Wayland-specific issues

## Prerequisites

- Docker installed and running
- Linux system with either X11 or Wayland
- Project directory you want to mount

## Usage

### For Wayland Users (Recommended)

```bash
# Make script executable (first time only)
chmod +x wayland_docker_gui.sh

# Run the script
./wayland_docker_gui.sh
```

### For X11 Users or Universal Support

```bash
# Make script executable (first time only)
chmod +x docker_gui_run.sh

# Run the script
./docker_gui_run.sh
```

## What These Scripts Do

1. **Detect Display Type**: Automatically identify if you're using X11 or Wayland
2. **Mount Project**: Mount your current project directory as `/workspace` in the container
3. **Setup GUI Forwarding**: Configure the necessary environment variables and socket sharing
4. **Run Container**: Start a Docker container with all the necessary configurations
5. **Handle Conflicts**: Manage existing containers gracefully

## Key Features

### Volume Mounting
- Your current project directory is mounted at `/workspace` inside the container
- Changes are synchronized between host and container
- Read-write access for development work

### GUI Forwarding
- **Wayland**: Shares the Wayland socket directory (`/run/user/<uid>`)
- **X11**: Shares X11 socket and authority files
- Applications can display on your host's screen

### Container Management
- Automatic detection of existing containers
- Options to stop, attach, or rename containers
- Clean container lifecycle management

## Customization

### Change Base Image
Edit the `IMAGE_NAME` variable in either script:
```bash
IMAGE_NAME="ubuntu:22.04"  # Change to your preferred image
```

### Change Container Name
Edit the `CONTAINER_NAME` variable:
```bash
CONTAINER_NAME="my_dev_container"  # Change to your preferred name
```

### Add Additional Mounts
You can modify the docker run command to add more volume mounts:
```bash
-v /path/on/host:/path/in/container:rw
```

## Troubleshooting

### Wayland Issues
- Ensure `WAYLAND_DISPLAY` environment variable is set
- Check if Wayland socket directory exists at `/run/user/<uid>`
- Verify Wayland is properly configured on your system

### X11 Issues
- Ensure `DISPLAY` environment variable is set
- Check if X11 socket directory exists at `/tmp/.X11-unix`
- Verify X11 forwarding is enabled

### Permission Issues
- Scripts use `--privileged` flag for better compatibility
- Ensure Docker has proper permissions to access display sockets
- Some systems may require additional configuration

## Installing GUI Applications

Once inside the container, you can install GUI applications:

```bash
# Update package list
sudo apt update

# Install common GUI tools
sudo apt install -y firefox gedit gnome-terminal

# Install development tools
sudo apt install -y build-essential cmake git vim
```

## Example Workflow

1. **Navigate to your project directory**:
   ```bash
   cd /path/to/your/project
   ```

2. **Run the appropriate script**:
   ```bash
   ./wayland_docker_gui.sh  # For Wayland users
   # or
   ./docker_gui_run.sh      # For universal support
   ```

3. **Inside the container, your project is available at `/workspace`**:
   ```bash
   ls /workspace  # See your project files
   cd /workspace  # Navigate to your project
   ```

4. **Run GUI applications**:
   ```bash
   firefox &      # Start Firefox
   gedit &        # Start text editor
   ```

## Security Notes

- Scripts use `--privileged` flag for better compatibility
- Network access is shared with host (`--network host`)
- Display sockets are shared between host and container
- Use these scripts in trusted development environments only

## Support

If you encounter issues:
1. Check the error messages for specific guidance
2. Verify your display protocol (X11 vs Wayland)
3. Ensure Docker has proper permissions
4. Check if required directories and sockets exist

## Contributing

Feel free to modify these scripts for your specific needs. Common modifications include:
- Adding support for additional display protocols
- Customizing the base image or container configuration
- Adding more volume mounts or environment variables
- Implementing additional error handling
