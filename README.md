# 🔋 Universal Battery Limiter

Professional battery charge limiting tool for all compatible laptops running Ubuntu/Linux. Helps extend battery lifespan by preventing overcharging and works with multiple laptop brands.

## ✨ Features

- **Multiple Installation Methods**: APT, Snap, .deb package, or manual
- **Ubuntu Native Updates**: Automatic updates through Software Updater (APT/Snap installs)
- **System Tray Integration**: Convenient access with battery status display
- **Beautiful Animated Icons**: Professional animated system tray icons that respond to battery state
- **GUI Application**: User-friendly graphical interface
- **CLI Tools**: Command-line interface for advanced users
- **Professional Packaging**: Enterprise-grade installation and removal

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

## 🚀 Quick Installation

### Method 1: Direct .deb Package (Recommended)
```bash
# Download the latest release
wget https://github.com/FrancyAlinston/Laptop-Battery-Limiter/releases/latest/download/universal-battery-limiter_2.0.0_all.deb

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

- Compatible laptop with ACPI battery charge control interface
- Ubuntu 18.04+ or compatible Linux distribution
- Python 3.6+
- Root/sudo access for installation

### Dependencies (automatically installed)
- `python3-gi`
- `gir1.2-gtk-3.0`
- `gir1.2-appindicator3-0.1`
- `zenity`
- `acpi`

## 🛠️ Supported Laptops

This tool works with laptops that support ACPI battery charge control, including:
- **Lenovo**: ThinkPad, IdeaPad, Legion series
- **HP**: Pavilion, Envy, Omen series
- **Dell**: XPS, Inspiron, Latitude series
- **ASUS**: ZenBook, VivoBook, ROG, TUF Gaming series
- **Acer**: Aspire, Predator, Swift series
- **MSI**: Gaming and Creator series
- **And many other brands that support charge control**

### Compatibility Check
```bash
# Check if your laptop supports battery charge control
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
