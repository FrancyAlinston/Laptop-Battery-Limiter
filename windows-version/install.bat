@echo off
REM Universal Battery Limiter - Windows 11 Installation Script
REM Creates professional .exe installer for distribution

echo ============================================
echo Universal Battery Limiter - Windows 11
echo Professional Installer Creator
echo ============================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.6 or higher from https://python.org
    pause
    exit /b 1
)

echo ✓ Python found
python --version

REM Check if pip is available
pip --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: pip is not available
    echo Please ensure pip is installed with Python
    pause
    exit /b 1
)

echo ✓ pip found
echo.

REM Run the professional installer creator
echo Creating professional Windows installer...
echo.
python create_installer.py

if errorlevel 1 (
    echo.
    echo ERROR: Failed to create installer
    echo Please check the error messages above
    pause
    exit /b 1
)

echo.
echo ✅ Installer creation completed!
echo.
echo Files created:
if exist "UniversalBatteryLimiter_v2.2.0_Setup.exe" (
    echo   📦 UniversalBatteryLimiter_v2.2.0_Setup.exe - Professional installer
) else (
    echo   📦 dist\Install_BatteryLimiter.bat - Fallback installer
)
echo   📁 dist\UniversalBatteryLimiter.exe - Main application
echo   📁 dist\battery-cli.exe - Command line interface
echo.
echo 🚀 Ready for distribution!
echo Share the installer file with users for easy installation.
echo.
pause
    pip install requests
)

echo.
echo ============================================
echo Installation completed!
echo ============================================
echo.

REM Create desktop shortcut
echo Creating desktop shortcut...
set DESKTOP=%USERPROFILE%\Desktop
set CURRENT_DIR=%~dp0

echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\CreateShortcut.vbs"
echo sLinkFile = "%DESKTOP%\Universal Battery Limiter.lnk" >> "%TEMP%\CreateShortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\CreateShortcut.vbs"
echo oLink.TargetPath = "python" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Arguments = """%CURRENT_DIR%battery_limiter_windows.py""" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.WorkingDirectory = "%CURRENT_DIR%" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Description = "Universal Battery Limiter for Windows 11" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Save >> "%TEMP%\CreateShortcut.vbs"

cscript "%TEMP%\CreateShortcut.vbs" >nul
del "%TEMP%\CreateShortcut.vbs"

echo ✓ Desktop shortcut created

echo.
echo ============================================
echo Setup Information:
echo ============================================
echo.
echo • Battery Limiter installed in: %CURRENT_DIR%
echo • Desktop shortcut created
echo • To run: double-click desktop shortcut or run battery_limiter_windows.py
echo • To uninstall: run uninstall.bat
echo.

REM Test installation
echo Testing installation...
echo.
python battery_limiter_windows.py --test >nul 2>&1
if errorlevel 1 (
    echo ⚠ WARNING: Installation test failed
    echo The application may not work correctly
    echo Check the requirements and try running manually
) else (
    echo ✓ Installation test passed
)

echo.
echo Installation complete! You can now run Universal Battery Limiter.
echo.
pause
