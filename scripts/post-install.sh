#!/bin/bash
#
# Post-installation script for Chlorine Linux
# This script is executed after the system is installed

set -e

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

# Configure development environment
setup_dev_environment() {
    log_info "Setting up development environment..."
    
    # Install common development tools
    apt-get update
    apt-get install -y \
        build-essential \
        git \
        vim \
        nano \
        curl \
        wget \
        python3 \
        python3-pip \
        nodejs \
        npm \
        gcc \
        g++ \
        gdb \
        make \
        cmake
    
    # Set up Git configuration
    git config --system core.editor "nano"
    
    log_info "Development environment set up successfully."
}

# Configure security tools
setup_security_tools() {
    log_info "Setting up security tools..."
    
    # Install common security tools
    apt-get update
    apt-get install -y \
        nmap \
        wireshark \
        tcpdump \
        netcat \
        aircrack-ng \
        john \
        hashcat \
        hydra \
        sqlmap \
        metasploit-framework
    
    log_info "Security tools set up successfully."
}

# Configure system settings
configure_system() {
    log_info "Configuring system settings..."
    
    # Set hostname
    echo "chlorine" > /etc/hostname
    
    # Configure hosts file
    cat > /etc/hosts << EOF
127.0.0.1       localhost
127.0.1.1       chlorine

# The following lines are desirable for IPv6 capable hosts
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF
    
    # Configure timezone
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime
    
    # Configure locale
    locale-gen en_US.UTF-8
    update-locale LANG=en_US.UTF-8
    
    log_info "System settings configured successfully."
}

# Configure desktop environment
configure_desktop() {
    log_info "Configuring desktop environment..."
    
    # Set up KDE Plasma theme (if installed)
    if [ -d "/usr/share/plasma" ]; then
        # Install Breeze Dark theme
        apt-get install -y breeze-gtk-theme
        
        # Configure KDE to use Breeze Dark
        if [ -d "/etc/skel/.config" ]; then
            mkdir -p /etc/skel/.config/
            
            # Create KDE color scheme configuration
            cat > /etc/skel/.config/kdeglobals << EOF
[General]
ColorScheme=BreezeDark

[KDE]
LookAndFeelPackage=org.kde.breezedark.desktop
EOF
        fi
    fi
    
    # Set up GNOME theme (if installed)
    if [ -d "/usr/share/gnome-shell" ]; then
        # Install GNOME dark theme
        apt-get install -y gnome-themes-extra
        
        # Configure GNOME to use dark theme
        if [ -d "/etc/skel/.config" ]; then
            mkdir -p /etc/skel/.config/gtk-3.0/
            
            # Create GTK configuration
            cat > /etc/skel/.config/gtk-3.0/settings.ini << EOF
[Settings]
gtk-application-prefer-dark-theme=1
EOF
        fi
    fi
    
    # Set up XFCE theme (if installed)
    if [ -d "/usr/share/xfce4" ]; then
        # Install XFCE dark theme
        apt-get install -y greybird-gtk-theme
        
        # Configure XFCE to use dark theme
        if [ -d "/etc/skel/.config" ]; then
            mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/
            
            # Create XFCE configuration
            cat > /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Greybird"/>
    <property name="IconThemeName" type="string" value="elementary-xfce-dark"/>
  </property>
</channel>
EOF
        fi
    fi
    
    log_info "Desktop environment configured successfully."
}

# Main function
main() {
    log_info "Starting post-installation configuration..."
    
    setup_dev_environment
    setup_security_tools
    configure_system
    configure_desktop
    
    log_info "Post-installation configuration completed successfully!"
}

# Run the main function
main "$@"