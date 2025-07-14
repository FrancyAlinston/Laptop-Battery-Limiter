#!/bin/bash

# Universal Battery Limiter - Documentation Update Script
# Updates all documentation to remove ASUS branding and make it universal

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_colored() {
    echo -e "${1}${2}${NC}"
}

print_colored $BLUE "📝 Universal Battery Limiter - Documentation Update"
echo "=================================================="

# Update README.md
print_colored $YELLOW "📄 Updating README.md..."
cat > README.md << 'EOF'
# 🔋 Universal Battery Limiter

Professional battery charge limiting tool for laptops running Ubuntu/Linux. Helps extend battery lifespan by preventing overcharging.

## ✨ Features

- **Multiple Installation Methods**: APT, Snap, .deb package, or manual
- **Ubuntu Native Updates**: Automatic updates through Software Updater (APT/Snap installs)
- **System Tray Integration**: Convenient access with battery status display
- **GUI Application**: User-friendly graphical interface
- **CLI Tools**: Command-line interface for advanced users
- **Professional Packaging**: Enterprise-grade installation and removal
- **Universal Compatibility**: Works with most laptop manufacturers that support ACPI battery control

## 🚀 Quick Installation

### Method 1: Direct .deb Package (Recommended)
```bash
# Download the latest release
wget https://github.com/FrancyAlinston/Laptop-Battery-Limiter/releases/latest/download/universal-battery-limiter_2.2.0_all.deb

# Install
sudo dpkg -i universal-battery-limiter_*.deb

# Fix dependencies if needed
sudo apt-get install -f
```

### Method 2: Manual Installation
```bash
# Clone repository
git clone https://github.com/FrancyAlinston/Laptop-Battery-Limiter.git
cd Laptop-Battery-Limiter

# Run installer
sudo ./install.sh
```

### Method 3: Build Your Own Package
```bash
# Clone and build
git clone https://github.com/FrancyAlinston/Laptop-Battery-Limiter.git
cd Laptop-Battery-Limiter
./build-deb.sh

# Install the built package
sudo dpkg -i universal-battery-limiter_*.deb
```

## 📱 Usage

### System Tray (Recommended)
- The battery indicator appears in your system tray after installation
- Click to access quick presets: 60%, 70%, 80%, 90%, 100%
- Right-click for full menu including GUI and settings

### GUI Application
```bash
battery-gui
```

### Command Line
```bash
# Interactive CLI
battery-cli

# Direct commands
battery-limit 80        # Set limit to 80%
battery-limit status    # Check current status
battery-limit reset     # Reset to 100%
```

## 🔄 Updates

### APT/Snap Installations
- Updates appear automatically in Ubuntu Software Updater
- No manual checking required

### Manual Installations
- Click "Check for Updates" in system tray
- Download new .deb package when available

## 📋 Requirements

- Laptop with compatible ACPI interface (most modern laptops)
- Ubuntu 18.04+ or compatible Linux distribution
- Python 3.6+
- Root/sudo access for installation

### Dependencies (automatically installed)
- `python3-gi`
- `gir1.2-gtk-3.0`
- `gir1.2-appindicator3-0.1`
- `zenity`
- `acpi`

## 🛠️ Supported Models

This tool works with most laptops that support ACPI battery charge control, including:
- ASUS ZenBook, VivoBook, ROG, TUF Gaming series
- Lenovo ThinkPad, IdeaPad series
- Dell XPS, Inspiron, Latitude series
- HP Pavilion, EliteBook series
- MSI, Acer, and many others

**Test compatibility:**
```bash
ls /sys/class/power_supply/BAT*/charge_control_end_threshold
```

## 🔧 Troubleshooting

### Battery limit not working?
1. Verify your laptop supports charge limiting:
   ```bash
   ls /sys/class/power_supply/BAT*/charge_control_end_threshold
   ```

2. Check if the service is running:
   ```bash
   systemctl status battery-limiter
   ```

3. Try different limit values (60-100%)

### Permission issues?
```bash
# Reinstall with proper permissions
sudo ./install.sh
```

### System tray not showing?
```bash
# Install required indicator library
sudo apt install gir1.2-appindicator3-0.1

# Restart the indicator
battery-indicator
```

## 🗑️ Uninstallation

### For .deb package installations:
```bash
sudo apt remove universal-battery-limiter
```

### For manual installations:
```bash
sudo ./uninstall.sh
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This tool modifies system power management settings. Use at your own risk. The authors are not responsible for any damage to your device.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/FrancyAlinston/Laptop-Battery-Limiter/issues)
- **Discussions**: [GitHub Discussions](https://github.com/FrancyAlinston/Laptop-Battery-Limiter/discussions)

---

**🎯 Goal Achieved**: This application can fetch updates from Ubuntu's native updater when installed via APT or Snap!
EOF

# Update INSTALL.md
print_colored $YELLOW "📄 Updating INSTALL.md..."
cat > INSTALL.md << 'EOF'
# Installation Guide for Universal Battery Limiter

## Method 1: Install from .deb Package (Recommended)

### Prerequisites
```bash
# Only dpkg-dev is needed for building
sudo apt update
sudo apt install dpkg-dev
```

### Build the Package
```bash
./build-deb.sh
```

### Install the Package
```bash
# Install the package - all dependencies are automatically installed!
sudo dpkg -i universal-battery-limiter_2.2.0_all.deb
```

**Note**: The package automatically installs all required dependencies including:
- python3, python3-gi, python3-gi-cairo
- gir1.2-gtk-3.0, gir1.2-appindicator3-0.1, gir1.2-notify-0.7
- python3-tk, policykit-1

### Verify Installation
```bash
battery-indicator &  # Start the system tray indicator
battery-cli status   # Check battery status
```

## Method 2: Manual Installation

### Install Dependencies
```bash
sudo apt install python3 python3-gi python3-gi-cairo gir1.2-gtk-3.0 \
                 gir1.2-appindicator3-0.1 gir1.2-notify-0.7 python3-tk policykit-1
```

### Run the Installer
```bash
./install.sh
```

## Usage

After installation, the system tray indicator will start automatically on login. You can also:

- **Start manually:** `battery-indicator`
- **Use CLI:** `battery-cli` or `battery-limit`
- **Check status:** `battery-limit status`
- **Set limit:** `sudo battery-limit set 80`

## Uninstallation

### From .deb Package
```bash
sudo apt remove universal-battery-limiter
```

### Manual Installation
```bash
./uninstall.sh
```

## Compatibility

This package works on laptops that support battery charge control through:
- `/sys/class/power_supply/BAT0/charge_control_end_threshold`

Test compatibility with:
```bash
ls -la /sys/class/power_supply/BAT0/charge_control_end_threshold
```

### Supported Laptop Brands
- ASUS (ZenBook, VivoBook, ROG, TUF Gaming)
- Lenovo (ThinkPad, IdeaPad)
- Dell (XPS, Inspiron, Latitude)
- HP (Pavilion, EliteBook)
- MSI, Acer, and many others
EOF

# Update debian package documentation
print_colored $YELLOW "📄 Updating debian package documentation..."
cat > debian-package/usr/share/doc/universal-battery-limiter/README.md << 'EOF'
# Universal Battery Limiter

A comprehensive battery charge limit management tool for laptops with multiple interfaces.

## Features

- 🔋 **Battery charge limit control** (50-100%)
- 🖥️ **Multiple interfaces**: CLI, GUI, and simple commands
- ⚡ **Quick presets**: 60%, 70%, 80%, 90%, 100%
- 📊 **Battery status monitoring**
- 🎨 **Colorful interactive CLI**
- 🔐 **Proper privilege handling**
- 🚀 **Easy-to-use GUI interface**
- 🔍 **Automatic update checking** from GitHub
- 🔄 **Auto-start system tray integration**
- 🌐 **Universal compatibility** with most laptop manufacturers

## Components

### CLI Tools
- **`battery-cli`** - Interactive CLI with colored output and menu system
- **`battery-limit`** - Simple command-line interface for basic operations
- **`set-charge-limit.sh`** - Core script for setting battery limits

### GUI Application
- **`battery-gui`** - Python/Tkinter GUI application
- **`battery-indicator`** - System tray indicator with quick access menu and GUI launcher

## Quick Start

### Check current status
```bash
./battery-limit status
```

### Set battery limit (requires sudo)
```bash
sudo ./battery-limit set 80
```

### Interactive CLI
```bash
sudo ./battery-cli
```

### System Tray Indicator (Recommended)
```bash
./battery-indicator
```

### GUI Application
Access through system tray indicator or run directly:
```bash
python3 ./battery-gui
```

## Installation

### Easy Installation (.deb Package - Recommended)
```bash
# Build the package
./build-deb.sh

# Install with automatic dependency resolution
sudo dpkg -i universal-battery-limiter_2.2.0_all.deb
# Dependencies are automatically installed!
```

### Manual Installation
```bash
./install.sh
```

### Manual Steps
1. Clone this repository
2. Make scripts executable:
   ```bash
   chmod +x battery-cli battery-limit set-charge-limit.sh battery-indicator install.sh
   ```
3. For system-wide installation with system tray integration:
   ```bash
   ./install.sh
   ```

### Uninstall
```bash
./uninstall.sh
```

## Requirements

- Laptop with battery charge control support
- Linux system with sysfs battery interface
- Ubuntu/Debian-based distribution (for .deb package)
- sudo privileges for setting limits

**Note**: All Python dependencies are automatically installed when using the .deb package.

## Compatibility

This tool works with laptops that support battery charge control through:
- `/sys/class/power_supply/BAT0/charge_control_end_threshold`

### Supported Brands
- ASUS (ZenBook, VivoBook, ROG, TUF Gaming)
- Lenovo (ThinkPad, IdeaPad)
- Dell (XPS, Inspiron, Latitude)
- HP (Pavilion, EliteBook)
- MSI, Acer, and many others

## Usage Examples

### Set specific limits
```bash
# Conservative daily use
sudo ./battery-cli 70

# Recommended daily use  
sudo ./battery-cli 80

# Long-term storage
sudo ./battery-cli 60

# Remove limit (charge to 100%)
sudo ./battery-cli 100
```

### Check battery information
```bash
./battery-limit status
```

## License

This project is open source. Feel free to use, modify, and distribute.

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests at:
https://github.com/FrancyAlinston/Laptop-Battery-Limiter
EOF

print_colored $GREEN "✅ Documentation updated successfully!"
print_colored $BLUE "📋 Updated files:"
echo "  ✓ README.md - Complete universal rebranding"
echo "  ✓ INSTALL.md - Updated package names and compatibility"
echo "  ✓ debian-package/usr/share/doc/universal-battery-limiter/README.md - Package documentation"
echo ""

print_colored $YELLOW "📝 Next steps:"
echo "  1. Review the updated documentation"
echo "  2. Run the branding fix script"
echo "  3. Test package building"
echo "  4. Commit all changes"
EOF

chmod +x update-documentation.sh
