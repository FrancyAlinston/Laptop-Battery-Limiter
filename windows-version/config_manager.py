#!/usr/bin/env python3
"""
Universal Battery Limiter - Windows Configuration Manager
Handles settings, preferences, and configuration persistence
"""

import json
import os
from pathlib import Path
import winreg
import sys


class WindowsConfig:
    """Configuration manager for Windows Battery Limiter"""
    
    def __init__(self):
        self.config_dir = Path.home() / "AppData" / "Local" / "UniversalBatteryLimiter"
        self.config_file = self.config_dir / "config.json"
        self.log_dir = self.config_dir / "logs"
        
        # Default configuration
        self.default_config = {
            "version": "1.0.0",
            "application": {
                "name": "Universal Battery Limiter",
                "edition": "Windows 11",
                "auto_start": False,
                "minimize_to_tray": True,
                "check_updates": True,
                "first_run": True
            },
            "battery": {
                "default_limit": 80,
                "monitoring_interval": 5,
                "notification_enabled": True,
                "low_battery_warning": 20,
                "full_battery_notification": True,
                "auto_apply_limit": False
            },
            "ui": {
                "theme": "auto",
                "window_position": "center",
                "remember_position": True,
                "show_system_info": True,
                "compact_mode": False,
                "last_window_x": None,
                "last_window_y": None
            },
            "methods": {
                "preferred_order": [
                    "Manufacturer Specific",
                    "WMI", 
                    "PowerShell Power Plans"
                ],
                "retry_failed": True,
                "fallback_enabled": True,
                "last_successful_method": None
            },
            "advanced": {
                "debug_mode": False,
                "log_level": "INFO",
                "backup_power_plans": True,
                "verify_settings": True,
                "registry_backup": True
            }
        }
        
        self.config = self.default_config.copy()
        self.load_config()
    
    def ensure_directories(self):
        """Create necessary directories"""
        try:
            self.config_dir.mkdir(parents=True, exist_ok=True)
            self.log_dir.mkdir(parents=True, exist_ok=True)
            return True
        except Exception as e:
            print(f"Failed to create directories: {e}")
            return False
    
    def load_config(self):
        """Load configuration from file"""
        self.ensure_directories()
        
        try:
            if self.config_file.exists():
                with open(self.config_file, 'r') as f:
                    loaded_config = json.load(f)
                
                # Merge with defaults (in case new settings were added)
                self.config = self.merge_config(self.default_config, loaded_config)
            else:
                # First run, save default config
                self.save_config()
        
        except Exception as e:
            print(f"Failed to load config: {e}")
            # Use defaults
            self.config = self.default_config.copy()
    
    def save_config(self):
        """Save configuration to file"""
        try:
            self.ensure_directories()
            
            with open(self.config_file, 'w') as f:
                json.dump(self.config, f, indent=4)
            
            return True
        
        except Exception as e:
            print(f"Failed to save config: {e}")
            return False
    
    def merge_config(self, default, loaded):
        """Merge loaded config with defaults"""
        result = default.copy()
        
        for key, value in loaded.items():
            if key in result:
                if isinstance(value, dict) and isinstance(result[key], dict):
                    result[key] = self.merge_config(result[key], value)
                else:
                    result[key] = value
        
        return result
    
    def get(self, key_path, default=None):
        """Get configuration value using dot notation"""
        keys = key_path.split('.')
        value = self.config
        
        try:
            for key in keys:
                value = value[key]
            return value
        except (KeyError, TypeError):
            return default
    
    def set(self, key_path, value):
        """Set configuration value using dot notation"""
        keys = key_path.split('.')
        config = self.config
        
        try:
            for key in keys[:-1]:
                if key not in config:
                    config[key] = {}
                config = config[key]
            
            config[keys[-1]] = value
            return True
        
        except Exception as e:
            print(f"Failed to set config {key_path}: {e}")
            return False
    
    def setup_autostart(self, enable=True):
        """Setup/remove Windows autostart"""
        try:
            key_path = r"SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
            app_name = "UniversalBatteryLimiter"
            
            if enable:
                # Get current script path
                script_path = Path(sys.argv[0]).absolute()
                python_path = sys.executable
                
                # Create command to run the application
                cmd = f'"{python_path}" "{script_path}"'
                
                # Add to registry
                with winreg.OpenKey(winreg.HKEY_CURRENT_USER, key_path, 0, winreg.KEY_SET_VALUE) as key:
                    winreg.SetValueEx(key, app_name, 0, winreg.REG_SZ, cmd)
                
                self.set("application.auto_start", True)
                return True
            
            else:
                # Remove from registry
                try:
                    with winreg.OpenKey(winreg.HKEY_CURRENT_USER, key_path, 0, winreg.KEY_SET_VALUE) as key:
                        winreg.DeleteValue(key, app_name)
                except FileNotFoundError:
                    pass  # Already removed
                
                self.set("application.auto_start", False)
                return True
        
        except Exception as e:
            print(f"Failed to setup autostart: {e}")
            return False
    
    def is_first_run(self):
        """Check if this is the first run"""
        return self.get("application.first_run", True)
    
    def mark_first_run_complete(self):
        """Mark first run as complete"""
        self.set("application.first_run", False)
        self.save_config()
    
    def get_log_file(self, log_type="main"):
        """Get log file path"""
        self.ensure_directories()
        return self.log_dir / f"{log_type}.log"
    
    def reset_to_defaults(self):
        """Reset configuration to defaults"""
        self.config = self.default_config.copy()
        self.save_config()
    
    def export_config(self, file_path):
        """Export configuration to file"""
        try:
            with open(file_path, 'w') as f:
                json.dump(self.config, f, indent=4)
            return True
        except Exception as e:
            print(f"Failed to export config: {e}")
            return False
    
    def import_config(self, file_path):
        """Import configuration from file"""
        try:
            with open(file_path, 'r') as f:
                imported_config = json.load(f)
            
            self.config = self.merge_config(self.default_config, imported_config)
            self.save_config()
            return True
        
        except Exception as e:
            print(f"Failed to import config: {e}")
            return False
    
    def get_window_position(self):
        """Get saved window position"""
        x = self.get("ui.last_window_x")
        y = self.get("ui.last_window_y")
        
        if x is not None and y is not None:
            return x, y
        return None
    
    def save_window_position(self, x, y):
        """Save window position"""
        if self.get("ui.remember_position", True):
            self.set("ui.last_window_x", x)
            self.set("ui.last_window_y", y)
            self.save_config()
    
    def get_preferred_methods(self):
        """Get preferred battery management methods in order"""
        return self.get("methods.preferred_order", [])
    
    def set_last_successful_method(self, method):
        """Remember the last successful method"""
        self.set("methods.last_successful_method", method)
        self.save_config()
    
    def get_last_successful_method(self):
        """Get the last successful method"""
        return self.get("methods.last_successful_method")
    
    def should_backup_power_plans(self):
        """Check if power plans should be backed up"""
        return self.get("advanced.backup_power_plans", True)
    
    def get_monitoring_interval(self):
        """Get battery monitoring interval in seconds"""
        return self.get("battery.monitoring_interval", 5)
    
    def should_show_notifications(self):
        """Check if notifications should be shown"""
        return self.get("battery.notification_enabled", True)
    
    def get_default_limit(self):
        """Get default battery charge limit"""
        return self.get("battery.default_limit", 80)
    
    def set_default_limit(self, limit):
        """Set default battery charge limit"""
        self.set("battery.default_limit", limit)
        self.save_config()


# Global configuration instance
_config_instance = None

def get_config():
    """Get global configuration instance"""
    global _config_instance
    if _config_instance is None:
        _config_instance = WindowsConfig()
    return _config_instance


if __name__ == "__main__":
    # Test configuration system
    config = WindowsConfig()
    
    print("Configuration Test")
    print("=" * 30)
    print(f"Config directory: {config.config_dir}")
    print(f"Default limit: {config.get_default_limit()}")
    print(f"First run: {config.is_first_run()}")
    print(f"Auto start: {config.get('application.auto_start')}")
    
    # Test setting values
    config.set("battery.default_limit", 85)
    print(f"New default limit: {config.get_default_limit()}")
    
    config.save_config()
    print("Configuration saved successfully!")
