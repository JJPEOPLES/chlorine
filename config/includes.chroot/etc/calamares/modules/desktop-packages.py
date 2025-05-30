#!/usr/bin/env python3

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
    
    # Add a script to run after installation to set the display manager
    libcalamares.job.setprogress(0.5)
    
    # Create a script to set the display manager based on the desktop choice
    script = [
        "#!/bin/bash",
        "# Run the display manager setup script",
        "/usr/bin/set-display-manager"
    ]
    
    # Add the script to the list of scripts to run
    libcalamares.globalstorage.insert("postinstallCommands", ["\n".join(script)])
    
    return None
