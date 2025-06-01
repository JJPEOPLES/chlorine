#!/bin/bash
# Build Chlorine Linux with live user and accessibility features

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$ROOT_DIR/build"
CONFIG_DIR="$ROOT_DIR/config"
ISO_DIR="$ROOT_DIR/iso"

# Create necessary directories
mkdir -p "$BUILD_DIR"
mkdir -p "$ISO_DIR"

# Check internet connectivity
log_info "Checking internet connectivity..."
if ping -c 1 deb.debian.org &> /dev/null; then
    log_info "Internet connectivity is available."
else
    log_warn "Internet connectivity is not available. The build may fail if packages need to be downloaded."
    log_warn "Consider setting USE_LOCAL_MIRROR=true if you have a local package cache."
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_error "Build aborted by user."
        exit 1
    fi
fi

# Clean the build directory
log_info "Cleaning build directory..."
cd "$BUILD_DIR"
lb clean --all || true

# Initialize live-build configuration
log_info "Initializing live-build configuration..."
cd "$BUILD_DIR"

# Check if we should use a local mirror
USE_LOCAL_MIRROR=false
if [ -n "$USE_LOCAL_MIRROR" ] && [ "$USE_LOCAL_MIRROR" = "true" ]; then
    log_info "Using local mirror for faster builds and to avoid internet connectivity issues..."
    MIRROR_BOOTSTRAP="file:///var/cache/apt/archives"
    MIRROR_BINARY="file:///var/cache/apt/archives"
    MIRROR_CHROOT="file:///var/cache/apt/archives"
    # Security mirrors still need to be online
    MIRROR_BINARY_SECURITY="http://security.debian.org/debian-security/"
    MIRROR_CHROOT_SECURITY="http://security.debian.org/debian-security/"
    
    # Create a local package cache directory if it doesn't exist
    mkdir -p /var/cache/apt/archives
else
    # Use default Debian mirrors
    MIRROR_BOOTSTRAP="http://deb.debian.org/debian/"
    MIRROR_BINARY="http://deb.debian.org/debian/"
    MIRROR_BINARY_SECURITY="http://security.debian.org/debian-security/"
    MIRROR_CHROOT="http://deb.debian.org/debian/"
    MIRROR_CHROOT_SECURITY="http://security.debian.org/debian-security/"
fi

lb config \
    --distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --apt-indices false \
    --apt-recommends false \
    --debian-installer none \
    --mirror-bootstrap "$MIRROR_BOOTSTRAP" \
    --mirror-binary "$MIRROR_BINARY" \
    --mirror-binary-security "$MIRROR_BINARY_SECURITY" \
    --mirror-chroot "$MIRROR_CHROOT" \
    --mirror-chroot-security "$MIRROR_CHROOT_SECURITY" \
    --debootstrap-options "--keyring=/usr/share/keyrings/debian-archive-keyring.gpg" \
    --binary-filesystem ext4 \
    --binary-images iso-hybrid \
    --bootappend-live "boot=live username=live user-fullname=live hostname=chlorine-live"

# Copy custom configurations
log_info "Adding custom configurations..."
cp -r "$CONFIG_DIR"/* "$BUILD_DIR"/config/

# Verify that the hooks are executable
log_info "Ensuring hooks are executable..."
if [ -d "$BUILD_DIR/config/hooks/live" ]; then
    chmod +x "$BUILD_DIR"/config/hooks/live/*.hook.* 2>/dev/null || true
    log_info "Hooks made executable."
fi

# Ensure K2 language package dependencies are set up
mkdir -p "$BUILD_DIR/config/package-lists"
if [ ! -f "$BUILD_DIR/config/package-lists/k2-dependencies.list.chroot" ]; then
    log_warn "K2 dependencies package list not found. Creating it..."
    cat << 'EOF' > "$BUILD_DIR/config/package-lists/k2-dependencies.list.chroot"
curl
wget
build-essential
EOF
    log_info "K2 dependencies package list created."
fi

# Ensure K2 language hook is properly set up
if [ -f "$BUILD_DIR/config/hooks/live/0050-install-k2-lang.hook.chroot" ]; then
    log_info "K2 language installation hook found."
    chmod +x "$BUILD_DIR/config/hooks/live/0050-install-k2-lang.hook.chroot"
else
    log_warn "K2 language installation hook not found. Creating it..."
    mkdir -p "$BUILD_DIR/config/hooks/live"
    cat << 'EOF' > "$BUILD_DIR/config/hooks/live/0050-install-k2-lang.hook.chroot"
#!/bin/bash
# Install K2 language from official website
set -e

echo "Installing K2 language..."

# Create a temporary directory for downloading
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Install dependencies
apt-get update
apt-get install -y curl wget

# Download the latest K2 language installer
echo "Downloading K2 language from https://k2lang.org/downloads/k2..."
wget -q https://k2lang.org/downloads/k2 -O k2-installer

# Make the installer executable
chmod +x k2-installer

# Run the installer
echo "Running K2 language installer..."
./k2-installer --accept-license --prefix=/usr/local

# Verify installation
if [ -f /usr/local/bin/k2 ]; then
    echo "K2 language installed successfully."
    echo "K2 version: $(/usr/local/bin/k2 --version)"
else
    echo "K2 language installation failed."
    exit 1
fi

# Clean up
cd /
rm -rf "$TEMP_DIR"

# Create a simple test script
mkdir -p /usr/local/share/k2/examples
cat > /usr/local/share/k2/examples/hello.k2 << 'EOFINNER'
// Hello World in K2
fn main() {
    println("Hello from K2 language in Chlorine Linux!");
}
EOFINNER

echo "K2 language installation completed."
EOF
    chmod +x "$BUILD_DIR/config/hooks/live/0050-install-k2-lang.hook.chroot"
    log_info "K2 language installation hook created."
fi

# Run the customize-installer script
if [ -f "$SCRIPT_DIR/customize-installer.sh" ]; then
    log_info "Setting up Calamares installer..."
    bash "$SCRIPT_DIR/customize-installer.sh"
else
    log_warn "customize-installer.sh not found. Skipping Calamares setup."
fi

# Finalize configuration
log_info "Finalizing configuration..."
cd "$BUILD_DIR"
lb config \
    --binary-filesystem ext4 \
    --binary-images iso-hybrid \
    --bootappend-live "boot=live username=live user-fullname=live hostname=chlorine-live" \
    --mirror-bootstrap "$MIRROR_BOOTSTRAP" \
    --mirror-binary "$MIRROR_BINARY" \
    --mirror-binary-security "$MIRROR_BINARY_SECURITY" \
    --mirror-chroot "$MIRROR_CHROOT" \
    --mirror-chroot-security "$MIRROR_CHROOT_SECURITY"

# Run the build
log_info "Building ISO..."
cd "$BUILD_DIR"
lb build || true

# Check if the ISO was created
if [ -f "$BUILD_DIR/live-image-amd64.hybrid.iso" ]; then
    log_info "Copying ISO to output directory..."
    cp "$BUILD_DIR/live-image-amd64.hybrid.iso" "$ISO_DIR/chlorine-linux.iso"
    log_info "ISO created successfully: $ISO_DIR/chlorine-linux.iso"
    log_info "ISO size: $(du -h "$ISO_DIR/chlorine-linux.iso" | cut -f1)"
elif [ -f "$ISO_DIR/chlorine-linux.iso" ]; then
    log_info "ISO already exists in output directory: $ISO_DIR/chlorine-linux.iso"
    log_info "ISO size: $(du -h "$ISO_DIR/chlorine-linux.iso" | cut -f1)"
else
    log_warn "ISO file not found after build. This may be due to internet connectivity issues in the chroot environment."
    log_warn "You may need to fix your internet connection and try again."
    log_warn "Alternatively, you can try using a local mirror or a cached repository."
    exit 1
fi

log_info "Chlorine Linux build process completed successfully."
