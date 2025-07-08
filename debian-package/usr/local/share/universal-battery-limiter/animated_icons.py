#!/usr/bin/env python3

"""
Animated System Tray Icon Manager for Universal Battery Limiter
Handles animated icons for different battery states
"""

import gi
gi.require_version('Gtk', '3.0')
gi.require_version('GdkPixbuf', '2.0')

from gi.repository import Gtk, GdkPixbuf, GObject
import os
import threading
import time
from pathlib import Path

class AnimatedIconManager:
    def __init__(self, indicator):
        self.indicator = indicator
        self.animation_active = False
        self.animation_thread = None
        self.current_animation = None
        self.frame_index = 0
        
        # Icon paths
        self.icons_dir = Path(__file__).parent / "icons"
        self.static_dir = self.icons_dir / "static"
        self.animated_dir = self.icons_dir / "animated"
        
        # Ensure directories exist
        self.static_dir.mkdir(parents=True, exist_ok=True)
        self.animated_dir.mkdir(parents=True, exist_ok=True)
        
        # Create static icons for different battery levels
        self.create_static_icons()
        
        # Animation frames for different states
        self.animations = {
            'charging': self.create_charging_frames(),
            'low_battery': self.create_low_battery_frames(),
            'limit_reached': self.create_limit_reached_frames(),
            'disconnected': self.create_disconnected_frames()
        }
    
    def create_static_icons(self):
        """Create static battery icons for different charge levels"""
        icon_size = 24
        
        # Battery levels: 0%, 25%, 50%, 75%, 100%
        levels = [0, 25, 50, 75, 100]
        colors = ['#F44336', '#FF9800', '#FFC107', '#8BC34A', '#4CAF50']
        
        for i, level in enumerate(levels):
            # Create SVG content
            width_fill = int((16 - 4) * level / 100)  # Battery width minus padding
            color = colors[i]
            
            svg_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg width="{icon_size}" height="{icon_size}" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <!-- Battery outline -->
  <rect x="3" y="7" width="16" height="10" rx="2" ry="2" 
        fill="none" stroke="#333" stroke-width="1.5"/>
  
  <!-- Battery terminal -->
  <rect x="19" y="10" width="2" height="4" rx="0.5" ry="0.5" 
        fill="#333"/>
  
  <!-- Battery fill -->
  <rect x="5" y="9" width="{width_fill}" height="6" rx="1" ry="1" 
        fill="{color}" opacity="0.8"/>
  
  <!-- Percentage text -->
  <text x="11" y="13" text-anchor="middle" font-family="Arial, sans-serif" 
        font-size="6" font-weight="bold" fill="#333">{level}%</text>
</svg>'''
            
            # Save SVG
            svg_path = self.static_dir / f"battery-{level}.svg"
            with open(svg_path, 'w') as f:
                f.write(svg_content)
    
    def create_charging_frames(self):
        """Create animation frames for charging state"""
        frames = []
        icon_size = 24
        
        for i in range(10):
            # Animate fill width
            fill_width = int(12 * (i + 1) / 10)
            opacity = 0.3 + 0.7 * (i + 1) / 10
            
            # Lightning bolt animation
            bolt_scale = 0.8 + 0.4 * abs(5 - i) / 5
            bolt_opacity = 0.5 + 0.5 * abs(5 - i) / 5
            
            svg_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg width="{icon_size}" height="{icon_size}" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <!-- Battery outline -->
  <rect x="3" y="7" width="16" height="10" rx="2" ry="2" 
        fill="none" stroke="#333" stroke-width="1.5"/>
  
  <!-- Battery terminal -->
  <rect x="19" y="10" width="2" height="4" rx="0.5" ry="0.5" 
        fill="#333"/>
  
  <!-- Animated charging fill -->
  <rect x="5" y="9" width="{fill_width}" height="6" rx="1" ry="1" 
        fill="#4CAF50" opacity="{opacity}"/>
  
  <!-- Charging bolt -->
  <g transform="translate(12, 12) scale({bolt_scale})">
    <path d="M-2,-4 L2,-1 L0,-1 L2,4 L-2,1 L0,1 Z" 
          fill="#FFD700" opacity="{bolt_opacity}"/>
  </g>
</svg>'''
            
            frames.append(svg_content)
        
        return frames
    
    def create_low_battery_frames(self):
        """Create animation frames for low battery warning"""
        frames = []
        icon_size = 24
        
        for i in range(6):
            # Pulsing red battery
            opacity = 0.4 + 0.6 * abs(3 - i) / 3
            warning_scale = 1.0 + 0.3 * abs(3 - i) / 3
            
            svg_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg width="{icon_size}" height="{icon_size}" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <!-- Battery outline -->
  <rect x="3" y="7" width="16" height="10" rx="2" ry="2" 
        fill="none" stroke="#333" stroke-width="1.5"/>
  
  <!-- Battery terminal -->
  <rect x="19" y="10" width="2" height="4" rx="0.5" ry="0.5" 
        fill="#333"/>
  
  <!-- Low battery fill -->
  <rect x="5" y="9" width="3" height="6" rx="1" ry="1" 
        fill="#F44336" opacity="{opacity}"/>
  
  <!-- Warning exclamation -->
  <g transform="translate(12, 12) scale({warning_scale})">
    <path d="M-0.5,-2 L0.5,-2 L0.5,0 L-0.5,0 Z M-0.5,1 L0.5,1 L0.5,2 L-0.5,2 Z" 
          fill="#FF5722" opacity="{opacity}"/>
  </g>
</svg>'''
            
            frames.append(svg_content)
        
        return frames
    
    def create_limit_reached_frames(self):
        """Create animation frames for charge limit reached"""
        frames = []
        icon_size = 24
        
        for i in range(8):
            # Checkmark animation
            checkmark_progress = min(i * 2, 6)  # 0 to 6
            circle_progress = min(i * 3, 15)    # 0 to 15
            
            svg_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg width="{icon_size}" height="{icon_size}" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <!-- Battery outline -->
  <rect x="3" y="7" width="16" height="10" rx="2" ry="2" 
        fill="none" stroke="#333" stroke-width="1.5"/>
  
  <!-- Battery terminal -->
  <rect x="19" y="10" width="2" height="4" rx="0.5" ry="0.5" 
        fill="#333"/>
  
  <!-- Full battery fill -->
  <rect x="5" y="9" width="12" height="6" rx="1" ry="1" 
        fill="#4CAF50" opacity="0.9"/>
  
  <!-- Animated checkmark -->
  <g transform="translate(12, 12)">
    <circle cx="0" cy="0" r="3" fill="none" stroke="#4CAF50" stroke-width="1"
            stroke-dasharray="{circle_progress},20"/>
    <path d="M-1.5,0 L-0.5,1 L1.5,-1" 
          fill="none" stroke="#4CAF50" stroke-width="1.5"
          stroke-linecap="round" stroke-linejoin="round"
          stroke-dasharray="{checkmark_progress},10"/>
  </g>
</svg>'''
            
            frames.append(svg_content)
        
        return frames
    
    def create_disconnected_frames(self):
        """Create animation frames for disconnected/error state"""
        frames = []
        icon_size = 24
        
        for i in range(4):
            # Fading effect
            opacity = 0.3 + 0.4 * abs(2 - i) / 2
            
            svg_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg width="{icon_size}" height="{icon_size}" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <!-- Battery outline (dashed for disconnected) -->
  <rect x="3" y="7" width="16" height="10" rx="2" ry="2" 
        fill="none" stroke="#666" stroke-width="1.5" 
        stroke-dasharray="2,2" opacity="{opacity}"/>
  
  <!-- Battery terminal -->
  <rect x="19" y="10" width="2" height="4" rx="0.5" ry="0.5" 
        fill="#666" opacity="{opacity}"/>
  
  <!-- Question mark or X -->
  <g transform="translate(12, 12)">
    <path d="M-1,-2 L1,-2 L1,-1 L0,-1 L0,0 L-1,0 Z M-0.5,1 L0.5,1 L0.5,2 L-0.5,2 Z" 
          fill="#FF5722" opacity="{opacity}"/>
  </g>
</svg>'''
            
            frames.append(svg_content)
        
        return frames
    
    def svg_to_pixbuf(self, svg_content, size=24):
        """Convert SVG content to GdkPixbuf"""
        try:
            # Create temporary file
            import tempfile
            with tempfile.NamedTemporaryFile(mode='w', suffix='.svg', delete=False) as f:
                f.write(svg_content)
                temp_path = f.name
            
            # Load as pixbuf
            pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_size(temp_path, size, size)
            
            # Clean up
            os.unlink(temp_path)
            
            return pixbuf
        except Exception as e:
            print(f"Error creating pixbuf from SVG: {e}")
            return None
    
    def start_animation(self, animation_type):
        """Start an animation"""
        if animation_type not in self.animations:
            return
        
        self.stop_animation()
        self.current_animation = animation_type
        self.animation_active = True
        self.frame_index = 0
        
        self.animation_thread = threading.Thread(target=self._animate, daemon=True)
        self.animation_thread.start()
    
    def stop_animation(self):
        """Stop current animation"""
        self.animation_active = False
        if self.animation_thread and self.animation_thread.is_alive():
            self.animation_thread.join(timeout=1)
    
    def _animate(self):
        """Animation loop"""
        frames = self.animations[self.current_animation]
        frame_delay = 0.2  # 200ms per frame
        
        while self.animation_active:
            if self.frame_index >= len(frames):
                self.frame_index = 0
            
            # Update icon on main thread
            GObject.idle_add(self._update_icon_frame, frames[self.frame_index])
            
            self.frame_index += 1
            time.sleep(frame_delay)
    
    def _update_icon_frame(self, svg_content):
        """Update the indicator icon with new frame"""
        try:
            # For AppIndicator3, we need to save as temporary file
            import tempfile
            with tempfile.NamedTemporaryFile(mode='w', suffix='.svg', delete=False) as f:
                f.write(svg_content)
                temp_path = f.name
            
            # Update indicator icon
            self.indicator.set_icon_full(temp_path, "Battery Status")
            
            # Schedule cleanup
            GObject.timeout_add(1000, lambda: os.unlink(temp_path) if os.path.exists(temp_path) else None)
            
        except Exception as e:
            print(f"Error updating icon frame: {e}")
    
    def set_static_icon(self, battery_level):
        """Set a static battery icon based on level"""
        self.stop_animation()
        
        # Find closest level
        levels = [0, 25, 50, 75, 100]
        closest_level = min(levels, key=lambda x: abs(x - battery_level))
        
        icon_path = self.static_dir / f"battery-{closest_level}.svg"
        if icon_path.exists():
            self.indicator.set_icon_full(str(icon_path), f"Battery {battery_level}%")
        else:
            # Fallback to system icon
            self.indicator.set_icon("battery")
    
    def update_battery_state(self, level, status, is_charging, at_limit):
        """Update icon based on battery state"""
        if is_charging:
            self.start_animation('charging')
        elif level <= 20:
            self.start_animation('low_battery')
        elif at_limit:
            self.start_animation('limit_reached')
        elif status == "Unknown":
            self.start_animation('disconnected')
        else:
            self.set_static_icon(level)

# Test the animated icons
if __name__ == "__main__":
    import sys
    
    # Test icon creation
    manager = AnimatedIconManager(None)
    
    print("✅ Created animated icon frames:")
    for anim_type, frames in manager.animations.items():
        print(f"  - {anim_type}: {len(frames)} frames")
    
    print(f"✅ Created static icons in: {manager.static_dir}")
    print(f"✅ Animated icons ready in: {manager.animated_dir}")
    
    # Test SVG generation
    test_svg = manager.animations['charging'][0]
    print(f"✅ Sample charging frame (first): {len(test_svg)} characters")
