#!/bin/bash
# Script to build a single desktop environment ISO

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

# Function to select desktop environment
select_desktop() {
    echo "Select desktop environment to build:"
    select desktop in "xfce" "kde" "lxde" "lxqt" "mate" "cinnamon" "budgie"; do
        if [ -n "$desktop" ]; then
            echo "$desktop"
            return
        else
            log_error "Invalid selection. Please try again."
        fi
    done
}

# Main function
main() {
    log_info "Chlorine Linux Desktop ISO Builder"
    
    # Select desktop environment if not provided
    if [ -z "$1" ]; then
        DESKTOP=$(select_desktop)
    else
        DESKTOP="$1"
    fi
    
    log_info "Building ISO for $DESKTOP desktop environment..."
    
    # Clean build directory
    log_info "Cleaning build directory..."
    
    # Unmount any filesystems in the build directory first
    if [ -d "$SCRIPT_DIR/build" ]; then
        log_info "Unmounting filesystems in build directory..."
        
        # List of common mount points in the build directory
        MOUNT_POINTS=(
            "$SCRIPT_DIR/build/chroot/dev/pts"
            "$SCRIPT_DIR/build/chroot/dev"
            "$SCRIPT_DIR/build/chroot/proc"
            "$SCRIPT_DIR/build/chroot/sys"
            "$SCRIPT_DIR/build/chroot/run"
            "$SCRIPT_DIR/build/chroot/tmp"
            "$SCRIPT_DIR/build/chroot/boot/efi"
        )
        
        # Unmount all mount points
        for mount_point in "${MOUNT_POINTS[@]}"; do
            if mount | grep -q "$mount_point"; then
                log_info "Unmounting $mount_point..."
                sudo umount -f "$mount_point" || log_warn "Failed to unmount $mount_point"
            fi
        done
        
        # Find any remaining mounts in the build directory
        REMAINING_MOUNTS=$(mount | grep "$SCRIPT_DIR/build" | awk '{print $3}' | sort -r)
        
        if [ -n "$REMAINING_MOUNTS" ]; then
            log_info "Unmounting remaining mount points..."
            for mount_point in $REMAINING_MOUNTS; do
                log_info "Unmounting $mount_point..."
                sudo umount -f "$mount_point" || log_warn "Failed to unmount $mount_point"
            done
        fi
    fi
    
    # Now it's safe to remove the build directory
    sudo rm -rf "$SCRIPT_DIR/build"
    
    # Create config directory if it doesn't exist
    mkdir -p "$SCRIPT_DIR/config/package-lists"
    
    # Create desktop package list
    log_info "Creating package list for $DESKTOP..."
    cat > "$SCRIPT_DIR/config/package-lists/desktop.list.chroot" << EOF
# Base desktop packages
xorg
network-manager
firefox-esr
pipewire
pipewire-pulse
pipewire-alsa
pipewire-jack
wireplumber
pavucontrol

# Selected desktop environment: $DESKTOP
EOF
    
    # Add specific desktop packages based on selection
    case "$DESKTOP" in
        xfce)
            cat >> "$SCRIPT_DIR/config/package-lists/desktop.list.chroot" << EOF
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
lightdm
lightdm-gtk-greeter
EOF
            ;;
        kde)
            cat >> "$SCRIPT_DIR/config/package-lists/desktop.list.chroot" << EOF
# KDE Plasma (minimal)
kde-plasma-desktop
plasma-nm
sddm
EOF
            ;;
        lxde)
            cat >> "$SCRIPT_DIR/config/package-lists/desktop.list.chroot" << EOF
# LXDE
lxde
lxde-core
lightdm
lightdm-gtk-greeter
EOF
            ;;
        lxqt)
            cat >> "$SCRIPT_DIR/config/package-lists/desktop.list.chroot" << EOF
# LXQt
lxqt
lxqt-core
sddm
EOF
            ;;
        mate)
            cat >> "$SCRIPT_DIR/config/package-lists/desktop.list.chroot" << EOF
# MATE
mate-desktop-environment
lightdm
lightdm-gtk-greeter
EOF
            ;;
        cinnamon)
            cat >> "$SCRIPT_DIR/config/package-lists/desktop.list.chroot" << EOF
# Cinnamon
cinnamon-desktop-environment
lightdm
lightdm-gtk-greeter
EOF
            ;;
        budgie)
            cat >> "$SCRIPT_DIR/config/package-lists/desktop.list.chroot" << EOF
# Budgie
budgie-desktop
lightdm
lightdm-gtk-greeter
EOF
            ;;
        *)
            log_error "Unsupported desktop environment: $DESKTOP"
            exit 1
            ;;
    esac
    
    # Set the ISO filename
    export CHLORINE_ISO_NAME="chlorine-linux-$DESKTOP-$(date +%Y%m%d).iso"
    
    # Run the build script
    log_info "Starting build process for $DESKTOP..."
    if [ -f "$SCRIPT_DIR/scripts/build-accessible.sh" ]; then
        sudo bash "$SCRIPT_DIR/scripts/build-accessible.sh"
        
        # Check if the ISO was created successfully
        if [ -f "$SCRIPT_DIR/chlorine-linux.iso" ]; then
            # Rename the ISO
            sudo mv "$SCRIPT_DIR/chlorine-linux.iso" "$SCRIPT_DIR/$CHLORINE_ISO_NAME"
            log_info "ISO for $DESKTOP created successfully: $CHLORINE_ISO_NAME"
        else
            log_error "Failed to build ISO for $DESKTOP."
        fi
    else
        log_error "build-accessible.sh not found in scripts directory. Cannot continue."
        exit 1
    fi
}

# Run the main function with the first argument (if provided)
main "$1"