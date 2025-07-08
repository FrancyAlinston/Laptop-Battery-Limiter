#!/bin/bash

# Universal Battery Limiter - System Diagnostic and Repair Tool
# This script diagnoses and fixes common installation issues

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_colored() {
    echo -e "${1}${2}${NC}"
}

print_colored $BLUE "🔧 Universal Battery Limiter - System Diagnostic"
echo "================================================"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_colored $RED "❌ Please do not run this script as root"
    print_colored $YELLOW "Run as normal user, sudo will be used when needed"
    exit 1
fi

# Function to check dpkg status
check_dpkg_status() {
    print_colored $BLUE "🔍 Checking package manager status..."
    
    if ! command -v dpkg >/dev/null 2>&1; then
        print_colored $YELLOW "⚠️ dpkg not available (non-Debian system)"
        return 1
    fi
    
    if ! dpkg -l >/dev/null 2>&1; then
        print_colored $RED "❌ dpkg status file corrupted"
        print_colored $YELLOW "💡 Consider running: sudo dpkg --configure -a"
        return 1
    fi
    
    print_colored $GREEN "✅ Package manager working correctly"
    return 0
}

# Function to check battery support
check_battery_support() {
    print_colored $BLUE "🔍 Checking battery charge control support..."
    
    THRESHOLD_FILES=(
        "/sys/class/power_supply/BAT0/charge_control_end_threshold"
        "/sys/class/power_supply/BAT1/charge_control_end_threshold"
        "/sys/class/power_supply/BAT*/charge_control_end_threshold"
    )
    
    for file in "${THRESHOLD_FILES[@]}"; do
        if [ -f "$file" ]; then
            print_colored $GREEN "✅ Battery control supported: $file"
            return 0
        fi
    done
    
    print_colored $RED "❌ Battery charge control not supported"
    print_colored $YELLOW "💡 This system may not support battery charge limiting"
    return 1
}

# Function to check dependencies
check_dependencies() {
    print_colored $BLUE "🔍 Checking Python GTK dependencies..."
    
    DEPS=(
        "python3-gi"
        "python3-gi-cairo"
        "gir1.2-gtk-3.0"
        "gir1.2-appindicator3-0.1"
        "gir1.2-notify-0.7"
        "python3-tk"
    )
    
    missing_deps=()
    
    for dep in "${DEPS[@]}"; do
        if ! dpkg -l "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -eq 0 ]; then
        print_colored $GREEN "✅ All dependencies installed"
        return 0
    else
        print_colored $YELLOW "⚠️ Missing dependencies: ${missing_deps[*]}"
        print_colored $BLUE "💡 Install with: sudo apt install ${missing_deps[*]}"
        return 1
    fi
}

# Function to check installed components
check_installation() {
    print_colored $BLUE "🔍 Checking installed components..."
    
    COMPONENTS=(
        "/usr/local/bin/battery-cli"
        "/usr/local/bin/battery-gui"
        "/usr/local/bin/battery-indicator"
        "/usr/local/bin/battery-limit"
        "/usr/local/bin/set-charge-limit.sh"
    )
    
    missing_components=()
    
    for component in "${COMPONENTS[@]}"; do
        if [ ! -f "$component" ]; then
            missing_components+=("$(basename $component)")
        fi
    done
    
    if [ ${#missing_components[@]} -eq 0 ]; then
        print_colored $GREEN "✅ All components installed"
        return 0
    else
        print_colored $YELLOW "⚠️ Missing components: ${missing_components[*]}"
        print_colored $BLUE "💡 Reinstall with: ./install.sh"
        return 1
    fi
}

# Function to test functionality
test_functionality() {
    print_colored $BLUE "🔍 Testing functionality..."
    
    # Test CLI
    if command -v battery-cli >/dev/null 2>&1; then
        if battery-cli status >/dev/null 2>&1; then
            print_colored $GREEN "✅ CLI working"
        else
            print_colored $YELLOW "⚠️ CLI has issues"
        fi
    else
        print_colored $RED "❌ CLI not found"
    fi
    
    # Test GUI
    if command -v battery-gui >/dev/null 2>&1; then
        if timeout 5 battery-gui --version >/dev/null 2>&1; then
            print_colored $GREEN "✅ GUI working"
        else
            print_colored $YELLOW "⚠️ GUI has issues"
        fi
    else
        print_colored $RED "❌ GUI not found"
    fi
    
    # Test indicator
    if command -v battery-indicator >/dev/null 2>&1; then
        if timeout 5 battery-indicator --version >/dev/null 2>&1; then
            print_colored $GREEN "✅ Indicator working"
        else
            print_colored $YELLOW "⚠️ Indicator has library conflicts"
            print_colored $BLUE "💡 Use battery-indicator-launcher instead"
        fi
    else
        print_colored $RED "❌ Indicator not found"
    fi
}

# Function to fix common issues
fix_common_issues() {
    print_colored $BLUE "🔧 Attempting to fix common issues..."
    
    # Fix permissions
    print_colored $YELLOW "🔧 Fixing file permissions..."
    sudo chmod +x /usr/local/bin/battery-* 2>/dev/null || true
    sudo chmod +x /usr/local/bin/set-charge-limit.sh 2>/dev/null || true
    
    # Recreate launcher if missing
    if [ ! -f "/usr/local/bin/battery-indicator-launcher" ]; then
        print_colored $YELLOW "🔧 Creating indicator launcher..."
        sudo tee /usr/local/bin/battery-indicator-launcher > /dev/null << 'EOF'
#!/bin/bash
# Battery Indicator Launcher Script
# Fixes library conflicts with snap packages

# Unset problematic environment variables
unset LD_LIBRARY_PATH
unset PYTHONPATH

# Set proper library path
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"

# Launch battery indicator
exec /usr/local/bin/battery-indicator "$@"
EOF
        sudo chmod +x /usr/local/bin/battery-indicator-launcher
    fi
    
    # Update autostart entry
    if [ -f "$HOME/.config/autostart/battery-limiter.desktop" ]; then
        print_colored $YELLOW "🔧 Updating autostart entry..."
        sed -i 's|Exec=/usr/local/bin/battery-indicator|Exec=/usr/local/bin/battery-indicator-launcher|g' "$HOME/.config/autostart/battery-limiter.desktop"
    fi
    
    print_colored $GREEN "✅ Common fixes applied"
}

# Main execution
echo
check_dpkg_status
echo
check_battery_support
echo
check_dependencies
echo
check_installation
echo
test_functionality
echo
fix_common_issues
echo

print_colored $GREEN "🎉 Diagnostic complete!"
print_colored $BLUE "💡 If issues persist, try:"
echo "  1. ./uninstall.sh && ./install.sh"
echo "  2. Check system logs: journalctl -u battery-*"
echo "  3. Test manually: battery-cli status"
