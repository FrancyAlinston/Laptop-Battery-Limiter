#!/usr/bin/env python3
"""
Test theme detection functionality
"""

import subprocess
import os

def test_theme_detection():
    """Test the theme detection methods"""
    print("Testing theme detection methods...")
    
    # Test GTK theme detection
    try:
        result = subprocess.run(['gsettings', 'get', 'org.gnome.desktop.interface', 'gtk-theme'], 
                              capture_output=True, text=True, timeout=2)
        if result.returncode == 0:
            theme_name = result.stdout.strip().strip("'\"")
            print(f"GTK Theme: {theme_name}")
            is_dark = 'dark' in theme_name.lower() or 'black' in theme_name.lower()
            print(f"Is Dark Theme: {is_dark}")
        else:
            print("GTK theme detection failed")
    except Exception as e:
        print(f"GTK theme detection error: {e}")
    
    # Test color scheme detection
    try:
        result = subprocess.run(['gsettings', 'get', 'org.gnome.desktop.interface', 'color-scheme'], 
                              capture_output=True, text=True, timeout=2)
        if result.returncode == 0:
            color_scheme = result.stdout.strip().strip("'\"")
            print(f"Color Scheme: {color_scheme}")
        else:
            print("Color scheme not available")
    except Exception as e:
        print(f"Color scheme detection error: {e}")
    
    # Test environment variables
    print("\nEnvironment variables:")
    print(f"GTK_THEME: {os.environ.get('GTK_THEME', 'Not set')}")
    print(f"XDG_CURRENT_DESKTOP: {os.environ.get('XDG_CURRENT_DESKTOP', 'Not set')}")
    print(f"XDG_SESSION_DESKTOP: {os.environ.get('XDG_SESSION_DESKTOP', 'Not set')}")
    print(f"DESKTOP_SESSION: {os.environ.get('DESKTOP_SESSION', 'Not set')}")

if __name__ == "__main__":
    test_theme_detection()
