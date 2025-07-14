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

## 🗑️ Uninstallation

### For .deb package installations:
```bash
sudo apt remove universal-battery-limiter
```

### For manual installations:
```bash
sudo ./uninstall.sh
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This tool modifies system power management settings. Use at your own risk. The authors are not responsible for any damage to your device.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/FrancyAlinston/Laptop-Battery-Limiter/issues)
- **Discussions**: [GitHub Discussions](https://github.com/FrancyAlinston/Laptop-Battery-Limiter/discussions)
