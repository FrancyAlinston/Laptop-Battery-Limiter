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
sudo dpkg -i universal-battery-limiter_2.0.0_all.deb
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
