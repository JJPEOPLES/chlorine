#!/bin/bash
# Script to build Chlorine Linux with K2 language

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$ROOT_DIR/build"
CONFIG_DIR="$ROOT_DIR/config"
ISO_DIR="$ROOT_DIR/iso"

# Clean the build environment
log_info "Cleaning build environment..."
rm -rf "$ISO_DIR"/*
rm -rf "$BUILD_DIR"/*
mkdir -p "$ISO_DIR"
mkdir -p "$BUILD_DIR"

# Ensure K2 language hook is properly set up
log_info "Ensuring K2 language hook is properly set up..."
mkdir -p "$CONFIG_DIR/hooks/live"
mkdir -p "$CONFIG_DIR/package-lists"

# Create the K2 language installation hook if it doesn't exist
if [ ! -f "$CONFIG_DIR/hooks/live/0050-install-k2-lang.hook.chroot" ]; then
    log_warn "K2 language installation hook not found. Creating it..."
    cat << 'EOFHOOK' > "$CONFIG_DIR/hooks/live/0050-install-k2-lang.hook.chroot"
#!/bin/bash
# Install K2 language from official website
set -e

echo "Installing K2 language..."

# Create a temporary directory for downloading
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Install dependencies
apt-get update
apt-get install -y curl wget build-essential

# Download the latest K2 language installer
echo "Downloading K2 language from https://k2lang.org/downloads/k2..."
wget -q https://k2lang.org/downloads/k2 -O k2-installer

# Make the installer executable
chmod +x k2-installer

# Run the installer
echo "Running K2 language installer..."
./k2-installer --accept-license --prefix=/usr/local

# Verify installation
if [ -f /usr/local/bin/k2 ]; then
    echo "K2 language installed successfully."
    echo "K2 version: $(/usr/local/bin/k2 --version)"
else
    echo "K2 language installation failed."
    exit 1
fi

# Clean up
cd /
rm -rf "$TEMP_DIR"

# Create a simple test script
mkdir -p /usr/local/share/k2/examples
cat > /usr/local/share/k2/examples/hello.k2 << 'EOFINNER'
// Hello World in K2
fn main() {
    println("Hello from K2 language in Chlorine Linux!");
}
EOFINNER

echo "K2 language installation completed."
EOFHOOK
    log_info "K2 language installation hook created."
fi

# Make the hook executable
chmod +x "$CONFIG_DIR/hooks/live/0050-install-k2-lang.hook.chroot"

# Create a package list for K2 dependencies if it doesn't exist
if [ ! -f "$CONFIG_DIR/package-lists/k2-dependencies.list.chroot" ]; then
    log_warn "K2 dependencies package list not found. Creating it..."
    cat << 'EOFPKG' > "$CONFIG_DIR/package-lists/k2-dependencies.list.chroot"
curl
wget
build-essential
EOFPKG
    log_info "K2 dependencies package list created."
fi

# Verify that the hooks are executable
log_info "Ensuring hooks are executable..."
find "$CONFIG_DIR/hooks" -type f -name "*.hook.*" -exec chmod +x {} \;

# Start the build process
log_info "Starting build process with K2 language..."
cd "$ROOT_DIR"
bash "$SCRIPT_DIR/build.sh"

log_info "Build process completed."
