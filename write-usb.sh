#!/bin/bash
#
# Chlorine Linux USB Writer Script
# This script writes the Chlorine Linux ISO to a USB drive with optimized settings

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISO_PATH="$SCRIPT_DIR/iso/chlorine-linux.iso"

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

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    log_error "This script must be run as root"
    exit 1
fi

# Check if ISO exists
if [ ! -f "$ISO_PATH" ]; then
    log_error "ISO file not found at: $ISO_PATH"
    log_info "Please build the ISO first using: sudo ./install.sh"
    exit 1
fi

# List available drives
list_drives() {
    log_info "Available drives:"
    echo
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -E "disk|part"
    echo
}

# Main function
main() {
    log_info "Chlorine Linux USB Writer"
    log_info "This script will write the Chlorine Linux ISO to a USB drive."
    log_warn "WARNING: This will erase all data on the selected USB drive!"
    echo

    # List available drives
    list_drives

    # Ask for the target drive
    read -p "Enter the target drive (e.g., sdb, sdc): " TARGET_DRIVE
    
    # Validate input
    if [ -z "$TARGET_DRIVE" ]; then
        log_error "No drive specified."
        exit 1
    fi
    
    # Add /dev/ prefix if not provided
    if [[ ! "$TARGET_DRIVE" == /dev/* ]]; then
        TARGET_DRIVE="/dev/$TARGET_DRIVE"
    fi
    
    # Check if the drive exists
    if [ ! -b "$TARGET_DRIVE" ]; then
        log_error "Drive not found: $TARGET_DRIVE"
        exit 1
    fi
    
    # Ask for block size
    log_info "Select block size for writing:"
    echo "1) 512K (Safe, works on all systems)"
    echo "2) 1M (Good balance of speed and compatibility)"
    echo "3) 4M (Faster, recommended for modern systems)"
    echo "4) 8M (Fastest, for high-performance systems)"
    read -p "Enter your choice [1-4]: " BLOCK_CHOICE
    
    # Set block size based on choice
    case "$BLOCK_CHOICE" in
        2)
            BLOCK_SIZE="1M"
            ;;
        3)
            BLOCK_SIZE="4M"
            ;;
        4)
            BLOCK_SIZE="8M"
            ;;
        *)
            BLOCK_SIZE="512K"
            ;;
    esac
    
    # Confirm before proceeding
    log_warn "You are about to erase all data on $TARGET_DRIVE and write Chlorine Linux to it."
    log_warn "Block size: $BLOCK_SIZE"
    read -p "Are you sure you want to continue? (y/n): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Operation cancelled."
        exit 0
    fi
    
    # Unmount any partitions on the target drive
    log_info "Unmounting any mounted partitions on $TARGET_DRIVE..."
    for mount in $(mount | grep "$TARGET_DRIVE" | awk '{print $1}'); do
        umount "$mount" 2>/dev/null || true
    done
    
    # Write the ISO to the USB drive
    log_info "Writing Chlorine Linux ISO to $TARGET_DRIVE with block size $BLOCK_SIZE..."
    log_info "This may take several minutes. Please be patient."
    
    # Use dd with the selected block size and show progress
    dd if="$ISO_PATH" of="$TARGET_DRIVE" bs="$BLOCK_SIZE" conv=fsync status=progress
    
    # Sync to ensure all data is written
    log_info "Syncing file system..."
    sync
    
    log_info "Chlorine Linux has been successfully written to $TARGET_DRIVE!"
    log_info "You can now boot from this USB drive."
}

# Run the main function
main "$@"