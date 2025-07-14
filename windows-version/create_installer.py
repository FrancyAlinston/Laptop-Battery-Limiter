#!/usr/bin/env python3
"""
Universal Battery Limiter - Windows Installer Creator
Creates professional .exe installer for Windows distribution
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

def print_banner():
    """Print application banner"""
    print("""
╔══════════════════════════════════════════════════════════════╗
║           Universal Battery Limiter - Windows 11             ║
║                Professional Installer Creator                ║
║                                                              ║
║  Creates production-ready .exe installer for Windows        ║
╚══════════════════════════════════════════════════════════════╝
""")

def check_requirements():
    """Check if all required tools are available"""
    print("🔍 Checking requirements...")
    
    requirements = {
        "Python": True,
        "PyInstaller": False,
        "NSIS": False,
        "Git": False
    }
    
    # Check Python
    try:
        version = sys.version_info
        if version.major >= 3 and version.minor >= 6:
            print(f"✅ Python {version.major}.{version.minor}.{version.micro}")
            requirements["Python"] = True
        else:
            print(f"❌ Python {version.major}.{version.minor} (3.6+ required)")
    except Exception:
        print("❌ Python not found")
    
    # Check PyInstaller
    try:
        result = subprocess.run(["pyinstaller", "--version"], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ PyInstaller {result.stdout.strip()}")
            requirements["PyInstaller"] = True
        else:
            print("❌ PyInstaller not working")
    except FileNotFoundError:
        print("❌ PyInstaller not installed")
    
    # Check NSIS
    try:
        result = subprocess.run(["makensis", "/VERSION"], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ NSIS {result.stdout.strip()}")
            requirements["NSIS"] = True
        else:
            print("⚠️ NSIS not found (optional)")
    except FileNotFoundError:
        print("⚠️ NSIS not installed (optional)")
    
    # Check Git
    try:
        result = subprocess.run(["git", "--version"], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ {result.stdout.strip()}")
            requirements["Git"] = True
        else:
            print("⚠️ Git not working")
    except FileNotFoundError:
        print("⚠️ Git not installed")
    
    return requirements

def install_dependencies():
    """Install Python dependencies"""
    print("\n📦 Installing Python dependencies...")
    
    try:
        result = subprocess.run([
            sys.executable, "-m", "pip", "install", "-r", "requirements.txt"
        ], check=True, capture_output=True, text=True)
        
        print("✅ Dependencies installed successfully!")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to install dependencies: {e}")
        print("Error output:", e.stderr)
        return False

def build_executable():
    """Build executable using PyInstaller"""
    print("\n🔨 Building executable...")
    
    # PyInstaller command
    cmd = [
        "pyinstaller",
        "--onefile",
        "--windowed",
        "--name=UniversalBatteryLimiter",
        "--icon=icons/battery-icon.ico" if os.path.exists("icons/battery-icon.ico") else "",
        "--add-data=config.json;.",
        "--add-data=README.md;.",
        "--add-data=battery_manager.ps1;.",
        "--hidden-import=wmi",
        "--hidden-import=win32api",
        "--hidden-import=win32con",
        "--hidden-import=win32gui",
        "--hidden-import=pystray",
        "--hidden-import=PIL",
        "battery_limiter_windows.py"
    ]
    
    # Remove empty icon parameter
    cmd = [arg for arg in cmd if arg]
    
    try:
        print("Running:", " ".join(cmd))
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        print("✅ Executable built successfully!")
        
        # Also build CLI executable
        cmd_cli = [
            "pyinstaller",
            "--onefile",
            "--console",
            "--name=battery-cli",
            "battery_cli.py"
        ]
        
        subprocess.run(cmd_cli, check=True, capture_output=True, text=True)
        print("✅ CLI executable built successfully!")
        
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to build executable: {e}")
        print("Error output:", e.stderr)
        return False

def create_nsis_installer():
    """Create NSIS installer script and compile"""
    print("\n🔧 Creating NSIS installer...")
    
    nsis_script = '''# Universal Battery Limiter - Professional Windows Installer
# Auto-generated installer script

!define APP_NAME "Universal Battery Limiter"
!define APP_VERSION "2.2.0"
!define APP_PUBLISHER "FrancyAlinston"
!define APP_URL "https://github.com/FrancyAlinston/Battery-Limter"
!define APP_EXECUTABLE "UniversalBatteryLimiter.exe"

# Modern UI
!include "MUI2.nsh"
!include "Sections.nsh"

# General
Name "${APP_NAME}"
OutFile "UniversalBatteryLimiter_v${APP_VERSION}_Setup.exe"
Unicode True
InstallDir "$PROGRAMFILES64\\${APP_NAME}"
InstallDirRegKey HKCU "Software\\${APP_NAME}" ""
RequestExecutionLevel admin

# Compression
SetCompress auto
SetCompressor /SOLID lzma

# Interface Settings
!define MUI_ABORTWARNING
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "icons\\header.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "icons\\welcome.bmp"

# Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\\${APP_EXECUTABLE}"
!define MUI_FINISHPAGE_RUN_TEXT "Launch ${APP_NAME}"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

# Languages
!insertmacro MUI_LANGUAGE "English"

# Version Information
VIProductVersion "2.2.0.0"
VIAddVersionKey "ProductName" "${APP_NAME}"
VIAddVersionKey "ProductVersion" "${APP_VERSION}"
VIAddVersionKey "CompanyName" "${APP_PUBLISHER}"
VIAddVersionKey "LegalCopyright" "© 2025 ${APP_PUBLISHER}"
VIAddVersionKey "FileDescription" "${APP_NAME} Installer"
VIAddVersionKey "FileVersion" "${APP_VERSION}"

# Installer Sections
Section "!Main Application" SecMain
    SectionIn RO
    SetOutPath "$INSTDIR"
    
    # Application files
    File "dist\\${APP_EXECUTABLE}"
    File "dist\\battery-cli.exe"
    File "config.json"
    File "README.md"
    File "battery_manager.ps1"
    
    # Store installation folder
    WriteRegStr HKCU "Software\\${APP_NAME}" "" $INSTDIR
    
    # Create uninstaller
    WriteUninstaller "$INSTDIR\\Uninstall.exe"
    
    # Add to Add/Remove Programs
    WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${APP_NAME}" "DisplayName" "${APP_NAME}"
    WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${APP_NAME}" "UninstallString" "$INSTDIR\\Uninstall.exe"
    WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${APP_NAME}" "DisplayVersion" "${APP_VERSION}"
    WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${APP_NAME}" "Publisher" "${APP_PUBLISHER}"
    WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${APP_NAME}" "URLInfoAbout" "${APP_URL}"
    WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${APP_NAME}" "DisplayIcon" "$INSTDIR\\${APP_EXECUTABLE}"
    WriteRegDWORD HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${APP_NAME}" "NoModify" 1
    WriteRegDWORD HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${APP_NAME}" "NoRepair" 1
SectionEnd

Section "Desktop Shortcut" SecDesktop
    CreateShortcut "$DESKTOP\\${APP_NAME}.lnk" "$INSTDIR\\${APP_EXECUTABLE}"
SectionEnd

Section "Start Menu Shortcuts" SecStartMenu
    CreateDirectory "$SMPROGRAMS\\${APP_NAME}"
    CreateShortcut "$SMPROGRAMS\\${APP_NAME}\\${APP_NAME}.lnk" "$INSTDIR\\${APP_EXECUTABLE}"
    CreateShortcut "$SMPROGRAMS\\${APP_NAME}\\Command Line.lnk" "$INSTDIR\\battery-cli.exe"
    CreateShortcut "$SMPROGRAMS\\${APP_NAME}\\Uninstall.lnk" "$INSTDIR\\Uninstall.exe"
SectionEnd

Section "Auto-Start" SecAutoStart
    WriteRegStr HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Run" "${APP_NAME}" "$INSTDIR\\${APP_EXECUTABLE} --minimized"
SectionEnd

# Section Descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecMain} "Core application files (required)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktop} "Create desktop shortcut"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecStartMenu} "Create Start Menu shortcuts"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecAutoStart} "Start automatically with Windows"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

# Uninstaller Section
Section "Uninstall"
    # Remove files
    Delete "$INSTDIR\\${APP_EXECUTABLE}"
    Delete "$INSTDIR\\battery-cli.exe"
    Delete "$INSTDIR\\config.json"
    Delete "$INSTDIR\\README.md"
    Delete "$INSTDIR\\battery_manager.ps1"
    Delete "$INSTDIR\\Uninstall.exe"
    
    # Remove shortcuts
    Delete "$DESKTOP\\${APP_NAME}.lnk"
    Delete "$SMPROGRAMS\\${APP_NAME}\\${APP_NAME}.lnk"
    Delete "$SMPROGRAMS\\${APP_NAME}\\Command Line.lnk"
    Delete "$SMPROGRAMS\\${APP_NAME}\\Uninstall.lnk"
    RMDir "$SMPROGRAMS\\${APP_NAME}"
    
    # Remove registry entries
    DeleteRegKey HKCU "Software\\${APP_NAME}"
    DeleteRegKey HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${APP_NAME}"
    DeleteRegValue HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Run" "${APP_NAME}"
    
    # Remove installation directory
    RMDir "$INSTDIR"
SectionEnd
'''
    
    # Write NSIS script
    with open("installer.nsi", "w", encoding="utf-8") as f:
        f.write(nsis_script)
    
    # Create LICENSE.txt if it doesn't exist
    if not os.path.exists("LICENSE.txt"):
        license_text = """MIT License

Copyright (c) 2025 FrancyAlinston

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""
        with open("LICENSE.txt", "w") as f:
            f.write(license_text)
    
    # Try to compile with NSIS
    try:
        result = subprocess.run(["makensis", "installer.nsi"], 
                              check=True, capture_output=True, text=True)
        print("✅ NSIS installer created successfully!")
        print("📦 Installer: UniversalBatteryLimiter_v2.2.0_Setup.exe")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"❌ NSIS compilation failed: {e}")
        return False
    except FileNotFoundError:
        print("⚠️ NSIS not found, creating fallback installer...")
        return False

def create_fallback_installer():
    """Create fallback installer when NSIS is not available"""
    print("🔧 Creating fallback installer...")
    
    # Create a PowerShell installer
    ps_installer = '''# Universal Battery Limiter - PowerShell Installer
param(
    [switch]$Uninstall
)

$AppName = "Universal Battery Limiter"
$AppVersion = "2.2.0"
$InstallDir = "$env:ProgramFiles\\$AppName"

if ($Uninstall) {
    Write-Host "Uninstalling $AppName..." -ForegroundColor Yellow
    
    # Remove files
    if (Test-Path $InstallDir) {
        Remove-Item -Recurse -Force $InstallDir
        Write-Host "✅ Application files removed" -ForegroundColor Green
    }
    
    # Remove shortcuts
    $DesktopShortcut = "$env:USERPROFILE\\Desktop\\$AppName.lnk"
    if (Test-Path $DesktopShortcut) {
        Remove-Item $DesktopShortcut
    }
    
    $StartMenuDir = "$env:APPDATA\\Microsoft\\Windows\\Start Menu\\Programs\\$AppName"
    if (Test-Path $StartMenuDir) {
        Remove-Item -Recurse -Force $StartMenuDir
    }
    
    # Remove from startup
    $StartupReg = "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Run"
    if (Get-ItemProperty -Path $StartupReg -Name $AppName -ErrorAction SilentlyContinue) {
        Remove-ItemProperty -Path $StartupReg -Name $AppName
    }
    
    Write-Host "✅ $AppName uninstalled successfully!" -ForegroundColor Green
    
} else {
    Write-Host "Installing $AppName v$AppVersion..." -ForegroundColor Green
    
    # Check if running as administrator
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "❌ Please run as Administrator" -ForegroundColor Red
        exit 1
    }
    
    # Create installation directory
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        Write-Host "✅ Created installation directory" -ForegroundColor Green
    }
    
    # Copy files
    Copy-Item "UniversalBatteryLimiter.exe" "$InstallDir\\" -Force
    Copy-Item "battery-cli.exe" "$InstallDir\\" -Force
    Copy-Item "config.json" "$InstallDir\\" -Force
    Copy-Item "README.md" "$InstallDir\\" -Force
    Copy-Item "battery_manager.ps1" "$InstallDir\\" -Force
    Write-Host "✅ Application files copied" -ForegroundColor Green
    
    # Create desktop shortcut
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\\Desktop\\$AppName.lnk")
    $Shortcut.TargetPath = "$InstallDir\\UniversalBatteryLimiter.exe"
    $Shortcut.Save()
    Write-Host "✅ Desktop shortcut created" -ForegroundColor Green
    
    # Create start menu shortcuts
    $StartMenuDir = "$env:APPDATA\\Microsoft\\Windows\\Start Menu\\Programs\\$AppName"
    New-Item -ItemType Directory -Path $StartMenuDir -Force | Out-Null
    
    $Shortcut = $WshShell.CreateShortcut("$StartMenuDir\\$AppName.lnk")
    $Shortcut.TargetPath = "$InstallDir\\UniversalBatteryLimiter.exe"
    $Shortcut.Save()
    
    $Shortcut = $WshShell.CreateShortcut("$StartMenuDir\\Command Line.lnk")
    $Shortcut.TargetPath = "$InstallDir\\battery-cli.exe"
    $Shortcut.Save()
    Write-Host "✅ Start Menu shortcuts created" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "🎉 $AppName installed successfully!" -ForegroundColor Green
    Write-Host "You can now run it from the Start Menu or Desktop shortcut." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To uninstall, run: PowerShell -ExecutionPolicy Bypass -File installer.ps1 -Uninstall" -ForegroundColor Yellow
}
'''
    
    with open("dist/installer.ps1", "w", encoding="utf-8") as f:
        f.write(ps_installer)
    
    # Create batch wrapper
    batch_installer = '''@echo off
echo Universal Battery Limiter - Windows Installer
echo.

REM Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This installer requires administrator privileges.
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)

REM Run PowerShell installer
PowerShell -ExecutionPolicy Bypass -File installer.ps1
pause
'''
    
    with open("dist/Install_BatteryLimiter.bat", "w") as f:
        f.write(batch_installer)
    
    print("✅ Fallback installer created: dist/Install_BatteryLimiter.bat")
    print("✅ PowerShell installer: dist/installer.ps1")

def main():
    """Main installer creation function"""
    print_banner()
    
    # Check if we're in the right directory
    if not os.path.exists("battery_limiter_windows.py"):
        print("❌ Error: Must be run from the Windows version directory")
        print("Please cd to the windows-version folder and try again")
        return False
    
    # Check requirements
    requirements = check_requirements()
    
    if not requirements["Python"]:
        print("❌ Python 3.6+ is required")
        return False
    
    # Install dependencies
    if not install_dependencies():
        print("❌ Failed to install dependencies")
        return False
    
    # Build executable
    if not build_executable():
        print("❌ Failed to build executable")
        return False
    
    # Create installer
    if requirements["NSIS"]:
        if not create_nsis_installer():
            create_fallback_installer()
    else:
        create_fallback_installer()
    
    print("\n" + "="*60)
    print("🎉 Universal Battery Limiter Windows installer creation complete!")
    print("\nFiles created:")
    print("📁 dist/UniversalBatteryLimiter.exe - Main application")
    print("📁 dist/battery-cli.exe - Command line interface")
    
    if os.path.exists("UniversalBatteryLimiter_v2.2.0_Setup.exe"):
        print("📦 UniversalBatteryLimiter_v2.2.0_Setup.exe - Professional installer")
    else:
        print("📦 dist/Install_BatteryLimiter.bat - Fallback installer")
        print("📦 dist/installer.ps1 - PowerShell installer")
    
    print("\n📖 Distribution Instructions:")
    print("1. Share the .exe installer with users")
    print("2. Users run installer as Administrator")
    print("3. Application installs to Program Files")
    print("4. Desktop and Start Menu shortcuts created")
    print("5. Optional auto-start with Windows")
    
    return True

if __name__ == "__main__":
    success = main()
    if not success:
        sys.exit(1)
