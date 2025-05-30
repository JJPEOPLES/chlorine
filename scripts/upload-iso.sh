#!/bin/bash
# Script to upload Chlorine Linux ISO files to a storage service

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
ISO_DIR="$ROOT_DIR/iso"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if rclone is installed
check_rclone() {
    if ! command -v rclone &> /dev/null; then
        log_warn "rclone is not installed. Would you like to install it? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            log_info "Installing rclone..."
            curl https://rclone.org/install.sh | sudo bash
        else
            log_error "rclone is required for uploading ISOs. Exiting."
            exit 1
        fi
    fi
}

# Configure rclone if not already configured
configure_rclone() {
    if ! rclone listremotes | grep -q "chlorine-iso:"; then
        log_info "Configuring rclone for ISO uploads..."
        log_info "You'll need to set up a remote storage service (like Google Drive, Dropbox, etc.)"
        log_info "Follow the prompts to configure rclone."
        
        rclone config
        
        if ! rclone listremotes | grep -q "chlorine-iso:"; then
            log_error "Failed to configure rclone remote. Please name your remote 'chlorine-iso'"
            exit 1
        fi
    fi
}

# Upload ISO files
upload_isos() {
    log_info "Checking for ISO files in $ISO_DIR..."
    
    if [ ! -d "$ISO_DIR" ]; then
        log_error "ISO directory not found: $ISO_DIR"
        exit 1
    fi
    
    ISO_COUNT=$(find "$ISO_DIR" -name "*.iso" | wc -l)
    
    if [ "$ISO_COUNT" -eq 0 ]; then
        log_warn "No ISO files found in $ISO_DIR"
        log_info "Build an ISO first using: sudo ./scripts/build-fixed.sh"
        exit 1
    fi
    
    log_info "Found $ISO_COUNT ISO file(s). Uploading..."
    
    for iso in "$ISO_DIR"/*.iso; do
        iso_name=$(basename "$iso")
        log_info "Uploading $iso_name..."
        
        # Calculate checksum
        log_info "Calculating SHA256 checksum..."
        sha256sum "$iso" > "$iso.sha256"
        
        # Upload ISO file
        log_info "Uploading ISO file to remote storage..."
        rclone copy "$iso" chlorine-iso:chlorine-linux/
        
        # Upload checksum file
        log_info "Uploading checksum file..."
        rclone copy "$iso.sha256" chlorine-iso:chlorine-linux/
        
        log_info "Upload complete for $iso_name"
    done
    
    # Generate and upload a file listing
    log_info "Generating file listing..."
    (
        echo "# Chlorine Linux ISO Files"
        echo ""
        echo "Last updated: $(date)"
        echo ""
        echo "## Available ISO Files"
        echo ""
        
        for iso in "$ISO_DIR"/*.iso; do
            iso_name=$(basename "$iso")
            iso_size=$(du -h "$iso" | cut -f1)
            iso_date=$(date -r "$iso" "+%Y-%m-%d %H:%M:%S")
            checksum=$(cat "$iso.sha256" | cut -d' ' -f1)
            
            echo "### $iso_name"
            echo ""
            echo "- Size: $iso_size"
            echo "- Date: $iso_date"
            echo "- SHA256: $checksum"
            echo ""
        done
    ) > "$ISO_DIR/iso-listing.md"
    
    rclone copy "$ISO_DIR/iso-listing.md" chlorine-iso:chlorine-linux/
    
    log_info "All uploads completed successfully."
    log_info "ISO files are available at: chlorine-iso:chlorine-linux/"
}

# Main function
main() {
    log_info "Chlorine Linux ISO Upload Utility"
    check_rclone
    configure_rclone
    upload_isos
}

# Run the main function
main "$@"