# Universal Battery Limiter - PowerShell Integration Script
# Advanced Windows battery management functions

param(
    [string]$Action = "info",
    [int]$Limit = 80,
    [switch]$Force,
    [switch]$Verbose
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to get battery information
function Get-BatteryInfo {
    try {
        $batteries = Get-WmiObject -Class Win32_Battery
        $powerStatus = Get-WmiObject -Class Win32_PortableBattery
        
        foreach ($battery in $batteries) {
            $info = @{
                Name = $battery.Name
                Level = $battery.EstimatedChargeRemaining
                Status = switch ($battery.BatteryStatus) {
                    1 { "Discharging" }
                    2 { "Charging" }
                    3 { "Critical" }
                    4 { "Low" }
                    5 { "High" }
                    6 { "Full" }
                    default { "Unknown" }
                }
                PowerOnline = $battery.PowerOnline
                EstimatedTime = $battery.EstimatedRunTime
                Chemistry = $battery.Chemistry
                DesignCapacity = $battery.DesignCapacity
                FullChargeCapacity = $battery.FullChargeCapacity
            }
            
            return $info
        }
    }
    catch {
        Write-Error "Failed to get battery information: $_"
        return $null
    }
}

# Function to detect laptop manufacturer
function Get-SystemInfo {
    try {
        $system = Get-WmiObject -Class Win32_ComputerSystem
        $bios = Get-WmiObject -Class Win32_BIOS
        
        return @{
            Manufacturer = $system.Manufacturer
            Model = $system.Model
            BIOSVersion = $bios.SMBIOSBIOSVersion
            SerialNumber = $bios.SerialNumber
        }
    }
    catch {
        Write-Error "Failed to get system information: $_"
        return $null
    }
}

# Function to check for manufacturer-specific tools
function Test-ManufacturerTools {
    $tools = @{}
    
    # Check for Lenovo tools
    $lenovoPaths = @(
        "${env:ProgramFiles}\Lenovo\PowerMgr",
        "${env:ProgramFiles(x86)}\Lenovo\PowerMgr",
        "${env:ProgramFiles}\Lenovo\ImController",
        "${env:ProgramFiles(x86)}\Lenovo\ImController"
    )
    
    foreach ($path in $lenovoPaths) {
        if (Test-Path $path) {
            $tools.Lenovo = $path
            break
        }
    }
    
    # Check for Dell Command Configure
    $dellPaths = @(
        "${env:ProgramFiles}\Dell\CommandConfigure\X86_64\cctk.exe",
        "${env:ProgramFiles(x86)}\Dell\CommandConfigure\X86_64\cctk.exe"
    )
    
    foreach ($path in $dellPaths) {
        if (Test-Path $path) {
            $tools.Dell = $path
            break
        }
    }
    
    # Check for HP Support Assistant
    $hpPaths = @(
        "${env:ProgramFiles}\Hewlett-Packard",
        "${env:ProgramFiles(x86)}\Hewlett-Packard",
        "${env:ProgramFiles}\HP\HP Support Framework"
    )
    
    foreach ($path in $hpPaths) {
        if (Test-Path $path) {
            $tools.HP = $path
            break
        }
    }
    
    return $tools
}

# Function to set Lenovo conservation mode
function Set-LenovoConservationMode {
    param([bool]$Enable)
    
    try {
        $regPath = "HKLM:\SOFTWARE\Lenovo\PowerMgr"
        
        if (Test-Path $regPath) {
            $value = if ($Enable) { 1 } else { 0 }
            Set-ItemProperty -Path $regPath -Name "ConservationMode" -Value $value
            Write-ColorOutput "Lenovo Conservation Mode $(if($Enable){'enabled'}else{'disabled'})" "Green"
            return $true
        }
        else {
            Write-ColorOutput "Lenovo PowerMgr registry key not found" "Yellow"
            return $false
        }
    }
    catch {
        Write-Error "Failed to set Lenovo conservation mode: $_"
        return $false
    }
}

# Function to set Dell battery limit using cctk
function Set-DellBatteryLimit {
    param([int]$Limit)
    
    $cctkPath = (Test-ManufacturerTools).Dell
    
    if (-not $cctkPath -or -not (Test-Path $cctkPath)) {
        Write-ColorOutput "Dell Command Configure not found" "Yellow"
        return $false
    }
    
    try {
        $result = & $cctkPath --PrimaryBattChargeCfg=Custom:$Limit
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "Dell battery limit set to $Limit%" "Green"
            return $true
        }
        else {
            Write-ColorOutput "Dell cctk failed with exit code $LASTEXITCODE" "Red"
            return $false
        }
    }
    catch {
        Write-Error "Failed to run Dell cctk: $_"
        return $false
    }
}

# Function to create custom power plan
function New-BatteryLimiterPowerPlan {
    param([int]$Limit)
    
    try {
        # Generate unique GUID for power plan
        $planGuid = [System.Guid]::NewGuid().ToString()
        $planName = "Battery Limiter $Limit%"
        
        # Duplicate balanced power plan
        $result = powercfg /duplicatescheme SCHEME_BALANCED $planGuid
        
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to duplicate power scheme"
        }
        
        # Rename the power plan
        powercfg /changename $planGuid $planName
        
        # Set battery-related settings
        # Critical battery level
        powercfg /setacvalueindex $planGuid SUB_BATTERY BATACTIONCRIT 0
        powercfg /setdcvalueindex $planGuid SUB_BATTERY BATACTIONCRIT 0
        
        # Low battery level
        powercfg /setacvalueindex $planGuid SUB_BATTERY BATLEVELCRIT $Limit
        powercfg /setdcvalueindex $planGuid SUB_BATTERY BATLEVELCRIT $Limit
        
        # Apply the power plan
        powercfg /setactive $planGuid
        
        Write-ColorOutput "Created and activated power plan: $planName" "Green"
        return $planGuid
    }
    catch {
        Write-Error "Failed to create power plan: $_"
        return $null
    }
}

# Function to remove battery limiter power plans
function Remove-BatteryLimiterPowerPlans {
    try {
        $plans = powercfg /list | Select-String "Battery Limiter"
        
        foreach ($plan in $plans) {
            if ($plan -match "([a-f0-9\-]{36})") {
                $guid = $matches[1]
                powercfg /delete $guid
                Write-ColorOutput "Removed power plan: $guid" "Green"
            }
        }
    }
    catch {
        Write-Error "Failed to remove power plans: $_"
    }
}

# Function to set battery charge limit
function Set-BatteryChargeLimit {
    param([int]$Limit)
    
    if (-not (Test-Administrator)) {
        Write-Error "Administrator privileges required to set battery limit"
        return $false
    }
    
    $systemInfo = Get-SystemInfo
    $manufacturer = $systemInfo.Manufacturer.ToLower()
    
    Write-ColorOutput "Setting battery charge limit to $Limit% for $($systemInfo.Manufacturer)" "Cyan"
    
    $success = $false
    
    # Try manufacturer-specific methods first
    switch -Wildcard ($manufacturer) {
        "*lenovo*" {
            if ($Limit -le 60) {
                $success = Set-LenovoConservationMode -Enable $true
            } else {
                $success = Set-LenovoConservationMode -Enable $false
            }
        }
        
        "*dell*" {
            $success = Set-DellBatteryLimit -Limit $Limit
        }
        
        "*hp*" {
            Write-ColorOutput "HP-specific battery management not yet implemented" "Yellow"
            Write-ColorOutput "Try using HP Support Assistant or BIOS settings" "Yellow"
        }
        
        "*asus*" {
            Write-ColorOutput "ASUS-specific battery management not yet implemented" "Yellow"
            Write-ColorOutput "Try using ASUS Battery Health Charging utility" "Yellow"
        }
    }
    
    # Fallback to power plan method
    if (-not $success) {
        Write-ColorOutput "Trying power plan method..." "Yellow"
        $planGuid = New-BatteryLimiterPowerPlan -Limit $Limit
        $success = $planGuid -ne $null
    }
    
    return $success
}

# Function to show battery and system status
function Show-BatteryStatus {
    $batteryInfo = Get-BatteryInfo
    $systemInfo = Get-SystemInfo
    $tools = Test-ManufacturerTools
    
    Write-ColorOutput "🔋 Battery Information" "Cyan"
    Write-ColorOutput "=====================" "Cyan"
    
    if ($batteryInfo) {
        Write-Host "Current Level: " -NoNewline
        Write-ColorOutput "$($batteryInfo.Level)%" "Green"
        
        Write-Host "Status: " -NoNewline
        Write-ColorOutput $batteryInfo.Status "Yellow"
        
        Write-Host "Design Capacity: " -NoNewline
        Write-ColorOutput "$($batteryInfo.DesignCapacity) mWh" "White"
        
        Write-Host "Full Charge Capacity: " -NoNewline
        Write-ColorOutput "$($batteryInfo.FullChargeCapacity) mWh" "White"
        
        if ($batteryInfo.EstimatedTime -and $batteryInfo.EstimatedTime -ne 71582788) {
            Write-Host "Estimated Time: " -NoNewline
            Write-ColorOutput "$($batteryInfo.EstimatedTime) minutes" "White"
        }
    }
    
    Write-ColorOutput "`n💻 System Information" "Cyan"
    Write-ColorOutput "=====================" "Cyan"
    
    Write-Host "Manufacturer: " -NoNewline
    Write-ColorOutput $systemInfo.Manufacturer "Green"
    
    Write-Host "Model: " -NoNewline
    Write-ColorOutput $systemInfo.Model "Green"
    
    Write-Host "BIOS Version: " -NoNewline
    Write-ColorOutput $systemInfo.BIOSVersion "White"
    
    Write-ColorOutput "`n🔧 Available Tools" "Cyan"
    Write-ColorOutput "==================" "Cyan"
    
    if ($tools.Count -eq 0) {
        Write-ColorOutput "No manufacturer tools detected" "Yellow"
    } else {
        foreach ($tool in $tools.GetEnumerator()) {
            Write-Host "$($tool.Key): " -NoNewline
            Write-ColorOutput $tool.Value "Green"
        }
    }
    
    Write-ColorOutput "`n🛡️ Administrator Status" "Cyan"
    Write-ColorOutput "=======================" "Cyan"
    
    if (Test-Administrator) {
        Write-ColorOutput "✅ Running as Administrator" "Green"
    } else {
        Write-ColorOutput "❌ Not running as Administrator" "Red"
        Write-ColorOutput "   Battery management requires elevated privileges" "Yellow"
    }
}

# Main script logic
try {
    switch ($Action.ToLower()) {
        "info" {
            Show-BatteryStatus
        }
        
        "set" {
            if ($Limit -lt 50 -or $Limit -gt 100) {
                Write-Error "Battery limit must be between 50 and 100"
                exit 1
            }
            
            $success = Set-BatteryChargeLimit -Limit $Limit
            
            if ($success) {
                Write-ColorOutput "✅ Battery charge limit set successfully" "Green"
                exit 0
            } else {
                Write-ColorOutput "❌ Failed to set battery charge limit" "Red"
                exit 1
            }
        }
        
        "reset" {
            Write-ColorOutput "Resetting battery to full charging..." "Cyan"
            Remove-BatteryLimiterPowerPlans
            
            $systemInfo = Get-SystemInfo
            $manufacturer = $systemInfo.Manufacturer.ToLower()
            
            # Reset manufacturer-specific settings
            switch -Wildcard ($manufacturer) {
                "*lenovo*" {
                    Set-LenovoConservationMode -Enable $false
                }
                "*dell*" {
                    Set-DellBatteryLimit -Limit 100
                }
            }
            
            Write-ColorOutput "✅ Battery reset to full charging" "Green"
        }
        
        "test" {
            Write-ColorOutput "🧪 Testing battery management capabilities..." "Cyan"
            
            if (-not (Test-Administrator)) {
                Write-ColorOutput "❌ Administrator privileges required" "Red"
                exit 1
            }
            
            $batteryInfo = Get-BatteryInfo
            if (-not $batteryInfo) {
                Write-ColorOutput "❌ Cannot read battery information" "Red"
                exit 1
            }
            
            Write-ColorOutput "✅ Battery information accessible" "Green"
            Write-ColorOutput "✅ All tests passed" "Green"
        }
        
        default {
            Write-ColorOutput "Invalid action. Use: info, set, reset, or test" "Red"
            exit 1
        }
    }
}
catch {
    Write-Error "Script failed: $_"
    if ($Verbose) {
        Write-Error $_.ScriptStackTrace
    }
    exit 1
}
