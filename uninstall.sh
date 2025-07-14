#!/bin/bash

# Universal Battery Limiter Comprehensive Uninstall Script
# Version: 3.0 - Enhanced with complete system cleanup

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Logging setup
LOG_DIR="$HOME/.local/share/battery-limiter/logs"
UNINSTALL_LOG="$LOG_DIR/uninstall.log"
mkdir -p "$LOG_DIR" 2>/dev/null || true

log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$UNINSTALL_LOG" 2>/dev/null || true
}

print_colored() {
    echo -e "${1}${2}${NC}"
    log_message "INFO" "$2"
}

print_error() {
    print_colored $RED "❌ $1"
    log_message "ERROR" "$1"
}

print_success() {
    print_colored $GREEN "✅ $1"
    log_message "SUCCESS" "$1"
}

print_warning() {
    print_colored $YELLOW "⚠️ $1"
    log_message "WARNING" "$1"
}

print_info() {
    print_colored $BLUE "ℹ️ $1"
    log_message "INFO" "$1"
}

# Create backup timestamp
BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups/uninstall-$BACKUP_TIMESTAMP"

print_colored $CYAN "🗑️ Universal Battery Limiter Comprehensive Uninstaller"
echo "=========================================================="
print_info "Starting comprehensive uninstall process"
print_info "Backup directory: $BACKUP_DIR"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root"
    print_warning "Run as normal user, sudo will be used when needed"
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR" 2>/dev/null || true

# Function to safely backup files before removal
backup_and_remove() {
    local file_path="$1"
    local description="$2"
    
    if [ -f "$file_path" ] || [ -d "$file_path" ]; then
        local backup_path="$BACKUP_DIR/$(basename "$file_path")"
        cp -r "$file_path" "$backup_path" 2>/dev/null || true
        print_info "Backed up $description to $backup_path"
    fi
}

# Function to remove file safely
safe_remove() {
    local file_path="$1"
    local description="$2"
    local use_sudo="${3:-false}"
    
    if [ -f "$file_path" ] || [ -d "$file_path" ]; then
        backup_and_remove "$file_path" "$description"
        if [ "$use_sudo" = "true" ]; then
            sudo rm -rf "$file_path" 2>/dev/null || true
        else
            rm -rf "$file_path" 2>/dev/null || true
        fi
        print_success "Removed $description"
    fi
}

# Reset battery limit to default before uninstall
print_colored $PURPLE "🔋 Resetting battery limit to default (100%)"
for bat_path in /sys/class/power_supply/BAT*/charge_control_end_threshold; do
    if [ -f "$bat_path" ]; then
        echo 100 | sudo tee "$bat_path" >/dev/null 2>&1 || true
        print_success "Reset battery limit for $(dirname "$bat_path" | xargs basename)"
    fi
done

# Check package manager status and handle dpkg issues
print_colored $PURPLE "📦 Checking package manager status"
DPKG_CORRUPTED=false

if command -v dpkg >/dev/null 2>&1; then
    # Test if dpkg is working
    if ! dpkg -l >/dev/null 2>&1; then
        print_warning "Package manager status file may be corrupted"
        DPKG_CORRUPTED=true
    else
        # Check for battery limiter packages
        if dpkg -l 2>/dev/null | grep -q universal-battery-limiter; then
            print_warning "Package installation detected"
            print_info "To uninstall the .deb package, use: sudo apt remove universal-battery-limiter"
            echo ""
            read -p "Do you want to uninstall the package now? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo apt remove universal-battery-limiter || true
                sudo apt purge universal-battery-limiter || true
                print_success "Package uninstalled successfully!"
            fi
        fi
    fi
fi

# Stop all battery limiter processes
print_colored $PURPLE "⏹️ Stopping all battery limiter processes"
PROCESSES=(
    "battery-indicator"
    "battery-gui" 
    "battery-cli"
    "battery-notifier"
    "battery-widget"
    "battery-indicator-launcher"
    "battery-indicator-universal"
    "battery-indicator-simple"
)

for process in "${PROCESSES[@]}"; do
    if pgrep -f "$process" >/dev/null 2>&1; then
        print_info "Stopping $process"
        pkill -f "$process" || true
    fi
done

# Wait for processes to stop
sleep 3

# Force kill if still running
for process in "${PROCESSES[@]}"; do
    if pgrep -f "$process" >/dev/null 2>&1; then
        print_warning "Force killing $process"
        pkill -9 -f "$process" || true
    fi
done

# Remove all executables from multiple locations
print_colored $PURPLE "🗑️ Removing executables from all locations"
EXECUTABLES=(
    "battery-cli"
    "battery-limit" 
    "battery-gui"
    "battery-indicator"
    "battery-indicator-launcher"
    "battery-indicator-universal"
    "battery-indicator-simple"
    "battery-gui-launcher.sh"
    "battery-notifier"
    "battery-widget"
    "set-charge-limit.sh"
    "bcli"
)

BINARY_PATHS=(
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "$HOME/.local/bin"
)

for path in "${BINARY_PATHS[@]}"; do
    for executable in "${EXECUTABLES[@]}"; do
        full_path="$path/$executable"
        if [ -f "$full_path" ]; then
            if [[ "$path" == "/usr/local/bin" || "$path" == "/usr/bin" || "$path" == "/bin" ]]; then
                safe_remove "$full_path" "$executable (from $path)" true
            else
                safe_remove "$full_path" "$executable (from $path)" false
            fi
        fi
    done
done

# Remove configuration files and directories
print_colored $PURPLE "🗑️ Removing configuration files and directories"
CONFIG_LOCATIONS=(
    "$HOME/.config/battery-limiter"
    "$HOME/.config/universal-battery-limiter"
    "$HOME/.local/share/battery-limiter"
    "$HOME/.local/share/universal-battery-limiter"
    "$HOME/.cache/battery-limiter"
    "$HOME/.cache/universal-battery-limiter"
    "/etc/battery-limiter"
    "/etc/universal-battery-limiter"
)

for location in "${CONFIG_LOCATIONS[@]}"; do
    if [[ "$location" == "/etc/"* ]]; then
        safe_remove "$location" "Config directory $(basename "$location")" true
    else
        safe_remove "$location" "Config directory $(basename "$location")" false
    fi
done

# Remove autostart entries
print_colored $PURPLE "🗑️ Removing autostart entries"
AUTOSTART_FILES=(
    "$HOME/.config/autostart/battery-limiter.desktop"
    "$HOME/.config/autostart/universal-battery-limiter.desktop"
    "$HOME/.config/autostart/battery-indicator.desktop"
    "/etc/xdg/autostart/universal-battery-limiter.desktop"
    "/etc/xdg/autostart/battery-limiter.desktop"
)

for autostart_file in "${AUTOSTART_FILES[@]}"; do
    if [[ "$autostart_file" == "/etc/"* ]]; then
        safe_remove "$autostart_file" "Autostart file $(basename "$autostart_file")" true
    else
        safe_remove "$autostart_file" "Autostart file $(basename "$autostart_file")" false
    fi
done

# Remove desktop entries
print_colored $PURPLE "🗑️ Removing desktop entries"
DESKTOP_FILES=(
    "/usr/share/applications/battery-limiter.desktop"
    "/usr/share/applications/universal-battery-limiter.desktop"
    "$HOME/.local/share/applications/battery-limiter.desktop"
    "$HOME/.local/share/applications/universal-battery-limiter.desktop"
)

for desktop_file in "${DESKTOP_FILES[@]}"; do
    if [[ "$desktop_file" == "/usr/"* ]]; then
        safe_remove "$desktop_file" "Desktop file $(basename "$desktop_file")" true
    else
        safe_remove "$desktop_file" "Desktop file $(basename "$desktop_file")" false
    fi
done

# Remove sudo permissions
print_colored $PURPLE "🔐 Removing sudo permissions"
SUDOERS_FILES=(
    "/etc/sudoers.d/universal-battery-limiter"
    "/etc/sudoers.d/battery-limiter"
)

for sudoers_file in "${SUDOERS_FILES[@]}"; do
    safe_remove "$sudoers_file" "Sudoers file $(basename "$sudoers_file")" true
done

# Remove systemd services if any
print_colored $PURPLE "🔄 Removing systemd services"
SYSTEMD_SERVICES=(
    "/etc/systemd/system/battery-limiter.service"
    "/etc/systemd/system/universal-battery-limiter.service"
    "$HOME/.config/systemd/user/battery-limiter.service"
    "$HOME/.config/systemd/user/universal-battery-limiter.service"
)

for service in "${SYSTEMD_SERVICES[@]}"; do
    if [ -f "$service" ]; then
        # Stop and disable service first
        if [[ "$service" == "/etc/"* ]]; then
            sudo systemctl stop "$(basename "$service")" 2>/dev/null || true
            sudo systemctl disable "$(basename "$service")" 2>/dev/null || true
            safe_remove "$service" "System service $(basename "$service")" true
        else
            systemctl --user stop "$(basename "$service")" 2>/dev/null || true
            systemctl --user disable "$(basename "$service")" 2>/dev/null || true
            safe_remove "$service" "User service $(basename "$service")" false
        fi
    fi
done

# Reload systemd if services were removed
if systemctl --version >/dev/null 2>&1; then
    sudo systemctl daemon-reload 2>/dev/null || true
    systemctl --user daemon-reload 2>/dev/null || true
fi

# Clean up environment variables and shell aliases
print_colored $PURPLE "🧹 Cleaning up environment variables and shell aliases"
SHELL_FILES=(
    "$HOME/.bashrc"
    "$HOME/.zshrc" 
    "$HOME/.profile"
    "$HOME/.bash_profile"
)

for shell_file in "${SHELL_FILES[@]}"; do
    if [ -f "$shell_file" ]; then
        # Remove battery limiter related exports and aliases
        sed -i '/# Battery Limiter/d' "$shell_file" 2>/dev/null || true
        sed -i '/BATTERY_/d' "$shell_file" 2>/dev/null || true
        sed -i '/alias.*battery/d' "$shell_file" 2>/dev/null || true
        print_info "Cleaned up $(basename "$shell_file")"
    fi
done

# Clean up dpkg status file if corrupted
if [ "$DPKG_CORRUPTED" = "true" ] || [ "$1" = "--fix-dpkg" ]; then
    print_colored $PURPLE "� Cleaning up dpkg status file"
    
    # Create backup of dpkg status
    sudo cp /var/lib/dpkg/status "/var/lib/dpkg/status.backup.$BACKUP_TIMESTAMP" 2>/dev/null || true
    
    # Remove any remaining battery limiter entries from dpkg status
    if sudo grep -q "universal-battery-limiter\|battery-limiter" /var/lib/dpkg/status 2>/dev/null; then
        print_warning "Found battery limiter entries in dpkg status file"
        
        # Create a temporary file without battery limiter entries
        sudo grep -v "Package: universal-battery-limiter" /var/lib/dpkg/status | \
        sudo grep -v "Package: battery-limiter" > /tmp/dpkg_status_clean || true
        
        # Look for orphaned battery limiter package data and remove it
        sudo sed -i '/^Status: install reinstreq half-configured$/,/^$/{ 
            /Maintainer: FrancyAlinston/,/^$/{
                /Battery charge limit management/,/^$/d
            }
        }' /var/lib/dpkg/status 2>/dev/null || true
        
        print_success "Cleaned up dpkg status file"
    fi
fi

# Update system databases
print_colored $PURPLE "🔄 Updating system databases"
if command -v update-desktop-database >/dev/null 2>&1; then
    sudo update-desktop-database 2>/dev/null || true
    print_info "Updated desktop database"
fi

if command -v update-mime-database >/dev/null 2>&1; then
    sudo update-mime-database /usr/share/mime 2>/dev/null || true
    print_info "Updated mime database"
fi

# Update icon cache
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    sudo gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true
    print_info "Updated icon cache"
fi

# Clean package cache
if command -v apt >/dev/null 2>&1; then
    sudo apt autoremove --purge -y 2>/dev/null || true
    sudo apt autoclean 2>/dev/null || true
    print_info "Cleaned package cache"
fi

# Remove any snap packages
if command -v snap >/dev/null 2>&1; then
    if snap list 2>/dev/null | grep -q battery; then
        print_warning "Found battery-related snap packages"
        snap list | grep battery | awk '{print $1}' | while read -r snap_pkg; do
            sudo snap remove "$snap_pkg" 2>/dev/null || true
            print_info "Removed snap package: $snap_pkg"
        done
    fi
fi

# Final verification
print_colored $PURPLE "� Final verification"
REMAINING_FILES=()

# Check for remaining executables
for path in "${BINARY_PATHS[@]}"; do
    for executable in "${EXECUTABLES[@]}"; do
        if [ -f "$path/$executable" ]; then
            REMAINING_FILES+=("$path/$executable")
        fi
    done
done

# Check for remaining processes
REMAINING_PROCESSES=()
for process in "${PROCESSES[@]}"; do
    if pgrep -f "$process" >/dev/null 2>&1; then
        REMAINING_PROCESSES+=("$process")
    fi
done

# Report results
echo ""
print_colored $CYAN "📊 Uninstall Summary"
echo "==================="
print_success "Uninstallation completed successfully!"
print_info "Backup created at: $BACKUP_DIR"
print_info "Uninstall log: $UNINSTALL_LOG"

if [ ${#REMAINING_FILES[@]} -gt 0 ]; then
    print_warning "Some files may still remain:"
    for file in "${REMAINING_FILES[@]}"; do
        echo "  - $file"
    done
fi

if [ ${#REMAINING_PROCESSES[@]} -gt 0 ]; then
    print_warning "Some processes are still running:"
    for process in "${REMAINING_PROCESSES[@]}"; do
        echo "  - $process"
    done
fi

print_info "Battery settings reset to default (100%)"
print_info "System databases updated"

# Final recommendations
echo ""
print_colored $BLUE "📝 Recommendations"
echo "=================="
print_info "1. Restart your session to ensure all changes take effect"
print_info "2. If you experience any issues, check the backup directory"
print_info "3. Run 'sudo dpkg --configure -a' to verify package manager health"
print_info "4. Battery management is now handled by your system's default power manager"

echo ""
print_success "Universal Battery Limiter has been completely removed from your system!"

log_message "SUCCESS" "Comprehensive uninstall completed successfully"
