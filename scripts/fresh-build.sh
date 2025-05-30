#!/bin/bash
# Script to completely clean the build directory and start fresh

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

# Completely clean the build directory
clean_build_directory() {
    log_info "Completely cleaning build directory..."
    
    # Remove the entire build directory
    if [ -d "$BUILD_DIR" ]; then
        log_info "Removing existing build directory..."
        sudo rm -rf "$BUILD_DIR"
    fi
    
    # Create a fresh build directory
    log_info "Creating fresh build directory..."
    mkdir -p "$BUILD_DIR"
    
    log_info "Build directory cleaned and recreated."
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
    log_info "Starting Chlorine Linux fresh build process..."
    
    # Clean up build directory completely
    clean_build_directory
    
    # Run the build script
    run_build
    
    log_info "Build process completed."
}

# Run the main function
main "$@"