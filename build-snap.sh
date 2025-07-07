#!/bin/bash

# Universal Battery Limiter Snap Build Script
# Builds a snap package for easy distribution

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_colored() {
    echo -e "${1}${2}${NC}"
}

print_colored $BLUE "🔧 Building Universal Battery Limiter Snap Package"
echo "=============================================="

# Check if snapcraft is available
if ! command -v snapcraft >/dev/null 2>&1; then
    print_colored $RED "❌ snapcraft not found. Please install snapcraft:"
    echo "sudo snap install snapcraft --classic"
    exit 1
fi

# Check if user is in lxd group
if ! groups | grep -q '\blxd\b'; then
    print_colored $RED "❌ User not in lxd group. Please add user to lxd group:"
    echo "sudo usermod -a -G lxd \$USER"
    echo "Then log out and log back in"
    exit 1
fi

# Clean up any previous builds
print_colored $YELLOW "🧹 Cleaning up previous builds..."
rm -f universal-battery-limiter_*.snap

# Build the snap package
print_colored $YELLOW "📦 Building snap package..."
if snapcraft pack; then
    print_colored $GREEN "✅ Snap package built successfully!"
    
    # Find the built snap
    SNAP_FILE=$(ls universal-battery-limiter_*.snap 2>/dev/null | head -1)
    if [ -n "$SNAP_FILE" ]; then
        print_colored $GREEN "📦 Package: $SNAP_FILE"
        
        # Show installation instructions
        print_colored $BLUE "🚀 To install (dangerous mode for development):"
        echo "sudo snap install $SNAP_FILE --dangerous"
        echo ""
        print_colored $BLUE "🔌 To connect required interfaces:"
        echo "sudo snap connect universal-battery-limiter:battery-control"
        echo ""
        print_colored $BLUE "🗑️ To uninstall:"
        echo "sudo snap remove universal-battery-limiter"
    else
        print_colored $YELLOW "⚠️ Snap file not found, but build may have succeeded"
    fi
else
    print_colored $RED "❌ Snap build failed"
    exit 1
fi
