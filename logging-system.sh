#!/bin/bash

# Universal Battery Limiter - Logging System
# This script sets up comprehensive logging for all components

LOG_DIR="$HOME/.local/share/battery-limiter/logs"
INSTALL_LOG="$LOG_DIR/install.log"
ERROR_LOG="$LOG_DIR/error.log"
SYSTEM_LOG="$LOG_DIR/system.log"
DEBUG_LOG="$LOG_DIR/debug.log"

# Create log directory
mkdir -p "$LOG_DIR"

# Log rotation function
rotate_logs() {
    local log_file="$1"
    local max_size=5242880  # 5MB in bytes
    
    if [ -f "$log_file" ] && [ $(stat -c%s "$log_file") -gt $max_size ]; then
        mv "$log_file" "${log_file}.old"
        touch "$log_file"
    fi
}

# Logging functions
log_info() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [INFO] $message" | tee -a "$SYSTEM_LOG"
}

log_error() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [ERROR] $message" | tee -a "$ERROR_LOG" "$SYSTEM_LOG"
}

log_debug() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [DEBUG] $message" >> "$DEBUG_LOG"
}

log_install() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [INSTALL] $message" | tee -a "$INSTALL_LOG" "$SYSTEM_LOG"
}

# System information logging
log_system_info() {
    log_info "=== SYSTEM INFORMATION ==="
    log_info "Date: $(date)"
    log_info "OS: $(lsb_release -d 2>/dev/null | cut -f2 || echo 'Unknown')"
    log_info "Kernel: $(uname -r)"
    log_info "Architecture: $(uname -m)"
    log_info "Desktop: ${XDG_CURRENT_DESKTOP:-Unknown}"
    log_info "Session: ${XDG_SESSION_TYPE:-Unknown}"
    log_info "Python: $(python3 --version 2>/dev/null || echo 'Not found')"
    log_info "User: $USER"
    log_info "Home: $HOME"
    log_info "=== END SYSTEM INFORMATION ==="
}

# Battery system information
log_battery_info() {
    log_info "=== BATTERY SYSTEM INFORMATION ==="
    
    # Check for battery files
    for bat in /sys/class/power_supply/BAT*; do
        if [ -d "$bat" ]; then
            battery_name=$(basename "$bat")
            log_info "Found battery: $battery_name"
            
            # Check threshold file
            threshold_file="$bat/charge_control_end_threshold"
            if [ -f "$threshold_file" ]; then
                current_limit=$(cat "$threshold_file" 2>/dev/null || echo "N/A")
                log_info "  Threshold file: $threshold_file (Current: $current_limit%)"
            else
                log_info "  Threshold file: NOT FOUND"
            fi
            
            # Check capacity
            capacity_file="$bat/capacity"
            if [ -f "$capacity_file" ]; then
                current_capacity=$(cat "$capacity_file" 2>/dev/null || echo "N/A")
                log_info "  Capacity: $current_capacity%"
            fi
            
            # Check status
            status_file="$bat/status"
            if [ -f "$status_file" ]; then
                current_status=$(cat "$status_file" 2>/dev/null || echo "N/A")
                log_info "  Status: $current_status"
            fi
        fi
    done
    
    log_info "=== END BATTERY SYSTEM INFORMATION ==="
}

# Package manager information
log_package_info() {
    log_info "=== PACKAGE MANAGER INFORMATION ==="
    
    # Check dpkg status
    if command -v dpkg >/dev/null 2>&1; then
        if dpkg -l >/dev/null 2>&1; then
            log_info "dpkg: Working correctly"
            
            # Check for battery-related packages
            dpkg -l | grep -i battery 2>/dev/null | while read line; do
                log_info "Installed package: $line"
            done
        else
            log_error "dpkg: Status file corrupted"
        fi
    else
        log_info "dpkg: Not available (non-Debian system)"
    fi
    
    # Check apt
    if command -v apt >/dev/null 2>&1; then
        log_info "apt: Available"
    else
        log_info "apt: Not available"
    fi
    
    log_info "=== END PACKAGE MANAGER INFORMATION ==="
}

# Python environment information
log_python_info() {
    log_info "=== PYTHON ENVIRONMENT INFORMATION ==="
    
    # Test Python imports
    python3 -c "
import sys
print(f'Python version: {sys.version}')
print(f'Python executable: {sys.executable}')
print(f'Python path: {sys.path}')

# Test GTK imports
try:
    import gi
    print('gi module: Available')
    try:
        gi.require_version('Gtk', '3.0')
        from gi.repository import Gtk
        print('Gtk: Available')
    except Exception as e:
        print(f'Gtk: Error - {e}')
    
    try:
        gi.require_version('AppIndicator3', '0.1')
        from gi.repository import AppIndicator3
        print('AppIndicator3: Available')
    except Exception as e:
        print(f'AppIndicator3: Error - {e}')
    
    try:
        gi.require_version('Notify', '0.7')
        from gi.repository import Notify
        print('Notify: Available')
    except Exception as e:
        print(f'Notify: Error - {e}')
        
except Exception as e:
    print(f'gi module: Error - {e}')

# Test tkinter
try:
    import tkinter
    print('tkinter: Available')
except Exception as e:
    print(f'tkinter: Error - {e}')
" 2>&1 | while read line; do
        log_info "$line"
    done
    
    log_info "=== END PYTHON ENVIRONMENT INFORMATION ==="
}

# Process information
log_process_info() {
    log_info "=== PROCESS INFORMATION ==="
    
    # Check for running battery processes
    ps aux | grep -E "(battery|universal)" | grep -v grep | while read line; do
        log_info "Running process: $line"
    done
    
    log_info "=== END PROCESS INFORMATION ==="
}

# File system information
log_filesystem_info() {
    log_info "=== FILESYSTEM INFORMATION ==="
    
    # Check installed files
    for file in /usr/local/bin/battery-* /usr/local/bin/set-charge-limit.sh; do
        if [ -f "$file" ]; then
            log_info "Installed file: $file ($(stat -c%s "$file") bytes, $(stat -c%Y "$file" | xargs -I {} date -d @{}))"
        else
            log_info "Missing file: $file"
        fi
    done
    
    # Check autostart
    if [ -f "$HOME/.config/autostart/battery-limiter.desktop" ]; then
        log_info "Autostart file exists: $HOME/.config/autostart/battery-limiter.desktop"
        log_info "Autostart content:"
        cat "$HOME/.config/autostart/battery-limiter.desktop" | while read line; do
            log_info "  $line"
        done
    else
        log_info "Autostart file missing: $HOME/.config/autostart/battery-limiter.desktop"
    fi
    
    # Check sudoers
    if [ -f "/etc/sudoers.d/battery-limiter" ]; then
        log_info "Sudoers file exists: /etc/sudoers.d/battery-limiter"
    else
        log_info "Sudoers file missing: /etc/sudoers.d/battery-limiter"
    fi
    
    log_info "=== END FILESYSTEM INFORMATION ==="
}

# Function to collect all system information
collect_full_system_info() {
    log_info "Starting full system information collection..."
    log_system_info
    log_battery_info
    log_package_info
    log_python_info
    log_process_info
    log_filesystem_info
    log_info "Full system information collection completed."
}

# Function to show log files
show_logs() {
    echo "🔍 Battery Limiter Log Files:"
    echo "=============================="
    echo "Log directory: $LOG_DIR"
    echo
    
    for log_file in "$INSTALL_LOG" "$ERROR_LOG" "$SYSTEM_LOG" "$DEBUG_LOG"; do
        if [ -f "$log_file" ]; then
            echo "📄 $(basename "$log_file"): $(wc -l < "$log_file") lines, $(stat -c%s "$log_file") bytes"
            echo "   Last modified: $(stat -c%y "$log_file")"
        else
            echo "📄 $(basename "$log_file"): Not found"
        fi
    done
    
    echo
    echo "To view logs:"
    echo "  tail -f $SYSTEM_LOG     # Follow system log"
    echo "  tail -f $ERROR_LOG      # Follow error log"
    echo "  cat $INSTALL_LOG        # View installation log"
    echo "  cat $DEBUG_LOG          # View debug log"
}

# Function to clear logs
clear_logs() {
    echo "🗑️ Clearing Battery Limiter logs..."
    for log_file in "$INSTALL_LOG" "$ERROR_LOG" "$SYSTEM_LOG" "$DEBUG_LOG"; do
        if [ -f "$log_file" ]; then
            > "$log_file"
            echo "Cleared: $(basename "$log_file")"
        fi
    done
    echo "All logs cleared."
}

# Rotate all logs
rotate_all_logs() {
    for log_file in "$INSTALL_LOG" "$ERROR_LOG" "$SYSTEM_LOG" "$DEBUG_LOG"; do
        rotate_logs "$log_file"
    done
}

# Export functions and variables
export LOG_DIR INSTALL_LOG ERROR_LOG SYSTEM_LOG DEBUG_LOG
export -f log_info log_error log_debug log_install
export -f log_system_info log_battery_info log_package_info log_python_info
export -f log_process_info log_filesystem_info collect_full_system_info
export -f rotate_logs rotate_all_logs

# Main execution
case "${1:-}" in
    "info")
        collect_full_system_info
        ;;
    "show")
        show_logs
        ;;
    "clear")
        clear_logs
        ;;
    "rotate")
        rotate_all_logs
        echo "Logs rotated."
        ;;
    *)
        echo "Battery Limiter Logging System"
        echo "Usage: $0 {info|show|clear|rotate}"
        echo
        echo "Commands:"
        echo "  info    - Collect full system information"
        echo "  show    - Show log file status"
        echo "  clear   - Clear all log files"
        echo "  rotate  - Rotate large log files"
        echo
        echo "Log directory: $LOG_DIR"
        ;;
esac
