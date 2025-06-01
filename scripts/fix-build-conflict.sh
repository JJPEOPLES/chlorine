#!/bin/bash
# Script to fix the conflict between includes.chroot and includes.chroot_after_packages

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
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Check if build directory exists
if [ -d "$ROOT_DIR/build" ]; then
    log_info "Cleaning build directory..."
    rm -rf "$ROOT_DIR/build"
    log_info "Build directory cleaned."
fi

# Check if includes.chroot_after_packages exists in config
if [ -d "$ROOT_DIR/config/includes.chroot_after_packages" ]; then
    log_info "Moving files from includes.chroot_after_packages to includes.chroot..."
    
    # Create includes.chroot directory if it doesn't exist
    mkdir -p "$ROOT_DIR/config/includes.chroot"
    
    # Move all files from includes.chroot_after_packages to includes.chroot
    cp -r "$ROOT_DIR/config/includes.chroot_after_packages/"* "$ROOT_DIR/config/includes.chroot/"
    
    # Remove includes.chroot_after_packages directory
    rm -rf "$ROOT_DIR/config/includes.chroot_after_packages"
    
    log_info "Files moved successfully."
fi

# Check for mksquashfs.conf in includes.chroot/etc
if [ -f "$ROOT_DIR/config/includes.chroot/etc/mksquashfs.conf" ]; then
    log_info "Found mksquashfs.conf in includes.chroot/etc"
else
    log_info "Creating mksquashfs.conf in includes.chroot/etc..."
    
    # Create directory if it doesn't exist
    mkdir -p "$ROOT_DIR/config/includes.chroot/etc"
    
    # Create mksquashfs.conf file
    cat > "$ROOT_DIR/config/includes.chroot/etc/mksquashfs.conf" << EOF
# Squashfs configuration file
# This file is used to configure the squashfs filesystem

# Compression options
COMPRESSION="gzip"
COMPRESSION_OPTIONS="-Xcompression-level 1"
BLOCK_SIZE="1M"
EOF
    
    log_info "mksquashfs.conf created successfully."
fi

log_info "Build conflict fixed successfully."