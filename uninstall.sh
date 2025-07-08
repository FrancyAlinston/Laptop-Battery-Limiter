#!/bin/bash

# Universal Battery Limiter Uninstall Script

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_colored() {
    echo -e "${1}${2}${NC}"
}

print_colored $BLUE "🗑️ Universal Battery Limiter Uninstaller"
echo "===================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_colored $RED "❌ Please do not run this script as root"
    print_colored $YELLOW "Run as normal user, sudo will be used when needed"
    exit 1
fi

# Check if installed via package manager
if command -v dpkg >/dev/null 2>&1; then
    # Check if dpkg is working properly
    if dpkg -l >/dev/null 2>&1; then
        if dpkg -l | grep -q universal-battery-limiter; then
            print_colored $YELLOW "📦 Package installation detected"
            print_colored $BLUE "To uninstall the .deb package, use:"
            echo "sudo apt remove universal-battery-limiter"
            echo ""
            read -p "Do you want to uninstall the package now? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo apt remove universal-battery-limiter
                print_colored $GREEN "✅ Package uninstalled successfully!"
                exit 0
            else
                print_colored $YELLOW "Continuing with manual uninstall..."
            fi
        fi
    else
        print_colored $YELLOW "⚠️ Package manager status file corrupted, proceeding with manual uninstall..."
    fi
fi

# Stop all battery limiter processes
print_colored $YELLOW "⏹️ Stopping battery indicator and other processes..."
pkill -f battery-indicator || true
pkill -f battery-gui || true
pkill -f battery-cli || true

# Wait for processes to stop
sleep 2

# Remove executables
print_colored $YELLOW "🗑️ Removing executables..."
sudo rm -f /usr/local/bin/battery-cli
sudo rm -f /usr/local/bin/battery-limit
sudo rm -f /usr/local/bin/battery-gui
sudo rm -f /usr/local/bin/battery-indicator
sudo rm -f /usr/local/bin/battery-indicator-launcher
sudo rm -f /usr/local/bin/battery-gui-launcher.sh
sudo rm -f /usr/local/bin/set-charge-limit.sh
sudo rm -f /usr/local/bin/bcli

# Remove autostart entries
print_colored $YELLOW "🗑️ Removing autostart entries..."
rm -f ~/.config/autostart/battery-limiter.desktop || true
rm -f ~/.config/autostart/universal-battery-limiter.desktop || true
sudo rm -f /etc/xdg/autostart/universal-battery-limiter.desktop || true

# Remove sudo permissions
print_colored $YELLOW "🔐 Removing sudo permissions..."
sudo rm -f /etc/sudoers.d/universal-battery-limiter
sudo rm -f /etc/sudoers.d/battery-limiter

# Update desktop database
print_colored $YELLOW "🔄 Updating desktop database..."
if command -v update-desktop-database >/dev/null 2>&1; then
    sudo update-desktop-database || true
fi

print_colored $GREEN "✅ Uninstallation completed!"
print_colored $BLUE "ℹ️ Your current battery settings will remain as they were last set"
print_colored $YELLOW "💡 To reset battery limit to default, run: echo 100 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold"
print_colored $BLUE "ℹ️ Your battery settings will remain as they were last set"
