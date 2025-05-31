#!/bin/bash
# Wrapper script for ruuf (Rufus for Linux)
# This script makes it easy to run ruuf from anywhere in the system

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUUF_DIR="$SCRIPT_DIR/ruuf"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if ruuf directory exists
if [ ! -d "$RUUF_DIR" ]; then
    log_error "ruuf directory not found at $RUUF_DIR"
    exit 1
fi

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    log_error "Python 3 is required but not installed. Please install Python 3."
    exit 1
fi

# Install dependencies if needed
if [ ! -f "$RUUF_DIR/.dependencies_installed" ]; then
    log_info "Installing dependencies for ruuf..."
    if [ -f "$RUUF_DIR/requirements.txt" ]; then
        pip3 install -r "$RUUF_DIR/requirements.txt"
        touch "$RUUF_DIR/.dependencies_installed"
    else
        log_warn "requirements.txt not found. Dependencies may not be installed correctly."
    fi
fi

# Make sure the main script is executable
if [ -f "$RUUF_DIR/ruuf_usb_flasher.py" ]; then
    chmod +x "$RUUF_DIR/ruuf_usb_flasher.py"
fi

# Run ruuf
log_info "Starting ruuf (Rufus for Linux)..."
cd "$RUUF_DIR"
python3 ruuf_usb_flasher.py "$@"