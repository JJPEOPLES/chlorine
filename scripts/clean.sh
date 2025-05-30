#!/bin/bash
#
# Chlorine Linux Clean Script
# This script cleans the build directory for Chlorine Linux

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Log functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Clean the build directory
clean_build() {
    log_info "Cleaning build directory..."
    
    if [ -d "$BUILD_DIR" ]; then
        cd "$BUILD_DIR"
        if [ -f "config/binary" ]; then
            log_info "Running lb clean..."
            lb clean
        fi
        
        log_info "Removing build directory..."
        cd "$PROJECT_ROOT"
        rm -rf "$BUILD_DIR"
    else
        log_info "Build directory does not exist. Nothing to clean."
    fi
    
    log_info "Build directory cleaned successfully."
}

# Main function
main() {
    log_info "Starting Chlorine Linux clean process..."
    
    clean_build
    
    log_info "Chlorine Linux clean completed successfully!"
}

# Run the main function
main "$@"