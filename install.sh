#!/bin/bash
# Chlorine Linux Installer Setup Script

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

check_dependencies() {
    log_info "Checking for required dependencies..."

    local DEPS=(
        "debootstrap"
        "squashfs-tools"
        "xorriso"
        "isolinux"
        "syslinux-utils"
        "grub-pc-bin"
        "grub-efi-amd64-bin"
        "mtools"
        "dosfstools"
        "live-build"
    )

    local MISSING=()
    for dep in "${DEPS[@]}"; do
        if ! command -v "$dep" &> /dev/null && ! dpkg -l | grep -q "$dep"; then
            MISSING+=("$dep")
        fi
    done

    if [ ${#MISSING[@]} -ne 0 ]; then
        log_warn "Missing dependencies: ${MISSING[*]}"
        read -p "Do you want to install the missing dependencies? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            apt-get update
            apt-get install -y "${MISSING[@]}"
        else
            log_error "Cannot continue without required dependencies."
            exit 1
        fi
    fi

    log_info "All dependencies are installed."
}

make_scripts_executable() {
    log_info "Making scripts executable..."
    if [ -d "$SCRIPT_DIR/scripts" ]; then
        chmod +x "$SCRIPT_DIR/scripts"/*.sh
        log_info "Scripts are now executable."
    else
        log_warn "Scripts directory not found. Skipping script permission changes."
    fi
}

run_build() {
    log_info "Starting build process..."
    
    # Run the build script
    if [ -f "$SCRIPT_DIR/scripts/build-fixed.sh" ]; then
        log_info "Running build script..."
        bash "$SCRIPT_DIR/scripts/build.sh"
        log_info "Build process completed."
    else
        log_error "build.sh not found in scripts directory. Cannot continue."
        exit 1
    fi
}

main() {
    log_info "Welcome to Chlorine Linux installer"
    check_dependencies
    make_scripts_executable
    run_build
}

main "$@"
