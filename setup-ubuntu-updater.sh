#!/bin/bash

# Ubuntu Native Updater Integration Setup Script
# Sets up PPA, Snap Store, and custom APT repository integration
# for ASUS Battery Limiter

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PACKAGE_NAME="asus-battery-limiter"
REPO_URL="https://github.com/FrancyAlinston/Battery-Limter"
VERSION=$(grep "^Version:" debian-package/DEBIAN/control | cut -d' ' -f2)

print_header() {
    echo -e "${BLUE}=================================${NC}"
    echo -e "${BLUE}Ubuntu Native Updater Integration${NC}"
    echo -e "${BLUE}=================================${NC}"
    echo
}

print_step() {
    echo -e "${GREEN}➤${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

check_dependencies() {
    print_step "Checking dependencies..."
    
    local missing_deps=()
    
    # Check for required tools
    command -v gpg >/dev/null || missing_deps+=("gnupg")
    command -v debuild >/dev/null || missing_deps+=("devscripts")
    command -v dput >/dev/null || missing_deps+=("dput-ng")
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_warning "Missing dependencies: ${missing_deps[*]}"
        echo "Installing missing dependencies..."
        sudo apt update
        sudo apt install -y "${missing_deps[@]}"
    fi
    
    # Check snapcraft separately (it's a snap package)
    if ! command -v snapcraft >/dev/null; then
        print_warning "Snapcraft not found. Install with: sudo snap install snapcraft --classic"
    fi
    
    print_success "Dependencies checked"
}

setup_gpg_key() {
    print_step "Setting up GPG key for package signing..."
    
    if gpg --list-secret-keys | grep -q "$USER@"; then
        print_success "GPG key already exists"
        return
    fi
    
    echo "Generating new GPG key for package signing..."
    cat > gpg-gen-config << EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $USER
Name-Email: $USER@$(hostname)
Expire-Date: 2y
Passphrase: 
%commit
EOF
    
    gpg --batch --generate-key gpg-gen-config
    rm gpg-gen-config
    
    # Export public key
    GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format=long | grep 'sec' | head -1 | awk '{print $2}' | cut -d'/' -f2)
    gpg --armor --export $GPG_KEY_ID > public-key.asc
    
    print_success "GPG key generated: $GPG_KEY_ID"
    echo "Public key saved to: public-key.asc"
}

setup_ppa_integration() {
    print_step "Setting up PPA integration..."
    
    echo "To enable PPA integration, you need to:"
    echo "1. Create a Launchpad account and PPA"
    echo "2. Upload your GPG public key to Launchpad"
    echo "3. Configure GitHub secrets for automated publishing"
    echo
    
    cat << EOF
GitHub Secrets needed for PPA integration:
- PPA_GPG_PRIVATE_KEY: $(gpg --armor --export-secret-keys $GPG_KEY_ID | base64 -w 0)
- PPA_GPG_PASSPHRASE: (your GPG key passphrase)
- PPA_GPG_KEY_ID: $GPG_KEY_ID
- PPA_USER: (your Launchpad username)
- PPA_NAME: (your PPA name, e.g., 'battery-limiter')

GitHub Variables needed:
- ENABLE_PPA: true

EOF
    
    # Create PPA configuration template
    cat > ppa-config.txt << EOF
# PPA Configuration Template
# Copy this to your Launchpad PPA description

ASUS Battery Limiter - Professional battery charge management for ASUS laptops

## Installation

sudo add-apt-repository ppa:YOUR_USERNAME/YOUR_PPA_NAME
sudo apt update
sudo apt install asus-battery-limiter

## Features

- Modern CLI and GUI interface
- System tray integration
- Automatic update checking via Ubuntu's native updater
- Professional installation and configuration

## Support

GitHub: $REPO_URL
Issues: $REPO_URL/issues

EOF
    
    print_success "PPA configuration template created: ppa-config.txt"
}

setup_snap_integration() {
    print_step "Setting up Snap Store integration..."
    
    if [ ! -f "snapcraft.yaml" ]; then
        print_error "snapcraft.yaml not found. Creating one..."
        
        # Create snapcraft.yaml if it doesn't exist
        mkdir -p snap
        cat > snapcraft.yaml << EOF
name: asus-battery-limiter
base: core22
version: '$VERSION'
summary: Battery charge limiter for ASUS laptops
description: |
  Professional battery charge limiter for ASUS laptops running Linux.
  Features a modern GUI, CLI interface, and system tray integration
  for managing battery charging limits to extend battery lifespan.

grade: stable
confinement: strict

apps:
  asus-battery-limiter:
    command: usr/bin/battery-gui
    desktop: usr/share/applications/asus-battery-limiter.desktop
    plugs:
      - desktop
      - desktop-legacy
      - wayland
      - x11
      - home
      - network
  
  battery-cli:
    command: usr/bin/battery-cli
    plugs:
      - home
      - network
  
  battery-indicator:
    command: usr/bin/battery-indicator
    desktop: usr/share/applications/asus-battery-limiter-indicator.desktop
    plugs:
      - desktop
      - desktop-legacy
      - wayland
      - x11
      - home
      - network
      - unity7

parts:
  asus-battery-limiter:
    plugin: dump
    source: .
    stage-packages:
      - python3
      - python3-gi
      - python3-gi-cairo
      - gir1.2-gtk-3.0
      - gir1.2-appindicator3-0.1
      - gir1.2-notify-0.7
      - python3-tk
    organize:
      battery-cli: usr/bin/battery-cli
      battery-limit: usr/bin/battery-limit
      battery-gui: usr/bin/battery-gui
      battery-indicator: usr/bin/battery-indicator
      set-charge-limit.sh: usr/lib/asus-battery-limiter/set-charge-limit.sh
    prime:
      - usr/bin/
      - usr/lib/asus-battery-limiter/
      - usr/share/
EOF
    fi
    
    echo "To enable Snap Store integration, you need to:"
    echo "1. Register as a Snap Store developer"
    echo "2. Register the snap name 'asus-battery-limiter'"
    echo "3. Configure GitHub secrets for automated publishing"
    echo
    
    cat << EOF
GitHub Secrets needed for Snap Store integration:
- SNAPCRAFT_TOKEN: (generate with 'snapcraft export-login token.txt')

GitHub Variables needed:
- ENABLE_SNAP: true

EOF
    
    print_success "Snap configuration ready"
}

setup_custom_apt_repo() {
    print_step "Setting up custom APT repository..."
    
    echo "To set up a custom APT repository, you need:"
    echo "1. A web server to host the repository"
    echo "2. Domain name for the repository"
    echo "3. GPG key for signing packages"
    echo
    
    # Create repository structure
    mkdir -p apt-repository/{conf,dists,pool}
    
    cat > apt-repository/conf/distributions << EOF
Codename: jammy
Components: main
Architectures: all amd64
SignWith: $GPG_KEY_ID
Description: ASUS Battery Limiter APT Repository

Codename: focal
Components: main
Architectures: all amd64
SignWith: $GPG_KEY_ID
Description: ASUS Battery Limiter APT Repository
EOF
    
    cat > apt-repository/README.md << EOF
# ASUS Battery Limiter APT Repository

## Adding this repository

\`\`\`bash
wget -qO - https://YOUR_DOMAIN/public-key.asc | sudo apt-key add -
echo "deb https://YOUR_DOMAIN/apt-repository/ \$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/asus-battery-limiter.list
sudo apt update
\`\`\`

## Installing

\`\`\`bash
sudo apt install asus-battery-limiter
\`\`\`

## Repository Management

This repository is automatically updated when new releases are published.
EOF
    
    cat << EOF
GitHub Secrets needed for custom APT repository:
- APT_REPO_GPG_KEY: $(gpg --armor --export-secret-keys $GPG_KEY_ID | base64 -w 0)
- APT_REPO_GPG_PASSPHRASE: (your GPG key passphrase)
- APT_REPO_GPG_KEY_ID: $GPG_KEY_ID

GitHub Variables needed:
- ENABLE_APT_REPO: true

EOF
    
    print_success "Custom APT repository structure created"
}

create_installation_guide() {
    print_step "Creating installation guide for users..."
    
    cat > UBUNTU_INSTALLATION.md << EOF
# Ubuntu Native Installation Guide

This guide explains how to install ASUS Battery Limiter using Ubuntu's native package management system for automatic updates.

## Method 1: Official PPA (Recommended)

The PPA provides automatic updates through Ubuntu's Software Updater.

\`\`\`bash
# Add the PPA repository
sudo add-apt-repository ppa:YOUR_USERNAME/battery-limiter
sudo apt update

# Install the package
sudo apt install asus-battery-limiter
\`\`\`

## Method 2: Snap Store

Install from the Snap Store for automatic updates:

\`\`\`bash
# Install from command line
sudo snap install asus-battery-limiter

# Or search "ASUS Battery Limiter" in the Ubuntu Software app
\`\`\`

## Method 3: Custom APT Repository

For users who prefer custom repositories:

\`\`\`bash
# Add repository key
wget -qO - https://YOUR_DOMAIN/public-key.asc | sudo apt-key add -

# Add repository
echo "deb https://YOUR_DOMAIN/apt-repository/ \$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/asus-battery-limiter.list

# Update and install
sudo apt update
sudo apt install asus-battery-limiter
\`\`\`

## Method 4: Direct .deb Download

For manual installation:

\`\`\`bash
# Download latest release
wget https://github.com/FrancyAlinston/Battery-Limter/releases/latest/download/asus-battery-limiter_VERSION_all.deb

# Install
sudo dpkg -i asus-battery-limiter_*.deb
sudo apt-get install -f  # Install any missing dependencies
\`\`\`

## Automatic Updates

Once installed via any of the native methods above:

- **PPA/APT**: Updates will appear in Software Updater and \`apt upgrade\`
- **Snap**: Updates are automatic or via \`snap refresh\`
- **Direct .deb**: Use the update checker in the app to download new versions

## Verification

After installation, verify the package:

\`\`\`bash
# Check installation
dpkg -l | grep asus-battery-limiter

# Test the application
battery-cli --help
battery-gui &
\`\`\`

## Uninstallation

\`\`\`bash
# For APT/PPA installations
sudo apt remove asus-battery-limiter

# For Snap installations
sudo snap remove asus-battery-limiter
\`\`\`

## Support

- GitHub: $REPO_URL
- Issues: $REPO_URL/issues
- Documentation: $REPO_URL/blob/main/README.md
EOF
    
    print_success "Ubuntu installation guide created: UBUNTU_INSTALLATION.md"
}

test_package_integration() {
    print_step "Testing package integration..."
    
    # Test .deb package creation
    if [ -f "build-deb.sh" ]; then
        echo "Testing .deb package build..."
        chmod +x build-deb.sh
        ./build-deb.sh
        
        if [ -f "asus-battery-limiter_*.deb" ]; then
            print_success ".deb package build successful"
            
            # Test package contents
            echo "Package contents:"
            dpkg-deb -c asus-battery-limiter_*.deb
            
            echo "Package information:"
            dpkg-deb -I asus-battery-limiter_*.deb
        else
            print_error ".deb package build failed"
        fi
    else
        print_warning "build-deb.sh not found"
    fi
    
    # Test snapcraft build (if available)
    if command -v snapcraft >/dev/null && [ -f "snapcraft.yaml" ]; then
        echo "Testing snap package build..."
        snapcraft --version
        print_success "Snapcraft is available"
    else
        print_warning "Snapcraft not available or snapcraft.yaml not found"
    fi
}

main() {
    print_header
    
    echo "This script sets up Ubuntu native updater integration for ASUS Battery Limiter."
    echo "It will configure PPA, Snap Store, and custom APT repository publishing."
    echo
    
    check_dependencies
    setup_gpg_key
    setup_ppa_integration
    setup_snap_integration
    setup_custom_apt_repo
    create_installation_guide
    test_package_integration
    
    echo
    print_success "Ubuntu native updater integration setup completed!"
    echo
    echo "Next steps:"
    echo "1. Review the generated configuration files"
    echo "2. Set up Launchpad PPA and/or Snap Store accounts"
    echo "3. Configure GitHub secrets and variables"
    echo "4. Test the automated publishing workflows"
    echo "5. Update documentation with your specific repository URLs"
    echo
    print_warning "Remember to replace placeholder URLs and usernames with your actual details!"
}

# Run main function
main "$@"
