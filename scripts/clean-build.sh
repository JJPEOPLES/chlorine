#!/bin/bash
# Script to clean up problematic directories and build Chlorine Linux

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$ROOT_DIR/build"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Clean up problematic directories
cleanup_directories() {
    log_info "Cleaning up problematic directories..."
    
    # Remove includes.chroot_after_packages if it exists
    if [ -d "$BUILD_DIR/config/includes.chroot_after_packages" ]; then
        log_info "Removing includes.chroot_after_packages directory..."
        sudo rm -rf "$BUILD_DIR/config/includes.chroot_after_packages"
    fi
    
    # Check if we need to move files from includes.chroot_after_packages to includes.chroot
    if [ -d "$ROOT_DIR/config/includes.chroot_after_packages" ]; then
        log_info "Found includes.chroot_after_packages in config directory..."
        
        # Create includes.chroot if it doesn't exist
        if [ ! -d "$ROOT_DIR/config/includes.chroot" ]; then
            log_info "Creating includes.chroot directory..."
            mkdir -p "$ROOT_DIR/config/includes.chroot"
        fi
        
        # Move files from includes.chroot_after_packages to includes.chroot if any exist
        log_info "Moving files from includes.chroot_after_packages to includes.chroot..."
        if [ "$(ls -A "$ROOT_DIR/config/includes.chroot_after_packages/" 2>/dev/null)" ]; then
            cp -r "$ROOT_DIR/config/includes.chroot_after_packages/"* "$ROOT_DIR/config/includes.chroot/"
        else
            log_info "No files found in includes.chroot_after_packages directory."
        fi
        
        # Remove includes.chroot_after_packages
        log_info "Removing original includes.chroot_after_packages directory..."
        rm -rf "$ROOT_DIR/config/includes.chroot_after_packages"
    fi
    
    log_info "Directory cleanup completed."
}

# Run the build script
run_build() {
    log_info "Running build script..."
    
    # Run the fixed build script
    if [ -f "$SCRIPT_DIR/build-fixed.sh" ]; then
        sudo bash "$SCRIPT_DIR/build-fixed.sh"
    else
        log_error "build-fixed.sh not found. Please make sure it exists."
        exit 1
    fi
}

# Main function
main() {
    log_info "Starting Chlorine Linux build process with cleanup..."
    
    # Clean up problematic directories
    cleanup_directories
    
    # Run the build script
    run_build
    
    log_info "Build process completed."
}

# Run the main function
main "$@"