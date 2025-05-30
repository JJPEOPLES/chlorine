#!/bin/bash
#
# Fix for Calamares modules desktop@desktop and desktop-packages@desktop-packages
# This script fixes issues with these modules by creating proper Python modules

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

# Fix desktop module
fix_desktop_module() {
    log_info "Fixing desktop@desktop module..."
    
    # Create directory if it doesn't exist
    mkdir -p config/includes.chroot/usr/lib/calamares/modules/desktop
    
    # Create module.desc
    cat > config/includes.chroot/usr/lib/calamares/modules/desktop/module.desc << EOF
---
type: "view"
name: "desktop"
interface: "python"
script: "main.py"
EOF
    
    # Create main.py
    cat > config/includes.chroot/usr/lib/calamares/modules/desktop/main.py << EOF
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import libcalamares
from libcalamares.ui.helpers import *
from PySide2.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QLabel,
    QRadioButton,
    QButtonGroup,
    QSpacerItem,
    QSizePolicy
)

class DesktopPage(QWidget):
    def __init__(self):
        super().__init__()
        
        # Set up the UI
        self.setLayout(QVBoxLayout())
        
        # Add title
        title = QLabel("Choose your desktop environment")
        title.setStyleSheet("font-size: 18pt; font-weight: bold;")
        self.layout().addWidget(title)
        
        # Add description
        description = QLabel("Select the desktop environment you want to install:")
        self.layout().addWidget(description)
        
        # Create button group
        self.button_group = QButtonGroup(self)
        
        # KDE option
        self.kde_radio = QRadioButton("KDE Plasma - A modern, feature-rich desktop environment")
        self.kde_radio.setChecked(True)
        self.layout().addWidget(self.kde_radio)
        self.button_group.addButton(self.kde_radio, 1)
        
        # GNOME option
        self.gnome_radio = QRadioButton("GNOME - A simple, elegant desktop environment")
        self.layout().addWidget(self.gnome_radio)
        self.button_group.addButton(self.gnome_radio, 2)
        
        # XFCE option
        self.xfce_radio = QRadioButton("XFCE - A lightweight desktop environment")
        self.layout().addWidget(self.xfce_radio)
        self.button_group.addButton(self.xfce_radio, 3)
        
        # Add spacer
        spacer = QSpacerItem(20, 40, QSizePolicy.Minimum, QSizePolicy.Expanding)
        self.layout().addItem(spacer)

def run():
    return None

def get_desktop_choice():
    if DesktopPage.kde_radio.isChecked():
        return "kde"
    elif DesktopPage.gnome_radio.isChecked():
        return "gnome"
    else:
        return "xfce"

def create_widget():
    return DesktopPage()

def next_clicked():
    # Get the selected desktop environment
    if DesktopPage.kde_radio.isChecked():
        desktop_env = "kde"
    elif DesktopPage.gnome_radio.isChecked():
        desktop_env = "gnome"
    else:
        desktop_env = "xfce"
    
    # Save it to a file
    with open("/tmp/desktop_choice", "w") as f:
        f.write(desktop_env)
    
    # Run the setup script
    os.system("/usr/bin/setup-desktop-packages")
    
    return None
EOF
    
    # Make the script executable
    chmod +x config/includes.chroot/usr/lib/calamares/modules/desktop/main.py
    
    log_info "desktop@desktop module fixed successfully."
}

# Fix desktop-packages module
fix_desktop_packages_module() {
    log_info "Fixing desktop-packages@desktop-packages module..."
    
    # Create directory if it doesn't exist
    mkdir -p config/includes.chroot/usr/lib/calamares/modules/desktop-packages
    
    # Create module.desc
    cat > config/includes.chroot/usr/lib/calamares/modules/desktop-packages/module.desc << EOF
---
type: "job"
name: "desktop-packages"
interface: "python"
script: "main.py"
EOF
    
    # Create main.py
    cat > config/includes.chroot/usr/lib/calamares/modules/desktop-packages/main.py << EOF
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import libcalamares

def run():
    """
    Set up the desktop packages for installation
    """
    # Run the setup script again to make sure
    os.system("/usr/bin/setup-desktop-packages")
    
    # Read the packages from the config file
    with open("/tmp/desktop_packages.conf", "r") as f:
        exec(f.read())
    
    # Set the packages in the global storage
    libcalamares.globalstorage.insert("packageOperations", [{"install": DESKTOP_PACKAGES.split()}])
    
    return None
EOF
    
    # Make the script executable
    chmod +x config/includes.chroot/usr/lib/calamares/modules/desktop-packages/main.py
    
    log_info "desktop-packages@desktop-packages module fixed successfully."
}

# Create setup-desktop-packages script
create_setup_script() {
    log_info "Creating setup-desktop-packages script..."
    
    # Create directory if it doesn't exist
    mkdir -p config/includes.chroot/usr/bin
    
    # Create the script
    cat > config/includes.chroot/usr/bin/setup-desktop-packages << EOF
#!/bin/bash

# This script sets up the desktop packages based on the user's selection in Calamares

# Get the selected desktop environment from Calamares
DESKTOP_ENV=\$(cat /tmp/desktop_choice 2>/dev/null || echo "kde")

# Set the packages based on the desktop environment
case "\$DESKTOP_ENV" in
    kde)
        PACKAGES="plasma-desktop sddm konsole dolphin kate kwrite ark gwenview okular"
        ;;
    gnome)
        PACKAGES="gnome-shell gdm3 gnome-terminal nautilus gedit eog evince"
        ;;
    xfce|*)
        PACKAGES="xfce4 xfce4-terminal thunar mousepad ristretto xfce4-screenshooter"
        ;;
esac

# Export the packages for Calamares to use
echo "DESKTOP_PACKAGES=\"\$PACKAGES\"" > /tmp/desktop_packages.conf

echo "Desktop packages set to: \$PACKAGES"
EOF
    
    # Make the script executable
    chmod +x config/includes.chroot/usr/bin/setup-desktop-packages
    
    log_info "setup-desktop-packages script created successfully."
}

# Update Calamares settings
update_calamares_settings() {
    log_info "Updating Calamares settings..."
    
    # Create directory if it doesn't exist
    mkdir -p config/includes.chroot/etc/calamares
    
    # Create settings.conf
    cat > config/includes.chroot/etc/calamares/settings.conf << EOF
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
    
    log_info "Calamares settings updated successfully."
}

# Main function
main() {
    log_info "Starting Calamares module fixes..."
    
    fix_desktop_module
    fix_desktop_packages_module
    create_setup_script
    update_calamares_settings
    
    log_info "All Calamares module fixes completed successfully!"
    log_info "You can now rebuild the ISO with these fixes applied."
}

# Run the main function
main "$@"