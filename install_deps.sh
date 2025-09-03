#!/usr/bin/env bash
set -e

echo "=============================================="
echo "   Installing dependencies                    "
echo "=============================================="
echo ""

OS="$(uname -s)"

install_linux_debian() {
    echo "Detected Linux (Debian/Ubuntu)"
    
    # Update package list
    sudo apt update
    
    # Install essential build dependencies
    sudo apt install -y \
        build-essential \
        cmake \
        pkg-config \
        libglfw3-dev \
        libgl1-mesa-dev \
        libglu1-mesa-dev

    echo "Dependencies installed successfully!"
}

check_dependencies() {
    echo ""
    echo "Checking installed dependencies..."
    
    local missing=()
    
    pkg-config --exists glfw3 || missing+=("GLFW")
    
    if [ ${#missing[@]} -eq 0 ]; then
        echo "✓ All dependencies verified!"
    else
        echo "⚠ Warning: The following may not be properly installed:"
        printf '%s\n' "${missing[@]}"
    fi
}

case "$OS" in
    Linux*)
        if [ -f /etc/debian_version ]; then
            install_linux_debian
            check_dependencies
        elif [ -f /etc/redhat-release ]; then
            echo "Red Hat/Fedora detected. Install dependencies with:"
            echo "  sudo dnf install glfw-devel mesa-libGL-devel mesa-libGLU-devel"
            exit 1
        elif [ -f /etc/arch-release ]; then
            echo "Arch Linux detected. Install dependencies with:"
            echo "  sudo pacman -S glfw mesa"
            exit 1
        else
            echo "Unsupported Linux distribution. Install deps manually."
            exit 1
        fi
        ;;
    Darwin*)
        echo "macOS detected. Install dependencies with Homebrew:"
        echo "  brew install glfw"
        exit 1
        ;;
    *)
        echo "Unsupported OS for this script. Use Windows PowerShell for Windows dependencies."
        exit 1
        ;;
esac

echo ""
echo "=============================================="
echo " All dependencies installed successfully!     "
echo "=============================================="
