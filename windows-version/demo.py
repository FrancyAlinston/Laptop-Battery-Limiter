#!/usr/bin/env python3
"""
Windows Version Demo Script
Demonstrates the Windows Battery Limiter functionality
"""

import os
import sys
import subprocess
from pathlib import Path

def print_header(title):
    print("\n" + "="*60)
    print(f" {title}")
    print("="*60)

def run_demo():
    """Run a demo of the Windows Battery Limiter"""
    
    print_header("Universal Battery Limiter - Windows 11 Demo")
    
    # Check if we're in the Windows version directory
    windows_dir = Path(__file__).parent
    if not (windows_dir / "battery_limiter_windows.py").exists():
        print("❌ Error: Not in Windows version directory")
        return False
    
    print(f"📁 Windows Version Directory: {windows_dir}")
    
    # List all available files
    print_header("Available Files")
    files = [
        ("🔋 Main Application", "battery_limiter_windows.py"),
        ("⚙️ Configuration", "config.json"),
        ("🖥️ Command Line Interface", "battery_cli.py"),
        ("🔧 Configuration Manager", "config_manager.py"),
        ("📝 PowerShell Integration", "battery_manager.ps1"),
        ("📦 Requirements", "requirements.txt"),
        ("🚀 Installer", "install.bat"),
        ("🗑️ Uninstaller", "uninstall.bat"),
        ("📖 Setup Script", "setup.py"),
        ("📚 Documentation", "README.md"),
        ("👨‍💻 Development Guide", "DEVELOPMENT.md")
    ]
    
    for description, filename in files:
        status = "✅" if (windows_dir / filename).exists() else "❌"
        print(f"{status} {description:<25} - {filename}")
    
    # Check Python dependencies
    print_header("Dependencies Check")
    
    dependencies = [
        ("wmi", "Windows Management Instrumentation"),
        ("pywin32", "Windows API Access"),
        ("pystray", "System Tray Integration"),
        ("PIL", "Image Processing"),
        ("psutil", "System Utilities"),
        ("tkinter", "GUI Framework")
    ]
    
    for module, description in dependencies:
        try:
            if module == "PIL":
                import PIL
            elif module == "tkinter":
                import tkinter
            else:
                __import__(module)
            print(f"✅ {module:<15} - {description}")
        except ImportError:
            print(f"❌ {module:<15} - {description} (Not installed)")
    
    # Show supported manufacturers
    print_header("Supported Manufacturers")
    
    manufacturers = [
        ("Lenovo", "ThinkPad, IdeaPad - Conservation Mode, Custom Limits"),
        ("Dell", "XPS, Inspiron, Latitude - Dell Command Configure Integration"),
        ("HP", "ProBook, EliteBook, Pavilion - Battery Health Manager"),
        ("ASUS", "ZenBook, VivoBook, ROG - Battery Health Charging"),
        ("Generic", "PowerShell Power Plans, WMI Management")
    ]
    
    for brand, support in manufacturers:
        print(f"🏭 {brand:<10} - {support}")
    
    # Show installation methods
    print_header("Installation Methods")
    
    print("1. 🚀 Quick Install (Recommended)")
    print("   - Run install.bat as Administrator")
    print("   - Automatic dependency installation")
    print("   - Desktop shortcut creation")
    
    print("\n2. 📦 Manual Install")
    print("   - pip install -r requirements.txt")
    print("   - python battery_limiter_windows.py")
    
    print("\n3. 🔧 Developer Install")
    print("   - python setup.py build")
    print("   - Creates standalone executable")
    
    # Show usage examples
    print_header("Usage Examples")
    
    print("🖥️ GUI Application:")
    print("   python battery_limiter_windows.py")
    print("   python battery_limiter_windows.py --minimized")
    
    print("\n⌨️ Command Line:")
    print("   python battery_cli.py --status")
    print("   python battery_cli.py --set-limit 80")
    print("   python battery_cli.py --info")
    
    print("\n🔥 PowerShell:")
    print("   .\\battery_manager.ps1 -Action set -Limit 80")
    print("   .\\battery_manager.ps1 -Action info")
    print("   .\\battery_manager.ps1 -Action reset")
    
    # Configuration example
    print_header("Configuration Example")
    
    config_example = """{
    "application": {
        "auto_start": true,
        "minimize_to_tray": true
    },
    "battery": {
        "default_limit": 80,
        "monitoring_interval": 30,
        "notification_enabled": true
    },
    "ui": {
        "theme": "auto",
        "compact_mode": false
    }
}"""
    
    print("📝 config.json:")
    print(config_example)
    
    print_header("Next Steps")
    
    print("1. 📥 Install dependencies: install.bat")
    print("2. 🔋 Run the application: python battery_limiter_windows.py")
    print("3. ⚙️ Configure settings via GUI")
    print("4. 🚀 Enable auto-start for convenience")
    
    print("\n📚 For detailed documentation, see:")
    print("   - README.md - Complete user guide")
    print("   - DEVELOPMENT.md - Developer documentation")
    
    print_header("Demo Complete")
    print("🎉 Windows Battery Limiter is ready to use!")
    
    return True

if __name__ == "__main__":
    run_demo()
