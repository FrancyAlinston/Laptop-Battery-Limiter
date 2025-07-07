# Git Commit Guide for Universal Battery Limiter

## Current Changes (v2.1.0)

### Main Commit Message:
```
feat(packaging): enhance distribution metadata and snap store presence v2.1.0

- Add comprehensive Snap Store metadata with professional presentation
- Enhance Debian package control with VCS and maintainer information  
- Create custom SVG icon and desktop entries for Snap GUI integration
- Add detailed package documentation and contributor attribution
- Implement proper version management across all components
- Optimize store presence with keywords, categories, and descriptions

BREAKING: Version bump to 2.1.0 for enhanced distribution features
Closes: Distribution readiness for professional package managers

Signed-off-by: FrancyAlinston <francyalen@gmail.com>
```

### Individual File Commits (if preferred):

#### 1. Snap Configuration Updates:
```
feat(snap): add comprehensive store metadata and GUI integration

- Add website, source-code, issues, and donation URLs to snapcraft.yaml
- Create snap/gui/ directory with desktop entry and custom SVG icon
- Add proper contact, license, and title information for Snap Store
- Implement secure confinement with system-files interface
- Add snap-store-metadata.md for store optimization

Version: 2.1.0
```

#### 2. Debian Package Enhancements:
```
feat(debian): enhance package metadata and repository compliance

- Add Uploaders, VCS-Git, VCS-Browser fields to control file
- Include Standards-Version 4.6.0 and Multi-Arch compliance
- Create debian-metadata.md with comprehensive package information
- Update changelog with detailed version history
- Add professional package description with manufacturer coverage

Version: 2.1.0
```

#### 3. Version Management:
```
chore(version): bump to 2.1.0 for enhanced distribution features

- Update version in snapcraft.yaml, debian control, and source files
- Synchronize version across battery-gui and battery-indicator
- Update build scripts with new package names
- Add version 2.1.0 entry to changelog with feature summary

Files: snapcraft.yaml, debian-package/DEBIAN/control, battery-*, build-deb.sh
```

#### 4. Documentation and Metadata:
```
docs(packaging): add comprehensive distribution documentation

- Create PACKAGE-INFO.md with complete project overview
- Add snap/snap-store-metadata.md for store optimization
- Add debian-package/debian-metadata.md for repository compliance
- Document all distribution channels and installation methods
- Include legal information and support channels

Files: PACKAGE-INFO.md, snap/snap-store-metadata.md, debian-package/debian-metadata.md
```

## Commit Workflow:

### Option A: Single Comprehensive Commit
```bash
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
```

### Option B: Separate Feature Commits
```bash
# Snap enhancements
git add snapcraft.yaml snap/
git commit -m "feat(snap): add comprehensive store metadata and GUI integration"

# Debian enhancements
git add debian-package/DEBIAN/control debian-package/usr/share/doc/universal-battery-limiter/changelog debian-package/debian-metadata.md
git commit -m "feat(debian): enhance package metadata and repository compliance"

# Version updates
git add battery-* build-deb.sh
git commit -m "chore(version): bump to 2.1.0 for enhanced distribution features"

# Documentation
git add PACKAGE-INFO.md build-snap.sh
git commit -m "docs(packaging): add comprehensive distribution documentation"
```

## Tag Creation:
```bash
git tag -a v2.1.0 -m "Version 2.1.0: Enhanced Distribution and Store Presence

- Comprehensive Snap Store metadata
- Enhanced Debian package information
- Professional packaging for wider distribution
- Custom icon and GUI integration
- Complete documentation and contributor attribution"
```

## Conventional Commit Types Used:

- **feat**: New features (snap metadata, debian enhancements)
- **chore**: Maintenance tasks (version bumps, build scripts)
- **docs**: Documentation updates (metadata files, package info)
- **fix**: Bug fixes (if any)
- **refactor**: Code restructuring (if any)

## Version Numbering Strategy:

- **2.0.0**: Major rebranding from ASUS to Universal
- **2.1.0**: Enhanced packaging and distribution metadata
- **2.1.x**: Future bug fixes and minor improvements
- **2.2.0**: Next feature release

## Release Notes for v2.1.0:

This release focuses on enhancing the distribution and packaging aspects of Universal Battery Limiter, making it ready for professional package manager distribution including Snap Store and Debian repositories.

### New Features:
- Comprehensive Snap Store metadata and presence
- Enhanced Debian package repository compliance
- Professional packaging documentation
- Custom SVG icon for store presence

### Improvements:
- Better store optimization with keywords and categories
- Complete contributor and maintainer information
- Professional changelog and version management
- Distribution-ready documentation
