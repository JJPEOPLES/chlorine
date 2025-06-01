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
    if [ -d "/home/jjshandy6161/Desktop/chlorine/scripts" ]; then
        chmod +x /home/jjshandy6161/Desktop/chlorine/scripts/*.sh
        log_info "Scripts are now executable."
    else
        log_warn "Scripts directory not found. Skipping script permission changes."
    fi
}

run_build() {
    log_info "Starting build process..."
    
    log_info "Running build-accessible.sh script..."
    if [ -f "$SCRIPT_DIR/build-accessible.sh" ]; then
        # Make sure the script is executable
        chmod +x "$SCRIPT_DIR/build-accessible.sh"
        
        # Run the build-accessible.sh script
        bash "$SCRIPT_DIR/build-accessible.sh"
        
        # Check if the build was successful
        if [ $? -eq 0 ]; then
            log_info "Build process completed successfully."
        else
            log_warn "Build process completed with errors. Check the logs for details."
        fi
    else
        log_error "build-accessible.sh not found in scripts directory. Cannot continue."
        exit 1
    fi
}

show_completion() {
    log_info "Chlorine Linux build completed successfully!"
    log_info "The ISO file is available at: /home/jjshandy6161/Desktop/chlorine/iso/chlorine-linux.iso"
    log_info ""
    log_info "This build includes the K2 programming language (https://k2lang.org)"
    log_info "After booting, you can run K2 programs with the 'k2' command."
    log_info "A sample program is available at /usr/local/share/k2/examples/hello.k2"
    log_info ""
    log_info "You can burn this ISO to a USB drive using:"
    log_info "  dd if=/home/jjshandy6161/Desktop/chlorine/iso/chlorine-linux.iso of=/dev/sdX bs=512K status=progress"
    log_info "  (Replace /dev/sdX with your USB drive device)"
    log_info ""
    log_info "For faster writes on modern systems, you can use larger block sizes:"
    log_info "  dd if=/home/jjshandy6161/Desktop/chlorine/iso/chlorine-linux.iso of=/dev/sdX bs=1M status=progress"
    log_info "  dd if=/home/jjshandy6161/Desktop/chlorine/iso/chlorine-linux.iso of=/dev/sdX bs=4M status=progress"
    log_info "  dd if=/home/jjshandy6161/Desktop/chlorine/iso/chlorine-linux.iso of=/dev/sdX bs=8M status=progress"
    log_info ""
    log_info "Or test it in a virtual machine:"
    log_info "  qemu-system-x86_64 -cdrom /home/jjshandy6161/Desktop/chlorine/iso/chlorine-linux.iso -m 2G"
}

main() {
    log_info "Welcome to Chlorine Linux installer"
    log_info "This build will include the K2 programming language (https://k2lang.org)"
    check_dependencies
    make_scripts_executable
    run_build
    show_completion
}

main "$@"
