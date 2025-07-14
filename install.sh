#!/bin/bash

# Universal Battery Limiter Installation Script
# Installs the battery limiter tools system-wide

set -e

# Setup comprehensive logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$HOME/.local/share/battery-limiter/logs"
INSTALL_LOG="$LOG_DIR/install.log"
ERROR_LOG="$LOG_DIR/error.log"
SYSTEM_LOG="$LOG_DIR/system.log"

# Create log directory
mkdir -p "$LOG_DIR"

# Enhanced logging functions
log_install() {
    local message="$1"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[$timestamp] [INSTALL] $message" | tee -a "$INSTALL_LOG"
}

log_error() {
    local message="$1"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[$timestamp] [ERROR] $message" | tee -a "$ERROR_LOG" | tee -a "$INSTALL_LOG"
}

log_info() {
    local message="$1"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[$timestamp] [INFO] $message" | tee -a "$SYSTEM_LOG" | tee -a "$INSTALL_LOG"
}

log_debug() {
    local message="$1"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[$timestamp] [DEBUG] $message" >> "$INSTALL_LOG"
}

# Function to log command execution
log_command() {
    local cmd="$1"
    local description="$2"
    log_install "EXECUTING: $description"
    log_debug "Command: $cmd"
    
    if eval "$cmd" 2>&1 | tee -a "$INSTALL_LOG"; then
        log_install "SUCCESS: $description"
        return 0
    else
        local exit_code=$?
        log_error "FAILED: $description (exit code: $exit_code)"
        return $exit_code
    fi
}

# Function to collect and log system information
collect_system_info() {
    log_install "=== SYSTEM INFORMATION COLLECTION ==="
    
    # OS Information
    log_info "Operating System: $(uname -a)"
    log_info "Distribution: $(lsb_release -a 2>/dev/null || echo 'Unknown')"
    log_info "Kernel: $(uname -r)"
    log_info "Architecture: $(uname -m)"
    
    # User Information
    log_info "User: $USER (UID: $EUID)"
    log_info "Home Directory: $HOME"
    log_info "Current Directory: $(pwd)"
    log_info "Script Directory: $SCRIPT_DIR"
    
    # Environment Information
    log_info "Desktop Environment: ${XDG_CURRENT_DESKTOP:-Unknown}"
    log_info "Session Type: ${XDG_SESSION_TYPE:-Unknown}"
    log_info "Display: ${DISPLAY:-Unknown}"
    log_info "Shell: $SHELL"
    
    # Python Information
    if command -v python3 >/dev/null 2>&1; then
        log_info "Python Version: $(python3 --version 2>&1)"
        log_info "Python Executable: $(which python3)"
        log_info "Python Path: $PYTHONPATH"
    else
        log_error "Python3 not found"
    fi
    
    # Package Manager Information
    if command -v apt >/dev/null 2>&1; then
        log_info "Package Manager: APT"
        log_info "APT Version: $(apt --version 2>&1 | head -1)"
    elif command -v yum >/dev/null 2>&1; then
        log_info "Package Manager: YUM"
    elif command -v dnf >/dev/null 2>&1; then
        log_info "Package Manager: DNF"
    else
        log_error "No supported package manager found"
    fi
    
    # Battery Information
    log_info "Battery Information:"
    for bat in /sys/class/power_supply/BAT*; do
        if [ -d "$bat" ]; then
            log_info "  Battery: $bat"
            [ -f "$bat/capacity" ] && log_info "    Capacity: $(cat "$bat/capacity" 2>/dev/null || echo 'Unknown')%"
            [ -f "$bat/status" ] && log_info "    Status: $(cat "$bat/status" 2>/dev/null || echo 'Unknown')"
            [ -f "$bat/charge_control_end_threshold" ] && log_info "    Threshold Support: YES" || log_info "    Threshold Support: NO"
        fi
    done
    
    # Disk Space
    log_info "Disk Space:"
    df -h / 2>/dev/null | tail -1 | while read -r filesystem size used avail use_percent mountpoint; do
        log_info "  Root: $use_percent used, $avail available"
    done
    
    # Memory Information
    if command -v free >/dev/null 2>&1; then
        log_info "Memory: $(free -h | grep '^Mem:' | awk '{print $2 " total, " $7 " available"}')"
    fi
    
    # Network Status
    log_info "Network Status: $(ping -c 1 google.com >/dev/null 2>&1 && echo 'Online' || echo 'Offline')"
    
    log_install "=== SYSTEM INFORMATION COLLECTION COMPLETE ==="
}

# Load logging system if available
if [ -f "$SCRIPT_DIR/logging-system.sh" ]; then
    source "$SCRIPT_DIR/logging-system.sh"
    log_install "Loaded centralized logging system"
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_colored() {
    echo -e "${1}${2}${NC}"
    log_install "${2}"
}

# Start installation logging
log_install "=== INSTALLATION STARTED ==="
log_install "Installation script: $0"
log_install "Arguments: $@"

# Collect comprehensive system information
collect_system_info

print_colored $BLUE "🔧 Universal Battery Limiter Installer"
echo "=================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    log_error "Script run as root (not recommended)"
    print_colored $RED "❌ Please do not run this script as root"
    print_colored $YELLOW "Run as normal user, sudo will be used when needed"
    exit 1
fi

log_install "Running as user: $USER (UID: $EUID)"

# Check if battery control is supported
THRESHOLD_FILE="/sys/class/power_supply/BAT0/charge_control_end_threshold"
log_install "Checking battery control support..."
log_install "Looking for threshold file: $THRESHOLD_FILE"

if [ ! -f "$THRESHOLD_FILE" ]; then
    log_error "Battery control not supported - threshold file not found"
    log_install "Checked file: $THRESHOLD_FILE"
    
    # Check for alternative batteries
    for bat in /sys/class/power_supply/BAT*; do
        if [ -d "$bat" ]; then
            log_install "Found battery directory: $bat"
            alt_threshold="$bat/charge_control_end_threshold"
            if [ -f "$alt_threshold" ]; then
                log_install "Found alternative threshold file: $alt_threshold"
                THRESHOLD_FILE="$alt_threshold"
                break
            fi
        fi
    done
    
    if [ ! -f "$THRESHOLD_FILE" ]; then
        print_colored $RED "❌ Battery charge control not supported on this system"
        print_colored $RED "File not found: $THRESHOLD_FILE"
        log_error "No battery threshold files found on system"
        log_install "Available battery directories:"
        ls -la /sys/class/power_supply/ 2>&1 | tee -a "$INSTALL_LOG"
        exit 1
    fi
fi

log_install "Battery control supported: $THRESHOLD_FILE"
print_colored $GREEN "✅ Battery charge control supported"

# Install dependencies
print_colored $YELLOW "📦 Installing dependencies..."
log_install "Starting dependency installation..."

if command -v apt >/dev/null 2>&1; then
    log_install "APT package manager detected"
    
    # Check if apt is working properly
    log_install "Testing APT functionality..."
    if log_command "sudo apt update" "APT package list update"; then
        log_install "APT update successful"
        
        # Try to install dependencies, continue if some fail
        print_colored $BLUE "Installing Python GTK dependencies..."
        log_install "Installing dependencies: python3-gi python3-gi-cairo gir1.2-gtk-3.0 gir1.2-appindicator3-0.1 gir1.2-notify-0.7 python3-tk"
        
        if log_command "sudo apt install -y python3-gi python3-gi-cairo gir1.2-gtk-3.0 gir1.2-appindicator3-0.1 gir1.2-notify-0.7 python3-tk" "Python GTK dependencies installation"; then
            log_install "All dependencies installed successfully"
        else
            log_error "Some dependencies failed to install"
            print_colored $YELLOW "⚠️ Some dependencies may not be available, continuing..."
        fi
    else
        log_error "APT update failed"
        print_colored $YELLOW "⚠️ Package manager issues detected, continuing with installation..."
    fi
else
    log_error "APT not available"
    print_colored $YELLOW "⚠️ APT not available, please install dependencies manually:"
    print_colored $BLUE "  python3-gi python3-gi-cairo gir1.2-gtk-3.0 gir1.2-appindicator3-0.1 gir1.2-notify-0.7 python3-tk"
fi

# Create directories
print_colored $YELLOW "📁 Creating directories..."
log_install "Creating installation directories..."
log_command "sudo mkdir -p /usr/local/bin" "Create /usr/local/bin directory"
log_command "sudo mkdir -p /usr/share/applications" "Create /usr/share/applications directory"
log_command "mkdir -p ~/.config/autostart" "Create autostart directory"

# Copy executables
print_colored $YELLOW "📋 Installing executables..."
log_install "Installing main executables..."

# Check if files exist before copying
files_to_copy=("battery-cli" "battery-limit" "battery-gui" "battery-indicator" "set-charge-limit.sh")
for file in "${files_to_copy[@]}"; do
    if [ -f "$file" ]; then
        log_command "sudo cp '$file' /usr/local/bin/" "Copy $file to /usr/local/bin"
    else
        log_error "File not found: $file"
    fi
done

# Copy logger if it exists
if [ -f "battery_logger.py" ]; then
    log_command "sudo cp battery_logger.py /usr/local/bin/" "Copy battery_logger.py"
else
    log_error "battery_logger.py not found"
fi

# Make executable
log_install "Setting executable permissions..."
log_command "sudo chmod +x /usr/local/bin/battery-*" "Set executable permissions for battery scripts"
log_command "sudo chmod +x /usr/local/bin/set-charge-limit.sh" "Set executable permissions for set-charge-limit.sh"

# Create battery indicator launcher to fix library conflicts
print_colored $YELLOW "🔧 Creating system tray launcher..."
log_install "Creating battery indicator launcher..."
log_command "sudo tee /usr/local/bin/battery-indicator-launcher > /dev/null << 'EOF'
#!/bin/bash
# Battery Indicator Launcher Script
# Fixes library conflicts with snap packages

# Enhanced logging
LOG_DIR=\"\$HOME/.local/share/battery-limiter/logs\"
LAUNCHER_LOG=\"\$LOG_DIR/indicator.log\"
mkdir -p \"\$LOG_DIR\"

log_launcher() {
    echo \"[\$(date '+%Y-%m-%d %H:%M:%S')] [LAUNCHER] \$1\" | tee -a \"\$LAUNCHER_LOG\"
}

log_launcher \"=== BATTERY INDICATOR LAUNCHER STARTED ===\"
log_launcher \"User: \$USER\"
log_launcher \"Desktop: \$XDG_CURRENT_DESKTOP\"
log_launcher \"Session: \$XDG_SESSION_TYPE\"
log_launcher \"Display: \$DISPLAY\"

# Check for snap environment
if [ -n \"\$SNAP\" ]; then
    log_launcher \"Snap environment detected, cleaning up...\"
    # Unset problematic environment variables
    unset LD_LIBRARY_PATH
    unset PYTHONPATH
    unset SNAP_LIBRARY_PATH
    unset SNAP_PYTHON_PATH
    log_launcher \"Snap environment variables unset\"
fi

# Set clean environment
export PATH=\"/usr/local/bin:/usr/bin:/bin\"
export PYTHONPATH=\"/usr/local/lib/python3/dist-packages:/usr/lib/python3/dist-packages\"

log_launcher \"Environment cleaned, starting battery indicator...\"
log_launcher \"Command: battery-indicator\"

# Start battery indicator with error handling
if battery-indicator 2>&1 | tee -a \"\$LAUNCHER_LOG\"; then
    log_launcher \"Battery indicator started successfully\"
else
    log_launcher \"Battery indicator failed to start\"
    exit 1
fi
EOF" "Create battery indicator launcher"
unset LD_LIBRARY_PATH
unset PYTHONPATH

# Set proper library path
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"

# Launch battery indicator
exec /usr/local/bin/battery-indicator "$@"
EOF

sudo chmod +x /usr/local/bin/battery-indicator-launcher

# Install desktop entries
print_colored $YELLOW "🖥️ Setting up autostart..."

# Create autostart entry
cat > ~/.config/autostart/battery-limiter.desktop << EOF
[Desktop Entry]
Name=Universal Battery Limiter
Comment=Battery charge limit management for all laptops
Exec=/usr/local/bin/battery-indicator-launcher
Icon=battery
Terminal=false
Type=Application
Categories=System;Settings;
StartupNotify=true
X-GNOME-Autostart-enabled=true
X-GNOME-AutoRestart=true
Hidden=false
EOF

# Set up sudo permissions for battery control
print_colored $YELLOW "🔐 Setting up sudo permissions..."
SUDOERS_FILE="/etc/sudoers.d/battery-limiter"
sudo tee "$SUDOERS_FILE" > /dev/null << EOF
# Allow users to set battery charge limits without password
%sudo ALL=(ALL) NOPASSWD: /usr/local/bin/set-charge-limit.sh
%sudo ALL=(ALL) NOPASSWD: /bin/bash -c echo * > /sys/class/power_supply/BAT0/charge_control_end_threshold
EOF

sudo chmod 440 "$SUDOERS_FILE"

# Update desktop database
if command -v update-desktop-database >/dev/null 2>&1; then
    sudo update-desktop-database 2>/dev/null || true
fi

# Installation completion logging
log_install "=== INSTALLATION COMPLETED ==="
log_install "Installation successful at $(date)"
log_install "Log files created in: $LOG_DIR"

# Final system information
if command -v collect_full_system_info >/dev/null 2>&1; then
    log_install "Collecting post-installation system information..."
    collect_full_system_info
fi

print_colored $GREEN "✅ Installation completed!"
echo
print_colored $BLUE "🚀 Available commands:"
echo "  battery-cli               - Interactive CLI"
echo "  battery-limit             - Simple CLI commands"
echo "  battery-indicator         - System tray indicator"
echo "  battery-indicator-launcher - System tray launcher (fixes library conflicts)"
echo "  battery-gui               - GUI application"
echo
print_colored $BLUE "🔄 The system tray indicator will start automatically on next login"
print_colored $YELLOW "Or start it now: battery-indicator-launcher"
echo
print_colored $BLUE "🧪 Test the installation:"
echo "  battery-cli status        - Check current battery status"
echo "  battery-gui               - Open GUI application"
echo
print_colored $BLUE "📋 View installation logs:"
echo "  $SCRIPT_DIR/logging-system.sh show"
echo "  tail -f $INSTALL_LOG"
echo
print_colored $GREEN "✨ Installation successful! You can now manage your battery limit from the system tray."

log_install "Installation script completed successfully"
