#!/usr/bin/env python3

"""
Universal Battery Limiter - Error and Event Logger
Centralized logging system for all battery limiter components
"""

import os
import sys
import logging
import json
from datetime import datetime
from pathlib import Path

class BatteryLimiterLogger:
    def __init__(self, component_name="battery-limiter"):
        self.component_name = component_name
        self.log_dir = Path.home() / ".local/share/battery-limiter/logs"
        self.log_dir.mkdir(parents=True, exist_ok=True)
        
        # Setup different log files
        self.system_log = self.log_dir / "system.log"
        self.error_log = self.log_dir / "error.log" 
        self.debug_log = self.log_dir / "debug.log"
        self.event_log = self.log_dir / "events.log"
        
        # Setup logging
        self.setup_logging()
        
        # Log startup
        self.log_startup()
    
    def setup_logging(self):
        """Setup logging configuration"""
        # Create formatters
        formatter = logging.Formatter(
            '[%(asctime)s] [%(name)s] [%(levelname)s] %(message)s'
        )
        
        # Setup main logger
        self.logger = logging.getLogger(self.component_name)
        self.logger.setLevel(logging.DEBUG)
        
        # System log handler (INFO and above)
        system_handler = logging.FileHandler(self.system_log)
        system_handler.setLevel(logging.INFO)
        system_handler.setFormatter(formatter)
        self.logger.addHandler(system_handler)
        
        # Error log handler (ERROR and above)
        error_handler = logging.FileHandler(self.error_log)
        error_handler.setLevel(logging.ERROR)
        error_handler.setFormatter(formatter)
        self.logger.addHandler(error_handler)
        
        # Debug log handler (DEBUG and above)
        debug_handler = logging.FileHandler(self.debug_log)
        debug_handler.setLevel(logging.DEBUG)
        debug_handler.setFormatter(formatter)
        self.logger.addHandler(debug_handler)
        
        # Console handler for immediate feedback
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setLevel(logging.WARNING)
        console_handler.setFormatter(formatter)
        self.logger.addHandler(console_handler)
    
    def log_startup(self):
        """Log component startup information"""
        self.logger.info(f"=== {self.component_name.upper()} STARTUP ===")
        self.logger.info(f"Python version: {sys.version}")
        self.logger.info(f"Python executable: {sys.executable}")
        self.logger.info(f"Working directory: {os.getcwd()}")
        self.logger.info(f"Desktop environment: {os.environ.get('XDG_CURRENT_DESKTOP', 'Unknown')}")
        self.logger.info(f"Session type: {os.environ.get('XDG_SESSION_TYPE', 'Unknown')}")
        self.logger.info(f"Display: {os.environ.get('DISPLAY', 'Unknown')}")
        self.logger.info(f"User: {os.environ.get('USER', 'Unknown')}")
        self.logger.info(f"Home directory: {os.environ.get('HOME', 'Unknown')}")
    
    def log_event(self, event_type, description, data=None):
        """Log structured events"""
        event = {
            'timestamp': datetime.now().isoformat(),
            'component': self.component_name,
            'event_type': event_type,
            'description': description,
            'data': data or {}
        }
        
        with open(self.event_log, 'a') as f:
            f.write(json.dumps(event) + '\n')
        
        self.logger.info(f"EVENT: {event_type} - {description}")
    
    def log_battery_status(self, level, limit, status):
        """Log battery status changes"""
        self.log_event('battery_status', f"Battery: {level}%, Limit: {limit}%, Status: {status}", {
            'level': level,
            'limit': limit,
            'status': status
        })
    
    def log_limit_change(self, old_limit, new_limit):
        """Log battery limit changes"""
        self.log_event('limit_change', f"Battery limit changed from {old_limit}% to {new_limit}%", {
            'old_limit': old_limit,
            'new_limit': new_limit
        })
    
    def log_error_with_context(self, error, context=None):
        """Log errors with additional context"""
        error_data = {
            'error_type': type(error).__name__,
            'error_message': str(error),
            'context': context or {}
        }
        
        self.log_event('error', f"Error occurred: {error}", error_data)
        self.logger.error(f"Error: {error}", exc_info=True)
    
    def log_system_info(self):
        """Log current system information"""
        try:
            # Battery information
            battery_info = self.get_battery_info()
            self.log_event('system_info', "Battery system information", battery_info)
            
            # Process information
            import subprocess
            try:
                ps_output = subprocess.check_output(['ps', 'aux'], text=True)
                battery_processes = [line for line in ps_output.split('\n') if 'battery' in line.lower()]
                self.log_event('system_info', "Battery processes", {'processes': battery_processes})
            except Exception as e:
                self.logger.warning(f"Could not get process information: {e}")
                
        except Exception as e:
            self.log_error_with_context(e, {'function': 'log_system_info'})
    
    def get_battery_info(self):
        """Get current battery information"""
        battery_info = {}
        
        try:
            # Check for battery directories
            for bat_path in Path('/sys/class/power_supply').glob('BAT*'):
                if bat_path.is_dir():
                    bat_name = bat_path.name
                    battery_info[bat_name] = {}
                    
                    # Read capacity
                    capacity_file = bat_path / 'capacity'
                    if capacity_file.exists():
                        battery_info[bat_name]['capacity'] = capacity_file.read_text().strip()
                    
                    # Read status
                    status_file = bat_path / 'status'
                    if status_file.exists():
                        battery_info[bat_name]['status'] = status_file.read_text().strip()
                    
                    # Read threshold
                    threshold_file = bat_path / 'charge_control_end_threshold'
                    if threshold_file.exists():
                        battery_info[bat_name]['threshold'] = threshold_file.read_text().strip()
                        battery_info[bat_name]['threshold_supported'] = True
                    else:
                        battery_info[bat_name]['threshold_supported'] = False
                        
        except Exception as e:
            self.logger.warning(f"Could not read battery information: {e}")
            
        return battery_info
    
    def info(self, message):
        """Log info message"""
        self.logger.info(message)
    
    def warning(self, message):
        """Log warning message"""
        self.logger.warning(message)
    
    def error(self, message, exception=None):
        """Log error message"""
        if exception:
            self.log_error_with_context(exception, {'message': message})
        else:
            self.logger.error(message)
    
    def debug(self, message):
        """Log debug message"""
        self.logger.debug(message)

# Global logger instance
_logger_instance = None

def get_logger(component_name="battery-limiter"):
    """Get or create logger instance"""
    global _logger_instance
    if _logger_instance is None:
        _logger_instance = BatteryLimiterLogger(component_name)
    return _logger_instance

# Example usage
if __name__ == "__main__":
    logger = get_logger("test-component")
    logger.info("Test log message")
    logger.log_battery_status(75, 80, "Charging")
    logger.log_system_info()
    print(f"Logs written to: {logger.log_dir}")
