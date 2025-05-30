# Chlorine Linux - Project Summary

## Overview

Chlorine Linux is a lightweight Ubuntu-based Linux distribution designed for developers and security professionals. It combines the ease of use of distributions like Linux Mint with powerful development and security tools.

> **Chlorine -- clean yourself u sweaty piece of shit**

## Key Components

### Build System

- `install.sh`: Main installation script that orchestrates the entire build process
- `scripts/build.sh`: Script to build the ISO image
- `scripts/customize-installer.sh`: Script to customize the Calamares installer
- `scripts/post-install.sh`: Script for post-installation configuration

### Configuration

- `config/kernel-config.sh`: Script to configure and build the custom kernel
- `config/live-config.sh`: Script to configure the live environment
- `config/logo.svg`: Logo for the distribution

### Documentation

- `docs/BUILD.md`: Instructions for building the distribution
- `docs/USER_GUIDE.md`: User guide for the distribution

## Features

1. **Base System**
   - Debian 12 (Bookworm) base
   - Custom 6.x kernel
   - Lightweight configuration

2. **Installation**
   - GUI installer (Calamares)
   - Desktop environment selection (KDE, GNOME, XFCE)
   - Automatic partitioning
   - User account creation

3. **Desktop Environments**
   - KDE Plasma (default)
   - GNOME
   - XFCE

4. **Development Tools**
   - Build essentials (gcc, g++, make)
   - Git for version control
   - Python 3 with pip
   - Node.js and npm
   - Various text editors and IDEs

5. **Security Tools**
   - Nmap for network scanning
   - Wireshark for packet analysis
   - Metasploit Framework
   - Various password cracking and penetration testing tools

## Building the Distribution

To build the distribution:

1. Install the required dependencies
2. Run the `install.sh` script as root
3. The ISO will be created in the `iso/` directory

## Next Steps

1. **Testing**: Test the distribution in a virtual machine
2. **Refinement**: Refine the configuration based on testing
3. **Documentation**: Expand the documentation
4. **Community**: Build a community around the distribution
5. **Updates**: Establish an update mechanism