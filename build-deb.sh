#!/bin/bash

# ASUS Battery Limiter .deb Package Builder
# Builds a Debian package for easy installation

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_colored() {
    echo -e "${1}${2}${NC}"
}

print_colored $BLUE "🔧 Building ASUS Battery Limiter .deb Package"
echo "============================================="

# Check if dpkg-deb is available
if ! command -v dpkg-deb >/dev/null 2>&1; then
    print_colored $RED "❌ dpkg-deb not found. Please install dpkg-dev:"
    echo "sudo apt install dpkg-dev"
    exit 1
fi

# Clean up any previous builds
print_colored $YELLOW "🧹 Cleaning up previous builds..."
rm -f asus-battery-limiter_*.deb

# Copy current executables to package
print_colored $YELLOW "📋 Updating package files..."
cp battery-cli battery-limit battery-gui battery-indicator set-charge-limit.sh debian-package/usr/local/bin/
cp README.md debian-package/usr/share/doc/asus-battery-limiter/

# Set permissions
chmod 755 debian-package/usr/local/bin/*
chmod 440 debian-package/etc/sudoers.d/asus-battery-limiter

# Build the package
print_colored $YELLOW "📦 Building .deb package..."
dpkg-deb --build debian-package

# Rename the package
PACKAGE_NAME="asus-battery-limiter_1.0.0_all.deb"
mv debian-package.deb "$PACKAGE_NAME"

# Verify the package
print_colored $YELLOW "🔍 Verifying package..."
dpkg-deb --info "$PACKAGE_NAME"
echo
dpkg-deb --contents "$PACKAGE_NAME"

print_colored $GREEN "✅ Package built successfully!"
print_colored $BLUE "📦 Package: $PACKAGE_NAME"
echo
print_colored $BLUE "🚀 To install (with automatic dependencies):"
echo "sudo dpkg -i $PACKAGE_NAME"
echo
print_colored $BLUE "🗑️ To uninstall:"
echo "sudo apt remove asus-battery-limiter"
