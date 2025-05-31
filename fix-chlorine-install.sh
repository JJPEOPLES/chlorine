#!/bin/bash
# Script to fix Chlorine Linux installation issues

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

# 1. Switch from GDM3 to SDDM
log_info "Switching from GDM3 to SDDM..."
apt-get update
apt-get install -y sddm plasma-desktop plasma-nm plasma-pa plasma-widgets-addons plasma-workspace

# Stop GDM3 if it's running
systemctl stop gdm3 || true

# Disable GDM3 and enable SDDM
systemctl disable gdm3 || true
systemctl enable sddm

# 2. Remove the live user if it exists
log_info "Checking for live user..."
if id "live" &>/dev/null; then
    log_info "Removing live user..."
    pkill -u live || true
    deluser --remove-home live
fi

# 3. Change TTY prompt from Debian to Chlorine
log_info "Changing TTY prompt to Chlorine GNU/Linux..."
if [ -f /etc/issue ]; then
    sed -i 's/Debian GNU\/Linux/Chlorine GNU\/Linux/g' /etc/issue
fi

if [ -f /etc/issue.net ]; then
    sed -i 's/Debian GNU\/Linux/Chlorine GNU\/Linux/g' /etc/issue.net
fi

# Update os-release file
if [ -f /etc/os-release ]; then
    sed -i 's/PRETTY_NAME="Debian GNU\/Linux/PRETTY_NAME="Chlorine GNU\/Linux/g' /etc/os-release
    sed -i 's/NAME="Debian GNU\/Linux"/NAME="Chlorine GNU\/Linux"/g' /etc/os-release
fi

# 4. Ensure apt is properly configured
log_info "Configuring apt..."
cat > /etc/apt/sources.list << SOURCES
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
SOURCES

# 5. Install full KDE if not already installed
log_info "Installing full KDE Plasma desktop..."
apt-get update
apt-get install -y kde-standard kde-plasma-desktop plasma-widgets-addons plasma-nm plasma-pa

# 6. Clean up unnecessary desktop files
log_info "Cleaning up unnecessary desktop files..."
find /usr/share/applications -name "*gnome*" -delete || true

# 7. Set up display manager configuration
log_info "Configuring display manager..."
cat > /etc/X11/default-display-manager << DISPLAY
/usr/bin/sddm
DISPLAY

# 8. Update GRUB configuration
log_info "Updating GRUB configuration..."
if [ -f /etc/default/grub ]; then
    sed -i 's/GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR="Chlorine"/g' /etc/default/grub
    update-grub
fi

log_info "All fixes have been applied. Please reboot your system."
log_info "After reboot, you should have a full KDE Plasma desktop with SDDM."
