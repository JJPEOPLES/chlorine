#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Calamares module for handling desktop environment configuration
# This script ensures that the selected desktop environment is properly configured

import libcalamares
import os
import subprocess
from libcalamares.utils import debug, warning

def run():
    """
    Configure the selected desktop environment
    :return:
    """
    # Get the selected desktop environment from packagechooser
    desktop_environment = libcalamares.globalstorage.value("packagechooser_packagechooser")
    
    if not desktop_environment:
        debug("No desktop environment selected, using default (xfce)")
        desktop_environment = "xfce"
    
    # Path to the target system
    root_mount_point = libcalamares.globalstorage.value("rootMountPoint")
    
    # Configure the desktop environment
    try:
        # Create a script to run in the target system
        script_path = os.path.join(root_mount_point, "tmp/configure_desktop.sh")
        with open(script_path, "w") as f:
            f.write(f"""#!/bin/bash
# Configure desktop environment: {desktop_environment}

# Set up display manager
if [ -f /etc/X11/default-display-manager ]; then
    case "{desktop_environment}" in
        kde|lxqt)
            echo "/usr/sbin/sddm" > /etc/X11/default-display-manager
            systemctl enable sddm
            ;;
        gnome)
            echo "/usr/sbin/gdm3" > /etc/X11/default-display-manager
            systemctl enable gdm3
            ;;
        *)
            echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager
            systemctl enable lightdm
            ;;
    esac
fi

# Create default user configuration
mkdir -p /etc/skel/.config

# Set default session based on desktop environment
case "{desktop_environment}" in
    xfce)
        mkdir -p /etc/skel/.config/xfce4
        echo "Configured XFCE4 defaults"
        ;;
    kde)
        mkdir -p /etc/skel/.config/plasma-workspace
        echo "Configured KDE Plasma defaults"
        ;;
    gnome)
        mkdir -p /etc/skel/.config/gnome-session
        echo "Configured GNOME defaults"
        ;;
    lxde)
        mkdir -p /etc/skel/.config/lxsession
        echo "Configured LXDE defaults"
        ;;
    lxqt)
        mkdir -p /etc/skel/.config/lxqt
        echo "Configured LXQt defaults"
        ;;
    mate)
        mkdir -p /etc/skel/.config/mate
        echo "Configured MATE defaults"
        ;;
    cinnamon)
        mkdir -p /etc/skel/.config/cinnamon-session
        echo "Configured Cinnamon defaults"
        ;;
    budgie)
        mkdir -p /etc/skel/.config/budgie-desktop
        echo "Configured Budgie defaults"
        ;;
esac

# Make sure desktop environment is installed
if ! dpkg -l | grep -q "{desktop_environment}"; then
    apt-get update
    case "{desktop_environment}" in
        xfce)
            apt-get install -y xfce4 xfce4-goodies
            ;;
        kde)
            apt-get install -y kde-plasma-desktop
            ;;
        gnome)
            apt-get install -y gnome-core
            ;;
        lxde)
            apt-get install -y lxde
            ;;
        lxqt)
            apt-get install -y lxqt
            ;;
        mate)
            apt-get install -y mate-desktop-environment
            ;;
        cinnamon)
            apt-get install -y cinnamon-desktop-environment
            ;;
        budgie)
            apt-get install -y budgie-desktop
            ;;
    esac
fi

echo "Desktop environment {desktop_environment} configured successfully."
exit 0
""")
        
        # Make the script executable
        os.chmod(script_path, 0o755)
        
        # Add the script to the list of chroot scripts to run
        libcalamares.job.setprogress(0.5)
        libcalamares.utils.target_env_call(["/tmp/configure_desktop.sh"])
        libcalamares.job.setprogress(1.0)
        
    except Exception as e:
        warning(f"Failed to configure desktop environment: {e}")
        return f"Failed to configure desktop environment: {e}", f"Error configuring {desktop_environment}"
    
    return None
