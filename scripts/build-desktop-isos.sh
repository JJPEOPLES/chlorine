#!/bin/bash
# Script to build separate ISOs for each desktop environment

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

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

# Function to update package lists for a specific desktop
update_package_lists() {
    local desktop=$1
    log_info "Updating package lists for $desktop..."
    
    # Disable all desktop package lists first
    for de in "${DESKTOP_ENVIRONMENTS[@]}"; do
        if [ -f "$ROOT_DIR/config/package-lists/desktop-$de.list.chroot" ]; then
            mv "$ROOT_DIR/config/package-lists/desktop-$de.list.chroot" "$ROOT_DIR/config/package-lists/desktop-$de.list.chroot.disabled"
        fi
    done
    
    # Enable only the selected desktop
    if [ -f "$ROOT_DIR/config/package-lists/desktop-$desktop.list.chroot.disabled" ]; then
        mv "$ROOT_DIR/config/package-lists/desktop-$desktop.list.chroot.disabled" "$ROOT_DIR/config/package-lists/desktop-$desktop.list.chroot"
    fi
    
    # Update the desktop-environments.list.chroot file
    cat > "$ROOT_DIR/config/package-lists/desktop-environments.list.chroot" << EOF
# Base desktop packages
xorg
lightdm
lightdm-gtk-greeter
network-manager
firefox-esr
pipewire
pipewire-pulse
pipewire-alsa
pipewire-jack
wireplumber
pavucontrol

# Selected desktop environment: $desktop
EOF
    
    # Add specific desktop packages based on selection
    case "$desktop" in
        xfce)
            cat >> "$ROOT_DIR/config/package-lists/desktop-environments.list.chroot" << EOF
# XFCE
xfce4
xfce4-goodies
thunar
thunar-archive-plugin
thunar-media-tags-plugin
xfce4-terminal
xfce4-power-manager
xfce4-notifyd
xfce4-screenshooter
xfce4-taskmanager
xfce4-whiskermenu-plugin
xfce4-clipman-plugin
xfce4-battery-plugin
xfce4-datetime-plugin
xfce4-weather-plugin
xfce4-systemload-plugin
EOF
            ;;
        kde)
            cat >> "$ROOT_DIR/config/package-lists/desktop-environments.list.chroot" << EOF
# KDE Plasma (minimal)
kde-plasma-desktop
plasma-nm
sddm
EOF
            ;;
        lxde)
            cat >> "$ROOT_DIR/config/package-lists/desktop-environments.list.chroot" << EOF
# LXDE
lxde
lxde-core
EOF
            ;;
        lxqt)
            cat >> "$ROOT_DIR/config/package-lists/desktop-environments.list.chroot" << EOF
# LXQt
lxqt
lxqt-core
EOF
            ;;
        mate)
            cat >> "$ROOT_DIR/config/package-lists/desktop-environments.list.chroot" << EOF
# MATE
mate-desktop-environment
EOF
            ;;
        cinnamon)
            cat >> "$ROOT_DIR/config/package-lists/desktop-environments.list.chroot" << EOF
# Cinnamon
cinnamon-desktop-environment
EOF
            ;;
        budgie)
            cat >> "$ROOT_DIR/config/package-lists/desktop-environments.list.chroot" << EOF
# Budgie
budgie-desktop
EOF
            ;;
    esac
    
    log_info "Package lists updated for $desktop."
}

# Function to update Calamares configuration for a specific desktop
update_calamares_config() {
    local desktop=$1
    log_info "Updating Calamares configuration for $desktop..."
    
    # Update the packagechooser.conf file to set the default desktop
    sed -i "s/^default: .*/default: \"$desktop\"/" "$ROOT_DIR/config/includes.chroot/etc/calamares/modules/packagechooser.conf"
    
    # Update the desktop.py script to set the default desktop
    sed -i "s/^DEFAULT_DESKTOP = .*$/DEFAULT_DESKTOP = \"$desktop\"/" "$ROOT_DIR/config/includes.chroot/etc/calamares/modules/desktop.py"
    
    log_info "Calamares configuration updated for $desktop."
}

# Function to safely clean build directory
clean_build_directory() {
    log_info "Safely cleaning build directory..."
    
    # Unmount any filesystems in the build directory first
    if [ -d "$ROOT_DIR/build" ]; then
        log_info "Unmounting filesystems in build directory..."
        
        # List of common mount points in the build directory
        MOUNT_POINTS=(
            "$ROOT_DIR/build/chroot/dev/pts"
            "$ROOT_DIR/build/chroot/dev"
            "$ROOT_DIR/build/chroot/proc"
            "$ROOT_DIR/build/chroot/sys"
            "$ROOT_DIR/build/chroot/run"
            "$ROOT_DIR/build/chroot/tmp"
            "$ROOT_DIR/build/chroot/boot/efi"
        )
        
        # Unmount all mount points
        for mount_point in "${MOUNT_POINTS[@]}"; do
            if mount | grep -q "$mount_point"; then
                log_info "Unmounting $mount_point..."
                umount -f "$mount_point" || log_warn "Failed to unmount $mount_point"
            fi
        done
        
        # Find any remaining mounts in the build directory
        REMAINING_MOUNTS=$(mount | grep "$ROOT_DIR/build" | awk '{print $3}' | sort -r)
        
        if [ -n "$REMAINING_MOUNTS" ]; then
            log_info "Unmounting remaining mount points..."
            for mount_point in $REMAINING_MOUNTS; do
                log_info "Unmounting $mount_point..."
                umount -f "$mount_point" || log_warn "Failed to unmount $mount_point"
            done
        fi
    fi
    
    # Now it's safe to remove the build directory
    rm -rf "$ROOT_DIR/build"
    log_info "Build directory cleaned."
}

# Function to build ISO for a specific desktop
build_desktop_iso() {
    local desktop=$1
    log_info "Building ISO for $desktop desktop environment..."
    
    # Clean build directory first
    clean_build_directory
    
    # Fix build conflicts
    if [ -f "$SCRIPT_DIR/fix-build-conflict.sh" ]; then
        log_info "Running build conflict fix script..."
        bash "$SCRIPT_DIR/fix-build-conflict.sh"
    fi
    
    # Update package lists and Calamares configuration
    update_package_lists "$desktop"
    update_calamares_config "$desktop"
    
    # Set the ISO filename
    export CHLORINE_ISO_NAME="chlorine-linux-$desktop-$(date +%Y%m%d).iso"
    
    # Run the build script
    log_info "Starting build process for $desktop..."
    if [ -f "$SCRIPT_DIR/build-accessible.sh" ]; then
        bash "$SCRIPT_DIR/build-accessible.sh"
        
        # Check if the ISO was created successfully
        if [ -f "$ROOT_DIR/chlorine-linux.iso" ]; then
            # Rename the ISO
            mv "$ROOT_DIR/chlorine-linux.iso" "$ROOT_DIR/$CHLORINE_ISO_NAME"
            log_info "ISO for $desktop created successfully: $CHLORINE_ISO_NAME"
        else
            log_error "Failed to build ISO for $desktop."
        fi
    else
        log_error "build-accessible.sh not found in scripts directory. Cannot continue."
        exit 1
    fi
}

# Main function
main() {
    log_info "Starting Chlorine Linux multi-desktop ISO build process..."
    
    # Check if we should build all desktops or just one
    if [ -n "$1" ]; then
        # Build for a specific desktop
        build_desktop_iso "$1"
    else
        # Build for all desktop environments
        for desktop in "${DESKTOP_ENVIRONMENTS[@]}"; do
            build_desktop_iso "$desktop"
        done
    fi
    
    log_info "All ISO builds completed."
}

# Run the main function with the first argument (if provided)
main "$1"