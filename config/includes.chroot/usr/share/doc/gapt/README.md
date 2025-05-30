# GAPT - GUI Frontend for APT

GAPT is a simple wrapper around APT that provides a graphical user interface for package management in Chlorine Linux.

## Usage

### GUI Mode
To launch the graphical interface:
```
gapt
```
or
```
gapt gui
```

This will open Synaptic Package Manager, which allows you to:
- Browse available packages
- Install new packages
- Remove existing packages
- Upgrade your system
- Search for packages

### Command Line Mode
GAPT also works as a drop-in replacement for apt:
```
gapt install firefox
gapt remove gimp
gapt update
gapt upgrade
```

## Features
- User-friendly graphical interface
- Command-line compatibility with apt
- Desktop shortcut for easy access
- Bash completion for commands

## Package Managers Included in Chlorine Linux
- Synaptic - Full-featured graphical package manager
- GDebi - Simple package installer for .deb files
- GNOME Software - Application-centric package manager for GNOME
- KDE Discover - Application-centric package manager for KDE
- Aptitude - Text-based package manager

## About
GAPT is part of Chlorine Linux, designed to make package management easier for users.
