# Universal Battery Limiter - Complete Package Information

## Project Overview
**Universal Battery Limiter** is a comprehensive battery charge management tool designed for all compatible laptops running Ubuntu and Linux distributions. Originally developed for ASUS laptops, it has been completely rebranded and enhanced to support all laptop manufacturers.

## Developer Information
- **Developer**: FrancyAlinston
- **Contact**: francyalen@gmail.com
- **GitHub**: https://github.com/FrancyAlinston/Laptop-Battery-Limiter
- **License**: MIT License
- **Version**: 2.0.0

## Distribution Channels

### 1. Debian Package (.deb)
- **Package Name**: universal-battery-limiter
- **Architecture**: all
- **Size**: ~23 KB
- **Dependencies**: python3, python3-gi, python3-gi-cairo, gir1.2-gtk-3.0, gir1.2-appindicator3-0.1, gir1.2-notify-0.7, python3-tk, policykit-1
- **Section**: utils
- **Priority**: optional
- **Standards**: 4.6.0

#### Installation
```bash
sudo dpkg -i universal-battery-limiter_2.0.0_all.deb
sudo apt-get install -f
```

### 2. Snap Package
- **Snap Name**: universal-battery-limiter
- **Base**: core22
- **Confinement**: strict
- **Grade**: stable
- **Channels**: stable, candidate, beta, edge

#### Installation
```bash
sudo snap install universal-battery-limiter
sudo snap connect universal-battery-limiter:battery-control
```

### 3. Manual Installation
- **Install Script**: install.sh
- **Uninstall Script**: uninstall.sh
- **Requirements**: Ubuntu 18.04+, Python 3.6+

## Package Contents

### Executables
- `battery-cli` - Interactive command-line interface
- `battery-gui` - GTK-based GUI application
- `battery-indicator` - System tray indicator
- `battery-limit` - Direct limit setter
- `set-charge-limit.sh` - Helper script

### Configuration Files
- `/etc/xdg/autostart/universal-battery-limiter.desktop` - Auto-start entry
- `/etc/sudoers.d/universal-battery-limiter` - Sudo configuration
- Desktop entries for application menu

### Documentation
- `README.md` - Complete user guide
- `changelog` - Version history
- `copyright` - MIT license text
- Installation and usage instructions

## Supported Hardware
- **Lenovo**: ThinkPad, IdeaPad, Legion series
- **HP**: Pavilion, Envy, Omen series
- **Dell**: XPS, Inspiron, Latitude series
- **ASUS**: ZenBook, VivoBook, ROG, TUF Gaming series
- **Acer**: Aspire, Predator, Swift series
- **MSI**: Gaming and Creator series
- **And many other brands** that support ACPI battery charge control

## Features
- **Universal Compatibility**: Works with all laptop brands
- **Multiple Interfaces**: CLI, GUI, and system tray
- **Modern Design**: Dark/light theme support
- **Battery Monitoring**: Real-time status display
- **Flexible Limits**: 50-100% charge limits
- **Quick Presets**: 60%, 70%, 80%, 90%, 100%
- **Auto-start**: System tray integration
- **Professional**: Proper privilege handling

## Store Metadata

### Snap Store
- **Title**: Universal Battery Limiter
- **Categories**: Utilities, System
- **Keywords**: battery, charge, limit, laptop, power, management
- **Icon**: Custom SVG icon included
- **Website**: GitHub repository
- **Support**: GitHub issues

### Debian Repository
- **Maintainer**: FrancyAlinston <francyalen@gmail.com>
- **Uploaders**: FrancyAlinston <francyalen@gmail.com>
- **Homepage**: https://github.com/FrancyAlinston/Laptop-Battery-Limiter
- **VCS**: Git repository on GitHub
- **Standards-Version**: 4.6.0

## Build Information
- **Debian Build**: `./build-deb.sh`
- **Snap Build**: `./build-snap.sh`
- **Manual Install**: `./install.sh`
- **Uninstall**: `./uninstall.sh`

## Support and Maintenance
- **Bug Reports**: GitHub Issues
- **Feature Requests**: GitHub Issues
- **Documentation**: Project README
- **Updates**: Automatic through package managers
- **Community**: GitHub Discussions

## Legal Information
- **Copyright**: 2025 FrancyAlinston
- **License**: MIT License
- **Distribution**: Free and open source
- **Commercial Use**: Permitted under MIT license

## Version History
- **2.0.0** - Universal rebranding, enhanced GUI, modern packaging
- **Previous** - ASUS-specific versions (deprecated)

This package represents a complete transformation from a manufacturer-specific tool to a universal battery management solution for all compatible laptops.
