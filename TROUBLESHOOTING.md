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
# Use the enhanced uninstall script to fix dpkg corruption
./uninstall.sh --fix-dpkg

# Or manually fix the corrupted file
sudo cp /var/lib/dpkg/status /var/lib/dpkg/status.backup
sudo dpkg --configure -a

# If that fails, use the diagnostic script
./diagnose-and-fix.sh
```

**Enhanced Uninstall Features**: The new comprehensive uninstall script:
- ✅ **Automatic dpkg corruption detection and cleanup**
- ✅ **Complete removal from all system locations**
- ✅ **Automatic backup creation before removal**
- ✅ **Process termination and cleanup**
- ✅ **System database updates**
- ✅ **Environment variable cleanup**
- ✅ **Verification and reporting**

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

If issues persist, perform a comprehensive clean reinstallation:

```bash
# 1. Use the enhanced comprehensive uninstall
./uninstall.sh

# 2. Fix any dpkg corruption if detected
./uninstall.sh --fix-dpkg

# 3. Verify complete removal
which battery-cli battery-gui battery-indicator 2>/dev/null || echo "✅ All executables removed"

# 4. Check for remaining processes
ps aux | grep battery | grep -v grep || echo "✅ No battery processes running"

# 5. Fresh installation
./install.sh

# 6. Test the installation
./diagnose-and-fix.sh
```

**Enhanced Uninstall Script Features:**
- 🔋 **Battery Reset**: Automatically resets battery limit to 100% before removal
- 📦 **dpkg Cleanup**: Detects and fixes corrupted package manager entries
- 🗑️ **Complete Removal**: Removes files from all possible locations (/usr/local/bin, /usr/bin, ~/.local/bin)
- ⏹️ **Process Management**: Safely stops all battery-related processes
- 🔐 **Permission Cleanup**: Removes sudo permissions and systemd services
- 🧹 **Environment Cleanup**: Cleans shell aliases and environment variables
- 💾 **Automatic Backup**: Creates timestamped backups before removal
- 📊 **Verification**: Reports any remaining files or processes
- 📝 **Comprehensive Logging**: Logs all uninstall actions for troubleshooting

**Uninstall Options:**
```bash
# Standard comprehensive uninstall
./uninstall.sh

# Force dpkg cleanup (use if package manager is corrupted)
./uninstall.sh --fix-dpkg

# View uninstall logs
cat ~/.local/share/battery-limiter/logs/uninstall.log
```

### 🗑️ Comprehensive Uninstall Script

The Universal Battery Limiter now includes a powerful comprehensive uninstall script designed to completely remove all traces of the application from your system, including fixing package manager corruption issues.

#### **Features of the Enhanced Uninstall Script:**

1. **🔍 Intelligent Detection**:
   - Detects package installations vs manual installations
   - Identifies dpkg corruption and offers automatic fixes
   - Scans multiple system locations for files

2. **💾 Safe Removal with Backup**:
   - Creates timestamped backups before any removal
   - Safely removes files from all possible locations
   - Preserves important system configurations

3. **🔧 System Repair**:
   - Fixes corrupted dpkg status files
   - Cleans orphaned package entries
   - Updates system databases after removal

4. **📊 Comprehensive Reporting**:
   - Detailed logging of all actions
   - Verification of removal completeness
   - Reports any remaining files or processes

#### **Usage Examples:**

```bash
# Standard comprehensive uninstall
./uninstall.sh

# Force fix dpkg corruption during uninstall
./uninstall.sh --fix-dpkg

# Check uninstall logs
cat ~/.local/share/battery-limiter/logs/uninstall.log

# Verify backup location
ls -la ./backups/uninstall-*/
```

#### **What Gets Removed:**

**Executables from all locations:**
- `/usr/local/bin/battery-*`
- `/usr/bin/battery-*`
- `~/.local/bin/battery-*`
- All launcher scripts and aliases

**Configuration and Data:**
- `~/.config/battery-limiter/`
- `~/.local/share/battery-limiter/`
- `~/.cache/battery-limiter/`
- `/etc/battery-limiter/`

**System Integration:**
- Autostart files from `~/.config/autostart/` and `/etc/xdg/autostart/`
- Desktop entries from `/usr/share/applications/` and `~/.local/share/applications/`
- Sudo permissions from `/etc/sudoers.d/`
- Systemd services (both system and user)

**Environment Cleanup:**
- Shell aliases and exports from `.bashrc`, `.zshrc`, `.profile`
- Environment variables
- Package manager entries (with corruption fix)

**System Database Updates:**
- Desktop database refresh
- Icon cache update
- MIME database update
- Package cache cleanup

#### **Recovery Options:**

If you need to recover after uninstall:

```bash
# Restore from backup
BACKUP_DIR="./backups/uninstall-YYYYMMDD_HHMMSS"
sudo cp "$BACKUP_DIR/battery-cli" /usr/local/bin/
sudo cp "$BACKUP_DIR/battery-gui" /usr/local/bin/
# ... restore other files as needed

# Or reinstall fresh
./install.sh
```

#### **Troubleshooting Uninstall Issues:**

```bash
# If uninstall script fails
sudo pkill -f battery  # Force stop all processes
sudo rm -rf /usr/local/bin/battery-*  # Manual removal
./uninstall.sh --fix-dpkg  # Fix package manager

# If dpkg corruption persists
sudo cp /var/lib/dpkg/status /var/lib/dpkg/status.backup
sudo dpkg --configure -a

# Check for remaining traces
find /usr -name "*battery*" 2>/dev/null
find ~ -name "*battery*" 2>/dev/null
```
