#!/usr/bin/env python3

"""
Advanced Animated Icon System for Universal Battery Limiter
Creates GIF animations and frame-based PNG sequences for better system tray compatibility
"""

import os
from pathlib import Path
from PIL import Image, ImageDraw, ImageSequence
import tempfile
import threading
import time

class AdvancedAnimatedIcons:
    def __init__(self):
        self.icons_dir = Path(__file__).parent / "icons"
        self.gif_dir = self.icons_dir / "gif"
        self.png_dir = self.icons_dir / "png_frames"

        # Create directories
        self.gif_dir.mkdir(parents=True, exist_ok=True)
        self.png_dir.mkdir(parents=True, exist_ok=True)

        # Icon size
        self.size = (24, 24)

        # Colors
        self.colors = {
            'outline': '#333333',
            'terminal': '#333333',
            'charging': '#4CAF50',
            'low': '#F44336',
            'medium': '#FF9800',
            'high': '#8BC34A',
            'full': '#4CAF50',
            'bolt': '#FFD700',
            'warning': '#FF5722'
        }

    def create_battery_base(self, draw, level=100, color='#4CAF50', show_percentage=False):
        """Draw base battery shape with fill level"""
        # Battery outline
        draw.rounded_rectangle([2, 6, 18, 16], radius=2, outline=self.colors['outline'], width=2)

        # Battery terminal
        draw.rounded_rectangle([18, 9, 21, 13], radius=1, fill=self.colors['terminal'])

        # Battery fill
        if level > 0:
            fill_width = int(14 * level / 100)
            if fill_width > 0:
                draw.rounded_rectangle([4, 8, 4 + fill_width, 14], radius=1, fill=color)

        # Percentage text (optional)
        if show_percentage and level >= 0:
            text = f"{level}%"
            # Simple text positioning (approximate)
            text_x = 12 - len(text) * 2
            text_y = 10
            # Note: PIL text rendering is basic, for better text use ImageFont
            try:
                draw.text((text_x, text_y), text, fill=self.colors['outline'])
            except:
                pass  # Skip text if font issues

    def create_charging_animation(self, frames=10):
        """Create charging animation GIF"""
        images = []

        for i in range(frames):
            # Create image
            img = Image.new('RGBA', self.size, (0, 0, 0, 0))
            draw = ImageDraw.Draw(img)

            # Animate fill level
            level = int(100 * (i + 1) / frames)
            opacity = int(255 * (0.3 + 0.7 * (i + 1) / frames))

            # Draw battery
            self.create_battery_base(draw, level, self.colors['charging'])

            # Lightning bolt (animated scale)
            bolt_scale = 0.8 + 0.4 * abs(frames/2 - i) / (frames/2)
            bolt_points = [
                (10, 8), (14, 11), (13, 11), (14, 16), (10, 13), (11, 13)
            ]

            # Scale bolt points
            center_x, center_y = 12, 12
            scaled_points = []
            for x, y in bolt_points:
                new_x = center_x + (x - center_x) * bolt_scale
                new_y = center_y + (y - center_y) * bolt_scale
                scaled_points.append((new_x, new_y))

            # Draw bolt
            draw.polygon(scaled_points, fill=self.colors['bolt'])

            images.append(img)

        # Save as GIF
        gif_path = self.gif_dir / "charging.gif"
        images[0].save(
            gif_path,
            save_all=True,
            append_images=images[1:],
            duration=200,  # 200ms per frame
            loop=0
        )

        return str(gif_path)

    def create_low_battery_animation(self, frames=6):
        """Create low battery warning animation"""
        images = []

        for i in range(frames):
            img = Image.new('RGBA', self.size, (0, 0, 0, 0))
            draw = ImageDraw.Draw(img)

            # Pulsing red battery
            opacity_factor = abs(frames/2 - i) / (frames/2)

            # Draw battery with low charge
            self.create_battery_base(draw, 15, self.colors['low'])

            # Warning exclamation mark
            warning_opacity = int(255 * (0.5 + 0.5 * opacity_factor))
            warning_color = (*[int(c) for c in bytes.fromhex(self.colors['warning'][1:])], warning_opacity)

            # Exclamation mark
            draw.rectangle([11, 8, 13, 12], fill=self.colors['warning'])
            draw.rectangle([11, 13, 13, 15], fill=self.colors['warning'])

            # Pulsing circle
            circle_radius = 8 + int(3 * opacity_factor)
            circle_opacity = int(50 * (1 - opacity_factor))
            draw.ellipse([12 - circle_radius, 12 - circle_radius,
                         12 + circle_radius, 12 + circle_radius],
                         outline=self.colors['warning'])

            images.append(img)

        gif_path = self.gif_dir / "low_battery.gif"
        images[0].save(
            gif_path,
            save_all=True,
            append_images=images[1:],
            duration=250,
            loop=0
        )

        return str(gif_path)

    def create_limit_reached_animation(self, frames=8):
        """Create charge limit reached animation"""
        images = []

        for i in range(frames):
            img = Image.new('RGBA', self.size, (0, 0, 0, 0))
            draw = ImageDraw.Draw(img)

            # Draw full battery
            self.create_battery_base(draw, 100, self.colors['full'])

            # Animated checkmark
            if i >= 2:  # Start checkmark after 2 frames
                check_progress = min((i - 2) / (frames - 2), 1.0)

                # Checkmark circle
                if check_progress > 0:
                    circle_angle = int(360 * check_progress)
                    draw.arc([8, 8, 16, 16], 0, circle_angle, fill=self.colors['full'], width=2)

                # Checkmark lines
                if check_progress > 0.5:
                    line_progress = (check_progress - 0.5) * 2

                    # First line of checkmark
                    if line_progress > 0:
                        draw.line([10, 12, 11, 13], fill=self.colors['full'], width=2)

                    # Second line of checkmark
                    if line_progress > 0.5:
                        draw.line([11, 13, 14, 10], fill=self.colors['full'], width=2)

            images.append(img)

        gif_path = self.gif_dir / "limit_reached.gif"
        images[0].save(
            gif_path,
            save_all=True,
            append_images=images[1:],
            duration=300,
            loop=0
        )

        return str(gif_path)

    def create_static_icons(self):
        """Create static PNG icons for different battery levels"""
        levels = [0, 10, 25, 50, 75, 90, 100]

        for level in levels:
            img = Image.new('RGBA', self.size, (0, 0, 0, 0))
            draw = ImageDraw.Draw(img)

            # Choose color based on level
            if level <= 20:
                color = self.colors['low']
            elif level <= 50:
                color = self.colors['medium']
            elif level <= 80:
                color = self.colors['high']
            else:
                color = self.colors['full']

            self.create_battery_base(draw, level, color, show_percentage=True)

            # Save as PNG
            png_path = self.icons_dir / f"battery-{level}.png"
            img.save(png_path, 'PNG')

    def create_all_animations(self):
        """Create all animated icons"""
        animations = {}

        print("🎬 Creating animated battery icons...")

        # Charging animation
        print("  ⚡ Creating charging animation...")
        animations['charging'] = self.create_charging_animation()

        # Low battery animation
        print("  ⚠️ Creating low battery animation...")
        animations['low_battery'] = self.create_low_battery_animation()

        # Limit reached animation
        print("  ✅ Creating limit reached animation...")
        animations['limit_reached'] = self.create_limit_reached_animation()

        # Static icons
        print("  📄 Creating static icons...")
        self.create_static_icons()

        print("🎉 All animations created successfully!")
        return animations

# Enhanced animated icon manager for system tray
class SystemTrayAnimatedIcons:
    def __init__(self, indicator):
        self.indicator = indicator
        self.animation_thread = None
        self.animation_active = False
        self.current_gif = None

        # Create animated icons
        self.icon_creator = AdvancedAnimatedIcons()
        self.animations = self.icon_creator.create_all_animations()

        # Frame extraction for manual animation
        self.frames = {}
        self.extract_gif_frames()

    def extract_gif_frames(self):
        """Extract individual frames from GIF files for manual animation"""
        for anim_name, gif_path in self.animations.items():
            if os.path.exists(gif_path):
                frames = []
                with Image.open(gif_path) as img:
                    for i, frame in enumerate(ImageSequence.Iterator(img)):
                        # Save frame as temporary PNG
                        frame_path = self.icon_creator.png_dir / f"{anim_name}_frame_{i:02d}.png"
                        frame.save(frame_path, 'PNG')
                        frames.append(str(frame_path))

                self.frames[anim_name] = frames

    def start_gif_animation(self, animation_type):
        """Start GIF-based animation (if supported by system tray)"""
        if animation_type in self.animations:
            gif_path = self.animations[animation_type]
            if os.path.exists(gif_path):
                try:
                    # Try to set animated GIF directly (may not work on all systems)
                    self.indicator.set_icon_full(gif_path, f"Battery {animation_type}")
                    return True
                except:
                    # Fallback to frame-based animation
                    return self.start_frame_animation(animation_type)
        return False

    def start_frame_animation(self, animation_type):
        """Start frame-based animation (more compatible)"""
        if animation_type not in self.frames:
            return False

        self.stop_animation()
        self.animation_active = True
        self.current_animation = animation_type

        self.animation_thread = threading.Thread(
            target=self._animate_frames,
            args=(animation_type,),
            daemon=True
        )
        self.animation_thread.start()
        return True

    def _animate_frames(self, animation_type):
        """Animate using individual PNG frames"""
        frames = self.frames[animation_type]
        frame_delays = {
            'charging': 0.2,
            'low_battery': 0.25,
            'limit_reached': 0.3
        }
        delay = frame_delays.get(animation_type, 0.2)

        frame_index = 0
        while self.animation_active:
            if frame_index >= len(frames):
                frame_index = 0

            try:
                frame_path = frames[frame_index]
                if os.path.exists(frame_path):
                    self.indicator.set_icon_full(frame_path, f"Battery {animation_type}")
            except Exception as e:
                print(f"Error setting frame {frame_index}: {e}")

            frame_index += 1
            time.sleep(delay)

    def stop_animation(self):
        """Stop current animation"""
        self.animation_active = False
        if self.animation_thread and self.animation_thread.is_alive():
            self.animation_thread.join(timeout=1)

    def set_static_icon(self, battery_level):
        """Set static battery icon"""
        self.stop_animation()

        # Find closest static icon
        static_icon = self.icon_creator.icons_dir / f"battery-{self.get_closest_level(battery_level)}.png"
        if static_icon.exists():
            self.indicator.set_icon_full(str(static_icon), f"Battery {battery_level}%")
        else:
            # Fallback to system icon
            self.indicator.set_icon("battery")

    def get_closest_level(self, level):
        """Get closest predefined battery level"""
        levels = [0, 10, 25, 50, 75, 90, 100]
        return min(levels, key=lambda x: abs(x - level))

    def update_battery_state(self, level, status, is_charging, at_limit):
        """Update icon based on battery state"""
        if is_charging and not at_limit:
            self.start_frame_animation('charging')
        elif level <= 20 and not is_charging:
            self.start_frame_animation('low_battery')
        elif at_limit:
            self.start_frame_animation('limit_reached')
        else:
            self.set_static_icon(level)

# Test the system
if __name__ == "__main__":
    # Test icon creation
    creator = AdvancedAnimatedIcons()
    animations = creator.create_all_animations()

    print("\n📋 Created animations:")
    for name, path in animations.items():
        if os.path.exists(path):
            size = os.path.getsize(path)
            print(f"  ✅ {name}: {path} ({size} bytes)")
        else:
            print(f"  ❌ {name}: File not created")

    print(f"\n📁 Icons directory: {creator.icons_dir}")
    print(f"📁 GIF animations: {creator.gif_dir}")
    print(f"📁 PNG frames: {creator.png_dir}")
