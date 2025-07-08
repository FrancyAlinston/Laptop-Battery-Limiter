#!/bin/bash

# Universal Battery Limiter - System Tray Icon Fix
# This script provides multiple approaches to show the battery system tray icon

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_colored() {
    echo -e "${1}${2}${NC}"
}

print_colored $BLUE "🔋 Universal Battery Limiter - System Tray Icon Fix"
echo "======================================================="

# Check desktop environment
DESKTOP=$(echo $XDG_CURRENT_DESKTOP | tr '[:upper:]' '[:lower:]')
SESSION=$(echo $XDG_SESSION_TYPE | tr '[:upper:]' '[:lower:]')

print_colored $YELLOW "Desktop Environment: $DESKTOP"
print_colored $YELLOW "Session Type: $SESSION"

# Function to install system tray support
install_systray_support() {
    print_colored $BLUE "📦 Installing system tray support..."
    
    case $DESKTOP in
        *gnome*|*ubuntu*)
            print_colored $YELLOW "Installing GNOME/Ubuntu system tray support..."
            sudo apt update
            sudo apt install -y gnome-shell-extension-appindicator
            sudo apt install -y gir1.2-appindicator3-0.1
            ;;
        *unity*)
            print_colored $YELLOW "Installing Unity system tray support..."
            sudo apt update
            sudo apt install -y unity-control-center
            sudo apt install -y gir1.2-appindicator3-0.1
            ;;
        *kde*|*plasma*)
            print_colored $YELLOW "Installing KDE/Plasma system tray support..."
            sudo apt update
            sudo apt install -y plasma-workspace-dev
            ;;
        *xfce*)
            print_colored $YELLOW "Installing XFCE system tray support..."
            sudo apt update
            sudo apt install -y xfce4-indicator-plugin
            ;;
        *)
            print_colored $YELLOW "Installing generic system tray support..."
            sudo apt update
            sudo apt install -y gir1.2-appindicator3-0.1
            ;;
    esac
}

# Function to create a notification-based alternative
create_notification_alternative() {
    print_colored $BLUE "🔔 Creating notification-based alternative..."
    
    cat > /tmp/battery-notifier << 'EOF'
#!/usr/bin/env python3

import subprocess
import time
import sys
import os

try:
    import gi
    gi.require_version('Notify', '0.7')
    from gi.repository import Notify
    NOTIFY_AVAILABLE = True
except:
    NOTIFY_AVAILABLE = False

def get_battery_info():
    try:
        with open('/sys/class/power_supply/BAT0/capacity', 'r') as f:
            level = int(f.read().strip())
        with open('/sys/class/power_supply/BAT0/status', 'r') as f:
            status = f.read().strip()
        with open('/sys/class/power_supply/BAT0/charge_control_end_threshold', 'r') as f:
            limit = int(f.read().strip())
        return level, status, limit
    except:
        return None, None, None

def main():
    if NOTIFY_AVAILABLE:
        Notify.init("Battery Limiter")
    
    last_notification_time = 0
    
    while True:
        level, status, limit = get_battery_info()
        current_time = time.time()
        
        if level is not None and current_time - last_notification_time > 300:  # 5 minutes
            if level >= limit and status == 'Charging':
                if NOTIFY_AVAILABLE:
                    notification = Notify.Notification.new(
                        "🔋 Battery Limit Reached",
                        f"Battery at {level}% (Limit: {limit}%)\nCharging stopped automatically",
                        "battery-full"
                    )
                    notification.show()
                last_notification_time = current_time
            elif level <= 15:
                if NOTIFY_AVAILABLE:
                    notification = Notify.Notification.new(
                        "⚠️ Low Battery",
                        f"Battery at {level}%\nPlease connect charger",
                        "battery-low"
                    )
                    notification.show()
                last_notification_time = current_time
        
        time.sleep(30)  # Check every 30 seconds

if __name__ == "__main__":
    main()
EOF
    
    chmod +x /tmp/battery-notifier
    sudo cp /tmp/battery-notifier /usr/local/bin/
    rm /tmp/battery-notifier
}

# Function to create a desktop widget alternative
create_desktop_widget() {
    print_colored $BLUE "🖥️ Creating desktop widget alternative..."
    
    cat > /tmp/battery-widget << 'EOF'
#!/usr/bin/env python3

import tkinter as tk
from tkinter import ttk
import subprocess
import threading
import time
import sys

class BatteryWidget:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Battery Status")
        self.root.geometry("200x100")
        self.root.resizable(False, False)
        
        # Position in corner
        self.root.geometry("+10+10")
        
        # Always on top
        self.root.attributes('-topmost', True)
        
        # Make it semi-transparent
        self.root.attributes('-alpha', 0.8)
        
        # Create widgets
        self.create_widgets()
        
        # Start monitoring
        self.start_monitoring()
    
    def create_widgets(self):
        frame = ttk.Frame(self.root, padding="10")
        frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        self.battery_label = ttk.Label(frame, text="Battery: ---%")
        self.battery_label.grid(row=0, column=0, pady=5)
        
        self.limit_label = ttk.Label(frame, text="Limit: ---%")
        self.limit_label.grid(row=1, column=0, pady=5)
        
        self.status_label = ttk.Label(frame, text="Status: ---")
        self.status_label.grid(row=2, column=0, pady=5)
    
    def update_display(self):
        try:
            with open('/sys/class/power_supply/BAT0/capacity', 'r') as f:
                level = int(f.read().strip())
            with open('/sys/class/power_supply/BAT0/status', 'r') as f:
                status = f.read().strip()
            with open('/sys/class/power_supply/BAT0/charge_control_end_threshold', 'r') as f:
                limit = int(f.read().strip())
            
            self.battery_label.config(text=f"Battery: {level}%")
            self.limit_label.config(text=f"Limit: {limit}%")
            self.status_label.config(text=f"Status: {status}")
            
            # Color coding
            if level >= limit:
                self.battery_label.config(foreground="green")
            elif level <= 15:
                self.battery_label.config(foreground="red")
            else:
                self.battery_label.config(foreground="black")
                
        except Exception as e:
            self.battery_label.config(text="Battery: Error")
            self.limit_label.config(text="Limit: Error")
            self.status_label.config(text="Status: Error")
    
    def start_monitoring(self):
        def monitor():
            while True:
                self.root.after(0, self.update_display)
                time.sleep(5)
        
        thread = threading.Thread(target=monitor, daemon=True)
        thread.start()
    
    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    widget = BatteryWidget()
    widget.run()
EOF
    
    chmod +x /tmp/battery-widget
    sudo cp /tmp/battery-widget /usr/local/bin/
    rm /tmp/battery-widget
}

# Main menu
show_menu() {
    echo
    print_colored $BLUE "Choose a solution:"
    echo "1. Install system tray support for your desktop"
    echo "2. Use notification-based monitoring"
    echo "3. Use desktop widget alternative"
    echo "4. Try all solutions"
    echo "5. Check current system tray status"
    echo "6. Exit"
    echo
    read -p "Enter your choice (1-6): " choice
    
    case $choice in
        1)
            install_systray_support
            ;;
        2)
            create_notification_alternative
            print_colored $GREEN "✅ Notification-based alternative created!"
            print_colored $YELLOW "Run: battery-notifier &"
            ;;
        3)
            create_desktop_widget
            print_colored $GREEN "✅ Desktop widget created!"
            print_colored $YELLOW "Run: battery-widget &"
            ;;
        4)
            install_systray_support
            create_notification_alternative
            create_desktop_widget
            print_colored $GREEN "✅ All solutions installed!"
            ;;
        5)
            print_colored $BLUE "🔍 Checking system tray status..."
            ps aux | grep -i indicator
            echo
            python3 -c "
try:
    import gi
    gi.require_version('AppIndicator3', '0.1')
    from gi.repository import AppIndicator3
    print('✅ AppIndicator3 available')
except Exception as e:
    print(f'❌ AppIndicator3 not available: {e}')
"
            ;;
        6)
            print_colored $BLUE "👋 Goodbye!"
            exit 0
            ;;
        *)
            print_colored $RED "❌ Invalid choice"
            show_menu
            ;;
    esac
}

# Run
show_menu

print_colored $GREEN "🎉 System tray icon fix completed!"
print_colored $BLUE "💡 Try these commands:"
echo "  battery-notifier &          # Notification-based monitoring"
echo "  battery-widget &            # Desktop widget"
echo "  battery-gui &               # Full GUI application"
