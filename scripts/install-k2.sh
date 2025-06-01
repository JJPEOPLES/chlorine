#!/bin/bash
# Script to install K2 language in the Chlorine Linux ISO

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

# Create hooks directory if it doesn't exist
mkdir -p "$CONFIG_DIR/hooks/live"

# Create the K2 language installation hook
log_info "Creating K2 language installation hook..."
cat << 'EOFHOOK' > "$CONFIG_DIR/hooks/live/0050-install-k2-lang.hook.chroot"
#!/bin/bash
# Install K2 language from official website
set -e

echo "Installing K2 language..."

# Create a temporary directory for downloading
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Install dependencies
apt-get update
apt-get install -y curl wget build-essential

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
EOFHOOK

# Make the hook executable
chmod +x "$CONFIG_DIR/hooks/live/0050-install-k2-lang.hook.chroot"

log_info "K2 language installation hook created successfully."
log_info "The hook will be executed during the build process to install K2 language."

# Create a package list for K2 dependencies
mkdir -p "$CONFIG_DIR/package-lists"
cat << 'EOFPKG' > "$CONFIG_DIR/package-lists/k2-dependencies.list.chroot"
curl
wget
build-essential
EOFPKG

log_info "K2 dependencies package list created successfully."

# Verify that the hooks are executable
log_info "Ensuring hooks are executable..."
find "$CONFIG_DIR/hooks" -type f -name "*.hook.*" -exec chmod +x {} \;

log_info "K2 language setup completed successfully."
