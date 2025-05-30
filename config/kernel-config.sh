#!/bin/bash
#
# Kernel configuration script for Chlorine Linux
# This script downloads and configures the kernel

set -e

# This script is meant to be run as a hook during the build process
# It will be copied to the hooks directory by customize-installer.sh

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Log functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Download kernel source
download_kernel() {
    log_info "Downloading kernel source..."
    
    # Create directory for kernel source
    mkdir -p /tmp/kernel-build
    cd /tmp/kernel-build
    
    # Download kernel source (Linux 6.x)
    wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.12.tar.xz
    tar -xf linux-6.12.tar.xz
    cd linux-6.12
    
    log_info "Kernel source downloaded successfully."
}

# Configure kernel
configure_kernel() {
    log_info "Configuring kernel..."
    
    # Copy the current kernel configuration as a base
    cp /boot/config-$(uname -r) .config
    
    # Update the configuration for our needs
    make olddefconfig
    
    # Enable/disable specific options
    scripts/config --enable CONFIG_PREEMPT
    scripts/config --enable CONFIG_HZ_1000
    scripts/config --set-val CONFIG_HZ 1000
    
    # Security features
    scripts/config --enable CONFIG_SECURITY
    scripts/config --enable CONFIG_SECURITY_SELINUX
    scripts/config --enable CONFIG_SECURITY_APPARMOR
    
    # Disable debugging options for performance
    scripts/config --disable CONFIG_DEBUG_KERNEL
    scripts/config --disable CONFIG_DEBUG_INFO
    
    # Enable performance options
    scripts/config --enable CONFIG_SMP
    scripts/config --enable CONFIG_SCHED_SMT
    
    log_info "Kernel configured successfully."
}

# Build kernel
build_kernel() {
    log_info "Building kernel..."
    
    # Determine number of CPU cores for parallel build
    CORES=$(nproc)
    
    # Build the kernel
    make -j$CORES
    
    # Build the modules
    make -j$CORES modules
    
    log_info "Kernel built successfully."
}

# Create kernel package
package_kernel() {
    log_info "Creating kernel package..."
    
    # Install build dependencies
    apt-get update
    apt-get install -y build-essential fakeroot libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf
    
    # Create the kernel package
    make -j$CORES deb-pkg
    
    # Move the package to the output directory
    mkdir -p /output
    mv /tmp/kernel-build/*.deb /output/
    
    log_info "Kernel package created successfully."
}

# Main function
main() {
    log_info "Starting kernel build process..."
    
    download_kernel
    configure_kernel
    build_kernel
    package_kernel
    
    log_info "Kernel build process completed successfully!"
}

# Run the main function
main "$@"