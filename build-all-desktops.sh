#!/bin/bash
# Script to build all desktop environment ISOs

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Desktop environments to build
DESKTOP_ENVIRONMENTS=(
    "xfce"
    "kde"
    "lxde"
    "lxqt"
    "mate"
    "cinnamon"
    "budgie"
)

# Main function
main() {
    log_info "Starting Chlorine Linux multi-desktop ISO build process..."
    
    # Check if we should build all desktops or just one
    if [ -n "$1" ]; then
        # Build for a specific desktop
        log_info "Building ISO for $1 desktop environment..."
        sudo "$SCRIPT_DIR/scripts/build-desktop-isos.sh" "$1"
    else
        # Build for all desktop environments
        for desktop in "${DESKTOP_ENVIRONMENTS[@]}"; do
            log_info "Building ISO for $desktop desktop environment..."
            sudo "$SCRIPT_DIR/scripts/build-desktop-isos.sh" "$desktop"
        done
    fi
    
    log_info "All ISO builds completed."
}

# Run the main function with the first argument (if provided)
main "$1"