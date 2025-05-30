# Building Chlorine Linux

This document explains how to build Chlorine Linux from source.

## Prerequisites

You need a Debian-based system with the following packages installed:

```bash
sudo apt update
sudo apt install -y \
    debootstrap \
    squashfs-tools \
    xorriso \
    isolinux \
    syslinux-utils \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    dosfstools \
    live-build
```

## Building the ISO

1. Clone the repository:

```bash
git clone https://github.com/yourusername/chlorine.git
cd chlorine
```

2. Make the scripts executable:

```bash
chmod +x scripts/*.sh
```

3. Run the build script:

```bash
./scripts/build.sh
```

The build process will:
- Set up the build environment
- Configure the ISO settings with Debian Bookworm repositories
- Customize the installer
- Build the ISO image

> **Note:** The build script has been configured to preserve your existing configuration. It will not run `lb clean` which would remove your configuration files.

The Debian repositories used are:
```
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free
deb http://deb.debian.org/debian bookworm-updates main contrib non-free
```

When the build is complete, the ISO file will be available in the `iso/` directory.

## Customizing the Build

### Changing the Kernel

To use a different kernel, modify the `scripts/customize-installer.sh` file and update the URL in the `configure_kernel` function to point to your kernel package.

### Adding Packages

To add more packages to the distribution, modify the package lists in the `config/package-lists/` directory.

### Customizing the Installer

The installer configuration is in the `scripts/customize-installer.sh` file. You can modify the Calamares configuration to change the installation process.

## Testing the ISO

You can test the ISO using a virtual machine like QEMU or VirtualBox:

```bash
# Using QEMU
qemu-system-x86_64 -cdrom iso/chlorine-linux.iso -m 2G

# Using VirtualBox
VBoxManage createvm --name "Chlorine Linux Test" --ostype Ubuntu_64 --register
VBoxManage modifyvm "Chlorine Linux Test" --memory 2048 --vram 128
VBoxManage storagectl "Chlorine Linux Test" --name "IDE Controller" --add ide
VBoxManage storageattach "Chlorine Linux Test" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium iso/chlorine-linux.iso
VBoxManage startvm "Chlorine Linux Test"
```