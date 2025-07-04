#!/bin/bash

# ASUS Battery Limiter Uninstall Script

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_colored() {
    echo -e "${1}${2}${NC}"
}

print_colored $BLUE "🗑️ ASUS Battery Limiter Uninstaller"
echo "===================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_colored $RED "❌ Please do not run this script as root"
    print_colored $YELLOW "Run as normal user, sudo will be used when needed"
    exit 1
fi

# Stop the indicator if running
print_colored $YELLOW "⏹️ Stopping battery indicator..."
pkill -f battery-indicator || true

# Remove executables
print_colored $YELLOW "🗑️ Removing executables..."
sudo rm -f /usr/local/bin/battery-cli
sudo rm -f /usr/local/bin/battery-limit
sudo rm -f /usr/local/bin/battery-gui
sudo rm -f /usr/local/bin/battery-indicator
sudo rm -f /usr/local/bin/set-charge-limit.sh

# Remove desktop entries
print_colored $YELLOW "🗑️ Removing autostart entries..."
rm -f ~/.config/autostart/battery-limiter.desktop

# Remove sudo permissions
print_colored $YELLOW "🔐 Removing sudo permissions..."
sudo rm -f /etc/sudoers.d/battery-limiter

# Update desktop database
sudo update-desktop-database

print_colored $GREEN "✅ Uninstallation completed!"
print_colored $BLUE "ℹ️ Your battery settings will remain as they were last set"
