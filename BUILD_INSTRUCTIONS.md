# Chlorine Linux Build Instructions

This guide explains how to build Chlorine Linux from source using the fixed build script and how to upload ISO files to a storage service.

## Prerequisites

Before starting the build process, make sure you have the following:

1. A Debian-based system (Debian, Ubuntu, etc.)
2. Sufficient disk space (at least 10GB)
3. Required dependencies installed (the script will check and prompt you to install them)
4. Root or sudo access

## Building Chlorine Linux

### Step 1: Clone the Repository

```bash
git clone https://github.com/JJPEOPLES/chlorine.git
cd chlorine
```

### Step 2: Run the Clean Build Script

Use the clean build script to avoid issues with the `includes.chroot_after_packages` directory:

```bash
./scripts/clean-build.sh
```

The script will:
1. Clean up any problematic directories
2. Check for required dependencies
3. Set up the build environment
4. Configure the ISO
5. Build the ISO image

If you encounter any issues with the clean build script, you can try running the fixed build script directly:

```bash
sudo ./scripts/build-fixed.sh
```

### Step 3: Find the ISO

Once the build process completes successfully, you'll find the ISO file at:

```
/path/to/chlorine/iso/chlorine-linux.iso
```

## Uploading ISO Files

For distributing ISO files, we use a separate upload mechanism instead of storing them in the Git repository.

### Step 1: Run the Upload Script

```bash
./scripts/upload-iso.sh
```

The script will:
1. Check if rclone is installed (and help you install it if needed)
2. Guide you through configuring a remote storage service (first time only)
3. Upload all ISO files from the `iso` directory
4. Generate and upload SHA256 checksums
5. Create a listing of available ISO files

## Troubleshooting

If you encounter issues during the build process:

1. **Dependency Issues**: Make sure all required dependencies are installed
2. **Permission Problems**: Ensure you're running the script with sudo
3. **Disk Space**: Verify you have enough free disk space
4. **Build Errors**: Check the build logs for specific error messages

## Writing the ISO to a USB Drive

After building the ISO, you can write it to a USB drive using:

```bash
sudo dd if=/path/to/chlorine/iso/chlorine-linux.iso of=/dev/sdX bs=4M status=progress
```

Replace `/dev/sdX` with your USB drive device (be careful to use the correct device!).

## Testing in a Virtual Machine

You can also test the ISO in a virtual machine:

```bash
qemu-system-x86_64 -cdrom /path/to/chlorine/iso/chlorine-linux.iso -m 2G
```

---

If you need assistance, visit the Chlorine Linux community forums or file an issue on our GitHub repository.