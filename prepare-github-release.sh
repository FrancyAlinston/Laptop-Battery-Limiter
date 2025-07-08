#!/bin/bash

# GitHub Release Preparation Script for Universal Battery Limiter v2.2.0
# Prepares all release assets and provides GitHub CLI commands

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_colored() {
    echo -e "${1}${2}${NC}"
}

print_colored $BLUE "🚀 Universal Battery Limiter v2.2.0 - GitHub Release Preparation"
echo "=================================================================="

VERSION="2.2.0"
TAG="v${VERSION}"
RELEASE_TITLE="Universal Battery Limiter v${VERSION} - Beautiful Animated System Tray Icons"

print_colored $YELLOW "📋 Checking release assets..."

# Check if .deb package exists
DEB_FILE="universal-battery-limiter_${VERSION}_all.deb"
if [ -f "$DEB_FILE" ]; then
    DEB_SIZE=$(du -h "$DEB_FILE" | cut -f1)
    print_colored $GREEN "✅ .deb package: $DEB_FILE ($DEB_SIZE)"
else
    print_colored $RED "❌ .deb package not found. Run ./build-deb.sh first"
    exit 1
fi

# Check release notes
if [ -f "RELEASE-NOTES-v${VERSION}.md" ]; then
    print_colored $GREEN "✅ Release notes: RELEASE-NOTES-v${VERSION}.md"
else
    print_colored $RED "❌ Release notes not found"
    exit 1
fi

# Check animated icons demo
if [ -f "animated-icons-demo.html" ]; then
    print_colored $GREEN "✅ Animation demo: animated-icons-demo.html"
else
    print_colored $YELLOW "⚠️ Animation demo not found"
fi

print_colored $YELLOW "📊 Release asset summary:"
echo "  • Main package: $DEB_FILE ($DEB_SIZE)"
echo "  • Source code: Automatic GitHub archive"
echo "  • Documentation: Included in package and repo"
echo "  • Animation demo: animated-icons-demo.html"

print_colored $PURPLE "🔧 Git preparation commands:"
echo ""
echo "# 1. Ensure all changes are committed"
echo "git add ."
echo "git commit -m \"Release v${VERSION}: Beautiful animated system tray icons\""
echo ""
echo "# 2. Create and push tag"
echo "git tag -a $TAG -m \"Version ${VERSION} - Animated Icons Release\""
echo "git push origin $TAG"
echo "git push origin main  # or your default branch"

print_colored $PURPLE "🌐 GitHub CLI release command:"
echo ""
echo "# Install GitHub CLI if not available:"
echo "sudo apt install gh"
echo ""
echo "# Authenticate with GitHub:"
echo "gh auth login"
echo ""
echo "# Create release with assets:"
cat << EOF
gh release create $TAG \\
    --title "$RELEASE_TITLE" \\
    --notes-file "RELEASE-NOTES-v${VERSION}.md" \\
    --repo FrancyAlinston/Laptop-Battery-Limiter \\
    "$DEB_FILE#Main .deb Package (${DEB_SIZE})" \\
    "animated-icons-demo.html#Animation Demo" \\
    "ANIMATED-ICONS.md#Animation Documentation" \\
    "ANIMATED-ICONS-COMPLETE.md#Implementation Report"
EOF

print_colored $PURPLE "🌐 Manual GitHub Release (if CLI not available):"
echo ""
echo "1. Go to: https://github.com/FrancyAlinston/Laptop-Battery-Limiter/releases/new"
echo "2. Tag: $TAG"
echo "3. Title: $RELEASE_TITLE"
echo "4. Description: Copy content from RELEASE-NOTES-v${VERSION}.md"
echo "5. Upload assets:"
echo "   • $DEB_FILE"
echo "   • animated-icons-demo.html"
echo "   • ANIMATED-ICONS.md"
echo "   • ANIMATED-ICONS-COMPLETE.md"

print_colored $BLUE "📦 Snap Store preparation (when snap build works):"
echo ""
echo "# Upload to Snap Store:"
echo "snapcraft upload universal-battery-limiter_${VERSION}_amd64.snap"
echo "snapcraft release universal-battery-limiter [revision] stable"

print_colored $GREEN "✅ Release preparation complete!"
print_colored $YELLOW "📝 Next steps:"
echo "1. Review all changes and ensure quality"
echo "2. Run git commands to create tag"
echo "3. Use GitHub CLI or manual process to create release"
echo "4. Test installation from GitHub release"
echo "5. Announce on relevant channels"

print_colored $BLUE "🎯 Post-release checklist:"
echo "• Test download and installation of .deb package"
echo "• Verify animated icons work correctly"
echo "• Update any documentation or README links"
echo "• Monitor for user feedback and issues"
echo "• Plan next version features"

echo ""
print_colored $PURPLE "🎉 Ready to release beautiful animated battery management!"
