# ASUS Battery Limiter

A comprehensive battery charge limit management tool for ASUS laptops with multiple interfaces.

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
sudo dpkg -i asus-battery-limiter_1.0.0_all.deb
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

- ASUS laptop with battery charge control support
- Linux system with sysfs battery interface
- Ubuntu/Debian-based distribution (for .deb package)
- sudo privileges for setting limits

**Note**: All Python dependencies are automatically installed when using the .deb package.

## Compatibility

This tool works with ASUS laptops that support battery charge control through:
- `/sys/class/power_supply/BAT0/charge_control_end_threshold`

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
