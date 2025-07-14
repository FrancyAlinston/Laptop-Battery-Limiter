#!/usr/bin/env python3

"""
Enhanced Animated Icon Manager for Universal Battery Limiter
Provides beautiful, smooth animations similar to Flaticon battery icons
"""

import gi
gi.require_version('Gtk', '3.0')
gi.require_version('GdkPixbuf', '2.0')

from gi.repository import Gtk, GdkPixbuf, GObject
import os
import threading
import time
from pathlib import Path
import subprocess

class EnhancedAnimatedIconManager:
    def __init__(self, indicator):
        self.indicator = indicator
        self.animation_active = False
        self.animation_thread = None
        self.current_animation = None
        self.frame_index = 0
        self.last_battery_level = 0
        self.last_battery_status = ""
        
        # Icon paths
        self.icons_dir = Path(__file__).parent / "icons"
        self.static_dir = self.icons_dir / "static"
        self.animated_dir = self.icons_dir / "animated"
        
        # Ensure directories exist
        self.static_dir.mkdir(parents=True, exist_ok=True)
        self.animated_dir.mkdir(parents=True, exist_ok=True)
        
        # Animation states
        self.animation_states = {
            'charging': 'advanced-charging.svg',
            'low_battery': 'advanced-low-battery.svg',
            'limit_reached': 'advanced-limit-reached.svg',
            'disconnected': 'advanced-disconnected.svg',
            'normal': 'advanced-normal.svg'
        }
        
        # Create fallback static icons if advanced animations aren't available
        self.create_fallback_icons()
        
        print("✨ Enhanced Animated Icon Manager initialized")
    
    def create_fallback_icons(self):
        """Create simple fallback icons for compatibility"""
        icon_size = 22
        
        # Simple battery icons for different states
        icons = {
            'charging': {
                'color': '#4CAF50',
                'symbol': '⚡',
                'fill_width': 12
            },
            'low_battery': {
                'color': '#F44336',
                'symbol': '!',
                'fill_width': 3
            },
            'limit_reached': {
                'color': '#FF9800',
                'symbol': '✓',
                'fill_width': 13
            },
            'disconnected': {
                'color': '#9E9E9E',
                'symbol': '×',
                'fill_width': 6
            },
            'normal': {
                'color': '#2196F3',
                'symbol': '',
                'fill_width': 9
            }
        }
        
        for state, props in icons.items():
            svg_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg width="{icon_size}" height="{icon_size}" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <rect x="2" y="6" width="17" height="12" rx="2" ry="2" 
        fill="none" stroke="#666" stroke-width="1.5"/>
  <rect x="19" y="9" width="3" height="6" rx="1" ry="1" fill="#666"/>
  <rect x="4" y="8" width="{props['fill_width']}" height="8" rx="1" ry="1" 
        fill="{props['color']}" opacity="0.8"/>
  <text x="12" y="13" text-anchor="middle" font-family="Arial, sans-serif" 
        font-size="8" font-weight="bold" fill="{props['color']}">{props['symbol']}</text>
</svg>'''
            
            fallback_path = self.static_dir / f"{state}.svg"
            with open(fallback_path, 'w') as f:
                f.write(svg_content)
    
    def update_icon(self, battery_level, battery_status, charge_limit):
        """Update icon based on battery state"""
        try:
            # Determine animation state
            new_state = self.determine_animation_state(battery_level, battery_status, charge_limit)
            
            # Only change animation if state changed
            if new_state != self.current_animation:
                self.stop_animation()
                self.current_animation = new_state
                self.start_animation(new_state)
            
            self.last_battery_level = battery_level
            self.last_battery_status = battery_status
            
        except Exception as e:
            print(f"❌ Error updating animated icon: {e}")
            self.set_fallback_icon(battery_level)
    
    def determine_animation_state(self, battery_level, battery_status, charge_limit):
        """Determine which animation state to use"""
        if battery_status.lower() == 'charging':
            return 'charging'
        elif battery_level <= 15:
            return 'low_battery'
        elif battery_level >= charge_limit and charge_limit < 100:
            return 'limit_reached'
        elif battery_status.lower() in ['not charging', 'unknown']:
            return 'disconnected'
        else:
            return 'normal'
    
    def start_animation(self, animation_state):
        """Start the specified animation"""
        try:
            if animation_state not in self.animation_states:
                print(f"❌ Unknown animation state: {animation_state}")
                return
            
            # Check if advanced animation file exists
            animation_file = self.animated_dir / self.animation_states[animation_state]
            
            if animation_file.exists():
                # Use advanced SVG animation
                self.set_animated_icon(str(animation_file))
                print(f"✨ Started advanced animation: {animation_state}")
            else:
                # Use fallback static icon
                fallback_file = self.static_dir / f"{animation_state}.svg"
                if fallback_file.exists():
                    self.set_static_icon(str(fallback_file))
                    print(f"📱 Using fallback icon: {animation_state}")
                else:
                    print(f"❌ No icon found for state: {animation_state}")
            
        except Exception as e:
            print(f"❌ Error starting animation: {e}")
            self.set_fallback_icon(self.last_battery_level)
    
    def set_animated_icon(self, svg_path):
        """Set an animated SVG icon"""
        try:
            # For AppIndicator3, we need to convert SVG to PNG or use SVG directly
            if svg_path.endswith('.svg'):
                # Try to use SVG directly (works on some systems)
                self.indicator.set_icon(svg_path)
            else:
                # Convert to PNG if needed
                png_path = self.convert_svg_to_png(svg_path)
                self.indicator.set_icon(png_path)
        except Exception as e:
            print(f"❌ Error setting animated icon: {e}")
    
    def set_static_icon(self, svg_path):
        """Set a static SVG icon"""
        try:
            self.indicator.set_icon(svg_path)
        except Exception as e:
            print(f"❌ Error setting static icon: {e}")
    
    def convert_svg_to_png(self, svg_path):
        """Convert SVG to PNG for better compatibility"""
        try:
            png_path = svg_path.replace('.svg', '.png')
            
            # Use rsvg-convert if available
            result = subprocess.run([
                'rsvg-convert', '-w', '22', '-h', '22', 
                svg_path, '-o', png_path
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                return png_path
            else:
                print(f"❌ Failed to convert SVG to PNG: {result.stderr}")
                return svg_path
                
        except FileNotFoundError:
            print("⚠️ rsvg-convert not found, using SVG directly")
            return svg_path
        except Exception as e:
            print(f"❌ Error converting SVG to PNG: {e}")
            return svg_path
    
    def set_fallback_icon(self, battery_level):
        """Set a simple fallback icon based on battery level"""
        try:
            if battery_level <= 15:
                icon_name = "battery-empty"
            elif battery_level <= 30:
                icon_name = "battery-low"
            elif battery_level <= 60:
                icon_name = "battery-medium"
            elif battery_level <= 90:
                icon_name = "battery-good"
            else:
                icon_name = "battery-full"
            
            self.indicator.set_icon(icon_name)
        except Exception as e:
            print(f"❌ Error setting fallback icon: {e}")
            self.indicator.set_icon("battery")
    
    def stop_animation(self):
        """Stop current animation"""
        if self.animation_active:
            self.animation_active = False
            if self.animation_thread and self.animation_thread.is_alive():
                self.animation_thread.join(timeout=1)
    
    def get_animation_info(self):
        """Get information about current animation"""
        return {
            'current_state': self.current_animation,
            'animation_active': self.animation_active,
            'battery_level': self.last_battery_level,
            'battery_status': self.last_battery_status,
            'available_animations': list(self.animation_states.keys())
        }
    
    def test_animations(self):
        """Test all available animations"""
        print("🧪 Testing all animations...")
        
        test_states = [
            ('charging', 50, 'Charging', 80),
            ('low_battery', 10, 'Discharging', 80),
            ('limit_reached', 80, 'Not charging', 80),
            ('disconnected', 60, 'Unknown', 80),
            ('normal', 70, 'Discharging', 80)
        ]
        
        for state, level, status, limit in test_states:
            print(f"  Testing {state}...")
            self.update_icon(level, status, limit)
            time.sleep(3)
        
        print("✅ Animation test completed")

# Backward compatibility wrapper
class AnimatedIconManager(EnhancedAnimatedIconManager):
    """Backward compatibility wrapper for the enhanced manager"""
    def __init__(self, indicator):
        super().__init__(indicator)
        print("🔄 Using enhanced animated icon manager (backward compatible)")

if __name__ == "__main__":
    # Test the enhanced icon manager
    print("🧪 Testing Enhanced Animated Icon Manager...")
    
    # Create a dummy indicator for testing
    class DummyIndicator:
        def set_icon(self, icon_path):
            print(f"🎨 Setting icon: {icon_path}")
    
    dummy_indicator = DummyIndicator()
    manager = EnhancedAnimatedIconManager(dummy_indicator)
    
    # Test different states
    manager.test_animations()
