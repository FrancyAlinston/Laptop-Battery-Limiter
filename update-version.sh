#!/bin/bash

# Version Update Script for ASUS Battery Limiter
# Updates version numbers across all package files

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_colored() {
    echo -e "${1}${2}${NC}"
}

if [ -z "$1" ]; then
    print_colored $RED "❌ Usage: $0 <new_version>"
    echo "Example: $0 1.1.0"
    exit 1
fi

NEW_VERSION="$1"
CURRENT_VERSION="1.0.0"

print_colored $BLUE "🔄 Updating ASUS Battery Limiter version to $NEW_VERSION"
echo "=================================================="

# Update Debian control file
print_colored $YELLOW "📦 Updating Debian control file..."
sed -i "s/Version: $CURRENT_VERSION/Version: $NEW_VERSION/" debian-package/DEBIAN/control

# Update battery-indicator version
print_colored $YELLOW "🔍 Updating battery-indicator version..."
sed -i "s/self.current_version = \"$CURRENT_VERSION\"/self.current_version = \"$NEW_VERSION\"/" battery-indicator

# Update battery-gui version  
print_colored $YELLOW "🖥️ Updating battery-gui version..."
sed -i "s/self.current_version = \"$CURRENT_VERSION\"/self.current_version = \"$NEW_VERSION\"/" battery-gui

# Update snapcraft.yaml
print_colored $YELLOW "📱 Updating snapcraft.yaml..."
sed -i "s/version: '$CURRENT_VERSION'/version: '$NEW_VERSION'/" snapcraft.yaml

# Update build script
print_colored $YELLOW "🔧 Updating build script..."
sed -i "s/PACKAGE_NAME=\"asus-battery-limiter_${CURRENT_VERSION}_all.deb\"/PACKAGE_NAME=\"asus-battery-limiter_${NEW_VERSION}_all.deb\"/" build-deb.sh

# Update changelog
print_colored $YELLOW "📝 Updating changelog..."
CURRENT_DATE=$(date -R)
cat > debian-package/usr/share/doc/asus-battery-limiter/changelog << EOF
asus-battery-limiter ($NEW_VERSION) stable; urgency=low

  * Version $NEW_VERSION release
  * See GitHub releases for detailed changelog

 -- FrancyAlinston <francyalen@gmail.com>  $CURRENT_DATE

$(cat debian-package/usr/share/doc/asus-battery-limiter/changelog)
EOF

# Update GitHub Actions workflow
print_colored $YELLOW "⚙️ Updating GitHub Actions workflow..."
sed -i "s/asus-battery-limiter_${CURRENT_VERSION}_all.deb/asus-battery-limiter_${NEW_VERSION}_all.deb/g" .github/workflows/python-app.yml

print_colored $GREEN "✅ Version updated successfully!"
echo
print_colored $BLUE "📋 Next steps:"
echo "1. Review changes: git diff"
echo "2. Commit changes: git add . && git commit -m 'Bump version to $NEW_VERSION'"
echo "3. Create tag: git tag v$NEW_VERSION"
echo "4. Push changes: git push origin main --tags"
echo "5. Create GitHub release with tag v$NEW_VERSION"
echo "6. Build package: ./build-deb.sh"
echo
print_colored $YELLOW "💡 Don't forget to update the release notes in GitHub!"
