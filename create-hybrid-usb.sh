#!/bin/bash
# Script to create a hybrid USB drive that works with both UEFI and BIOS systems

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

# Create a new partition table
log_info "Creating new partition table..."
parted -s /dev/$TARGET_DRIVE mklabel gpt

# Create an EFI System Partition
log_info "Creating EFI System Partition..."
parted -s /dev/$TARGET_DRIVE mkpart ESP fat32 1MiB 200MiB
parted -s /dev/$TARGET_DRIVE set 1 boot on
parted -s /dev/$TARGET_DRIVE set 1 esp on

# Create a data partition for the ISO
log_info "Creating data partition..."
parted -s /dev/$TARGET_DRIVE mkpart primary ext4 200MiB 100%

# Format the EFI partition
log_info "Formatting EFI partition..."
mkfs.fat -F32 /dev/${TARGET_DRIVE}1

# Format the data partition
log_info "Formatting data partition..."
mkfs.ext4 -F /dev/${TARGET_DRIVE}2

# Mount the partitions
log_info "Mounting partitions..."
mkdir -p /mnt/efi
mkdir -p /mnt/data
mount /dev/${TARGET_DRIVE}1 /mnt/efi
mount /dev/${TARGET_DRIVE}2 /mnt/data

# Extract the ISO to the data partition
log_info "Extracting ISO to data partition..."
mkdir -p /mnt/iso
mount -o loop "$ISO_PATH" /mnt/iso
cp -r /mnt/iso/* /mnt/data/

# Set up EFI boot
log_info "Setting up EFI boot..."
mkdir -p /mnt/efi/EFI/BOOT
cp /mnt/iso/EFI/BOOT/* /mnt/efi/EFI/BOOT/ 2>/dev/null || true

# Create a minimal GRUB configuration
log_info "Creating GRUB configuration..."
mkdir -p /mnt/efi/boot/grub
cat > /mnt/efi/boot/grub/grub.cfg << GRUBCFG
# Minimal GRUB configuration for hybrid boot
insmod all_video
insmod gfxterm
set gfxmode=auto
terminal_output gfxterm

set timeout=5
set default=0

menuentry "Chlorine Linux (Live)" {
  linux /live/vmlinuz boot=live quiet splash
  initrd /live/initrd.img
}
GRUBCFG

# Install GRUB for BIOS boot
log_info "Installing GRUB for BIOS boot..."
grub-install --target=i386-pc --boot-directory=/mnt/data/boot /dev/$TARGET_DRIVE

# Clean up
log_info "Cleaning up..."
umount /mnt/iso
umount /mnt/efi
umount /mnt/data
rmdir /mnt/iso
rmdir /mnt/efi
rmdir /mnt/data

# Sync to ensure all data is written
log_info "Syncing data..."
sync

log_info "USB drive is ready to boot Chlorine Linux in both UEFI and BIOS modes."
log_info "You can safely remove the USB drive and use it to boot your computer."
