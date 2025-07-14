@echo off
REM Universal Battery Limiter - Windows 11 Installation Script
REM Installs dependencies and sets up the battery limiter

echo ============================================
echo Universal Battery Limiter - Windows 11
echo Installation Script
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

REM Install required packages
echo Installing required Python packages...
echo.
pip install -r requirements.txt

if errorlevel 1 (
    echo.
    echo ERROR: Failed to install some packages
    echo Trying individual installation...
    echo.
    
    pip install wmi
    pip install pywin32
    pip install pystray
    pip install Pillow
    pip install psutil
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
