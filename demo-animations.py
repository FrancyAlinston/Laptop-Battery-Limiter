#!/usr/bin/env python3

"""
Demo script for Enhanced Animated Icons
Shows how the animations work with different battery states
"""

import os
import time
import sys
from pathlib import Path

# Add current directory to path
sys.path.insert(0, str(Path(__file__).parent))

from enhanced_animated_icons import EnhancedAnimatedIconManager

class MockIndicator:
    """Mock indicator for demonstration"""
    def __init__(self):
        self.current_icon = None
        self.title = ""
    
    def set_icon(self, icon_path):
        self.current_icon = icon_path
        icon_name = Path(icon_path).name if icon_path else "system-icon"
        print(f"🎨 System Tray Icon: {icon_name}")
    
    def set_title(self, title):
        self.title = title
        print(f"📝 Tooltip: {title}")

def demo_animations():
    """Demonstrate all animation states"""
    print("🚀 Universal Battery Limiter - Enhanced Animated Icons Demo")
    print("=" * 60)
    
    # Create mock indicator
    indicator = MockIndicator()
    
    # Create animation manager
    icon_manager = EnhancedAnimatedIconManager(indicator)
    
    # Demo scenarios
    scenarios = [
        {
            "name": "💚 Charging Battery",
            "level": 45,
            "status": "Charging",
            "limit": 80,
            "description": "Battery is actively charging with beautiful energy waves"
        },
        {
            "name": "🔋 Normal Operation",
            "level": 70,
            "status": "Discharging",
            "limit": 80,
            "description": "Gentle breathing animation for stable battery state"
        },
        {
            "name": "⚠️ Low Battery Alert",
            "level": 12,
            "status": "Discharging",
            "limit": 80,
            "description": "Urgent blinking animation with warning indicators"
        },
        {
            "name": "✅ Charge Limit Reached",
            "level": 80,
            "status": "Not charging",
            "limit": 80,
            "description": "Success animation with sparkles and checkmark"
        },
        {
            "name": "🔌 Disconnected/Standby",
            "level": 60,
            "status": "Unknown",
            "limit": 80,
            "description": "Fading discharge animation with floating particles"
        }
    ]
    
    print("\n🎬 Animation Demo Sequence:")
    print("-" * 40)
    
    for i, scenario in enumerate(scenarios, 1):
        print(f"\n{i}. {scenario['name']}")
        print(f"   📊 Level: {scenario['level']}% | Status: {scenario['status']}")
        print(f"   📝 {scenario['description']}")
        print("   " + "-" * 35)
        
        # Update icon
        icon_manager.update_icon(
            scenario['level'], 
            scenario['status'], 
            scenario['limit']
        )
        
        # Show animation info
        info = icon_manager.get_animation_info()
        print(f"   🎯 Animation State: {info['current_state']}")
        
        # Simulate time for animation
        print("   ⏳ Animation running... (3 seconds)")
        time.sleep(3)
    
    print("\n" + "=" * 60)
    print("🎉 Animation Demo Complete!")
    print("\nTo see the animations in action:")
    print("  1. 🌐 Open 'animated-icons-demo.html' in your browser")
    print("  2. 🖥️ Run the system tray: 'python3 battery-indicator'")
    print("  3. 📱 Watch your system tray for live animations!")
    
    print("\n🔧 Animation System Info:")
    print(f"  Available States: {', '.join(info['available_animations'])}")
    print(f"  Icons Directory: {icon_manager.icons_dir}")
    print(f"  Fallback Support: ✅ Enabled")
    print(f"  SVG Animations: ✅ Available")
    
    print("\n💡 Pro Tips:")
    print("  • Animations automatically respond to your battery state")
    print("  • Each state has unique visual effects and timing")
    print("  • System tray icons update in real-time")
    print("  • Fallback icons ensure compatibility across all systems")
    
    return True

if __name__ == "__main__":
    try:
        demo_animations()
    except KeyboardInterrupt:
        print("\n\n⏹️ Demo interrupted by user")
    except Exception as e:
        print(f"\n❌ Demo error: {e}")
        sys.exit(1)
