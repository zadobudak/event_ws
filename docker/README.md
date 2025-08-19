# Docker Development Environment

This folder contains all Docker-related files for the ROS/Event Camera development environment.

## 📁 File Structure

```
docker/
├── README.md                    # This file
├── Dockerfile                   # Custom Docker image definition (placeholder)
├── .dockerignore               # Files to exclude from Docker builds
├── docker_gui_run.sh           # Universal GUI runner script
├── wayland_docker_gui.sh       # Wayland-specific GUI runner script
├── build_and_run.sh            # Future script for custom image builds
└── README_Docker_GUI.md        # Detailed GUI forwarding documentation
```

## 🚀 Quick Start

### For Immediate Use (with base Ubuntu image):
```bash
# From the project root directory
./docker/wayland_docker_gui.sh    # For Wayland users
# or
./docker/docker_gui_run.sh        # For universal support
```

### For Future Use (with custom image):
```bash
# Navigate to docker folder
cd docker

# Build and run custom image
./build_and_run.sh
```

## 🔧 Current Status

- ✅ **Ready to use**: GUI forwarding scripts with base Ubuntu image
- 🔄 **In development**: Custom Dockerfile (placeholder)
- 📋 **Future**: Custom image build and run system

## 🎯 What Each File Does

### **Immediate Use Scripts**
- `wayland_docker_gui.sh` - Optimized for Wayland users
- `docker_gui_run.sh` - Universal support for X11 and Wayland

### **Future Development**
- `Dockerfile` - Will define your custom development environment
- `build_and_run.sh` - Will build and run your custom image
- `.dockerignore` - Optimizes Docker builds by excluding unnecessary files

## 🐳 Current vs Future Workflow

### **Current (Base Image)**
```bash
./docker/wayland_docker_gui.sh
# Uses ubuntu:22.04 base image
# Installs packages on each run
# Good for testing and development
```

### **Future (Custom Image)**
```bash
cd docker
./build_and_run.sh
# Builds custom image with all dependencies
# Faster startup, consistent environment
# Better for production and team development
```

## 📋 Next Steps

1. **Customize Dockerfile** - Add ROS, event camera dependencies
2. **Test custom image** - Use `build_and_run.sh` when ready
3. **Optimize build** - Refine `.dockerignore` and multi-stage builds
4. **Add development tools** - IDE, debugging tools, etc.

## 🔍 Troubleshooting

- **GUI not working**: Check display protocol (X11 vs Wayland)
- **Permission issues**: Ensure Docker has proper access
- **Build failures**: Check Dockerfile syntax and dependencies

## 📚 More Information

- See `README_Docker_GUI.md` for detailed GUI forwarding setup
- Check main project README for overall project structure
- Docker documentation for advanced customization
