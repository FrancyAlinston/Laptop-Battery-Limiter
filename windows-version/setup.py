#!/usr/bin/env python3
"""
Universal Battery Limiter - Windows Setup Script
Creates executable and installer for Windows distribution
"""

import sys
import os
from pathlib import Path

try:
    from cx_Freeze import setup, Executable
    CX_FREEZE_AVAILABLE = True
except ImportError:
    CX_FREEZE_AVAILABLE = False

try:
    import py2exe
    PY2EXE_AVAILABLE = True
except ImportError:
    PY2EXE_AVAILABLE = False

# Application information
APP_NAME = "Universal Battery Limiter"
APP_VERSION = "1.0.0"
APP_DESCRIPTION = "Battery charge management for Windows 11 laptops"
APP_AUTHOR = "FrancyAlinston"
APP_URL = "https://github.com/FrancyAlinston/Battery-Limter"

# Files to include
include_files = [
    "README.md",
    "config.json",
    "battery_manager.ps1",
    "requirements.txt"
]

# Packages to include
packages = [
    "tkinter",
    "json", 
    "pathlib",
    "subprocess",
    "threading",
    "time",
    "sys",
    "os",
    "platform"
]

# Packages to exclude (if not available on target system)
excludes = [
    "unittest",
    "email",
    "html",
    "http",
    "urllib",
    "xml",
    "pydoc",
    "doctest",
    "argparse"
]

def setup_cx_freeze():
    """Setup using cx_Freeze"""
    if not CX_FREEZE_AVAILABLE:
        print("cx_Freeze not available. Install with: pip install cx_Freeze")
        return False
    
    # Build options
    build_exe_options = {
        "packages": packages,
        "excludes": excludes,
        "include_files": include_files,
        "include_msvcrt": True,
        "optimize": 2
    }
    
    # Executables
    executables = [
        Executable(
            "battery_limiter_windows.py",
            base="Win32GUI",  # Use Win32GUI for GUI app, None for console
            target_name="BatteryLimiter.exe",
            icon=None,  # Add icon file if available
            shortcut_name="Universal Battery Limiter",
            shortcut_dir="DesktopFolder"
        ),
        Executable(
            "battery_cli.py", 
            base=None,  # Console application
            target_name="battery_cli.exe"
        )
    ]
    
    setup(
        name=APP_NAME,
        version=APP_VERSION,
        description=APP_DESCRIPTION,
        author=APP_AUTHOR,
        url=APP_URL,
        options={"build_exe": build_exe_options},
        executables=executables
    )
    
    return True

def setup_py2exe():
    """Setup using py2exe"""
    if not PY2EXE_AVAILABLE:
        print("py2exe not available. Install with: pip install py2exe")
        return False
    
    setup(
        name=APP_NAME,
        version=APP_VERSION,
        description=APP_DESCRIPTION,
        author=APP_AUTHOR,
        url=APP_URL,
        
        # GUI application
        windows=[{
            "script": "battery_limiter_windows.py",
            "dest_base": "BatteryLimiter",
            "icon_resources": []  # Add icon if available
        }],
        
        # Console application
        console=[{
            "script": "battery_cli.py",
            "dest_base": "battery_cli"
        }],
        
        options={
            "py2exe": {
                "packages": packages,
                "excludes": excludes,
                "bundle_files": 2,  # Bundle everything except Python interpreter
                "compressed": True,
                "optimize": 2,
                "includes": ["sip"]
            }
        },
        
        # Additional files
        data_files=[
            (".", include_files)
        ],
        
        zipfile=None
    )
    
    return True

def create_installer_script():
    """Create NSIS installer script"""
    nsis_script = f'''
; Universal Battery Limiter - NSIS Installer Script

!define APP_NAME "Universal Battery Limiter"
!define APP_VERSION "1.0.0"
!define APP_PUBLISHER "FrancyAlinston"
!define APP_URL "https://github.com/FrancyAlinston/Battery-Limter"
!define APP_EXEC "BatteryLimiter.exe"

; Include Modern UI
!include "MUI2.nsh"

; General settings
Name "${{APP_NAME}}"
OutFile "UniversalBatteryLimiter_Setup.exe"
InstallDir "$PROGRAMFILES\\${{APP_NAME}}"
InstallDirRegKey HKCU "Software\\${{APP_NAME}}" ""
RequestExecutionLevel admin

; Interface Configuration
!define MUI_ABORTWARNING
!define MUI_ICON "${{NSISDIR}}\\Contrib\\Graphics\\Icons\\modern-install.ico"
!define MUI_UNICON "${{NSISDIR}}\\Contrib\\Graphics\\Icons\\modern-uninstall.ico"

; Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; Languages
!insertmacro MUI_LANGUAGE "English"

; Version Information
VIProductVersion "1.0.0.0"
VIAddVersionKey "ProductName" "${{APP_NAME}}"
VIAddVersionKey "Comments" "Battery charge management for Windows laptops"
VIAddVersionKey "CompanyName" "${{APP_PUBLISHER}}"
VIAddVersionKey "LegalCopyright" "© 2025 ${{APP_PUBLISHER}}"
VIAddVersionKey "FileDescription" "${{APP_NAME}} Setup"
VIAddVersionKey "FileVersion" "${{APP_VERSION}}"
VIAddVersionKey "ProductVersion" "${{APP_VERSION}}"
VIAddVersionKey "OriginalFilename" "UniversalBatteryLimiter_Setup.exe"

; Installation section
Section "Install"
    SetOutPath "$INSTDIR"
    
    ; Copy files
    File /r "dist\\*"
    
    ; Create shortcuts
    CreateDirectory "$SMPROGRAMS\\${{APP_NAME}}"
    CreateShortCut "$SMPROGRAMS\\${{APP_NAME}}\\${{APP_NAME}}.lnk" "$INSTDIR\\${{APP_EXEC}}"
    CreateShortCut "$SMPROGRAMS\\${{APP_NAME}}\\Battery CLI.lnk" "$INSTDIR\\battery_cli.exe"
    CreateShortCut "$SMPROGRAMS\\${{APP_NAME}}\\Uninstall.lnk" "$INSTDIR\\Uninstall.exe"
    CreateShortCut "$DESKTOP\\${{APP_NAME}}.lnk" "$INSTDIR\\${{APP_EXEC}}"
    
    ; Registry entries
    WriteRegStr HKCU "Software\\${{APP_NAME}}" "" $INSTDIR
    WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APP_NAME}}" "DisplayName" "${{APP_NAME}}"
    WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APP_NAME}}" "UninstallString" "$INSTDIR\\Uninstall.exe"
    WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APP_NAME}}" "Publisher" "${{APP_PUBLISHER}}"
    WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APP_NAME}}" "URLInfoAbout" "${{APP_URL}}"
    WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APP_NAME}}" "DisplayVersion" "${{APP_VERSION}}"
    WriteRegDWORD HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APP_NAME}}" "NoModify" 1
    WriteRegDWORD HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APP_NAME}}" "NoRepair" 1
    
    ; Create uninstaller
    WriteUninstaller "$INSTDIR\\Uninstall.exe"
SectionEnd

; Uninstallation section
Section "Uninstall"
    ; Remove files
    RMDir /r "$INSTDIR"
    
    ; Remove shortcuts
    RMDir /r "$SMPROGRAMS\\${{APP_NAME}}"
    Delete "$DESKTOP\\${{APP_NAME}}.lnk"
    
    ; Remove registry entries
    DeleteRegKey HKCU "Software\\${{APP_NAME}}"
    DeleteRegKey HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${{APP_NAME}}"
SectionEnd
'''
    
    with open("installer.nsi", "w") as f:
        f.write(nsis_script)
    
    print("Created installer.nsi - Use NSIS to compile the installer")

def main():
    """Main setup function"""
    print(f"Setting up {APP_NAME} v{APP_VERSION}")
    print("=" * 50)
    
    if len(sys.argv) < 2:
        print("Usage: python setup.py [build_exe|py2exe|installer]")
        print("\nAvailable options:")
        print("  build_exe  - Create executable using cx_Freeze")
        print("  py2exe     - Create executable using py2exe")
        print("  installer  - Create NSIS installer script")
        return
    
    command = sys.argv[1].lower()
    
    if command == "build_exe":
        if setup_cx_freeze():
            print("✅ Executable created successfully using cx_Freeze")
            print("Check the 'build' directory for output")
        else:
            print("❌ Failed to create executable with cx_Freeze")
    
    elif command == "py2exe":
        if setup_py2exe():
            print("✅ Executable created successfully using py2exe")
            print("Check the 'dist' directory for output")
        else:
            print("❌ Failed to create executable with py2exe")
    
    elif command == "installer":
        create_installer_script()
        print("✅ Installer script created: installer.nsi")
        print("Use NSIS (Nullsoft Scriptable Install System) to compile")
    
    else:
        print(f"❌ Unknown command: {command}")
        print("Use: build_exe, py2exe, or installer")

if __name__ == "__main__":
    main()
