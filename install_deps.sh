#!/usr/bin/env bash

set -e

echo "=============================================="
echo "   Installing dependencies for Bloodvalley    "
echo "   (GLFW, ZeroMQ, SQLite3, GTest)             "
echo "=============================================="
echo ""

# Detect OS
OS="$(uname -s)"

install_linux_debian() {
    echo "Detected Linux (Debian/Ubuntu)"
    sudo apt update
    sudo apt install -y build-essential cmake pkg-config \
        libglfw3-dev libzmq3-dev libsqlite3-dev libgtest-dev

    # Build and install GoogleTest manually (Ubuntu ships only headers)
    echo "Building GoogleTest from source..."
    cd /usr/src/gtest
    sudo cmake .
    sudo make -j$(nproc)
    sudo cp lib/*.a /usr/lib
    echo "GoogleTest installed successfully!"
}

install_linux_arch() {
    echo "Detected Linux (Arch/Manjaro)"
    sudo pacman -Syu --noconfirm
    sudo pacman -S --needed --noconfirm base-devel cmake glfw-x11 zeromq sqlite gtest
}

install_linux_fedora() {
    echo "Detected Linux (Fedora)"
    sudo dnf install -y make automake gcc gcc-c++ kernel-devel cmake \
        glfw-devel zeromq-devel sqlite-devel gtest-devel
}

install_macos() {
    echo "Detected macOS"
    # Install Homebrew if missing
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew update
    brew install cmake glfw zeromq sqlite googletest
}

install_windows_msys2() {
    echo "Detected Windows (MSYS2)"
    echo "Make sure you're running this script inside MSYS2 shell!"
    pacman -Syu --noconfirm
    pacman -S --needed --noconfirm \
        mingw-w64-x86_64-toolchain mingw-w64-x86_64-cmake \
        mingw-w64-x86_64-glfw mingw-w64-x86_64-zeromq \
        mingw-w64-x86_64-sqlite3 mingw-w64-x86_64-gtest
}

case "$OS" in
    Linux*)
        if [ -f /etc/debian_version ]; then
            install_linux_debian
        elif [ -f /etc/arch-release ]; then
            install_linux_arch
        elif [ -f /etc/fedora-release ]; then
            install_linux_fedora
        else
            echo "Unsupported Linux distribution. Install deps manually."
            exit 1
        fi
        ;;
    Darwin*)
        install_macos
        ;;
    MINGW*|MSYS*|CYGWIN*)
        install_windows_msys2
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

echo ""
echo "=============================================="
echo " All dependencies installed successfully!     "
echo "=============================================="
