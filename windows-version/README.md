# Universal Battery Limiter - Windows 11 Edition

## 🚀 **Cross-Platform Battery Management for Windows Laptops**

This is the Windows 11 compatible version of Universal Battery Limiter, designed specifically for Windows laptops with manufacturer-specific battery management support.

### ✨ **Features**

#### 🔋 **Advanced Battery Control**
- **Multi-Manufacturer Support**: Lenovo, Dell, HP, ASUS, and generic laptops
- **Smart Detection**: Automatically detects your laptop manufacturer and available methods
- **Multiple APIs**: WMI, manufacturer-specific tools, PowerShell power plans
- **Real-time Monitoring**: Live battery status and charge level display

#### 💻 **Windows 11 Native Integration**
- **Modern GUI**: Windows 11 styled interface with Segoe UI font
- **System Tray**: Minimize to system tray with quick access menu
- **UAC Integration**: Proper Windows User Account Control handling
- **Power Plans**: Integration with Windows power management

#### 🎯 **Manufacturer-Specific Support**

##### **Lenovo**
- Conservation Mode (60% limit)
- Lenovo Vantage integration
- Registry-based control

##### **Dell**
- Dell Command Configure (cctk) integration
- Custom charge limits (50-100%)
- BIOS-level battery settings

##### **HP**
- HP Battery Health Manager
- WMI-based control
- BIOS integration

##### **ASUS**
- ASUS Battery Health Charging
- Three modes: Maximum Lifespan (60%), Balanced (80%), Full Capacity (100%)
- Registry-based configuration

##### **Generic Laptops**
- PowerShell power plan modification
- WMI battery management
- Fallback methods for unsupported hardware

### 📋 **System Requirements**

- **Operating System**: Windows 10 version 1903 or later, Windows 11 (recommended)
- **Python**: Python 3.6 or higher
- **Administrator Access**: Required for battery management
- **Supported Hardware**: Laptops with ACPI battery management or manufacturer-specific tools

### 🔧 **Installation**

#### **Method 1: Professional Installer (Recommended)**

1. **Download** the latest release: `UniversalBatteryLimiter_v2.2.0_Setup.exe`
2. **Right-click** and select "Run as administrator"
3. **Follow** the installation wizard
4. **Launch** from Start Menu or Desktop shortcut
5. **Optional**: Enable auto-start with Windows

#### **Method 2: Build from Source**

```cmd
# Clone the repository
git clone https://github.com/FrancyAlinston/Battery-Limter.git
cd Battery-Limter/windows-version

# Create professional installer
install.bat

# This creates UniversalBatteryLimiter_v2.2.0_Setup.exe
```

#### **Method 3: Direct Python Execution**

```cmd
# Install Python dependencies
pip install -r requirements.txt

# Run the application directly
python battery_limiter_windows.py
```

### 🎮 **Usage**

#### **Main Interface**
- **Battery Status**: Real-time battery level and charging status
- **System Info**: Detected manufacturer and supported methods
- **Charge Limit**: Set custom limit from 50-100%
- **Quick Presets**: 60%, 70%, 80%, 90%, 100% buttons

#### **System Tray**
- **Quick Access**: Right-click tray icon for menu
- **Fast Limits**: Set common limits without opening main window
- **Background Monitoring**: Continuous battery monitoring

#### **Supported Charge Limits**
- **50-60%**: Maximum battery lifespan (recommended for desk use)
- **70-80%**: Balanced usage (recommended for daily use)
- **90-100%**: Full capacity (for travel/heavy use)

### 🔒 **Security & Permissions**

#### **UAC Requirements**
- Battery management requires administrator privileges
- Registry modifications need elevated access
- Hardware-level changes require system permissions

#### **Safe Operation**
- No permanent system modifications
- Registry changes are reversible
- Power plans can be deleted
- Safe fallback methods

### 🛠️ **Troubleshooting**

#### **Common Issues**

##### **"No supported methods detected"**
- Install manufacturer software (Lenovo Vantage, Dell Command, HP Support Assistant)
- Update laptop drivers and BIOS
- Check if laptop supports battery charge limiting

##### **"Access denied" errors**
- Run as administrator
- Check UAC settings
- Verify user account permissions

##### **"Module not found" errors**
- Install required packages: `pip install -r requirements.txt`
- Check Python installation
- Verify virtual environment (if used)

#### **Manufacturer-Specific Issues**

##### **Lenovo**
- Install Lenovo Vantage from Microsoft Store
- Enable "Conservation Mode" in Vantage first
- Check BIOS settings for battery management

##### **Dell**
- Download Dell Command Configure from Dell Support
- Install in default location (C:\Program Files\Dell\CommandConfigure)
- Enable battery settings in BIOS

##### **HP**
- Install HP Support Assistant
- Check for HP Battery Health Manager
- Update HP drivers and software

##### **ASUS**
- Install ASUS Battery Health Charging utility
- Check MyASUS app for battery settings
- Verify BIOS battery management options

### 📊 **Technical Details**

#### **Battery Management APIs**
- **WMI**: Windows Management Instrumentation for system info
- **Registry**: Manufacturer-specific settings storage
- **PowerShell**: Power plan creation and modification
- **Command Line**: Manufacturer tools integration

#### **Detection Methods**
```python
# Example detection logic
def detect_manufacturer():
    wmi_connection = wmi.WMI()
    for system in wmi_connection.Win32_ComputerSystem():
        manufacturer = system.Manufacturer.lower()
        if "lenovo" in manufacturer:
            return "lenovo"
        elif "dell" in manufacturer:
            return "dell"
        # ... other manufacturers
```

#### **Power Plan Integration**
- Creates custom power plans for battery limits
- Modifies existing plans for hardware-specific settings
- Integrates with Windows power management

### 🔄 **Uninstallation**

1. **Run** `uninstall.bat` as administrator
2. **Choose** whether to remove Python packages
3. **Manually delete** folder if desired

### 📝 **Changelog**

#### **Version 1.0.0 (Initial Release)**
- Multi-manufacturer battery management support
- Windows 11 native GUI interface
- System tray integration
- Automatic hardware detection
- UAC integration
- PowerShell power plan support

### 🔗 **Related Projects**

- **Linux Version**: Main Universal Battery Limiter (../battery-indicator)
- **Cross-Platform**: Future unified version planned

### 📞 **Support**

- **Issues**: Report on GitHub repository
- **Documentation**: This README and inline help
- **Community**: GitHub Discussions

### ⚖️ **License**

MIT License - Same as main Universal Battery Limiter project

### ⚠️ **Disclaimer**

- Battery management involves low-level system access
- Use at your own risk
- Test thoroughly before relying on settings
- Keep original manufacturer software as backup

---

**Universal Battery Limiter - Windows 11 Edition**  
*Extending battery life through intelligent charge management*
