# Universal Battery Limiter - Windows Edition Development Guide

## 📋 **Architecture Overview**

The Windows edition is built with a modular architecture supporting multiple battery management methods across different laptop manufacturers.

### **Core Components**

#### **1. WindowsBatteryManager** (`battery_limiter_windows.py`)
- **WMI Integration**: Windows Management Instrumentation for system info
- **Manufacturer Detection**: Automatic laptop brand identification
- **Multi-Method Support**: Fallback system for different control methods
- **Registry Management**: Safe registry modifications for settings

#### **2. WindowsBatteryGUI** (`battery_limiter_windows.py`)
- **Modern Interface**: Windows 11 styled GUI with Segoe UI
- **System Tray**: Background operation with quick access menu
- **Real-time Monitoring**: Live battery status updates
- **Configuration**: Persistent settings and preferences

#### **3. WindowsBatteryCLI** (`battery_cli.py`)
- **Command Line Interface**: Full functionality via terminal
- **JSON Output**: Machine-readable status information
- **Scripting Support**: Automation and batch operations
- **Testing Tools**: System compatibility verification

#### **4. WindowsConfig** (`config_manager.py`)
- **Settings Persistence**: User preferences and configuration
- **Autostart Management**: Windows startup integration
- **Registry Integration**: Safe Windows registry operations
- **Backup System**: Configuration export/import

#### **5. PowerShell Integration** (`battery_manager.ps1`)
- **Advanced Operations**: Low-level Windows power management
- **Manufacturer Tools**: Integration with vendor utilities
- **Power Plans**: Custom Windows power scheme creation
- **Administrative Tasks**: Elevated privilege operations

## 🔧 **Battery Management Methods**

### **1. WMI (Windows Management Instrumentation)**
```python
# Example WMI battery control
def get_battery_info():
    wmi_connection = wmi.WMI()
    for battery in wmi_connection.Win32_Battery():
        return {
            "level": battery.EstimatedChargeRemaining,
            "status": battery.BatteryStatus,
            "is_charging": battery.BatteryStatus == 2
        }
```

### **2. Manufacturer-Specific APIs**

#### **Lenovo Conservation Mode**
- **Registry Path**: `HKLM\SOFTWARE\Lenovo\PowerMgr`
- **Values**: ConservationMode (0=disabled, 1=enabled)
- **Limits**: 60% (conservation) or 100% (normal)

#### **Dell Command Configure**
- **Tool**: cctk.exe (Dell Command Configure)
- **Command**: `cctk --PrimaryBattChargeCfg=Custom:80`
- **Limits**: 50-100% in 1% increments

#### **HP Battery Health Manager**
- **Method**: WMI BIOS interface
- **Registry**: Various HP-specific keys
- **Integration**: HP Support Assistant

#### **ASUS Battery Health Charging**
- **Registry**: `HKLM\SOFTWARE\ASUS\ASUS Battery Health Charging`
- **Modes**: 1=60%, 2=80%, 3=100%
- **Tool**: MyASUS application

### **3. PowerShell Power Plans**
```powershell
# Create custom power plan
$planGuid = [System.Guid]::NewGuid()
powercfg /duplicatescheme SCHEME_BALANCED $planGuid
powercfg /changename $planGuid "Battery Limiter 80%"
powercfg /setactive $planGuid
```

## 🛡️ **Security and Permissions**

### **UAC Integration**
- **Elevation Required**: Battery management needs admin rights
- **Safe Operations**: All changes are reversible
- **Registry Backup**: Configuration preservation
- **Error Handling**: Graceful fallback on permission errors

### **Registry Safety**
```python
def safe_registry_write(key_path, value_name, value):
    try:
        # Backup existing value
        backup_value = read_registry_value(key_path, value_name)
        
        # Write new value
        with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, key_path, 0, winreg.KEY_SET_VALUE) as key:
            winreg.SetValueEx(key, value_name, 0, winreg.REG_DWORD, value)
            
        return True, backup_value
    except Exception as e:
        return False, None
```

## 📦 **Build and Distribution**

### **Development Setup**
```bash
# Clone repository
git clone https://github.com/FrancyAlinston/Battery-Limter.git
cd Battery-Limter/windows-version

# Install dependencies
pip install -r requirements.txt

# Run application
python battery_limiter_windows.py
```

### **Creating Executables**

#### **Using cx_Freeze**
```bash
# Install cx_Freeze
pip install cx_Freeze

# Build executable
python setup.py build_exe

# Output in build/ directory
```

#### **Using py2exe**
```bash
# Install py2exe
pip install py2exe

# Build executable
python setup.py py2exe

# Output in dist/ directory
```

### **Creating Installer**
```bash
# Generate NSIS script
python setup.py installer

# Compile with NSIS
makensis installer.nsi
```

## 🧪 **Testing Framework**

### **Unit Tests**
```python
def test_battery_detection():
    manager = WindowsBatteryManager()
    info = manager.get_battery_info()
    
    assert info is not None
    assert 'level' in info
    assert 0 <= info['level'] <= 100

def test_manufacturer_detection():
    manager = WindowsBatteryManager()
    
    assert manager.manufacturer != ""
    assert manager.model != ""
    assert isinstance(manager.supported_methods, list)
```

### **Integration Tests**
```bash
# Run compatibility test
python battery_cli.py test

# Test specific manufacturer
python battery_cli.py info --verbose

# Test limit setting (requires admin)
python battery_cli.py set 80
```

## 🔄 **Update System**

### **Version Checking**
```python
def check_for_updates():
    try:
        response = requests.get("https://api.github.com/repos/FrancyAlinston/Battery-Limter/releases/latest")
        latest_version = response.json()["tag_name"]
        
        if version.parse(latest_version) > version.parse(CURRENT_VERSION):
            return latest_version, response.json()["html_url"]
    except:
        pass
    
    return None, None
```

### **Auto-Update Process**
1. **Check GitHub API** for latest release
2. **Compare versions** using semantic versioning
3. **Download update** to temporary location
4. **Verify signature** (if available)
5. **Install update** with user confirmation

## 📊 **Performance Optimization**

### **Battery Monitoring**
- **Interval**: 5-second default (configurable)
- **Background Thread**: Non-blocking GUI updates
- **Resource Usage**: Minimal CPU and memory impact
- **Power Efficiency**: Optimized for battery life

### **Memory Management**
```python
# Lazy loading of heavy libraries
def get_wmi_connection():
    global _wmi_connection
    if _wmi_connection is None:
        _wmi_connection = wmi.WMI()
    return _wmi_connection
```

## 🐛 **Error Handling**

### **Common Issues and Solutions**

#### **"No supported methods detected"**
```python
def diagnose_support_issues():
    issues = []
    
    if not is_admin():
        issues.append("Administrator privileges required")
    
    if not detect_manufacturer_tools():
        issues.append("Manufacturer software not installed")
    
    if not check_hardware_support():
        issues.append("Hardware may not support battery limiting")
    
    return issues
```

#### **Access Denied Errors**
- **Solution**: Run as administrator
- **Detection**: Check UAC status
- **Fallback**: Limited functionality mode

#### **Registry Permission Errors**
- **Backup**: Create restore points
- **Validation**: Verify changes
- **Recovery**: Automatic rollback on failure

## 📈 **Future Enhancements**

### **Planned Features**
1. **Unified Cross-Platform**: Single codebase for Linux and Windows
2. **Advanced Scheduling**: Time-based charge limit profiles
3. **Machine Learning**: Adaptive limit suggestions
4. **Cloud Sync**: Settings synchronization across devices
5. **Enterprise Management**: Group policy integration

### **API Extensions**
```python
# Future API design
class BatteryManager:
    def set_schedule(self, schedule):
        """Set time-based charging schedule"""
        pass
    
    def get_health_metrics(self):
        """Get battery health analytics"""
        pass
    
    def optimize_for_usage(self, usage_pattern):
        """AI-powered optimization"""
        pass
```

## 🤝 **Contributing**

### **Development Guidelines**
1. **Code Style**: Follow PEP 8 for Python
2. **Documentation**: Comprehensive docstrings
3. **Testing**: Unit tests for new features
4. **Compatibility**: Windows 10 1903+ support
5. **Security**: Safe registry and system operations

### **Pull Request Process**
1. **Fork** the repository
2. **Create** feature branch
3. **Add** tests for new functionality
4. **Update** documentation
5. **Submit** pull request with detailed description

---

**Universal Battery Limiter - Windows Edition**  
*Professional battery management for Windows 11 laptops*
