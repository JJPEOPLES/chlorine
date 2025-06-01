#!/bin/bash
# Script to unmount all virtual filesystems in the build directory

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    log_info "Build directory does not exist. Nothing to unmount."
    exit 0
fi

log_info "Unmounting virtual filesystems in build directory..."

# List of common mount points in the build directory
MOUNT_POINTS=(
    "$BUILD_DIR/chroot/dev/pts"
    "$BUILD_DIR/chroot/dev"
    "$BUILD_DIR/chroot/proc"
    "$BUILD_DIR/chroot/sys"
    "$BUILD_DIR/chroot/run"
    "$BUILD_DIR/chroot/tmp"
    "$BUILD_DIR/chroot/boot/efi"
)

# Unmount all mount points
for mount_point in "${MOUNT_POINTS[@]}"; do
    if mount | grep -q "$mount_point"; then
        log_info "Unmounting $mount_point..."
        sudo umount -f "$mount_point" || log_warn "Failed to unmount $mount_point"
    fi
done

# Find any remaining mounts in the build directory
REMAINING_MOUNTS=$(mount | grep "$BUILD_DIR" | awk '{print $3}' | sort -r)

if [ -n "$REMAINING_MOUNTS" ]; then
    log_info "Unmounting remaining mount points..."
    for mount_point in $REMAINING_MOUNTS; do
        log_info "Unmounting $mount_point..."
        sudo umount -f "$mount_point" || log_warn "Failed to unmount $mount_point"
    done
fi

# Check for processes using the build directory (but don't kill them)
log_info "Checking for processes using the build directory..."
PROCS=$(sudo lsof +D "$BUILD_DIR" 2>/dev/null | grep -v "lsof" | awk '{print $2}' | sort -u)
if [ -n "$PROCS" ]; then
    log_warn "There are still processes using the build directory. You may need to terminate them manually."
    log_warn "Process IDs: $PROCS"
fi


# Optionally, clean the build directory
read -p "Do you want to clean the build directory? (y/n): " CLEAN_BUILD
if [ "$CLEAN_BUILD" = "y" ] || [ "$CLEAN_BUILD" = "Y" ]; then
    log_info "Cleaning build directory..."
    sudo rm -rf "$BUILD_DIR"
    log_info "Build directory cleaned."
fi

exit 0