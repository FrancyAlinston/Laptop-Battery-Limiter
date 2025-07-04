#!/bin/bash

# ASUS Battery Limiter Installation Script
# Installs the battery limiter tools system-wide

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_colored() {
    echo -e "${1}${2}${NC}"
}

print_colored $BLUE "🔧 ASUS Battery Limiter Installer"
echo "=================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_colored $RED "❌ Please do not run this script as root"
    print_colored $YELLOW "Run as normal user, sudo will be used when needed"
    exit 1
fi

# Check if battery control is supported
THRESHOLD_FILE="/sys/class/power_supply/BAT0/charge_control_end_threshold"
if [ ! -f "$THRESHOLD_FILE" ]; then
    print_colored $RED "❌ Battery charge control not supported on this system"
    print_colored $RED "File not found: $THRESHOLD_FILE"
    exit 1
fi

print_colored $GREEN "✅ Battery charge control supported"

# Install dependencies
print_colored $YELLOW "📦 Installing dependencies..."
sudo apt update
sudo apt install -y python3-gi python3-gi-cairo gir1.2-gtk-3.0 gir1.2-appindicator3-0.1 gir1.2-notify-0.7 python3-tk

# Create directories
print_colored $YELLOW "📁 Creating directories..."
sudo mkdir -p /usr/local/bin
sudo mkdir -p /usr/share/applications
mkdir -p ~/.config/autostart

# Copy executables
print_colored $YELLOW "📋 Installing executables..."
sudo cp battery-cli /usr/local/bin/
sudo cp battery-limit /usr/local/bin/
sudo cp battery-gui /usr/local/bin/
sudo cp battery-indicator /usr/local/bin/
sudo cp set-charge-limit.sh /usr/local/bin/
sudo cp battery-gui-launcher.sh /usr/local/bin/

# Make executable
sudo chmod +x /usr/local/bin/battery-*
sudo chmod +x /usr/local/bin/set-charge-limit.sh

# Install desktop entries
print_colored $YELLOW "🖥️ Installing desktop entries..."
sudo cp battery-limiter.desktop /usr/share/applications/

# Create autostart entry
cat > ~/.config/autostart/battery-limiter.desktop << EOF
[Desktop Entry]
Name=ASUS Battery Limiter
Comment=Battery charge limit management for ASUS laptops
Exec=/usr/local/bin/battery-indicator
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
sudo update-desktop-database

print_colored $GREEN "✅ Installation completed!"
echo
print_colored $BLUE "🚀 Available commands:"
echo "  battery-cli           - Interactive CLI"
echo "  battery-limit         - Simple CLI commands"
echo "  battery-indicator     - System tray indicator"
echo "  battery-gui           - GUI application"
echo
print_colored $BLUE "🔄 The system tray indicator will start automatically on next login"
print_colored $YELLOW "Or start it now: battery-indicator"
echo
print_colored $GREEN "✨ Installation successful! You can now manage your battery limit from the system tray."
