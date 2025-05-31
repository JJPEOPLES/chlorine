#!/bin/bash
# Script to write Chlorine Linux ISO to USB with verification

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

# Write the ISO to the drive
log_info "Writing ISO to /dev/$TARGET_DRIVE..."
log_info "This may take several minutes. Please be patient."
dd if="$ISO_PATH" of="/dev/$TARGET_DRIVE" bs=4M status=progress conv=fsync

# Sync to ensure all data is written
log_info "Syncing data..."
sync

# Verify the write
log_info "Verifying the write..."
log_info "This may take several minutes. Please be patient."

# Calculate ISO size in bytes
ISO_SIZE=$(stat -c %s "$ISO_PATH")
log_info "ISO size: $ISO_SIZE bytes"

# Read back the same number of bytes from the USB drive and compare checksums
ISO_MD5=$(dd if="$ISO_PATH" bs=1M | md5sum | cut -d' ' -f1)
USB_MD5=$(dd if="/dev/$TARGET_DRIVE" bs=1M count=$((ISO_SIZE/1024/1024)) | md5sum | cut -d' ' -f1)

if [ "$ISO_MD5" = "$USB_MD5" ]; then
    log_info "Verification successful! The USB drive was written correctly."
else
    log_error "Verification failed! The USB drive may not have been written correctly."
    exit 1
fi

log_info "USB drive is ready to boot Chlorine Linux."
log_info "You can safely remove the USB drive and use it to boot your computer."
