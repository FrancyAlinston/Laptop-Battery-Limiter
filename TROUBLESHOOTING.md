# Universal Battery Limiter - Troubleshooting Guide

## 🔧 Common Issues and Solutions

This guide addresses the most common installation and runtime issues encountered with Universal Battery Limiter.

### 📋 Quick Diagnostic

Run the diagnostic script to automatically check for common issues:

```bash
./diagnose-and-fix.sh
```

This script will:
- Check package manager status
- Verify battery support
- Check dependencies
- Test functionality
- Apply common fixes

### 🚨 Known Issues and Solutions

#### 1. **Package Manager Issues**

**Problem**: `dpkg: error: parsing file '/var/lib/dpkg/status'`

**Solution**:
```bash
# Back up the current status file
sudo cp /var/lib/dpkg/status /var/lib/dpkg/status.backup

# Try to fix the corrupted file
sudo dpkg --configure -a

# If that fails, use the diagnostic script
./diagnose-and-fix.sh
```

#### 2. **System Tray Indicator Library Conflicts**

**Problem**: `python3: symbol lookup error: ... undefined symbol: __libc_pthread_init`

**Solution**: Use the launcher script instead of the direct indicator:
```bash
# Use this instead of battery-indicator
battery-indicator-launcher

# Or update autostart entry
sed -i 's|battery-indicator|battery-indicator-launcher|g' ~/.config/autostart/battery-limiter.desktop
```

#### 3. **Missing Dependencies**

**Problem**: GTK/GI import errors

**Solution**:
```bash
# Install all required dependencies
sudo apt update
sudo apt install -y python3-gi python3-gi-cairo gir1.2-gtk-3.0 gir1.2-appindicator3-0.1 gir1.2-notify-0.7 python3-tk

# If apt is broken, fix it first
sudo apt --fix-broken install
```

#### 4. **Battery Control Not Supported**

**Problem**: `Battery charge control not supported on this system`

**Solution**:
```bash
# Check if any battery threshold files exist
ls -la /sys/class/power_supply/BAT*/charge_control_end_threshold

# If no files exist, your system doesn't support battery limiting
# Consider using TLP or other power management tools
```

#### 5. **Permission Issues**

**Problem**: `Permission denied` when setting battery limits

**Solution**:
```bash
# Fix sudo permissions
sudo tee /etc/sudoers.d/battery-limiter > /dev/null << 'EOF'
%sudo ALL=(ALL) NOPASSWD: /usr/local/bin/set-charge-limit.sh
%sudo ALL=(ALL) NOPASSWD: /bin/bash -c echo * > /sys/class/power_supply/BAT0/charge_control_end_threshold
EOF

sudo chmod 440 /etc/sudoers.d/battery-limiter
```

### 🔄 Clean Reinstallation

If issues persist, perform a clean reinstallation:

```bash
# 1. Completely remove the current installation
./uninstall.sh

# 2. Clean up any remaining files
sudo rm -f /usr/local/bin/battery-*
sudo rm -f /usr/local/bin/set-charge-limit.sh
sudo rm -f /etc/sudoers.d/battery-limiter
rm -f ~/.config/autostart/battery-limiter.desktop

# 3. Install fresh
./install.sh

# 4. Test the installation
./diagnose-and-fix.sh
```

### 🧪 Testing Components

Test each component individually:

```bash
# Test CLI
battery-cli status

# Test GUI (with timeout to avoid hanging)
timeout 10 battery-gui

# Test indicator with launcher
battery-indicator-launcher &
```

### 🔍 Advanced Troubleshooting

#### Enable Debug Mode

For detailed error information:

```bash
# Enable debug mode for Python scripts
export PYTHONPATH="/usr/local/lib/python3/dist-packages:$PYTHONPATH"
export G_MESSAGES_DEBUG=all

# Run components with verbose output
battery-indicator --verbose
```

#### Check System Logs

```bash
# Check for battery-related errors
journalctl -u battery-* --since "1 hour ago"

# Check system log for GTK errors
journalctl --since "1 hour ago" | grep -i gtk
```

#### Alternative Battery Paths

If your system uses a different battery path:

```bash
# Find your battery path
find /sys/class/power_supply -name "charge_control_end_threshold"

# Update the scripts to use your battery path
# Edit battery-cli, set-charge-limit.sh, etc.
```

### 🌟 Best Practices

1. **Always run diagnostic script first**: `./diagnose-and-fix.sh`
2. **Use the launcher for system tray**: `battery-indicator-launcher`
3. **Check battery support before installation**: Verify threshold files exist
4. **Keep dependencies updated**: `sudo apt update && sudo apt upgrade`
5. **Use GUI for complex operations**: `battery-gui` is more reliable than indicator

### 📞 Getting Help

If you're still experiencing issues:

1. Run the diagnostic script and save output
2. Check the project's GitHub issues
3. Provide system information:
   ```bash
   uname -a
   lsb_release -a
   python3 --version
   ls -la /sys/class/power_supply/
   ```

### 🔧 Script Improvements Made

The following improvements were made to handle common errors:

#### `install.sh`:
- ✅ Better dependency checking and error handling
- ✅ Automatic creation of library conflict launcher
- ✅ Graceful handling of package manager issues
- ✅ Improved autostart configuration

#### `uninstall.sh`:
- ✅ Safe package manager checking
- ✅ Removal of all launcher scripts
- ✅ Better error handling for missing components

#### `battery-cli`:
- ✅ Multi-battery system support (BAT0, BAT1, etc.)
- ✅ Better error detection and reporting
- ✅ Improved file validation

#### `battery-indicator`:
- ✅ Library conflict detection and handling
- ✅ Better GTK import error handling
- ✅ Snap package environment compatibility

#### `set-charge-limit.sh`:
- ✅ Auto-detection of battery threshold files
- ✅ Enhanced input validation
- ✅ Better error messages

#### New Scripts:
- ✅ `diagnose-and-fix.sh` - Comprehensive system diagnostic
- ✅ `battery-indicator-launcher` - Library conflict resolver
