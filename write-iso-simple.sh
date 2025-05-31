#!/bin/bash
# Simple script to write Chlorine Linux ISO to USB with verification

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    log_error "This script must be run as root."
    exit 1
fi

# ISO file path
ISO_PATH="/home/jjshandy6161/Desktop/chlorine/iso/chlorine-linux.iso"

# Check if ISO exists
if [ ! -f "$ISO_PATH" ]; then
    log_error "ISO file not found at $ISO_PATH"
    exit 1
fi

# List available drives
log_info "Available drives:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -v loop

# Ask for target drive
read -p "Enter the target drive (e.g., sdb, NOT sdb1): " TARGET_DRIVE

# Validate target drive
if [ ! -b "/dev/$TARGET_DRIVE" ]; then
    log_error "Invalid drive: /dev/$TARGET_DRIVE"
    exit 1
fi

# Confirm target drive
log_warn "WARNING: All data on /dev/$TARGET_DRIVE will be erased!"
log_warn "Target drive: /dev/$TARGET_DRIVE ($(lsblk -no SIZE /dev/$TARGET_DRIVE))"
read -p "Are you sure you want to continue? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    log_info "Operation cancelled."
    exit 0
fi

# Unmount any partitions on the target drive
log_info "Unmounting any partitions on /dev/$TARGET_DRIVE..."
umount /dev/${TARGET_DRIVE}* 2>/dev/null || true

# Choose block size
log_info "Choose block size for writing:"
log_info "1) 1M (Slower but more compatible)"
log_info "2) 4M (Recommended balance of speed and compatibility)"
log_info "3) 8M (Faster but may have issues on some systems)"
read -p "Enter choice [1-3]: " BLOCK_SIZE_CHOICE

case $BLOCK_SIZE_CHOICE in
    1) BLOCK_SIZE="1M" ;;
    2) BLOCK_SIZE="4M" ;;
    3) BLOCK_SIZE="8M" ;;
    *) BLOCK_SIZE="4M" ;;
esac

# Write the ISO to the drive
log_info "Writing ISO to /dev/$TARGET_DRIVE with block size $BLOCK_SIZE..."
log_info "This may take several minutes. Please be patient."
dd if="$ISO_PATH" of="/dev/$TARGET_DRIVE" bs=$BLOCK_SIZE status=progress conv=fsync

# Sync to ensure all data is written
log_info "Syncing data..."
sync

log_info "USB drive is ready to boot Chlorine Linux."
log_info "You can safely remove the USB drive and use it to boot your computer."
log_info ""
log_info "If you have boot issues, try these troubleshooting steps:"
log_info "1. In your BIOS/UEFI settings, try changing between UEFI and Legacy boot modes"
log_info "2. Disable Secure Boot if it's enabled"
log_info "3. Try a different USB port (preferably USB 2.0 if available)"
log_info "4. When booting, look for boot menu options like 'Try without installing'"
