#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Calamares module for handling desktop environment packages
# This script ensures that the selected desktop environment packages are installed

import libcalamares
import os
import subprocess
from libcalamares.utils import debug, warning

def run():
    """
    Install the selected desktop environment packages
    :return:
    """
    # Get the selected desktop environment from packagechooser
    desktop_environment = libcalamares.globalstorage.value("packagechooser_packagechooser")
    
    if not desktop_environment:
        debug("No desktop environment selected, using default (xfce)")
        desktop_environment = "xfce"
    
    # Define package lists for each desktop environment
    desktop_packages = {
        "xfce": [
            "xfce4", "xfce4-goodies", "lightdm", "lightdm-gtk-greeter"
        ],
        "kde": [
            "kde-plasma-desktop", "plasma-nm", "sddm"
        ],
        "gnome": [
            "gnome-core", "gnome-shell", "gdm3"
        ],
        "lxde": [
            "lxde", "lxde-core", "lightdm", "lightdm-gtk-greeter"
        ],
        "lxqt": [
            "lxqt", "lxqt-core", "sddm"
        ],
        "mate": [
            "mate-desktop-environment", "lightdm", "lightdm-gtk-greeter"
        ],
        "cinnamon": [
            "cinnamon-desktop-environment", "lightdm", "lightdm-gtk-greeter"
        ],
        "budgie": [
            "budgie-desktop", "lightdm", "lightdm-gtk-greeter"
        ]
    }
    
    # Get the packages for the selected desktop environment
    packages = desktop_packages.get(desktop_environment, desktop_packages["xfce"])
    
    # Add the packages to the list of packages to install
    libcalamares.globalstorage.insert("packageOperations", [
        {
            "install": packages
        }
    ])
    
    # Set the display manager based on the desktop environment
    if desktop_environment in ["kde", "lxqt"]:
        dm = "sddm"
    elif desktop_environment == "gnome":
        dm = "gdm3"
    else:
        dm = "lightdm"
    
    # Configure the display manager
    try:
        with open("/etc/X11/default-display-manager", "w") as f:
            f.write(f"/usr/sbin/{dm}\n")
    except Exception as e:
        warning(f"Failed to set default display manager: {e}")
    
    return None
