#!/bin/bash
# Chlorine Linux Installer Setup Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
CONFIG_DIR="$PROJECT_ROOT/config"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

prompt_desktop_choice() {
    echo -e "\nChoose your desktop environment:"
    echo "  1) KDE Plasma"
    echo "  2) GNOME"
    echo "  3) XFCE"
    read -rp "Enter choice [1-3]: " choice
    case $choice in
        1) DESKTOP="kde";;
        2) DESKTOP="gnome";;
        3) DESKTOP="xfce";;
        *) echo "Invalid option, defaulting to KDE."; DESKTOP="kde";;
    esac
}

setup_calamares() {
    log_info "Setting up Calamares configuration..."

    BRAND_DIR="$CONFIG_DIR/includes.chroot/etc/calamares/branding/chlorine"
    MODULES_DIR="$CONFIG_DIR/includes.chroot/etc/calamares/modules"
    mkdir -p "$BRAND_DIR" "$MODULES_DIR"

    # settings.conf
    tee "$CONFIG_DIR/includes.chroot/etc/calamares/settings.conf" > /dev/null <<EOF
---
modules-search: [ local, /usr/lib/calamares/modules ]
sequence:
  - show:
    - welcome
    - locale
    - keyboard
    - partition
    - users
    - desktop
    - summary
  - exec:
    - partition
    - mount
    - unpackfs
    - machineid
    - fstab
    - locale
    - keyboard
    - localecfg
    - users
    - displaymanager
    - networkcfg
    - hwclock
    - services-systemd
    - bootloader-config
    - bootloader
    - desktop-packages
    - umount
  - show:
    - finished
branding: chlorine
prompt-install: true
EOF

    # desktop.conf
    tee "$MODULES_DIR/desktop.conf" > /dev/null <<EOF
---
type: "choice"
name: "desktop"
pretty_name: "Desktop Environment"
description: "Choose your preferred desktop environment"
choices:
  - id: "kde"
    name: "KDE Plasma"
    description: "A modern, feature-rich desktop environment (default)"
    selected: ${DESKTOP:-true}
  - id: "gnome"
    name: "GNOME"
    description: "A simple, elegant desktop environment"
  - id: "xfce"
    name: "XFCE"
    description: "A lightweight desktop environment"
EOF

    # desktop-packages.conf
    tee "$MODULES_DIR/desktop-packages.conf" > /dev/null <<EOF
---
type: "contextualprocess"
pretty_name: "Installing desktop environment..."
contextualprocess:
  kde:
    - command: "apt-get update && apt-get install -y plasma-desktop sddm konsole dolphin kate kwrite ark gwenview okular"
  gnome:
    - command: "apt-get update && apt-get install -y gnome-shell gdm3 gnome-terminal nautilus gedit eog evince"
  xfce:
    - command: "apt-get update && apt-get install -y xfce4 xfce4-terminal thunar mousepad ristretto xfce4-screenshooter"
EOF

    # branding.desc
    tee "$BRAND_DIR/branding.desc" > /dev/null <<EOF
---
componentName: chlorine
welcomeStyleCalamares: true
welcomeExpandingLogo: true
strings:
  productName: Chlorine Linux
  shortProductName: Chlorine
  version: 1.0
  shortVersion: 1.0
  versionedName: Chlorine Linux 1.0
  shortVersionedName: Chlorine 1.0
  bootloaderEntryName: Chlorine
  productUrl: https://github.com/yourusername/chlorine
  supportUrl: https://github.com/yourusername/chlorine/issues
  welcomeMessage: "Chlorine -- clean yourself u sweaty piece of shit"
images:
  productLogo: "/usr/share/chlorine-branding/logo.svg"
  productIcon: "/usr/share/chlorine-branding/logo.svg"
  productWelcome: "/usr/share/chlorine-branding/background.svg"
slideshow: "show.qml"
style:
  sidebarBackground: "#2d2d2d"
  sidebarText: "#FFFFFF"
  sidebarTextSelect: "#4DD0E1"
EOF

    # show.qml
    tee "$BRAND_DIR/show.qml" > /dev/null <<EOF
import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation {
    id: presentation
    Timer {
        interval: 20000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }
    Slide {
        Image {
            id: background1
            source: "/usr/share/chlorine-branding/background.svg"
            width: 800; height: 450
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: background1.bottom
            anchors.topMargin: 20
            text: "Welcome to Chlorine Linux"
            color: "#4DD0E1"
            font.pixelSize: 22
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            text: "A lightweight Debian-based Linux distribution designed for developers and security professionals."
            color: "white"
            font.pixelSize: 16
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }
}
EOF

    mkdir -p "$CONFIG_DIR/package-lists/"
    echo "calamares calamares-settings-debian" > "$CONFIG_DIR/package-lists/calamares.list.chroot"

    log_info "Calamares setup complete."
}

configure_autologin() {
    log_info "Configuring auto-login..."
    AUTOLOGIN_DIR="$CONFIG_DIR/includes.chroot/etc/systemd/system/getty@tty1.service.d"
    mkdir -p "$AUTOLOGIN_DIR"
    tee "$AUTOLOGIN_DIR/override.conf" > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I \$TERM
EOF
    log_info "Auto-login configured."
}

configure_kernel() {
    log_info "Setting up custom kernel..."
    HOOK_DIR="$CONFIG_DIR/hooks/live"
    mkdir -p "$HOOK_DIR"
    tee "$HOOK_DIR/0100-install-kernel.hook.chroot" > /dev/null <<EOF
#!/bin/bash
set -e
apt-get update
apt-get install -y linux-image-amd64 linux-headers-amd64 firmware-linux firmware-linux-nonfree
update-initramfs -u -k all
EOF
    chmod +x "$HOOK_DIR/0100-install-kernel.hook.chroot"
    log_info "Kernel hook installed."
}

run_live_build() {
    log_info "Initializing live-build configuration..."
    lb config \
        --distribution bookworm \
        --archive-areas "main contrib non-free non-free-firmware" \
        --apt-indices false \
        --apt-recommends false \
        --debian-installer none \
        --mirror-bootstrap http://deb.debian.org/debian/ \
        --mirror-binary http://deb.debian.org/debian/ \
        --mirror-binary-security http://security.debian.org/debian-security/ \
        --mirror-chroot http://deb.debian.org/debian/ \
        --mirror-chroot-security http://security.debian.org/debian-security/ \
        --debootstrap-options "--keyring=/usr/share/keyrings/debian-archive-keyring.gpg" \
        --binary-filesystem ext4 \
        --binary-images iso-hybrid \
        --compression gzip
}

main() {
    log_info "Starting Chlorine Linux customization..."
    prompt_desktop_choice
    setup_calamares
    configure_autologin
    configure_kernel
    run_live_build
    log_info "Customization finished."
}

main "$@"
