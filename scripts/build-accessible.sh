#!/bin/bash
# Build Chlorine Linux with live user and accessibility features

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

# Create necessary directories
mkdir -p "$BUILD_DIR"
mkdir -p "$ISO_DIR"

# Clean the build directory
log_info "Cleaning build directory..."
cd "$BUILD_DIR"
lb clean --all || true

# Initialize live-build configuration
log_info "Initializing live-build configuration..."
cd "$BUILD_DIR"
lb config \
    --distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --apt-indices false \
    --apt-recommends false \
    --debian-installer none \
    --mirror-bootstrap "http://deb.debian.org/debian/" \
    --mirror-binary "http://deb.debian.org/debian/" \
    --mirror-binary-security "http://security.debian.org/debian-security/" \
    --mirror-chroot "http://deb.debian.org/debian/" \
    --mirror-chroot-security "http://security.debian.org/debian-security/" \
    --debootstrap-options "--keyring=/usr/share/keyrings/debian-archive-keyring.gpg" \
    --binary-filesystem ext4 \
    --binary-images iso-hybrid \
    --bootappend-live "boot=live username=live user-fullname=live hostname=chlorine-live"

# Copy custom configurations
log_info "Adding custom configurations..."
cp -r "$CONFIG_DIR"/* "$BUILD_DIR"/config/

# Verify that the hooks are executable
log_info "Ensuring hooks are executable..."
chmod +x "$BUILD_DIR"/config/hooks/live/*.hook.*

# Run the customize-installer script
if [ -f "$SCRIPT_DIR/customize-installer.sh" ]; then
    log_info "Setting up Calamares installer..."
    bash "$SCRIPT_DIR/customize-installer.sh"
else
    log_warn "customize-installer.sh not found. Skipping Calamares setup."
fi

# Finalize configuration
log_info "Finalizing configuration..."
cd "$BUILD_DIR"
lb config \
    --binary-filesystem ext4 \
    --binary-images iso-hybrid \
    --bootappend-live "boot=live username=live user-fullname=live hostname=chlorine-live"

# Run the build
log_info "Building ISO..."
cd "$BUILD_DIR"
lb build || true

# Check if the ISO was created
if [ -f "$BUILD_DIR/live-image-amd64.hybrid.iso" ]; then
    log_info "Copying ISO to output directory..."
    cp "$BUILD_DIR/live-image-amd64.hybrid.iso" "$ISO_DIR/chlorine-linux.iso"
    log_info "ISO created successfully: $ISO_DIR/chlorine-linux.iso"
    log_info "ISO size: $(du -h "$ISO_DIR/chlorine-linux.iso" | cut -f1)"
else
    log_error "ISO file not found after build."
    exit 1
fi

log_info "Chlorine Linux build process completed successfully."
