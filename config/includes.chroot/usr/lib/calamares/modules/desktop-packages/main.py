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
