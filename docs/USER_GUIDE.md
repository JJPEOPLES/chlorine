# Chlorine Linux User Guide

Welcome to Chlorine Linux, a lightweight Ubuntu-based distribution designed for developers and security professionals.

> **Chlorine -- clean yourself u sweaty piece of shit**

## Installation

1. Download the Chlorine Linux ISO from the releases page.
2. Create a bootable USB drive using a tool like Rufus, Etcher, or dd.
3. Boot from the USB drive.
4. Follow the GUI installer instructions:
   - Select your language and keyboard layout
   - Choose your preferred desktop environment (KDE, GNOME, or XFCE)
   - Configure partitioning
   - Create your user account
   - Complete the installation

## First Boot

On first boot, you will be automatically logged in as the root user. This is intended for initial setup only. We recommend creating a regular user account for daily use.

### Creating a User Account

To create a new user account, open a terminal and run:

```bash
adduser username
# Follow the prompts to set a password and user information

# Add the user to sudo group
usermod -aG sudo username
```

## Desktop Environments

Chlorine Linux comes with your choice of desktop environment:

### KDE Plasma (Default)

KDE Plasma is a feature-rich desktop environment with high customizability. Key applications include:
- Konsole (terminal)
- Dolphin (file manager)
- Kate (text editor)
- System Settings (configuration)

### GNOME

GNOME provides a clean, simple interface focused on minimalism. Key applications include:
- GNOME Terminal
- Nautilus (file manager)
- Gedit (text editor)
- GNOME Settings

### XFCE

XFCE is a lightweight desktop environment that's fast and resource-efficient. Key applications include:
- XFCE Terminal
- Thunar (file manager)
- Mousepad (text editor)
- XFCE Settings Manager

## Development Tools

Chlorine Linux comes with a comprehensive set of development tools:

- Build essentials (gcc, g++, make)
- Git for version control
- Python 3 with pip
- Node.js and npm
- Various text editors and IDEs

## Security Tools

For security professionals, Chlorine includes:

- Nmap for network scanning
- Wireshark for packet analysis
- Metasploit Framework
- Various password cracking and penetration testing tools

## Customizing Your System

### Updating the System

```bash
apt update
apt upgrade
```

### Installing Additional Software

```bash
apt install package-name
```

### Changing System Settings

Use your desktop environment's settings application to customize appearance, keyboard shortcuts, and other preferences.

## Getting Help

If you encounter issues or have questions:

- Check the documentation in the `/usr/share/doc/chlorine` directory
- Visit our GitHub repository for updates and issue reporting
- Join our community forums for discussion and support