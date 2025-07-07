#!/usr/bin/env python3
"""
Test script to verify OS theme detection and color scheme functionality
"""

import tkinter as tk
from tkinter import ttk
import subprocess
import os

def detect_os_theme():
    """Test the OS theme detection"""
    print("🔍 Testing OS theme detection...")
    
    is_dark_theme = False
    
    # Test GTK theme detection
    try:
        result = subprocess.run(['gsettings', 'get', 'org.gnome.desktop.interface', 'gtk-theme'],
                              capture_output=True, text=True, timeout=2)
        if result.returncode == 0:
            theme_name = result.stdout.strip().strip("'\"").lower()
            if 'dark' in theme_name or 'black' in theme_name:
                is_dark_theme = True
                print(f"✅ Dark theme detected: {theme_name}")
            else:
                print(f"☀️ Light theme detected: {theme_name}")
    except Exception as e:
        print(f"❌ GTK theme detection failed: {e}")
    
    # Set colors based on theme
    if is_dark_theme:
        colors = {
            'bg': '#2e3440',
            'card': '#3b4252',
            'text': '#eceff4',
            'accent': '#88c0d0',
            'success': '#a3be8c',
            'warning': '#ebcb8b',
            'error': '#bf616a'
        }
        print("🌙 Using dark theme colors (Nord palette)")
    else:
        colors = {
            'bg': '#fafafa',
            'card': '#ffffff',
            'text': '#212121',
            'accent': '#1976d2',
            'success': '#388e3c',
            'warning': '#f57c00',
            'error': '#d32f2f'
        }
        print("☀️ Using light theme colors (Material palette)")
    
    # Print color scheme
    print("\n🎨 Color scheme:")
    for name, color in colors.items():
        print(f"  {name.capitalize()}: {color}")
    
    return is_dark_theme, colors

def create_test_window():
    """Create a test window to demonstrate theme colors"""
    is_dark, colors = detect_os_theme()
    
    root = tk.Tk()
    root.title(f"Theme Test - {'Dark' if is_dark else 'Light'} Mode")
    root.geometry("400x300")
    root.configure(bg=colors['bg'])
    
    # Main frame
    main_frame = tk.Frame(root, bg=colors['bg'])
    main_frame.pack(fill='both', expand=True, padx=20, pady=20)
    
    # Title
    title_label = tk.Label(main_frame, 
                          text=f"🔋 Universal Battery Limiter",
                          bg=colors['bg'], fg=colors['text'],
                          font=('Segoe UI', 16, 'bold'))
    title_label.pack(pady=(0, 20))
    
    # Card frame
    card_frame = tk.Frame(main_frame, bg=colors['card'], relief='raised', bd=2)
    card_frame.pack(fill='x', pady=10)
    
    # Theme info
    theme_label = tk.Label(card_frame,
                          text=f"Theme: {'Dark' if is_dark else 'Light'} Mode",
                          bg=colors['card'], fg=colors['accent'],
                          font=('Segoe UI', 12, 'bold'))
    theme_label.pack(pady=10)
    
    # Status examples
    status_frame = tk.Frame(card_frame, bg=colors['card'])
    status_frame.pack(fill='x', padx=20, pady=10)
    
    # Success status
    success_label = tk.Label(status_frame,
                            text="✅ Theme detection successful",
                            bg=colors['card'], fg=colors['success'],
                            font=('Segoe UI', 10))
    success_label.pack(anchor='w')
    
    # Warning status
    warning_label = tk.Label(status_frame,
                            text="⚠️ Battery level: 45%",
                            bg=colors['card'], fg=colors['warning'],
                            font=('Segoe UI', 10))
    warning_label.pack(anchor='w')
    
    # Error status
    error_label = tk.Label(status_frame,
                          text="❌ Low battery: 15%",
                          bg=colors['card'], fg=colors['error'],
                          font=('Segoe UI', 10))
    error_label.pack(anchor='w')
    
    # Close button
    close_btn = tk.Button(main_frame,
                         text="Close",
                         command=root.destroy,
                         bg=colors['accent'], fg=colors['card'],
                         font=('Segoe UI', 10, 'bold'),
                         relief='flat', bd=0)
    close_btn.pack(pady=(20, 0))
    
    # Auto-close after 5 seconds
    root.after(5000, root.destroy)
    
    print(f"\n🖥️ Test window created with {'dark' if is_dark else 'light'} theme")
    print("Window will auto-close in 5 seconds...")
    
    root.mainloop()

if __name__ == "__main__":
    create_test_window()
