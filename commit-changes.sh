#!/bin/bash

# Universal Battery Limiter - Automated Commit Script
# Version 2.1.0 - Enhanced Distribution and Store Presence

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_colored() {
    echo -e "${1}${2}${NC}"
}

print_colored $BLUE "🔧 Universal Battery Limiter - Git Commit Assistant"
echo "=================================================="

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_colored $RED "❌ Not in a git repository"
    exit 1
fi

# Show current status
print_colored $YELLOW "📋 Current Git Status:"
git status --short

echo ""
print_colored $YELLOW "🔍 Files to be committed:"
echo "  Modified:"
echo "    - snapcraft.yaml (v2.1.0, enhanced metadata)"
echo "    - debian-package/DEBIAN/control (enhanced fields)"
echo "    - debian-package/usr/share/doc/universal-battery-limiter/changelog (v2.1.0)"
echo "    - battery-indicator (version update)"
echo "    - battery-gui (version update)"
echo "    - build-deb.sh (version update)"
echo ""
echo "  New files:"
echo "    - snap/ directory (GUI integration, icon, metadata)"
echo "    - PACKAGE-INFO.md (comprehensive documentation)"
echo "    - COMMIT-GUIDE.md (this guide)"
echo "    - build-snap.sh (snap build automation)"
echo "    - debian-package/debian-metadata.md (debian info)"

echo ""
print_colored $BLUE "📝 Commit Options:"
echo "1) Single comprehensive commit (recommended)"
echo "2) Separate feature commits"
echo "3) Custom commit message"
echo "4) Show detailed commit message"
echo "5) Cancel"

read -p "Choose option (1-5): " choice

case $choice in
    1)
        print_colored $YELLOW "🚀 Creating comprehensive commit..."
        git add .
        git commit -m "feat(packaging): enhance distribution metadata and snap store presence v2.1.0

- Add comprehensive Snap Store metadata with professional presentation
- Enhance Debian package control with VCS and maintainer information  
- Create custom SVG icon and desktop entries for Snap GUI integration
- Add detailed package documentation and contributor attribution
- Implement proper version management across all components
- Optimize store presence with keywords, categories, and descriptions

BREAKING: Version bump to 2.1.0 for enhanced distribution features
Closes: Distribution readiness for professional package managers

Signed-off-by: FrancyAlinston <francyalen@gmail.com>"
        
        print_colored $GREEN "✅ Comprehensive commit created successfully!"
        ;;
        
    2)
        print_colored $YELLOW "🔄 Creating separate feature commits..."
        
        # Snap enhancements
        git add snapcraft.yaml snap/
        git commit -m "feat(snap): add comprehensive store metadata and GUI integration v2.1.0"
        
        # Debian enhancements  
        git add debian-package/DEBIAN/control debian-package/usr/share/doc/universal-battery-limiter/changelog debian-package/debian-metadata.md
        git commit -m "feat(debian): enhance package metadata and repository compliance v2.1.0"
        
        # Version updates
        git add battery-indicator battery-gui build-deb.sh
        git commit -m "chore(version): bump to 2.1.0 for enhanced distribution features"
        
        # Documentation
        git add PACKAGE-INFO.md COMMIT-GUIDE.md build-snap.sh
        git commit -m "docs(packaging): add comprehensive distribution documentation v2.1.0"
        
        print_colored $GREEN "✅ All feature commits created successfully!"
        ;;
        
    3)
        print_colored $YELLOW "✏️ Enter custom commit message:"
        read -p "Commit message: " custom_message
        git add .
        git commit -m "$custom_message"
        print_colored $GREEN "✅ Custom commit created successfully!"
        ;;
        
    4)
        print_colored $BLUE "📖 Detailed commit message:"
        echo ""
        cat << 'EOF'
feat(packaging): enhance distribution metadata and snap store presence v2.1.0

This release focuses on enhancing the distribution and packaging aspects of 
Universal Battery Limiter, making it ready for professional package manager 
distribution including Snap Store and Debian repositories.

## Snap Store Enhancements:
- Added comprehensive metadata (website, source-code, issues, donation URLs)
- Created snap/gui/ directory with desktop entry and custom SVG icon
- Added proper contact, license, and title information for store presence
- Implemented secure confinement with system-files interface for battery access
- Added snap-store-metadata.md for store optimization and SEO

## Debian Package Improvements:
- Enhanced control file with Uploaders, VCS-Git, VCS-Browser fields
- Added Standards-Version 4.6.0 and Multi-Arch compliance
- Created debian-metadata.md with comprehensive package information
- Updated changelog with detailed version history for v2.1.0
- Enhanced package description with manufacturer coverage details

## Version Management:
- Bumped version to 2.1.0 across all components (snapcraft.yaml, control, sources)
- Updated battery-gui and battery-indicator version strings
- Modified build scripts to use new version numbers
- Added comprehensive changelog entry for v2.1.0

## Documentation and Metadata:
- Created PACKAGE-INFO.md with complete project overview
- Added distribution-specific metadata files for store compliance
- Documented all distribution channels and installation methods
- Included legal information, support channels, and contributor attribution

## Store Optimization:
- Added professional keywords and categories for better discoverability
- Created custom SVG icon for Snap Store branding
- Enhanced descriptions for both Snap Store and Debian repositories
- Optimized metadata for professional distribution channels

BREAKING CHANGES:
- Version bump from 2.0.0 to 2.1.0
- New package file names include version 2.1.0

Closes: #distribution-readiness
Closes: #snap-store-presence  
Closes: #debian-repository-compliance

Signed-off-by: FrancyAlinston <francyalen@gmail.com>
EOF
        echo ""
        read -p "Use this detailed message? (y/n): " confirm
        if [[ $confirm == "y" || $confirm == "Y" ]]; then
            git add .
            git commit -F - << 'EOF'
feat(packaging): enhance distribution metadata and snap store presence v2.1.0

This release focuses on enhancing the distribution and packaging aspects of 
Universal Battery Limiter, making it ready for professional package manager 
distribution including Snap Store and Debian repositories.

## Snap Store Enhancements:
- Added comprehensive metadata (website, source-code, issues, donation URLs)
- Created snap/gui/ directory with desktop entry and custom SVG icon
- Added proper contact, license, and title information for store presence
- Implemented secure confinement with system-files interface for battery access
- Added snap-store-metadata.md for store optimization and SEO

## Debian Package Improvements:
- Enhanced control file with Uploaders, VCS-Git, VCS-Browser fields
- Added Standards-Version 4.6.0 and Multi-Arch compliance
- Created debian-metadata.md with comprehensive package information
- Updated changelog with detailed version history for v2.1.0
- Enhanced package description with manufacturer coverage details

## Version Management:
- Bumped version to 2.1.0 across all components (snapcraft.yaml, control, sources)
- Updated battery-gui and battery-indicator version strings
- Modified build scripts to use new version numbers
- Added comprehensive changelog entry for v2.1.0

## Documentation and Metadata:
- Created PACKAGE-INFO.md with complete project overview
- Added distribution-specific metadata files for store compliance
- Documented all distribution channels and installation methods
- Included legal information, support channels, and contributor attribution

## Store Optimization:
- Added professional keywords and categories for better discoverability
- Created custom SVG icon for Snap Store branding
- Enhanced descriptions for both Snap Store and Debian repositories
- Optimized metadata for professional distribution channels

BREAKING CHANGES:
- Version bump from 2.0.0 to 2.1.0
- New package file names include version 2.1.0

Closes: #distribution-readiness
Closes: #snap-store-presence  
Closes: #debian-repository-compliance

Signed-off-by: FrancyAlinston <francyalen@gmail.com>
EOF
            print_colored $GREEN "✅ Detailed commit created successfully!"
        else
            print_colored $YELLOW "⏭️ Commit cancelled"
        fi
        ;;
        
    5)
        print_colored $YELLOW "⏭️ Commit cancelled"
        exit 0
        ;;
        
    *)
        print_colored $RED "❌ Invalid option"
        exit 1
        ;;
esac

# Ask about tagging
echo ""
print_colored $BLUE "🏷️ Create version tag?"
read -p "Create tag v2.1.0? (y/n): " tag_confirm

if [[ $tag_confirm == "y" || $tag_confirm == "Y" ]]; then
    git tag -a v2.1.0 -m "Version 2.1.0: Enhanced Distribution and Store Presence

- Comprehensive Snap Store metadata and GUI integration
- Enhanced Debian package repository compliance  
- Professional packaging for wider distribution
- Custom icon and store optimization
- Complete documentation and contributor attribution"
    
    print_colored $GREEN "✅ Tag v2.1.0 created successfully!"
fi

# Show final status
echo ""
print_colored $GREEN "🎉 Commit process completed!"
print_colored $BLUE "📊 Final status:"
git log --oneline -5
echo ""
print_colored $YELLOW "🚀 Next steps:"
echo "  1. Push commits: git push origin beta"
echo "  2. Push tags: git push origin v2.1.0"
echo "  3. Create pull request to main/stable branch"
echo "  4. Create GitHub release with changelog"
echo "  5. Build and test packages"
