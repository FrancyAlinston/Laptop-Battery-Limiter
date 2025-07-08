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
