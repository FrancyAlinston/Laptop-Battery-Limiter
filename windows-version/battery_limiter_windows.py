#!/usr/bin/env python3
"""
Universal Battery Limiter - Windows 11 Compatible Version
Cross-platform battery charge management for Windows laptops
"""

import os
import sys
import platform
import subprocess
import tkinter as tk
from tkinter import ttk, messagebox
import threading
import time
import json
import winreg
from pathlib import Path

# Windows-specific imports
try:
    import wmi
    import win32api
    import win32con
    import win32gui
    import pystray
    from PIL import Image, ImageDraw
    WINDOWS_LIBS_AVAILABLE = True
except ImportError:
    WINDOWS_LIBS_AVAILABLE = False
    print("Windows-specific libraries not available. Install: pip install wmi pywin32 pystray pillow")

class WindowsBatteryManager:
    """Windows-specific battery management using WMI and manufacturer APIs"""
    
    def __init__(self):
        self.wmi_connection = None
        self.supported_methods = []
        self.manufacturer = ""
        self.model = ""
        self.initialize_wmi()
        self.detect_manufacturer()
    
    def initialize_wmi(self):
        """Initialize WMI connection for battery management"""
        try:
            if WINDOWS_LIBS_AVAILABLE:
                self.wmi_connection = wmi.WMI()
                return True
        except Exception as e:
            print(f"WMI initialization failed: {e}")
        return False
    
    def detect_manufacturer(self):
        """Detect laptop manufacturer and model for specific APIs"""
        try:
            if self.wmi_connection:
                for system in self.wmi_connection.Win32_ComputerSystem():
                    self.manufacturer = system.Manufacturer.lower()
                    self.model = system.Model
                    break
                
                print(f"Detected: {self.manufacturer} {self.model}")
                self.detect_supported_methods()
        except Exception as e:
            print(f"Manufacturer detection failed: {e}")
    
    def detect_supported_methods(self):
        """Detect which battery control methods are supported"""
        methods = []
        
        # Check WMI battery control
        if self.check_wmi_battery_control():
            methods.append("WMI")
        
        # Check manufacturer-specific methods
        if "lenovo" in self.manufacturer:
            if self.check_lenovo_conservation_mode():
                methods.append("Lenovo Conservation Mode")
        
        elif "dell" in self.manufacturer:
            if self.check_dell_battery_settings():
                methods.append("Dell BIOS Settings")
        
        elif "hp" in self.manufacturer:
            if self.check_hp_battery_settings():
                methods.append("HP Battery Health Manager")
        
        elif "asus" in self.manufacturer:
            if self.check_asus_battery_settings():
                methods.append("ASUS Battery Health Charging")
        
        # Check PowerShell power plan modification
        if self.check_powershell_support():
            methods.append("PowerShell Power Plans")
        
        self.supported_methods = methods
        print(f"Supported methods: {methods}")
    
    def check_wmi_battery_control(self):
        """Check if WMI supports direct battery control"""
        try:
            if self.wmi_connection:
                for battery in self.wmi_connection.Win32_Battery():
                    # Check if battery supports charge control
                    return hasattr(battery, 'DesignCapacity')
        except:
            pass
        return False
    
    def check_lenovo_conservation_mode(self):
        """Check if Lenovo Conservation Mode is available"""
        try:
            # Check for Lenovo Energy Management or Vantage
            registry_paths = [
                r"SOFTWARE\Lenovo\PowerMgr",
                r"SOFTWARE\Lenovo\ImController\PluginData\IdeaNotebookAddin"
            ]
            
            for path in registry_paths:
                try:
                    key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, path)
                    winreg.CloseKey(key)
                    return True
                except:
                    continue
        except:
            pass
        return False
    
    def check_dell_battery_settings(self):
        """Check if Dell battery settings are available"""
        try:
            # Check for Dell Command Configure
            dell_paths = [
                r"C:\Program Files\Dell\CommandConfigure\X86_64\cctk.exe",
                r"C:\Program Files (x86)\Dell\CommandConfigure\X86_64\cctk.exe"
            ]
            
            for path in dell_paths:
                if os.path.exists(path):
                    return True
        except:
            pass
        return False
    
    def check_hp_battery_settings(self):
        """Check if HP battery settings are available"""
        try:
            # Check for HP Support Assistant or BIOS settings
            hp_registry = r"SOFTWARE\Hewlett-Packard"
            key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, hp_registry)
            winreg.CloseKey(key)
            return True
        except:
            pass
        return False
    
    def check_asus_battery_settings(self):
        """Check if ASUS battery settings are available"""
        try:
            # Check for ASUS Battery Health Charging
            asus_paths = [
                r"SOFTWARE\ASUS\ASUS Battery Health Charging",
                r"SOFTWARE\ASUS\PowerMaster"
            ]
            
            for path in asus_paths:
                try:
                    key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, path)
                    winreg.CloseKey(key)
                    return True
                except:
                    continue
        except:
            pass
        return False
    
    def check_powershell_support(self):
        """Check if PowerShell power plan modification is available"""
        try:
            result = subprocess.run(
                ["powershell", "-Command", "Get-WmiObject -Class Win32_PowerPlan -Namespace root/cimv2/power"],
                capture_output=True, text=True, timeout=10
            )
            return result.returncode == 0
        except:
            return False
    
    def get_battery_info(self):
        """Get current battery information"""
        info = {
            "level": 0,
            "status": "Unknown",
            "is_charging": False,
            "is_plugged": False,
            "health": "Unknown"
        }
        
        try:
            if self.wmi_connection:
                for battery in self.wmi_connection.Win32_Battery():
                    info["level"] = getattr(battery, 'EstimatedChargeRemaining', 0)
                    info["status"] = getattr(battery, 'BatteryStatus', 'Unknown')
                    info["is_charging"] = battery.BatteryStatus == 2  # Charging
                    info["health"] = getattr(battery, 'Status', 'Unknown')
                    break
                
                # Check AC adapter status
                for adapter in self.wmi_connection.Win32_Battery():
                    info["is_plugged"] = True
                    break
        except Exception as e:
            print(f"Battery info error: {e}")
        
        return info
    
    def set_charge_limit(self, limit):
        """Set battery charge limit using available methods"""
        success = False
        methods_tried = []
        
        for method in self.supported_methods:
            try:
                if method == "Lenovo Conservation Mode":
                    success = self.set_lenovo_limit(limit)
                elif method == "Dell BIOS Settings":
                    success = self.set_dell_limit(limit)
                elif method == "HP Battery Health Manager":
                    success = self.set_hp_limit(limit)
                elif method == "ASUS Battery Health Charging":
                    success = self.set_asus_limit(limit)
                elif method == "PowerShell Power Plans":
                    success = self.set_powershell_limit(limit)
                
                methods_tried.append(method)
                if success:
                    break
            except Exception as e:
                print(f"Method {method} failed: {e}")
        
        return success, methods_tried
    
    def set_lenovo_limit(self, limit):
        """Set Lenovo conservation mode (60% or 80%)"""
        try:
            if limit <= 60:
                # Enable conservation mode (60%)
                cmd = ["powershell", "-Command", 
                       "Set-ItemProperty -Path 'HKLM:\\SOFTWARE\\Lenovo\\PowerMgr' -Name 'ConservationMode' -Value 1"]
            else:
                # Disable conservation mode (100%)
                cmd = ["powershell", "-Command", 
                       "Set-ItemProperty -Path 'HKLM:\\SOFTWARE\\Lenovo\\PowerMgr' -Name 'ConservationMode' -Value 0"]
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            return result.returncode == 0
        except:
            return False
    
    def set_dell_limit(self, limit):
        """Set Dell battery charge limit using cctk"""
        try:
            cctk_path = self.find_dell_cctk()
            if not cctk_path:
                return False
            
            cmd = [cctk_path, f"--PrimaryBattChargeCfg=Custom:{limit}"]
            result = subprocess.run(cmd, capture_output=True, text=True)
            return result.returncode == 0
        except:
            return False
    
    def set_hp_limit(self, limit):
        """Set HP battery charge limit"""
        try:
            # HP typically uses BIOS settings, try WMI approach
            cmd = ["powershell", "-Command", 
                   f"Set-WmiInstance -Namespace 'root/wmi' -Class 'HPBIOS_BIOSSettingInterface' -Arguments @{{Name='Battery Health Manager';Value='{limit}%'}}"]
            result = subprocess.run(cmd, capture_output=True, text=True)
            return result.returncode == 0
        except:
            return False
    
    def set_asus_limit(self, limit):
        """Set ASUS battery health charging limit"""
        try:
            if limit <= 60:
                mode = 1  # Maximum Lifespan Mode (60%)
            elif limit <= 80:
                mode = 2  # Balanced Mode (80%)
            else:
                mode = 3  # Full Capacity Mode (100%)
            
            cmd = ["powershell", "-Command", 
                   f"Set-ItemProperty -Path 'HKLM:\\SOFTWARE\\ASUS\\ASUS Battery Health Charging' -Name 'Mode' -Value {mode}"]
            result = subprocess.run(cmd, capture_output=True, text=True)
            return result.returncode == 0
        except:
            return False
    
    def set_powershell_limit(self, limit):
        """Set charge limit using PowerShell power plans"""
        try:
            # Create custom power plan with battery settings
            script = f"""
            $planGuid = [System.Guid]::NewGuid()
            $planName = "Battery Limiter {limit}%"
            
            # Create new power plan
            powercfg /duplicatescheme SCHEME_BALANCED $planGuid
            powercfg /changename $planGuid "$planName"
            
            # Set battery charge limit (if supported by hardware)
            powercfg /setacvalueindex $planGuid SUB_BATTERY BATACTIONCRIT 0
            powercfg /setacvalueindex $planGuid SUB_BATTERY BATLEVELCRIT {limit}
            
            # Apply the scheme
            powercfg /setactive $planGuid
            """
            
            result = subprocess.run(
                ["powershell", "-Command", script],
                capture_output=True, text=True
            )
            return result.returncode == 0
        except:
            return False
    
    def find_dell_cctk(self):
        """Find Dell Command Configure Tool"""
        paths = [
            r"C:\Program Files\Dell\CommandConfigure\X86_64\cctk.exe",
            r"C:\Program Files (x86)\Dell\CommandConfigure\X86_64\cctk.exe"
        ]
        
        for path in paths:
            if os.path.exists(path):
                return path
        return None


class WindowsBatteryGUI:
    """Windows 11 styled GUI for battery management"""
    
    def __init__(self):
        self.root = tk.Tk()
        self.battery_manager = WindowsBatteryManager()
        self.system_tray = None
        self.setup_gui()
        self.setup_system_tray()
        self.start_monitoring()
    
    def setup_gui(self):
        """Setup the main GUI window"""
        self.root.title("Universal Battery Limiter - Windows 11")
        self.root.geometry("500x600")
        self.root.resizable(True, True)
        
        # Apply Windows 11 styling
        self.apply_windows11_theme()
        
        # Create main frame
        main_frame = ttk.Frame(self.root, padding="20")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Title
        title_label = ttk.Label(main_frame, text="Universal Battery Limiter", 
                               font=("Segoe UI", 18, "bold"))
        title_label.grid(row=0, column=0, columnspan=2, pady=(0, 20))
        
        # Subtitle
        subtitle_label = ttk.Label(main_frame, text="Windows 11 Edition", 
                                  font=("Segoe UI", 10))
        subtitle_label.grid(row=1, column=0, columnspan=2, pady=(0, 20))
        
        # Battery status frame
        status_frame = ttk.LabelFrame(main_frame, text="Battery Status", padding="10")
        status_frame.grid(row=2, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        # Battery level
        self.level_var = tk.StringVar(value="Unknown")
        ttk.Label(status_frame, text="Current Level:").grid(row=0, column=0, sticky=tk.W)
        self.level_label = ttk.Label(status_frame, textvariable=self.level_var, 
                                    font=("Segoe UI", 12, "bold"))
        self.level_label.grid(row=0, column=1, sticky=tk.W, padx=(10, 0))
        
        # Battery status
        self.status_var = tk.StringVar(value="Unknown")
        ttk.Label(status_frame, text="Status:").grid(row=1, column=0, sticky=tk.W)
        self.status_label = ttk.Label(status_frame, textvariable=self.status_var)
        self.status_label.grid(row=1, column=1, sticky=tk.W, padx=(10, 0))
        
        # Manufacturer info
        manufacturer_frame = ttk.LabelFrame(main_frame, text="System Information", padding="10")
        manufacturer_frame.grid(row=3, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        ttk.Label(manufacturer_frame, text="Manufacturer:").grid(row=0, column=0, sticky=tk.W)
        ttk.Label(manufacturer_frame, text=self.battery_manager.manufacturer.title()).grid(row=0, column=1, sticky=tk.W, padx=(10, 0))
        
        ttk.Label(manufacturer_frame, text="Model:").grid(row=1, column=0, sticky=tk.W)
        ttk.Label(manufacturer_frame, text=self.battery_manager.model).grid(row=1, column=1, sticky=tk.W, padx=(10, 0))
        
        # Supported methods
        methods_frame = ttk.LabelFrame(main_frame, text="Supported Methods", padding="10")
        methods_frame.grid(row=4, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        methods_text = "\n".join(self.battery_manager.supported_methods) if self.battery_manager.supported_methods else "None detected"
        ttk.Label(methods_frame, text=methods_text).grid(row=0, column=0, sticky=tk.W)
        
        # Charge limit control
        control_frame = ttk.LabelFrame(main_frame, text="Charge Limit Control", padding="10")
        control_frame.grid(row=5, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        ttk.Label(control_frame, text="Set Charge Limit:").grid(row=0, column=0, sticky=tk.W)
        
        # Limit slider
        self.limit_var = tk.IntVar(value=80)
        self.limit_scale = ttk.Scale(control_frame, from_=50, to=100, 
                                    variable=self.limit_var, orient=tk.HORIZONTAL)
        self.limit_scale.grid(row=1, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=5)
        
        # Limit display
        self.limit_display = ttk.Label(control_frame, text="80%", font=("Segoe UI", 12, "bold"))
        self.limit_display.grid(row=2, column=0, columnspan=2)
        
        # Update display when slider changes
        self.limit_scale.configure(command=self.update_limit_display)
        
        # Preset buttons
        preset_frame = ttk.Frame(control_frame)
        preset_frame.grid(row=3, column=0, columnspan=2, pady=10)
        
        presets = [60, 70, 80, 90, 100]
        for i, preset in enumerate(presets):
            btn = ttk.Button(preset_frame, text=f"{preset}%", width=8,
                           command=lambda p=preset: self.set_preset(p))
            btn.grid(row=0, column=i, padx=2)
        
        # Apply button
        apply_btn = ttk.Button(control_frame, text="Apply Limit", 
                              command=self.apply_limit, style="Accent.TButton")
        apply_btn.grid(row=4, column=0, columnspan=2, pady=10)
        
        # Configure grid weights
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(1, weight=1)
        
        # Update battery info
        self.update_battery_info()
    
    def apply_windows11_theme(self):
        """Apply Windows 11 styling to the application"""
        style = ttk.Style()
        
        # Configure theme
        if "winnative" in style.theme_names():
            style.theme_use("winnative")
        elif "clam" in style.theme_names():
            style.theme_use("clam")
        
        # Windows 11 colors
        bg_color = "#f3f3f3"
        accent_color = "#0078d4"
        
        # Configure styles
        style.configure("Accent.TButton", background=accent_color, foreground="white")
        
        self.root.configure(bg=bg_color)
    
    def update_limit_display(self, value):
        """Update the limit display when slider changes"""
        limit = int(float(value))
        self.limit_display.configure(text=f"{limit}%")
    
    def set_preset(self, preset):
        """Set a preset charge limit"""
        self.limit_var.set(preset)
        self.update_limit_display(preset)
    
    def apply_limit(self):
        """Apply the selected charge limit"""
        limit = self.limit_var.get()
        
        try:
            success, methods = self.battery_manager.set_charge_limit(limit)
            
            if success:
                messagebox.showinfo("Success", 
                                  f"Battery charge limit set to {limit}%\n"
                                  f"Method used: {methods[-1] if methods else 'Unknown'}")
            else:
                messagebox.showerror("Error", 
                                   f"Failed to set battery charge limit.\n"
                                   f"Methods tried: {', '.join(methods)}\n\n"
                                   f"Your laptop may not support battery charge limiting, "
                                   f"or additional software may be required.")
        except Exception as e:
            messagebox.showerror("Error", f"An error occurred: {str(e)}")
    
    def update_battery_info(self):
        """Update battery information display"""
        try:
            info = self.battery_manager.get_battery_info()
            
            self.level_var.set(f"{info['level']}%")
            
            status_text = "Charging" if info['is_charging'] else "Not Charging"
            if info['is_plugged']:
                status_text += " (Plugged In)"
            self.status_var.set(status_text)
            
            # Update level label color based on level
            if info['level'] < 20:
                self.level_label.configure(foreground="red")
            elif info['level'] < 50:
                self.level_label.configure(foreground="orange")
            else:
                self.level_label.configure(foreground="green")
        
        except Exception as e:
            print(f"Battery info update error: {e}")
        
        # Schedule next update
        self.root.after(5000, self.update_battery_info)
    
    def setup_system_tray(self):
        """Setup system tray icon"""
        if not WINDOWS_LIBS_AVAILABLE:
            return
        
        try:
            # Create tray icon
            image = Image.new('RGB', (64, 64), color='white')
            draw = ImageDraw.Draw(image)
            draw.rectangle([16, 20, 48, 44], fill='black', outline='black')
            draw.rectangle([18, 22, 46, 42], fill='white')
            draw.text((20, 25), "B", fill='black')
            
            menu = pystray.Menu(
                pystray.MenuItem("Show", self.show_window),
                pystray.MenuItem("Quick Limits", pystray.Menu(
                    pystray.MenuItem("60%", lambda: self.quick_limit(60)),
                    pystray.MenuItem("80%", lambda: self.quick_limit(80)),
                    pystray.MenuItem("100%", lambda: self.quick_limit(100))
                )),
                pystray.MenuItem("Exit", self.quit_app)
            )
            
            self.system_tray = pystray.Icon("battery_limiter", image, 
                                          "Universal Battery Limiter", menu)
            
            # Start tray in separate thread
            threading.Thread(target=self.system_tray.run, daemon=True).start()
        
        except Exception as e:
            print(f"System tray setup failed: {e}")
    
    def show_window(self, icon=None, item=None):
        """Show the main window"""
        self.root.deiconify()
        self.root.lift()
    
    def quick_limit(self, limit):
        """Quick set limit from system tray"""
        success, methods = self.battery_manager.set_charge_limit(limit)
        if success:
            self.limit_var.set(limit)
    
    def quit_app(self, icon=None, item=None):
        """Quit the application"""
        if self.system_tray:
            self.system_tray.stop()
        self.root.quit()
    
    def start_monitoring(self):
        """Start battery monitoring"""
        self.update_battery_info()
    
    def run(self):
        """Run the application"""
        # Hide window on startup if system tray is available
        if self.system_tray:
            self.root.withdraw()
        
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
        self.root.mainloop()
    
    def on_closing(self):
        """Handle window closing"""
        if self.system_tray:
            self.root.withdraw()  # Hide to system tray
        else:
            self.quit_app()


def main():
    """Main entry point"""
    print("Universal Battery Limiter - Windows 11 Edition")
    print("=" * 50)
    
    # Check if running on Windows
    if platform.system() != "Windows":
        print("This version is designed for Windows 11.")
        print("For Linux, use the main battery limiter.")
        return
    
    # Check Python version
    if sys.version_info < (3, 6):
        print("Python 3.6 or higher is required.")
        return
    
    # Check dependencies
    if not WINDOWS_LIBS_AVAILABLE:
        print("Required Windows libraries not found.")
        print("Please install: pip install wmi pywin32 pystray pillow")
        return
    
    try:
        app = WindowsBatteryGUI()
        app.run()
    except KeyboardInterrupt:
        print("\nApplication terminated by user.")
    except Exception as e:
        print(f"Application error: {e}")


if __name__ == "__main__":
    main()
