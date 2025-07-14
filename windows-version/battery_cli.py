#!/usr/bin/env python3
"""
Universal Battery Limiter - Windows CLI Version
Command-line interface for Windows battery management
"""

import sys
import platform
import argparse
import subprocess
import json
from pathlib import Path

# Import the Windows battery manager
try:
    from battery_limiter_windows import WindowsBatteryManager
except ImportError:
    print("Error: Cannot import WindowsBatteryManager")
    print("Make sure battery_limiter_windows.py is in the same directory")
    sys.exit(1)


class WindowsBatteryCLI:
    """Command-line interface for Windows battery management"""
    
    def __init__(self):
        self.battery_manager = WindowsBatteryManager()
        self.setup_args()
    
    def setup_args(self):
        """Setup command-line arguments"""
        self.parser = argparse.ArgumentParser(
            description="Universal Battery Limiter - Windows CLI",
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog="""
Examples:
  %(prog)s status                    Show battery status
  %(prog)s info                     Show system information  
  %(prog)s set 80                   Set charge limit to 80%%
  %(prog)s presets                  Show available presets
  %(prog)s methods                  Show supported methods
  %(prog)s reset                    Reset to full charging (100%%)
            """
        )
        
        self.parser.add_argument('command', 
                               choices=['status', 'info', 'set', 'presets', 'methods', 'reset', 'test'],
                               help='Command to execute')
        
        self.parser.add_argument('value', nargs='?', type=int,
                               help='Charge limit percentage (for set command)')
        
        self.parser.add_argument('--json', action='store_true',
                               help='Output in JSON format')
        
        self.parser.add_argument('--verbose', '-v', action='store_true',
                               help='Verbose output')
    
    def run(self):
        """Run the CLI application"""
        args = self.parser.parse_args()
        
        try:
            if args.command == 'status':
                self.show_status(args)
            elif args.command == 'info':
                self.show_info(args)
            elif args.command == 'set':
                self.set_limit(args)
            elif args.command == 'presets':
                self.show_presets(args)
            elif args.command == 'methods':
                self.show_methods(args)
            elif args.command == 'reset':
                self.reset_limit(args)
            elif args.command == 'test':
                self.test_system(args)
        
        except KeyboardInterrupt:
            print("\nOperation cancelled by user.")
            sys.exit(1)
        except Exception as e:
            print(f"Error: {e}")
            if args.verbose:
                import traceback
                traceback.print_exc()
            sys.exit(1)
    
    def show_status(self, args):
        """Show current battery status"""
        info = self.battery_manager.get_battery_info()
        
        if args.json:
            print(json.dumps(info, indent=2))
            return
        
        print("🔋 Battery Status")
        print("=" * 30)
        print(f"Current Level: {info['level']}%")
        print(f"Status: {info['status']}")
        print(f"Charging: {'Yes' if info['is_charging'] else 'No'}")
        print(f"Plugged In: {'Yes' if info['is_plugged'] else 'No'}")
        print(f"Health: {info['health']}")
        
        # Show visual battery indicator
        level = info['level']
        bar_length = 20
        filled_length = int(bar_length * level // 100)
        bar = '█' * filled_length + '░' * (bar_length - filled_length)
        
        print(f"\nBattery: [{bar}] {level}%")
        
        # Add recommendations based on level
        if level < 20:
            print("\n⚠️  Low battery - consider charging soon")
        elif level > 95 and info['is_charging']:
            print("\n✅ Battery nearly full - consider unplugging")
    
    def show_info(self, args):
        """Show system information"""
        if args.json:
            data = {
                "manufacturer": self.battery_manager.manufacturer,
                "model": self.battery_manager.model,
                "supported_methods": self.battery_manager.supported_methods,
                "platform": platform.platform(),
                "python_version": platform.python_version()
            }
            print(json.dumps(data, indent=2))
            return
        
        print("💻 System Information")
        print("=" * 30)
        print(f"Manufacturer: {self.battery_manager.manufacturer.title()}")
        print(f"Model: {self.battery_manager.model}")
        print(f"Platform: {platform.platform()}")
        print(f"Python: {platform.python_version()}")
        
        print(f"\n🔧 Supported Methods:")
        if self.battery_manager.supported_methods:
            for method in self.battery_manager.supported_methods:
                print(f"  ✅ {method}")
        else:
            print("  ❌ No supported methods detected")
            print("     Your laptop may not support battery charge limiting")
    
    def set_limit(self, args):
        """Set battery charge limit"""
        if args.value is None:
            print("Error: Charge limit value required")
            print("Usage: battery_cli set <limit>")
            print("Example: battery_cli set 80")
            sys.exit(1)
        
        limit = args.value
        
        if limit < 50 or limit > 100:
            print("Error: Charge limit must be between 50 and 100")
            sys.exit(1)
        
        print(f"Setting battery charge limit to {limit}%...")
        
        success, methods = self.battery_manager.set_charge_limit(limit)
        
        if args.json:
            result = {
                "success": success,
                "limit": limit,
                "methods_tried": methods
            }
            print(json.dumps(result, indent=2))
            return
        
        if success:
            print(f"✅ Battery charge limit set to {limit}%")
            print(f"Method used: {methods[-1] if methods else 'Unknown'}")
            
            # Show recommendations
            if limit <= 60:
                print("\n💡 60% limit maximizes battery lifespan (desk use)")
            elif limit <= 80:
                print("\n💡 80% limit balances lifespan and usability (daily use)")
            else:
                print("\n💡 High limit for maximum runtime (travel use)")
        else:
            print(f"❌ Failed to set battery charge limit")
            print(f"Methods tried: {', '.join(methods) if methods else 'None'}")
            print("\nPossible solutions:")
            print("• Install manufacturer software (Lenovo Vantage, Dell Command, etc.)")
            print("• Run as administrator")
            print("• Check if your laptop supports battery charge limiting")
            sys.exit(1)
    
    def show_presets(self, args):
        """Show available charge limit presets"""
        presets = {
            50: "Maximum Lifespan (long-term storage)",
            60: "Desk Use (plugged in most of the time)",
            70: "Light Daily Use",
            80: "Balanced Daily Use (recommended)",
            90: "Heavy Daily Use",
            100: "Full Capacity (travel/unplugged use)"
        }
        
        if args.json:
            print(json.dumps(presets, indent=2))
            return
        
        print("🎯 Charge Limit Presets")
        print("=" * 30)
        
        for limit, description in presets.items():
            print(f"{limit}% - {description}")
        
        print("\nTo set a preset:")
        print("  battery_cli set <percentage>")
        print("  Example: battery_cli set 80")
    
    def show_methods(self, args):
        """Show supported battery management methods"""
        methods_info = {
            "WMI": "Windows Management Instrumentation (generic)",
            "Lenovo Conservation Mode": "Lenovo Vantage/Energy Management",
            "Dell BIOS Settings": "Dell Command Configure (cctk)",
            "HP Battery Health Manager": "HP Support Assistant",
            "ASUS Battery Health Charging": "ASUS utilities",
            "PowerShell Power Plans": "Windows power management"
        }
        
        if args.json:
            data = {
                "detected_methods": self.battery_manager.supported_methods,
                "all_methods": methods_info
            }
            print(json.dumps(data, indent=2))
            return
        
        print("🔧 Battery Management Methods")
        print("=" * 35)
        
        print("Detected on your system:")
        if self.battery_manager.supported_methods:
            for method in self.battery_manager.supported_methods:
                description = methods_info.get(method, "Unknown method")
                print(f"  ✅ {method} - {description}")
        else:
            print("  ❌ No methods detected")
        
        print("\nAll available methods:")
        for method, description in methods_info.items():
            status = "✅" if method in self.battery_manager.supported_methods else "❌"
            print(f"  {status} {method} - {description}")
    
    def reset_limit(self, args):
        """Reset battery to full charging (100%)"""
        print("Resetting battery to full charging (100%)...")
        
        success, methods = self.battery_manager.set_charge_limit(100)
        
        if args.json:
            result = {
                "success": success,
                "limit": 100,
                "methods_tried": methods
            }
            print(json.dumps(result, indent=2))
            return
        
        if success:
            print("✅ Battery reset to full charging (100%)")
            print("Your laptop will now charge to 100% as normal")
        else:
            print("❌ Failed to reset battery charging")
            print("You may need to manually disable any manufacturer software settings")
    
    def test_system(self, args):
        """Test system compatibility and functionality"""
        print("🧪 System Compatibility Test")
        print("=" * 35)
        
        tests = []
        
        # Test 1: Platform check
        is_windows = platform.system() == "Windows"
        tests.append(("Windows Platform", is_windows, "Must be running on Windows"))
        
        # Test 2: Python version
        python_ok = sys.version_info >= (3, 6)
        tests.append(("Python 3.6+", python_ok, f"Current: {platform.python_version()}"))
        
        # Test 3: WMI availability
        wmi_ok = self.battery_manager.wmi_connection is not None
        tests.append(("WMI Connection", wmi_ok, "Windows Management Instrumentation"))
        
        # Test 4: Battery detection
        battery_info = self.battery_manager.get_battery_info()
        battery_ok = battery_info['level'] > 0
        tests.append(("Battery Detection", battery_ok, "Can read battery information"))
        
        # Test 5: Supported methods
        methods_ok = len(self.battery_manager.supported_methods) > 0
        tests.append(("Battery Control", methods_ok, f"Methods: {len(self.battery_manager.supported_methods)}"))
        
        # Test 6: Administrator privileges
        try:
            import ctypes
            admin_ok = ctypes.windll.shell32.IsUserAnAdmin()
        except:
            admin_ok = False
        tests.append(("Admin Privileges", admin_ok, "Required for battery management"))
        
        # Show results
        all_passed = True
        for test_name, passed, description in tests:
            status = "✅ PASS" if passed else "❌ FAIL"
            print(f"{status} {test_name}: {description}")
            if not passed:
                all_passed = False
        
        print("\n" + "=" * 35)
        if all_passed:
            print("✅ All tests passed! System is compatible.")
        else:
            print("❌ Some tests failed. Check requirements.")
            
        if args.json:
            result = {
                "overall_success": all_passed,
                "tests": [
                    {"name": name, "passed": passed, "description": desc}
                    for name, passed, desc in tests
                ]
            }
            print(json.dumps(result, indent=2))


def main():
    """Main entry point"""
    # Check if running on Windows
    if platform.system() != "Windows":
        print("Error: This tool is designed for Windows systems only.")
        print("For Linux, use the main battery limiter.")
        sys.exit(1)
    
    cli = WindowsBatteryCLI()
    cli.run()


if __name__ == "__main__":
    main()
