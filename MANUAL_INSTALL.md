# Chlorine Linux Manual Installation Guide

This guide explains how to manually install Chlorine Linux if the Calamares installer doesn't work in the live environment.

## Prerequisites

Before starting the manual installation, you should:

1. Boot into the Chlorine Linux live environment from your USB drive
2. Make sure you have an internet connection
3. Use GParted or GNOME Disks to create a partition for installation
4. Note the device name of the partition (e.g., /dev/sda1)

## Using the Manual Installation Script

The manual installation script provides a guided, interactive way to install Chlorine Linux.

### Step 1: Open a Terminal

Open a terminal in the live environment.

### Step 2: Run the Manual Installation Script

Run the following command:

```bash
sudo bash /path/to/manual-install.sh
```

Replace `/path/to/` with the actual path to the script. If you're running from the USB drive, it might be in a location like `/cdrom/manual-install.sh` or `/run/live/medium/manual-install.sh`.

### Step 3: Follow the Interactive Prompts

The script will guide you through the installation process:

1. Select the target partition
2. Choose a filesystem (ext4, btrfs, or xfs)
3. Select a desktop environment
4. Choose a display manager
5. Set hostname and username
6. Create a password

### Step 4: Confirm and Install

Review your choices and type "yes" to confirm and start the installation.

## Manual Installation Without the Script

If the script doesn't work, you can follow these manual steps:

### 1. Format and Mount the Target Partition

```bash
# Format the partition (replace /dev/sdXY with your target partition)
sudo mkfs.ext4 /dev/sdXY

# Mount the partition
sudo mount /dev/sdXY /mnt
```

### 2. Copy the Live System to the Target Partition

```bash
sudo rsync -av --exclude='/mnt' --exclude='/proc' --exclude='/sys' --exclude='/dev' --exclude='/run' --exclude='/media' --exclude='/tmp' / /mnt/
```

### 3. Create Necessary Directories

```bash
sudo mkdir -p /mnt/{proc,sys,dev,run,media,tmp}
```

### 4. Create fstab

```bash
UUID=$(sudo blkid -s UUID -o value /dev/sdXY)
echo "UUID=$UUID / ext4 defaults 0 1" | sudo tee /mnt/etc/fstab
```

### 5. Set Hostname

```bash
echo "chlorine" | sudo tee /mnt/etc/hostname
echo "127.0.1.1 chlorine" | sudo tee -a /mnt/etc/hosts
```

### 6. Create User

```bash
sudo chroot /mnt useradd -m -s /bin/bash username
echo "username:password" | sudo chroot /mnt chpasswd
sudo chroot /mnt usermod -aG sudo,audio,video,netdev,plugdev username
```

### 7. Set Root Password

```bash
echo "root:password" | sudo chroot /mnt chpasswd
```

### 8. Install GRUB Bootloader

```bash
DISK=$(echo "/dev/sdXY" | sed 's/[0-9]*$//')
sudo chroot /mnt apt-get install -y grub-pc
sudo chroot /mnt grub-install "$DISK"
sudo chroot /mnt update-grub
```

### 9. Unmount and Reboot

```bash
sudo umount /mnt
sudo reboot
```

## Troubleshooting

If you encounter issues during installation:

1. **Bootloader Problems**: Make sure you're installing GRUB to the disk (e.g., /dev/sda), not the partition (e.g., /dev/sda1)
2. **Missing Packages**: If the system can't find certain packages, make sure you have an internet connection in the chroot environment
3. **Filesystem Errors**: Try a different filesystem if you encounter errors with your first choice

## Getting Help

If you need assistance, visit the Chlorine Linux community forums or file an issue on our GitHub repository.

---

Good luck with your installation!