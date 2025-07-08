#!/bin/bash

# Package Verification Script for Universal Battery Limiter v2.2.0
# Verifies package contents and prepares for release

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_colored() {
    echo -e "${1}${2}${NC}"
}

PACKAGE="universal-battery-limiter_2.2.0_all.deb"

print_colored $BLUE "🔍 Package Verification: $PACKAGE"
echo "=========================================="

if [ ! -f "$PACKAGE" ]; then
    echo "❌ Package not found: $PACKAGE"
    exit 1
fi

print_colored $YELLOW "📦 Package Information:"
dpkg-deb --info "$PACKAGE" | grep -E "(Package|Version|Architecture|Depends)"

print_colored $YELLOW "📁 Animated Icons Content:"
echo "Checking for animated icons..."
dpkg-deb --contents "$PACKAGE" | grep -E "(icons/animated|enhanced_animated)" | while read line; do
    print_colored $GREEN "✅ $line"
done

print_colored $YELLOW "📊 Package Size:"
ls -lh "$PACKAGE" | awk '{print $5 " - " $9}'

print_colored $YELLOW "🔧 Dependencies Check:"
dpkg-deb --info "$PACKAGE" | grep "Depends:" | sed 's/Depends: //'

print_colored $BLUE "✅ Package verification complete!"
echo ""
print_colored $YELLOW "Ready for GitHub release! 🚀"
