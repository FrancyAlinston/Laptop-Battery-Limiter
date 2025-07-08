#!/bin/bash

# Universal Battery Limiter - Log Viewer
# View and analyze installation and runtime logs

LOG_DIR="$HOME/.local/share/battery-limiter/logs"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_colored() {
    echo -e "${1}${2}${NC}"
}

print_header() {
    echo
    print_colored $CYAN "======================================"
    print_colored $CYAN "$1"
    print_colored $CYAN "======================================"
}

if [ ! -d "$LOG_DIR" ]; then
    print_colored $RED "❌ Log directory not found: $LOG_DIR"
    exit 1
fi

print_header "Universal Battery Limiter - Log Viewer"

# Show log directory info
print_colored $BLUE "📁 Log directory: $LOG_DIR"
print_colored $BLUE "📊 Log files:"
ls -lah "$LOG_DIR" 2>/dev/null || echo "No log files found"

# Function to show log file
show_log() {
    local log_file="$1"
    local log_name="$2"
    local lines="${3:-50}"
    
    if [ -f "$log_file" ]; then
        print_header "$log_name (Last $lines lines)"
        tail -n "$lines" "$log_file" | while IFS= read -r line; do
            # Color-code log levels
            if echo "$line" | grep -q "\[ERROR\]"; then
                print_colored $RED "$line"
            elif echo "$line" | grep -q "\[WARNING\]"; then
                print_colored $YELLOW "$line"
            elif echo "$line" | grep -q "\[INFO\]"; then
                print_colored $BLUE "$line"
            elif echo "$line" | grep -q "\[DEBUG\]"; then
                print_colored $CYAN "$line"
            else
                echo "$line"
            fi
        done
    else
        print_colored $YELLOW "⚠️ $log_name not found"
    fi
}

# Function to show log summary
show_summary() {
    print_header "Log Summary"
    
    for log_file in "$LOG_DIR"/*.log; do
        if [ -f "$log_file" ]; then
            local basename=$(basename "$log_file")
            local lines=$(wc -l < "$log_file" 2>/dev/null || echo "0")
            local size=$(du -h "$log_file" 2>/dev/null | cut -f1 || echo "0")
            local errors=$(grep -c "\[ERROR\]" "$log_file" 2>/dev/null || echo "0")
            local warnings=$(grep -c "\[WARNING\]" "$log_file" 2>/dev/null || echo "0")
            
            print_colored $GREEN "📄 $basename"
            echo "   Lines: $lines | Size: $size | Errors: $errors | Warnings: $warnings"
        fi
    done
}

# Main menu
if [ "$1" = "all" ]; then
    # Show all logs
    show_log "$LOG_DIR/install.log" "Installation Log"
    show_log "$LOG_DIR/error.log" "Error Log"
    show_log "$LOG_DIR/system.log" "System Log"
    show_log "$LOG_DIR/debug.log" "Debug Log"
    show_log "$LOG_DIR/events.log" "Events Log"
    show_log "$LOG_DIR/gui.log" "GUI Log"
    show_log "$LOG_DIR/indicator.log" "Indicator Log"
elif [ "$1" = "errors" ]; then
    # Show only errors
    print_header "All Errors"
    for log_file in "$LOG_DIR"/*.log; do
        if [ -f "$log_file" ]; then
            local basename=$(basename "$log_file")
            local errors=$(grep "\[ERROR\]" "$log_file" 2>/dev/null)
            if [ -n "$errors" ]; then
                print_colored $RED "From $basename:"
                echo "$errors" | while IFS= read -r line; do
                    print_colored $RED "  $line"
                done
            fi
        fi
    done
elif [ "$1" = "install" ]; then
    # Show installation log
    show_log "$LOG_DIR/install.log" "Installation Log" 100
elif [ "$1" = "runtime" ]; then
    # Show runtime logs
    show_log "$LOG_DIR/gui.log" "GUI Log"
    show_log "$LOG_DIR/indicator.log" "Indicator Log"
elif [ "$1" = "summary" ]; then
    # Show summary
    show_summary
elif [ "$1" = "live" ]; then
    # Live view of logs
    print_header "Live Log View (Press Ctrl+C to exit)"
    tail -f "$LOG_DIR"/*.log 2>/dev/null
elif [ "$1" = "clear" ]; then
    # Clear logs
    read -p "Are you sure you want to clear all logs? (y/N): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        rm -f "$LOG_DIR"/*.log
        print_colored $GREEN "✅ All logs cleared"
    else
        print_colored $YELLOW "❌ Operation cancelled"
    fi
else
    # Show help
    print_colored $BLUE "Usage: $0 [option]"
    echo
    print_colored $YELLOW "Options:"
    echo "  all      - Show all logs"
    echo "  errors   - Show only errors from all logs"
    echo "  install  - Show installation log"
    echo "  runtime  - Show runtime logs (GUI, indicator)"
    echo "  summary  - Show log summary"
    echo "  live     - Live view of logs"
    echo "  clear    - Clear all logs"
    echo
    print_colored $YELLOW "Examples:"
    echo "  $0 all      # Show all logs"
    echo "  $0 errors   # Show only errors"
    echo "  $0 install  # Show installation log"
    echo "  $0 live     # Live log monitoring"
    echo
    
    # Show basic summary by default
    show_summary
fi
