#!/bin/bash

# ============================================================
# Discord Updater Script
# Downloads and installs Discord from the official tar.gz
# ============================================================

set -e

# Configuration
DISCORD_URL="https://discord.com/api/download?platform=linux&format=tar.gz"
INSTALL_DIR="/opt"
TEMP_DIR="./downloads"
DESKTOP_FILE="$HOME/.local/share/applications/discord.desktop"
BIN_LINK="$HOME/.local/bin/discord"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check for required dependencies
check_dependencies() {
    local missing_deps=()
    
    for cmd in curl tar; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Please install them using your package manager."
        exit 1
    fi
}

# Create necessary directories
create_directories() {
    log_info "Creating directories..."
    #mkdir -p "$INSTALL_DIR"
    mkdir -p "$TEMP_DIR"
    #mkdir -p "$(dirname "$DESKTOP_FILE")"
    #mkdir -p "$(dirname "$BIN_LINK")"
}

# Download Discord
download_discord() {
    log_info "Downloading Discord..."
    
    if curl -L "$DISCORD_URL" -o "$TEMP_DIR/discord.tar.gz" --progress-bar; then
        log_success "Download completed!"
    else
        log_error "Failed to download Discord"
        exit 1
    fi
}

# Extract and install Discord
install_discord() {
    log_info "Extracting Discord..."
    
    # Remove old installation if exists
    if [ -d "$INSTALL_DIR/Discord" ]; then
        log_info "Removing old installation..."
        rm -rf "$INSTALL_DIR/Discord"
    fi

    #mkdir -p "$INSTALL_DIR"
    
    # Extract to install directory
    tar -xzf "$TEMP_DIR/discord.tar.gz" -C "$INSTALL_DIR"
    
    log_success "Discord extracted to $INSTALL_DIR/Discord"
    mv "$INSTALL_DIR/Discord" "$INSTALL_DIR/discord"
}

# Create desktop entry
create_desktop_entry() {
    log_info "Creating desktop entry..."
    
    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers
GenericName=Internet Messenger
Exec=$INSTALL_DIR/Discord/Discord
Icon=$INSTALL_DIR/Discord/discord.png
Type=Application
Categories=Network;InstantMessaging;
Path=$INSTALL_DIR/Discord
EOF
    
    # Make desktop file executable
    chmod +x "$DESKTOP_FILE"
    
    log_success "Desktop entry created at $DESKTOP_FILE"
}

# Create symlink in bin directory
create_bin_link() {
    log_info "Creating binary symlink..."
    
    # Remove old symlink if exists
    if [ -L "$BIN_LINK" ]; then
        rm "$BIN_LINK"
    fi
    
    ln -s "$INSTALL_DIR/Discord/Discord" "$BIN_LINK"
    
    log_success "Symlink created at $BIN_LINK"
    
    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        log_warning "~/.local/bin is not in your PATH"
        log_info "Add this line to your ~/.bashrc or ~/.zshrc:"
        echo -e "${YELLOW}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    fi
}

# Cleanup temporary files
cleanup() {
    log_info "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
    log_success "Cleanup completed!"
}

# Get installed version
get_installed_version() {
    if [ -f "$INSTALL_DIR/Discord/resources/build_info.json" ]; then
        grep -o '"version": "[^"]*"' "$INSTALL_DIR/Discord/resources/build_info.json" | cut -d'"' -f4
    else
        echo "Not installed"
    fi
}

# Main function
main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║       Discord Updater for Linux        ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    local current_version=$(get_installed_version)
    log_info "Current installed version: $current_version"
    echo ""
    
    check_dependencies
    create_directories
    download_discord
    install_discord
    #create_desktop_entry
    #create_bin_link
    cleanup
    
    local new_version=$(get_installed_version)
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Discord updated successfully!      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    log_success "Installed version: $new_version"
    log_info "You can now launch Discord from your application menu or by running 'discord'"
    echo ""
}

# Run main function
main "$@"
