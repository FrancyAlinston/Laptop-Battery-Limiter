@echo off
REM Universal Battery Limiter - Windows 11 Uninstaller
REM Removes application files and shortcuts

echo ============================================
echo Universal Battery Limiter - Windows 11
echo Uninstaller
echo ============================================
echo.

set /p CONFIRM=Are you sure you want to uninstall Universal Battery Limiter? (y/N): 
if /i not "%CONFIRM%"=="y" (
    echo Uninstallation cancelled.
    pause
    exit /b 0
)

echo.
echo Uninstalling Universal Battery Limiter...
echo.

REM Remove desktop shortcut
set DESKTOP=%USERPROFILE%\Desktop
if exist "%DESKTOP%\Universal Battery Limiter.lnk" (
    del "%DESKTOP%\Universal Battery Limiter.lnk"
    echo ✓ Desktop shortcut removed
)

REM Remove start menu shortcut (if exists)
set STARTMENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs
if exist "%STARTMENU%\Universal Battery Limiter.lnk" (
    del "%STARTMENU%\Universal Battery Limiter.lnk"
    echo ✓ Start menu shortcut removed
)

REM Remove autostart entry (if exists)
set STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
if exist "%STARTUP%\Universal Battery Limiter.lnk" (
    del "%STARTUP%\Universal Battery Limiter.lnk"
    echo ✓ Autostart entry removed
)

REM Ask about removing Python packages
echo.
set /p REMOVE_PACKAGES=Do you want to remove Python packages installed for Battery Limiter? (y/N): 
if /i "%REMOVE_PACKAGES%"=="y" (
    echo.
    echo Removing Python packages...
    pip uninstall -y wmi pywin32 pystray Pillow psutil requests
    echo ✓ Python packages removed
)

echo.
echo ============================================
echo Uninstallation Information:
echo ============================================
echo.
echo • Shortcuts removed
echo • Application files remain in current directory
echo • To completely remove, delete this folder manually
echo.

REM Reset any power plans that might have been created
echo Cleaning up power plans...
for /f "tokens=*" %%i in ('powercfg /list ^| findstr "Battery Limiter"') do (
    for /f "tokens=4" %%j in ("%%i") do (
        powercfg /delete %%j >nul 2>&1
        echo ✓ Removed power plan: %%j
    )
)

echo.
echo Uninstallation completed successfully!
echo.
echo Note: This folder and its contents have not been deleted.
echo You can safely delete this entire folder to complete removal.
echo.
pause
