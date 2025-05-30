#!/bin/bash
#
# Live environment configuration script for Chlorine Linux
# This script configures the live environment settings

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_ROOT/config"

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

# Configure live environment settings
configure_live_settings() {
    log_info "Configuring live environment settings..."
    
    # Create directory for live settings
    mkdir -p "$CONFIG_DIR/includes.chroot/etc/live/config"
    
    # Configure hostname
    echo "chlorine-live" > "$CONFIG_DIR/includes.chroot/etc/hostname"
    
    # Configure hosts file
    cat > "$CONFIG_DIR/includes.chroot/etc/hosts" << EOF
127.0.0.1       localhost
127.0.1.1       chlorine-live

# The following lines are desirable for IPv6 capable hosts
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF
    
    # Configure auto-login for root in live environment
    mkdir -p "$CONFIG_DIR/includes.chroot/etc/systemd/system/getty@tty1.service.d/"
    cat > "$CONFIG_DIR/includes.chroot/etc/systemd/system/getty@tty1.service.d/override.conf" << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I $TERM
EOF
    
    # Configure live user settings
    mkdir -p "$CONFIG_DIR/includes.chroot/etc/live/config/"
    cat > "$CONFIG_DIR/includes.chroot/etc/live/config/user-setup.conf" << EOF
# Live user configuration
LIVE_USER_DEFAULT_GROUPS="audio cdrom dip floppy video plugdev netdev powerdev scanner bluetooth sudo"
LIVE_USER_FULLNAME="Chlorine Live User"
EOF
    
    log_info "Live environment settings configured successfully."
}

# Configure desktop environment for live session
configure_live_desktop() {
    log_info "Configuring desktop environment for live session..."
    
    # Create directory for desktop configuration
    mkdir -p "$CONFIG_DIR/includes.chroot/etc/skel/.config"
    
    # Configure KDE Plasma (default)
    mkdir -p "$CONFIG_DIR/includes.chroot/etc/skel/.config/plasma-workspace/env"
    cat > "$CONFIG_DIR/includes.chroot/etc/skel/.config/plasma-workspace/env/live-session.sh" << EOF
#!/bin/sh
# Configure KDE for live session

# Set desktop background
if [ -f /usr/share/wallpapers/chlorine/contents/images/1920x1080.jpg ]; then
    dbus-send --session --dest=org.kde.plasmashell --type=method_call /PlasmaShell org.kde.PlasmaShell.evaluateScript 'string:
        var allDesktops = desktops();
        for (i=0;i<allDesktops.length;i++) {
            d = allDesktops[i];
            d.wallpaperPlugin = "org.kde.image";
            d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
            d.writeConfig("Image", "file:///usr/share/wallpapers/chlorine/contents/images/1920x1080.jpg");
        }
    '
fi

# Add installer icon to desktop
mkdir -p ~/Desktop
cat > ~/Desktop/installer.desktop << EOL
[Desktop Entry]
Type=Application
Name=Install Chlorine Linux
Comment=Chlorine -- clean yourself u sweaty piece of shit
Exec=sudo calamares
Icon=system-software-install
Terminal=false
Categories=System;
EOL
chmod +x ~/Desktop/installer.desktop
EOF
    chmod +x "$CONFIG_DIR/includes.chroot/etc/skel/.config/plasma-workspace/env/live-session.sh"
    
    # Configure GNOME
    mkdir -p "$CONFIG_DIR/includes.chroot/etc/skel/.config/autostart"
    cat > "$CONFIG_DIR/includes.chroot/etc/skel/.config/autostart/live-session-gnome.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Live Session Setup
Comment=Configure GNOME for live session
Exec=/usr/local/bin/live-session-gnome.sh
Terminal=false
Hidden=true
X-GNOME-Autostart-enabled=true
EOF
    
    mkdir -p "$CONFIG_DIR/includes.chroot/usr/local/bin"
    cat > "$CONFIG_DIR/includes.chroot/usr/local/bin/live-session-gnome.sh" << EOF
#!/bin/sh
# Configure GNOME for live session

# Set desktop background
if [ -f /usr/share/backgrounds/chlorine.jpg ]; then
    gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/chlorine.jpg
fi

# Add installer icon to desktop
mkdir -p ~/Desktop
cat > ~/Desktop/installer.desktop << EOL
[Desktop Entry]
Type=Application
Name=Install Chlorine Linux
Comment=Chlorine -- clean yourself u sweaty piece of shit
Exec=sudo calamares
Icon=system-software-install
Terminal=false
Categories=System;
EOL
chmod +x ~/Desktop/installer.desktop

# Enable desktop icons
gsettings set org.gnome.desktop.background show-desktop-icons true
EOF
    chmod +x "$CONFIG_DIR/includes.chroot/usr/local/bin/live-session-gnome.sh"
    
    # Configure XFCE
    mkdir -p "$CONFIG_DIR/includes.chroot/etc/skel/.config/autostart"
    cat > "$CONFIG_DIR/includes.chroot/etc/skel/.config/autostart/live-session-xfce.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Live Session Setup
Comment=Configure XFCE for live session
Exec=/usr/local/bin/live-session-xfce.sh
Terminal=false
Hidden=true
X-XFCE-Autostart-enabled=true
EOF
    
    cat > "$CONFIG_DIR/includes.chroot/usr/local/bin/live-session-xfce.sh" << EOF
#!/bin/sh
# Configure XFCE for live session

# Set desktop background
if [ -f /usr/share/backgrounds/chlorine.jpg ]; then
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s /usr/share/backgrounds/chlorine.jpg
fi

# Add installer icon to desktop
mkdir -p ~/Desktop
cat > ~/Desktop/installer.desktop << EOL
[Desktop Entry]
Type=Application
Name=Install Chlorine Linux
Comment=Chlorine -- clean yourself u sweaty piece of shit
Exec=sudo calamares
Icon=system-software-install
Terminal=false
Categories=System;
EOL
chmod +x ~/Desktop/installer.desktop
EOF
    chmod +x "$CONFIG_DIR/includes.chroot/usr/local/bin/live-session-xfce.sh"
    
    log_info "Desktop environment for live session configured successfully."
}

# Configure installer launcher
configure_installer_launcher() {
    log_info "Configuring installer launcher..."
    
    # Create directory for installer launcher
    mkdir -p "$CONFIG_DIR/includes.chroot/usr/share/applications"
    
    # Create installer launcher
    cat > "$CONFIG_DIR/includes.chroot/usr/share/applications/chlorine-installer.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Install Chlorine Linux
Comment=Chlorine -- clean yourself u sweaty piece of shit
Exec=sudo calamares
Icon=system-software-install
Terminal=false
Categories=System;
EOF
    
    log_info "Installer launcher configured successfully."
}

# Main function
main() {
    log_info "Starting live environment configuration..."
    
    configure_live_settings
    configure_live_desktop
    configure_installer_launcher
    
    log_info "Live environment configuration completed successfully!"
}

# Run the main function
main "$@"