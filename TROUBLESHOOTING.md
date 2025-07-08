# Universal Battery Limiter - Troubleshooting Guide

## 🔧 Common Issues and Solutions

This guide addresses the most common installation and runtime issues encountered with Universal Battery Limiter.

### 📋 Quick Diagnostic

Run the comprehensive diagnostic script to automatically check for common issues and install with full logging:

```bash
./diagnose-and-install.sh
```

This script will:
- Check system requirements and compatibility
- Diagnose and fix package manager issues
- Install with comprehensive logging
- Test the installation
- Show detailed log analysis

**Alternative diagnostic options:**
```bash
# Basic diagnostic (legacy)
./diagnose-and-fix.sh

# View installation and runtime logs
./view-logs.sh all

# View only errors from all logs
./view-logs.sh errors

# Live log monitoring
./view-logs.sh live
```

### 📊 Logging System

The Universal Battery Limiter now includes a comprehensive logging system that tracks:

- **Installation Process**: Complete log of installation steps, errors, and system information
- **Runtime Events**: Battery status changes, limit modifications, GUI operations
- **Error Tracking**: Detailed error logs with context and stack traces
- **System Information**: Environment details, dependencies, and configuration

**Log Files Location**: `~/.local/share/battery-limiter/logs/`

**Log Files:**
- `install.log` - Installation process and system setup
- `error.log` - All errors from all components
- `system.log` - System events and information
- `debug.log` - Detailed debug information
- `events.log` - Structured events in JSON format
- `gui.log` - GUI application events
- `indicator.log` - System tray indicator events
- `diagnostic.log` - Diagnostic script output

**View Logs:**
```bash
# View all logs
./view-logs.sh all

# View installation log
./view-logs.sh install

# View runtime logs (GUI, indicator)
./view-logs.sh runtime

# View only errors
./view-logs.sh errors

# View log summary
./view-logs.sh summary

# Live log monitoring
./view-logs.sh live

# Clear all logs
./view-logs.sh clear
```

### 🔄 Enhanced Installation Process

The installation process now includes:

1. **Pre-installation Checks**:
   - System requirements validation
   - Battery support verification
   - Package manager health check
   - Disk space and network connectivity

2. **Comprehensive Logging**:
   - Every installation step is logged
   - System information collection
   - Error tracking with context
   - Command execution logging

3. **Post-installation Validation**:
   - Component testing
   - Functionality verification
   - Log analysis and summary

**Enhanced Installation Commands:**
```bash
# Comprehensive installation with diagnostics
./diagnose-and-install.sh

# Standard installation (now with enhanced logging)
./install.sh

# View installation logs
./view-logs.sh install
```

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

#### 6. **System Tray Icon Not Showing**

**Problem**: System tray icon doesn't appear even though the process is running

**Common Causes**:
- AppIndicator3 libraries missing or broken
- System tray not supported by desktop environment
- Library conflicts with snap packages
- Process crashes silently on startup

**🔧 QUICK FIX - Use the automated solution:**
```bash
# Run the comprehensive system tray fix
./fix-system-tray.sh
```

**Manual Solutions**:

**Step 1: Check if AppIndicator3 is working**
```bash
# Test AppIndicator3 import
python3 -c "
try:
    import gi
    gi.require_version('Gtk', '3.0')
    gi.require_version('AppIndicator3', '0.1')
    from gi.repository import Gtk, AppIndicator3
    print('✅ AppIndicator3 import successful')
except Exception as e:
    print(f'❌ AppIndicator3 import failed: {e}')
"
```

**Step 2: Install system tray support**
```bash
# For Ubuntu/Unity
sudo apt install gir1.2-appindicator3-0.1

# For GNOME (requires extension)
sudo apt install gnome-shell-extension-appindicator

# For KDE
sudo apt install plasma-workspace-dev
```

**Step 3: Alternative Solutions**

**Option A: Notification-based monitoring**
```bash
# Creates a background service that shows notifications
./fix-system-tray.sh  # Choose option 2
battery-notifier &
```

**Option B: Desktop widget**
```bash
# Creates a small floating window showing battery status
./fix-system-tray.sh  # Choose option 3
battery-widget &
```

**Option C: GUI application (always works)**
```bash
# Full GUI interface - most reliable option
battery-gui &
```

**Step 4: Test the indicator manually**
```bash
# Kill any existing instances
pkill -f battery-indicator

# Start with debug output
battery-indicator-launcher 2>&1 | head -20

# Check if process is running
ps aux | grep battery-indicator
```

**Step 5: Use alternative system tray methods**
```bash
# Try with different backends
export GDK_BACKEND=x11
battery-indicator-launcher &

# Or use notification-based approach
battery-notifier &  # New notification service
```

**Step 6: Desktop Environment Specific Fixes**

**GNOME/Ubuntu:**
```bash
# Enable system tray extension
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com

# Or install TopIcons Plus
sudo apt install gnome-shell-extension-top-icons-plus
```

**Unity:**
```bash
# Unity has built-in system tray support
# Use notification-based alternative if icon doesn't show
battery-notifier &
```

**KDE/Plasma:**
```bash
# System tray is built-in, check if it's enabled
# Right-click on panel → Add Widgets → System Tray
```

**XFCE:**
```bash
# Add notification area to panel
# Right-click panel → Panel → Add New Items → Notification Area
```

### 🔧 **System Tray Icon Troubleshooting Commands**

Quick diagnostic commands:
```bash
# Check what's running
ps aux | grep battery

# Check system tray support
echo $XDG_CURRENT_DESKTOP
echo $XDG_SESSION_TYPE

# Test with simple indicator
python3 -c "
import gi
gi.require_version('AppIndicator3', '0.1')
from gi.repository import AppIndicator3, Gtk
indicator = AppIndicator3.Indicator.new('test', 'battery', AppIndicator3.IndicatorCategory.SYSTEM_SERVICES)
indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)
print('Test indicator created')
"

# Check logs for errors
journalctl --user -f | grep -i indicator
```

### 📋 **Recommended Solutions by Desktop Environment**

| Desktop Environment | Recommended Solution |
|-------------------|-------------------|
| GNOME/Ubuntu | `battery-notifier &` |
| Unity | `battery-widget &` |
| KDE/Plasma | `battery-indicator-launcher &` |
| XFCE | `battery-indicator-launcher &` |
| Any/Fallback | `battery-gui &` |

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

1. **Run the comprehensive diagnostic**:
   ```bash
   ./diagnose-and-install.sh
   ```

2. **Check the logs**:
   ```bash
   ./view-logs.sh errors    # View all errors
   ./view-logs.sh summary   # View log summary
   ./view-logs.sh all       # View all logs
   ```

3. **Collect system information**:
   ```bash
   # System info
   uname -a
   lsb_release -a
   python3 --version

   # Battery info
   ls -la /sys/class/power_supply/

   # Installation info
   which battery-cli battery-gui battery-indicator

   # Recent logs
   ./view-logs.sh install | tail -50
   ```

4. **Check the project's GitHub issues**

5. **When reporting issues, include**:
   - Output from `./diagnose-and-install.sh`
   - Error logs from `./view-logs.sh errors`
   - System information from the commands above
   - Steps to reproduce the issue

### 🔍 Advanced Troubleshooting with Logs

#### Analyzing Installation Issues

```bash
# Check installation log for errors
./view-logs.sh install | grep -i error

# Check what happened during dependency installation
./view-logs.sh install | grep -A 5 -B 5 "Installing dependencies"

# Check if all files were copied correctly
./view-logs.sh install | grep -i "copy\|install"
```

#### Analyzing Runtime Issues

```bash
# Check GUI errors
./view-logs.sh runtime | grep -i error

# Check system tray issues
tail -f ~/.local/share/battery-limiter/logs/indicator.log

# Check battery status changes
./view-logs.sh all | grep -i "battery.*status"
```

#### Debug Mode

Enable debug mode for detailed logging:

```bash
# Enable debug mode for Python components
export BATTERY_DEBUG=1

# Run with debug output
battery-gui --debug
battery-indicator --verbose

# Check debug logs
tail -f ~/.local/share/battery-limiter/logs/debug.log
```

### 🛠️ Log Management

#### Automated Log Rotation

Logs are automatically rotated when they exceed 10MB:

```bash
# Check log sizes
./view-logs.sh summary

# Manually rotate logs
./logging-system.sh rotate

# Clear old logs
./logging-system.sh clear
```

#### Log Analysis Commands

```bash
# Find specific errors
grep -r "ImportError\|ModuleNotFoundError" ~/.local/share/battery-limiter/logs/

# Find battery-related issues
grep -r "battery\|threshold\|charge" ~/.local/share/battery-limiter/logs/

# Find GUI-related issues
grep -r "gtk\|tkinter\|display" ~/.local/share/battery-limiter/logs/

# Find system tray issues
grep -r "indicator\|appindicator\|tray" ~/.local/share/battery-limiter/logs/
```

### 🔧 Script Improvements Made

The following improvements were made to handle common errors:

#### **Comprehensive Logging System Added** ✅
- **Installation Logging**: All installation steps logged to `~/.local/share/battery-limiter/logs/install.log`
- **Error Logging**: Detailed error tracking in `~/.local/share/battery-limiter/logs/error.log`
- **System Logging**: General application logs in `~/.local/share/battery-limiter/logs/system.log`
- **Debug Logging**: Detailed debug information in `~/.local/share/battery-limiter/logs/debug.log`
- **Component Logs**: Individual logs for GUI, indicator, and other components

#### **Logging Management Commands**:
```bash
# View log status
./logging-system.sh show

# Collect full system information
./logging-system.sh info

# Clear all logs
./logging-system.sh clear

# Rotate large logs
./logging-system.sh rotate

# Follow logs in real-time
tail -f ~/.local/share/battery-limiter/logs/install.log
tail -f ~/.local/share/battery-limiter/logs/error.log
tail -f ~/.local/share/battery-limiter/logs/system.log
```

#### **What Gets Logged During Installation**:
- ✅ Complete system information (OS, kernel, desktop environment)
- ✅ Battery system details (available batteries, threshold files)
- ✅ Package manager status and dependency installation
- ✅ Python environment and library availability
- ✅ File installation and permission setting
- ✅ Process creation and startup status
- ✅ All errors with full context and timestamps

#### **Application Runtime Logging**:
- ✅ GUI application startup and errors (`gui.log`)
- ✅ System tray indicator status (`indicator.log`)
- ✅ Battery monitoring and notifications
- ✅ User actions and battery limit changes
- ✅ Library conflicts and environment issues

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
