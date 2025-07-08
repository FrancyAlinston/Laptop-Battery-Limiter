#!/bin/bash

# Universal Battery Limiter - Comprehensive Diagnostic and Installation Script
# Diagnoses system, fixes issues, and installs with comprehensive logging

set -e

# Setup comprehensive logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$HOME/.local/share/battery-limiter/logs"
DIAGNOSTIC_LOG="$LOG_DIR/diagnostic.log"
INSTALL_LOG="$LOG_DIR/install.log"
ERROR_LOG="$LOG_DIR/error.log"

# Create log directory
mkdir -p "$LOG_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Enhanced logging functions
log_diagnostic() {
    local message="$1"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[$timestamp] [DIAGNOSTIC] $message" | tee -a "$DIAGNOSTIC_LOG"
}

log_error() {
    local message="$1"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[$timestamp] [ERROR] $message" | tee -a "$ERROR_LOG" | tee -a "$DIAGNOSTIC_LOG"
}

log_info() {
    local message="$1"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[$timestamp] [INFO] $message" | tee -a "$DIAGNOSTIC_LOG"
}

print_colored() {
    echo -e "${1}${2}${NC}"
    log_diagnostic "${2}"
}

print_header() {
    echo
    print_colored $CYAN "======================================"
    print_colored $CYAN "$1"
    print_colored $CYAN "======================================"
}

# Function to run command with logging
run_with_logging() {
    local cmd="$1"
    local description="$2"
    
    log_diagnostic "EXECUTING: $description"
    log_diagnostic "Command: $cmd"
    
    if eval "$cmd" 2>&1 | tee -a "$DIAGNOSTIC_LOG"; then
        log_diagnostic "SUCCESS: $description"
        return 0
    else
        local exit_code=$?
        log_error "FAILED: $description (exit code: $exit_code)"
        return $exit_code
    fi
}

# Function to check system requirements
check_system_requirements() {
    print_header "System Requirements Check"
    local all_good=true
    
    # Check OS
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        log_info "OS: $NAME $VERSION"
        print_colored $GREEN "✅ Operating System: $NAME $VERSION"
    else
        log_error "Cannot determine OS version"
        print_colored $RED "❌ Cannot determine OS version"
        all_good=false
    fi
    
    # Check Python
    if command -v python3 >/dev/null 2>&1; then
        local python_version=$(python3 --version 2>&1)
        log_info "Python: $python_version"
        print_colored $GREEN "✅ Python: $python_version"
    else
        log_error "Python3 not found"
        print_colored $RED "❌ Python3 not found"
        all_good=false
    fi
    
    # Check package manager
    if command -v apt >/dev/null 2>&1; then
        log_info "Package Manager: APT"
        print_colored $GREEN "✅ Package Manager: APT"
    elif command -v yum >/dev/null 2>&1; then
        log_info "Package Manager: YUM"
        print_colored $GREEN "✅ Package Manager: YUM"
    elif command -v dnf >/dev/null 2>&1; then
        log_info "Package Manager: DNF"
        print_colored $GREEN "✅ Package Manager: DNF"
    else
        log_error "No supported package manager found"
        print_colored $RED "❌ No supported package manager found"
        all_good=false
    fi
    
    # Check battery support
    local battery_found=false
    for bat in /sys/class/power_supply/BAT*; do
        if [ -d "$bat" ]; then
            battery_found=true
            if [ -f "$bat/charge_control_end_threshold" ]; then
                log_info "Battery with threshold control: $bat"
                print_colored $GREEN "✅ Battery threshold control: $bat"
            else
                log_info "Battery without threshold control: $bat"
                print_colored $YELLOW "⚠️ Battery without threshold control: $bat"
            fi
        fi
    done
    
    if [ "$battery_found" = false ]; then
        log_error "No battery found"
        print_colored $RED "❌ No battery found"
        all_good=false
    fi
    
    # Check disk space
    local available_space=$(df / | tail -1 | awk '{print $4}')
    if [ "$available_space" -gt 100000 ]; then  # 100MB
        log_info "Available disk space: ${available_space}KB"
        print_colored $GREEN "✅ Sufficient disk space"
    else
        log_error "Insufficient disk space: ${available_space}KB"
        print_colored $RED "❌ Insufficient disk space"
        all_good=false
    fi
    
    # Check network
    if ping -c 1 google.com >/dev/null 2>&1; then
        log_info "Network: Connected"
        print_colored $GREEN "✅ Network: Connected"
    else
        log_info "Network: Disconnected"
        print_colored $YELLOW "⚠️ Network: Disconnected"
    fi
    
    return $all_good
}

# Function to diagnose and fix package manager issues
fix_package_manager() {
    print_header "Package Manager Diagnostic"
    
    if command -v apt >/dev/null 2>&1; then
        # Check APT status
        if sudo apt update >/dev/null 2>&1; then
            log_info "APT is working correctly"
            print_colored $GREEN "✅ APT is working correctly"
        else
            log_error "APT has issues, attempting to fix..."
            print_colored $YELLOW "⚠️ APT has issues, attempting to fix..."
            
            # Try to fix APT
            run_with_logging "sudo apt --fix-broken install" "Fix broken APT packages"
            run_with_logging "sudo dpkg --configure -a" "Configure pending packages"
            run_with_logging "sudo apt update" "Update package lists"
        fi
    fi
}

# Function to install with comprehensive logging
install_with_logging() {
    print_header "Installation with Logging"
    
    if [ -f "$SCRIPT_DIR/install.sh" ]; then
        log_diagnostic "Starting installation with logging..."
        
        # Run installation script with comprehensive logging
        if bash "$SCRIPT_DIR/install.sh" 2>&1 | tee -a "$INSTALL_LOG"; then
            log_diagnostic "Installation completed successfully"
            print_colored $GREEN "✅ Installation completed successfully"
        else
            log_error "Installation failed"
            print_colored $RED "❌ Installation failed"
            return 1
        fi
    else
        log_error "install.sh not found"
        print_colored $RED "❌ install.sh not found"
        return 1
    fi
}

# Function to test installation
test_installation() {
    print_header "Installation Testing"
    
    # Test CLI
    if command -v battery-cli >/dev/null 2>&1; then
        log_info "Testing battery-cli..."
        if run_with_logging "battery-cli status" "Test CLI status command"; then
            print_colored $GREEN "✅ CLI working"
        else
            log_error "CLI test failed"
            print_colored $RED "❌ CLI test failed"
        fi
    else
        log_error "battery-cli not found"
        print_colored $RED "❌ battery-cli not found"
    fi
    
    # Test GUI (with timeout)
    if command -v battery-gui >/dev/null 2>&1; then
        log_info "Testing battery-gui (with timeout)..."
        if run_with_logging "timeout 5 battery-gui --version" "Test GUI version"; then
            print_colored $GREEN "✅ GUI working"
        else
            log_error "GUI test failed or timed out"
            print_colored $YELLOW "⚠️ GUI test failed or timed out"
        fi
    else
        log_error "battery-gui not found"
        print_colored $RED "❌ battery-gui not found"
    fi
    
    # Test indicator launcher
    if command -v battery-indicator-launcher >/dev/null 2>&1; then
        log_info "Testing battery-indicator-launcher..."
        print_colored $GREEN "✅ Indicator launcher available"
    else
        log_error "battery-indicator-launcher not found"
        print_colored $RED "❌ battery-indicator-launcher not found"
    fi
}

# Function to show log summary
show_log_summary() {
    print_header "Log Summary"
    
    if [ -f "$SCRIPT_DIR/view-logs.sh" ]; then
        bash "$SCRIPT_DIR/view-logs.sh" summary
    else
        print_colored $YELLOW "⚠️ Log viewer not available"
        
        # Basic log summary
        for log_file in "$LOG_DIR"/*.log; do
            if [ -f "$log_file" ]; then
                local basename=$(basename "$log_file")
                local lines=$(wc -l < "$log_file" 2>/dev/null || echo "0")
                local errors=$(grep -c "\[ERROR\]" "$log_file" 2>/dev/null || echo "0")
                print_colored $BLUE "📄 $basename: $lines lines, $errors errors"
            fi
        done
    fi
}

# Main execution
main() {
    log_diagnostic "=== COMPREHENSIVE DIAGNOSTIC STARTED ==="
    log_diagnostic "Script: $0"
    log_diagnostic "User: $USER"
    log_diagnostic "Date: $(date)"
    log_diagnostic "Working directory: $(pwd)"
    
    print_header "Universal Battery Limiter - Comprehensive Diagnostic & Installation"
    
    # System requirements check
    if check_system_requirements; then
        print_colored $GREEN "✅ System requirements check passed"
    else
        print_colored $RED "❌ System requirements check failed"
        log_error "System requirements not met"
    fi
    
    # Package manager diagnostic
    fix_package_manager
    
    # Ask user what to do
    echo
    print_colored $YELLOW "What would you like to do?"
    echo "1. Install/Reinstall Battery Limiter"
    echo "2. Test existing installation"
    echo "3. View logs"
    echo "4. Exit"
    echo
    read -p "Enter your choice (1-4): " choice
    
    case $choice in
        1)
            install_with_logging
            test_installation
            ;;
        2)
            test_installation
            ;;
        3)
            show_log_summary
            ;;
        4)
            log_diagnostic "User chose to exit"
            print_colored $BLUE "Goodbye!"
            exit 0
            ;;
        *)
            log_error "Invalid choice: $choice"
            print_colored $RED "❌ Invalid choice"
            exit 1
            ;;
    esac
    
    # Show final log summary
    show_log_summary
    
    log_diagnostic "=== COMPREHENSIVE DIAGNOSTIC COMPLETED ==="
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    log_error "Script run as root (not recommended)"
    print_colored $RED "❌ Please do not run this script as root"
    exit 1
fi

# Execute main function
main "$@"
