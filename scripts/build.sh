#!/bin/bash
# Chlorine Linux Build Script

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$ROOT_DIR/build"
CONFIG_DIR="$ROOT_DIR/config"
ISO_DIR="$ROOT_DIR/iso"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create necessary directories
mkdir -p "$BUILD_DIR"
mkdir -p "$ISO_DIR"

# Clean the build directory
clean_build_directory() {
    log_info "Cleaning build directory..."
    cd "$BUILD_DIR"
    lb clean --all
    log_info "Build directory cleaned completely."
}

# Set up the build environment
setup_build_environment() {
    log_info "Setting up build environment..."
    cd "$BUILD_DIR"
    
    # Initialize live-build configuration
    log_info "Initializing live-build configuration..."
    lb config \
        --distribution bookworm \
        --archive-areas "main contrib non-free non-free-firmware" \
        --apt-indices false \
        --apt-recommends false \
        --debian-installer none \
        --mirror-bootstrap "http://deb.debian.org/debian/" \
        --mirror-binary "http://deb.debian.org/debian/" \
        --mirror-binary-security "http://security.debian.org/debian-security/" \
        --mirror-chroot "http://deb.debian.org/debian/" \
        --mirror-chroot-security "http://security.debian.org/debian-security/" \
        --debootstrap-options "--keyring=/usr/share/keyrings/debian-archive-keyring.gpg" \
        --binary-filesystem ext4 \
        --binary-images iso-hybrid
    
    # Set compression to gzip (valid values are gzip, bzip2, lzma, xz)
    export LB_COMPRESSION="gzip"
    
    # Verify that the configuration was created
    if [ ! -f "config/binary" ]; then
        log_error "Failed to create live-build configuration."
        exit 1
    fi
    
    # Copy our custom configurations
    log_info "Adding custom configurations..."
    if [ -d "$CONFIG_DIR" ]; then
        cp -r "$CONFIG_DIR"/* "$BUILD_DIR"/config/
    fi
    
    # Update binary configuration for squashfs
    log_info "Configuring squashfs options..."
    if [ -f "$BUILD_DIR/config/binary" ]; then
        # Add squashfs options if not already present
        if ! grep -q "LB_SQUASHFS_COMP_OPT" "$BUILD_DIR/config/binary"; then
            echo '# Set squashfs compression options (512K block size for better performance)' >> "$BUILD_DIR/config/binary"
            echo 'LB_SQUASHFS_COMP_OPT="-b 512K -Xcompression-level 9"' >> "$BUILD_DIR/config/binary"
        fi
    fi
    
    # Create squashfs configuration directory
    mkdir -p "$BUILD_DIR/config/includes.chroot_after_packages/etc/"
    
    # Create squashfs configuration file
    log_info "Creating squashfs configuration file..."
    cat > "$BUILD_DIR/config/includes.chroot_after_packages/etc/mksquashfs.conf" << EOL
# Squashfs configuration for Chlorine Linux
# This file configures mksquashfs to use a 512K block size for better performance

# Use 512K block size
-b 512K

# Use maximum compression level
-Xcompression-level 9

# Use all available processors for compression
-processors 0
EOL
    
    # Create hooks directory
    mkdir -p "$BUILD_DIR/config/hooks/live/"
    
    # Create squashfs hook
    log_info "Creating squashfs hook..."
    cat > "$BUILD_DIR/config/hooks/live/0020-configure-squashfs.hook.chroot" << EOL
#!/bin/bash
# Configure squashfs options for Chlorine Linux

set -e

# Create directory if it doesn't exist
mkdir -p /etc

# Create mksquashfs.conf with 512K block size
cat > /etc/mksquashfs.conf << EOLINNER
# Squashfs configuration for Chlorine Linux
# This file configures mksquashfs to use a 512K block size for better performance

# Use 512K block size
-b 512K

# Use maximum compression level
-Xcompression-level 9

# Use all available processors for compression
-processors 0
EOLINNER

echo "SquashFS configured with 512K block size for better performance."
EOL
    chmod +x "$BUILD_DIR/config/hooks/live/0020-configure-squashfs.hook.chroot"
    
    # Verify that the configuration is valid
    log_info "Verifying configuration..."
    if ! lb config --quiet; then
        log_error "Invalid live-build configuration."
        exit 1
    fi
    
    log_info "Build environment set up successfully."
}

# Configure the ISO
configure_iso() {
    log_info "Configuring ISO..."
    # Add any ISO configuration steps here
}

# Build the ISO
build_iso() {
    log_info "Building ISO..."
    cd "$BUILD_DIR"
    
    # Run lb build to create the ISO
    if lb build; then
        # Copy the ISO to the output directory
        if [ -f "$BUILD_DIR/live-image-amd64.hybrid.iso" ]; then
            cp "$BUILD_DIR/live-image-amd64.hybrid.iso" "$ISO_DIR/chlorine-linux.iso"
            log_info "ISO created successfully: $ISO_DIR/chlorine-linux.iso"
        else
            log_error "ISO file not found after build."
            exit 1
        fi
    else
        log_error "Failed to build ISO."
        exit 1
    fi
}

# Main function
main() {
    log_info "Starting Chlorine Linux build process..."
    
    # Clean the build directory
    clean_build_directory
    
    # Set up the build environment
    setup_build_environment
    
    # Run lb config to ensure the configuration is properly set up
    cd "$BUILD_DIR"
    log_info "Verifying configuration..."
    lb config
    
    # Configure the ISO
    configure_iso
    
    # Run the customize-installer script to set up Calamares
    if [ -f "$SCRIPT_DIR/customize-installer.sh" ]; then
        log_info "Setting up Calamares installer..."
        bash "$SCRIPT_DIR/customize-installer.sh"
    else
        log_warn "customize-installer.sh not found. Skipping Calamares setup."
    fi
    
    # Run lb config again to ensure all configuration is properly set up
    cd "$BUILD_DIR"
    log_info "Finalizing configuration..."
    lb config \
        --binary-filesystem ext4 \
        --binary-images iso-hybrid
    
    # Build the ISO
    build_iso
    
    log_info "Chlorine Linux build process completed successfully."
}

# Run the main function
main "$@"
