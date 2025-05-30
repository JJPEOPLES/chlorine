#!/usr/bin/env python3

import os
import libcalamares

def run():
    """
    Save the selected desktop environment to a file
    """
    # Get the selected desktop environment
    desktop_env = libcalamares.globalstorage.value("packagechooser_packagechooser")
    
    # Save it to a file
    with open("/tmp/desktop_choice", "w") as f:
        f.write(desktop_env)
    
    # Run the setup script
    os.system("/usr/bin/setup-desktop-packages")
    
    return None
