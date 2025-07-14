# 🔋 Universal Battery Limiter

<<<<<<< HEAD
Professional battery charge limiting tool for laptops running Ubuntu/Linux. Helps extend battery lifespan by preventing overcharging.
=======
Professional battery charge limiting tool for all compatible laptops running **Linux** and **Windows**. Helps extend battery lifespan by preventing overcharging and works with multiple laptop brands.

## 🖥️ **Cross-Platform Support**

- **🐧 Linux Edition**: Ubuntu/Debian with APT, Snap, and .deb packages
- **🪟 Windows Edition**: Windows 10/11 with manufacturer-specific support ([Windows Version](windows-version/))
>>>>>>> b7bc7b0b56711038f603cfa2e7b321eb884ac7d4

## ✨ Features

### 🐧 **Linux Edition**
- **Multiple Installation Methods**: APT, Snap, .deb package, or manual
- **Ubuntu Native Updates**: Automatic updates through Software Updater (APT/Snap installs)
- **System Tray Integration**: Convenient access with battery status display
- **GUI Application**: User-friendly graphical interface
- **CLI Tools**: Command-line interface for advanced users
- **Professional Packaging**: Enterprise-grade installation and removal
<<<<<<< HEAD
- **Universal Compatibility**: Works with most laptop manufacturers that support ACPI battery control
=======

### 🪟 **Windows Edition** ([View Details](windows-version/))
- **Multi-Manufacturer Support**: Lenovo, Dell, HP, ASUS, and generic laptops
- **Windows 11 Integration**: Native GUI with system tray support
- **Smart Detection**: Automatically detects your laptop and available methods
- **Multiple APIs**: WMI, manufacturer tools, PowerShell power plans
- **UAC Integration**: Proper Windows privilege handling
- **Professional Installation**: Windows installer with uninstall support

## 🎨 Enhanced Animated Icons

The Universal Battery Limiter features beautiful, professional animated system tray icons inspired by premium icon sets:

### Animation States
- **⚡ Charging**: Energy waves, sparkling particles, and pulsing lightning bolt
- **🔋 Normal**: Gentle breathing animation with percentage display
- **⚠️ Low Battery**: Urgent blinking animation with warning indicators
- **✅ Limit Reached**: Success sparkles with checkmark and gentle glow
- **🔌 Disconnected**: Fading discharge animation with floating particles

### Demo
```bash
# View animations in browser
firefox animated-icons-demo.html

# Test animation system
python3 demo-animations.py
```

See [ANIMATED-ICONS.md](ANIMATED-ICONS.md) for detailed documentation.
>>>>>>> b7bc7b0b56711038f603cfa2e7b321eb884ac7d4

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
<<<<<<< HEAD
git clone https://github.com/FrancyAlinston/Laptop-Battery-Limiter.git
cd Laptop-Battery-Limiter
=======
git clone https://github.com/FrancyAlinston/Battery-Limter.git
cd Battery-Limter
>>>>>>> b7bc7b0b56711038f603cfa2e7b321eb884ac7d4

# Run installer
sudo ./install.sh
```

### Method 3: Build Your Own Package
```bash
# Clone and build
<<<<<<< HEAD
git clone https://github.com/FrancyAlinston/Laptop-Battery-Limiter.git
cd Laptop-Battery-Limiter
=======
git clone https://github.com/FrancyAlinston/Battery-Limter.git
cd Battery-Limter
>>>>>>> b7bc7b0b56711038f603cfa2e7b321eb884ac7d4
./build-deb.sh

# Install the built package
sudo dpkg -i universal-battery-limiter_*.deb
```

## 📱 Usage

### 🐧 **Linux Usage**

#### System Tray (Recommended)
- The battery indicator appears in your system tray after installation
- Click to access quick presets: 60%, 70%, 80%, 90%, 100%
- Right-click for full menu including GUI and settings

#### GUI Application
```bash
battery-gui
```

#### Command Line
```bash
# Interactive CLI
battery-cli

# Direct commands
battery-limit 80        # Set limit to 80%
battery-limit status    # Check current status
battery-limit reset     # Reset to 100%
```

<<<<<<< HEAD
## 🛠️ Supported Models
=======
### 🪟 **Windows Usage** ([Full Guide](windows-version/README.md))

#### GUI Application
- Double-click desktop shortcut or start from Start Menu
- Modern Windows 11 interface with system tray support
- Real-time battery monitoring and manufacturer detection

#### Command Line
```cmd
# Check battery status
battery_cli status

# Set charge limit
battery_cli set 80

# Show system information
battery_cli info

# Test compatibility
battery_cli test
```

#### PowerShell Integration
```powershell
# Advanced battery management
.\battery_manager.ps1 -Action set -Limit 80

# System information
.\battery_manager.ps1 -Action info

# Reset to full charging
.\battery_manager.ps1 -Action reset
```

## 🔄 Updates
>>>>>>> b7bc7b0b56711038f603cfa2e7b321eb884ac7d4

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
