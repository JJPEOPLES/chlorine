# Ruuf Integration with Chlorine Linux

This document describes how Ruuf (Rufus for Linux) has been integrated into Chlorine Linux.

## Overview

Ruuf is a Linux alternative to the popular Windows USB ISO flasher Rufus. It has been integrated into Chlorine Linux to provide an easy way to create bootable USB drives.

## Integration Components

Ruuf is integrated into Chlorine Linux through the following components:

1. **Installation Script**: `/usr/local/bin/install-ruuf`
   - Installs dependencies
   - Clones the repository
   - Sets up the wrapper script

2. **Wrapper Script**: `/usr/local/bin/ruuf`
   - Provides a simple way to run ruuf from anywhere

3. **Desktop Entry**: `/usr/share/applications/ruuf.desktop`
   - Makes ruuf accessible from the application menu

4. **PolicyKit Policy**: `/usr/share/polkit-1/actions/org.chlorinelinux.ruuf.policy`
   - Allows running ruuf with elevated privileges

5. **Installation Hook**: `/config/hooks/live/0100-install-ruuf.hook.chroot`
   - Ensures ruuf is installed during system setup

## Installation Process

During the Chlorine Linux build process, the following steps are performed:

1. The installation hook (`0100-install-ruuf.hook.chroot`) is executed
2. The hook runs the installation script (`install-ruuf`)
3. The installation script:
   - Installs dependencies
   - Clones the Ruuf repository
   - Creates the wrapper script
   - Makes the wrapper script executable

## Usage

After installation, users can run Ruuf in two ways:

1. From the application menu: Look for "Ruuf" in the System or Utilities category
2. From the terminal: Run the command `ruuf`

Both methods will prompt for administrator privileges when needed.

## Source Code

The source code for Ruuf is available at: https://github.com/JJPEOPLES/Ruuf-

## Maintenance

To update the Ruuf integration:

1. Update the repository URL in the installation script if needed
2. Modify the wrapper script if the main script name or location changes
3. Update the PolicyKit policy if the permissions model changes

## License

See the LICENSE file in the Ruuf repository for licensing information.