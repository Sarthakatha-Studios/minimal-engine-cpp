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
    sudo apt update
    sudo apt install -y build-essential cmake pkg-config \
        libglfw3-dev libzmq3-dev libsqlite3-dev libgtest-dev

    # Build GoogleTest from source safely
    echo "Building GoogleTest from source..."
    TMP_GTEST=$(mktemp -d)
    pushd "$TMP_GTEST"
    cmake /usr/src/gtest
    make -j$(nproc)
    sudo cp lib/*.a /usr/lib
    popd
    rm -rf "$TMP_GTEST"
    echo "GoogleTest installed successfully!"
}

case "$OS" in
    Linux*)
        if [ -f /etc/debian_version ]; then
            install_linux_debian
        else
            echo "Unsupported Linux distribution. Install deps manually."
            exit 1
        fi
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
