#!/bin/bash

# Universal Battery Limiter - Simple Installation Script
# Installs the battery limiter tools without advanced animations

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

print_colored $BLUE "🔧 Universal Battery Limiter - Simple Installer"
echo "=============================================="
print_colored $YELLOW "Installing basic version without advanced animations"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_colored $RED "❌ Please do not run this script as root"
    print_colored $YELLOW "Run as normal user, sudo will be used when needed"
    exit 1
fi

# Check if battery control is supported
THRESHOLD_FILE="/sys/class/power_supply/BAT0/charge_control_end_threshold"
if [ ! -f "$THRESHOLD_FILE" ]; then
    # Check for alternative batteries
    for bat in /sys/class/power_supply/BAT*; do
        if [ -d "$bat" ]; then
            alt_threshold="$bat/charge_control_end_threshold"
            if [ -f "$alt_threshold" ]; then
                THRESHOLD_FILE="$alt_threshold"
                break
            fi
        fi
    done
    
    if [ ! -f "$THRESHOLD_FILE" ]; then
        print_colored $RED "❌ Battery charge control not supported on this system"
        exit 1
    fi
fi

print_colored $GREEN "✅ Battery charge control supported"

# Install dependencies
print_colored $YELLOW "📦 Installing dependencies..."
if command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y python3-gi python3-gi-cairo gir1.2-gtk-3.0 gir1.2-appindicator3-0.1 gir1.2-notify-0.7 python3-tk || {
        print_colored $YELLOW "⚠️ Some dependencies may not be available, continuing..."
    }
fi

# Create directories
print_colored $YELLOW "📁 Creating directories..."
sudo mkdir -p /usr/local/bin
sudo mkdir -p /usr/share/applications
mkdir -p ~/.config/autostart

# Copy core executables (basic versions only)
print_colored $YELLOW "📋 Installing executables..."
sudo cp battery-cli /usr/local/bin/
sudo cp battery-limit /usr/local/bin/
sudo cp battery-gui /usr/local/bin/
sudo cp battery-indicator-simple /usr/local/bin/battery-indicator
sudo cp set-charge-limit.sh /usr/local/bin/

# Copy logger if it exists
[ -f "battery_logger.py" ] && sudo cp battery_logger.py /usr/local/bin/

# Make executable
sudo chmod +x /usr/local/bin/battery-*
sudo chmod +x /usr/local/bin/set-charge-limit.sh

# Create simple launcher (no complex environment handling)
print_colored $YELLOW "🔧 Creating simple launcher..."
sudo tee /usr/local/bin/battery-indicator-launcher > /dev/null << 'EOF'
#!/bin/bash
# Simple Battery Indicator Launcher

# Start battery indicator
exec battery-indicator "$@"
EOF

sudo chmod +x /usr/local/bin/battery-indicator-launcher

# Setup sudo permissions
print_colored $YELLOW "🔑 Setting up sudo permissions..."
sudo tee /etc/sudoers.d/battery-limiter > /dev/null << 'EOF'
%sudo ALL=(ALL) NOPASSWD: /usr/local/bin/set-charge-limit.sh
%sudo ALL=(ALL) NOPASSWD: /bin/bash -c echo * > /sys/class/power_supply/BAT*/charge_control_end_threshold
EOF

sudo chmod 440 /etc/sudoers.d/battery-limiter

# Create desktop entry
print_colored $YELLOW "🖥️ Creating desktop entry..."
sudo tee /usr/share/applications/battery-limiter.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=Universal Battery Limiter
Comment=Control battery charge limits
Exec=battery-gui
Icon=battery
Terminal=false
Type=Application
Categories=System;Settings;
EOF

# Setup autostart (simple version)
print_colored $YELLOW "🚀 Setting up autostart..."
tee ~/.config/autostart/battery-limiter.desktop > /dev/null << 'EOF'
[Desktop Entry]
Type=Application
Name=Battery Limiter Indicator
Comment=Battery charge limit indicator
Exec=battery-indicator-simple
Icon=battery
Terminal=false
NoDisplay=true
StartupNotify=true
X-GNOME-Autostart-enabled=true
X-GNOME-AutoRestart=true
Hidden=false
EOF

# Test installation
print_colored $YELLOW "🧪 Testing installation..."
if battery-cli status >/dev/null 2>&1; then
    print_colored $GREEN "✅ CLI test passed"
else
    print_colored $RED "❌ CLI test failed"
fi

print_colored $GREEN "🎉 Installation complete!"
echo ""
print_colored $BLUE "Usage:"
echo "  battery-cli status          - Check battery status"
echo "  battery-cli set 80          - Set charge limit to 80%"
echo "  battery-gui                 - Open GUI interface"
echo "  battery-indicator-simple    - Start simple system tray indicator"
echo ""
print_colored $YELLOW "Starting simple indicator..."
nohup battery-indicator-simple >/dev/null 2>&1 &

print_colored $GREEN "✅ Simple Battery Limiter installed successfully!"
print_colored $BLUE "The simple indicator is now running in the system tray."
