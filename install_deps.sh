#!/usr/bin/env bash
set -e

echo "=============================================="
echo "   Installing dependencies for Bloodvalley    "
echo "   (GLFW, ZeroMQ, SQLite3, GTest)             "
echo "=============================================="
echo ""

OS="$(uname -s)"

install_linux_debian() {
    echo "Detected Linux (Debian/Ubuntu)"
    
    # Update package list
    sudo apt update
    
    # Install dependencies including OpenGL headers that GLFW might need
    sudo apt install -y \
        build-essential \
        cmake \
        pkg-config \
        libglfw3-dev \
        libzmq3-dev \
        libsqlite3-dev \
        libgtest-dev \
        libgl1-mesa-dev \
        libglu1-mesa-dev
    
    # Build GoogleTest from source safely
    echo "Building GoogleTest from source..."
    
    # Find the GoogleTest source directory
    GTEST_SRC=""
    if [ -d "/usr/src/googletest/googletest" ]; then
        GTEST_SRC="/usr/src/googletest/googletest"
    elif [ -d "/usr/src/gtest" ]; then
        GTEST_SRC="/usr/src/gtest"
    else
        echo "Warning: GoogleTest source not found. You may need to build it manually."
        echo "Try: sudo apt install googletest"
        return 0
    fi
    
    TMP_GTEST=$(mktemp -d)
    trap "rm -rf $TMP_GTEST" EXIT  # Ensure cleanup on exit
    
    pushd "$TMP_GTEST" > /dev/null
    cmake "$GTEST_SRC"
    make -j$(nproc)
    
    # Find and copy the built libraries
    if find . -name "*.a" -type f | grep -q .; then
        sudo find . -name "*.a" -type f -exec cp {} /usr/lib \;
        echo "GoogleTest installed successfully!"
    else
        echo "Warning: No GoogleTest libraries found after build"
    fi
    
    popd > /dev/null
}

check_dependencies() {
    echo ""
    echo "Checking installed dependencies..."
    
    local missing=()
    
    # Check for pkg-config files
    pkg-config --exists glfw3 || missing+=("GLFW")
    pkg-config --exists libzmq || missing+=("ZeroMQ")
    pkg-config --exists sqlite3 || missing+=("SQLite3")
    
    # Check for GTest
    if ! [ -f /usr/lib/libgtest.a ] && ! [ -f /usr/lib/x86_64-linux-gnu/libgtest.a ]; then
        missing+=("GoogleTest")
    fi
    
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
            echo "  sudo dnf install glfw-devel zeromq-devel sqlite-devel gtest-devel"
            exit 1
        elif [ -f /etc/arch-release ]; then
            echo "Arch Linux detected. Install dependencies with:"
            echo "  sudo pacman -S glfw zeromq sqlite gtest"
            exit 1
        else
            echo "Unsupported Linux distribution. Install deps manually."
            exit 1
        fi
        ;;
    Darwin*)
        echo "macOS detected. Install dependencies with Homebrew:"
        echo "  brew install glfw zeromq sqlite googletest"
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
