#!/usr/bin/env bash
set -e

echo "=============================================="
echo "   Installing dependencies for Bloodvalley    "
echo "=============================================="
echo ""

OS="$(uname -s)"

install_linux_debian() {
    echo "Detected Linux (Debian/Ubuntu)"
    sudo apt update
    sudo apt install -y build-essential cmake pkg-config \
        libglfw3-dev libzmq3-dev libsqlite3-dev libgtest-dev

    # Build GTest in temp folder
    TMP_GTEST=$(mktemp -d)
    pushd $TMP_GTEST
    cmake /usr/src/gtest
    make -j$(nproc)
    sudo cp lib/*.a /usr/lib
    popd
    rm -rf $TMP_GTEST
}

install_macos() {
    echo "Detected macOS"

    # Install Homebrew if missing
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    brew update

    # Only install packages that are missing
    for pkg in glfw zeromq sqlite googletest; do
        if ! brew list "$pkg" &>/dev/null; then
            brew install "$pkg"
        else
            echo "$pkg already installed, skipping..."
        fi
    done
}

case "$OS" in
    Linux*)
        if [ -f /etc/debian_version ]; then
            install_linux_debian
        else
            echo "Unsupported Linux distro. Install deps manually."
            exit 1
        fi
        ;;
    Darwin*)
        install_macos
        ;;
    MINGW*|MSYS*|CYGWIN*)
        echo "Windows not supported in CI. Use MSYS2 manually."
        exit 1
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
