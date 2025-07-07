#!/usr/bin/env python3

import tkinter as tk
from tkinter import ttk, messagebox
import subprocess
import os
import threading
import time
import json
import urllib.request
import urllib.error
from pathlib import Path

class BatteryControlGUI:
    def __init__(self, root):
        self.root = root
        self.setup_window()
        self.setup_variables()
        self.create_widgets()
        self.update_battery_info()
        self.start_auto_refresh()
        # Start theme monitoring
        self.root.after(10000, self.check_theme_change)

    def setup_window(self):
        """Configure the main window"""
        self.root.title("Universal Battery Control Center - Light Mode Demo")
        self.root.geometry("450x600")
        self.root.resizable(False, False)

        # Force light theme for demo
        self.force_light_theme()

        self.root.configure(bg=self.bg_color)

        # Configure styles
        self.setup_styles()

    def force_light_theme(self):
        """Force light theme colors for demonstration"""
        print("Forcing light theme for demonstration...")
        
        # Light theme colors - improved palette
        self.bg_color = "#fafafa"          # Light grey background
        self.card_color = "#ffffff"        # Pure white cards
        self.accent_color = "#1976d2"      # Material blue
        self.text_color = "#212121"        # Dark text
        self.secondary_text = "#757575"    # Grey text
        self.button_bg = "#1976d2"         # Material blue button
        self.button_fg = "#ffffff"         # White button text
        self.entry_bg = "#ffffff"          # White input background
        self.entry_fg = "#212121"          # Dark input text
        self.success_color = "#388e3c"     # Material green
        self.warning_color = "#f57c00"     # Material orange
        self.error_color = "#d32f2f"       # Material red
        self.border_color = "#e0e0e0"      # Light grey border
        self.is_dark_theme = False
        
        print("Light theme colors applied:")
        print(f"  Background: {self.bg_color}")
        print(f"  Cards: {self.card_color}")
        print(f"  Accent: {self.accent_color}")
        print(f"  Text: {self.text_color}")

    def setup_styles(self):
        """Setup custom styles for widgets"""
        style = ttk.Style()

        # Use clam theme for modern light appearance
        try:
            style.theme_use('clam')
        except:
            style.theme_use('default')

        # Configure theme-aware styles
        style.configure('Dark.TFrame',
                       background=self.bg_color,
                       relief='flat',
                       borderwidth=0)

        style.configure('Card.TFrame',
                       background=self.card_color,
                       relief='raised',
                       borderwidth=2,
                       padding=15)

        style.configure('Dark.TLabel',
                       background=self.bg_color,
                       foreground=self.text_color,
                       font=('Segoe UI', 10))

        style.configure('Title.TLabel',
                       background=self.bg_color,
                       foreground=self.text_color,
                       font=('Segoe UI', 16, 'bold'))

        style.configure('Card.TLabel',
                       background=self.card_color,
                       foreground=self.text_color,
                       font=('Segoe UI', 10))

        style.configure('Secondary.TLabel',
                       background=self.card_color,
                       foreground=self.secondary_text,
                       font=('Segoe UI', 9))

        style.configure('Accent.TLabel',
                       background=self.card_color,
                       foreground=self.accent_color,
                       font=('Segoe UI', 12, 'bold'))

        style.configure('Large.TLabel',
                       background=self.card_color,
                       foreground=self.text_color,
                       font=('Segoe UI', 14, 'bold'))

        # Custom button styles
        style.configure('Accent.TButton',
                       background=self.button_bg,
                       foreground=self.button_fg,
                       font=('Segoe UI', 10, 'bold'),
                       focuscolor='none',
                       borderwidth=0,
                       padding=(10, 5),
                       relief='flat')

        # Button hover effects
        hover_color = "#1565c0"
        pressed_color = "#0d47a1"
        style.map('Accent.TButton',
                 background=[('active', hover_color),
                           ('pressed', pressed_color)],
                 relief=[('pressed', 'flat'),
                        ('active', 'flat')])

        # Secondary button style
        style.configure('Secondary.TButton',
                       background=self.card_color,
                       foreground=self.text_color,
                       font=('Segoe UI', 10),
                       focuscolor='none',
                       borderwidth=1,
                       padding=(10, 5),
                       relief='solid')

        style.map('Secondary.TButton',
                 background=[('active', self.border_color),
                           ('pressed', self.border_color)],
                 bordercolor=[('active', self.accent_color),
                            ('pressed', self.accent_color)])

        # Scale style with improved appearance
        trough_color = self.border_color
        style.configure('Accent.Horizontal.TScale',
                       background=self.card_color,
                       troughcolor=trough_color,
                       borderwidth=0,
                       sliderlength=20,
                       sliderrelief='flat',
                       lightcolor=self.accent_color,
                       darkcolor=self.accent_color)

        style.map('Accent.Horizontal.TScale',
                 background=[('active', self.accent_color)])

        # Progressbar style with better colors
        style.configure('Themed.Horizontal.TProgressbar',
                       background=self.accent_color,
                       troughcolor=trough_color,
                       borderwidth=0,
                       lightcolor=self.accent_color,
                       darkcolor=self.accent_color)

        # Success/Warning/Error progressbar styles
        style.configure('Success.Horizontal.TProgressbar',
                       background=self.success_color,
                       troughcolor=trough_color,
                       borderwidth=0)

        style.configure('Warning.Horizontal.TProgressbar',
                       background=self.warning_color,
                       troughcolor=trough_color,
                       borderwidth=0)

        style.configure('Error.Horizontal.TProgressbar',
                       background=self.error_color,
                       troughcolor=trough_color,
                       borderwidth=0)

        # Radiobutton style
        style.configure('Card.TRadiobutton',
                       background=self.card_color,
                       foreground=self.text_color,
                       font=('Segoe UI', 10),
                       focuscolor='none',
                       borderwidth=0)

        style.map('Card.TRadiobutton',
                 background=[('active', self.card_color)],
                 foreground=[('active', self.accent_color)])

        # Entry style
        style.configure('Themed.TEntry',
                       fieldbackground=self.entry_bg,
                       foreground=self.entry_fg,
                       borderwidth=1,
                       bordercolor=self.border_color,
                       insertcolor=self.text_color,
                       padding=5)

        style.map('Themed.TEntry',
                 bordercolor=[('focus', self.accent_color)])

    def setup_variables(self):
        """Initialize variables"""
        self.charge_limit_var = tk.IntVar(value=80)
        self.current_level = tk.StringVar(value="85")
        self.battery_status = tk.StringVar(value="Charging")
        self.power_mode = tk.StringVar(value="Performance")
        self.auto_refresh = True

        # Battery threshold file
        self.threshold_file = "/sys/class/power_supply/BAT0/charge_control_end_threshold"
        self.capacity_file = "/sys/class/power_supply/BAT0/capacity"
        self.status_file = "/sys/class/power_supply/BAT0/status"

        # Version info for updates
        self.current_version = "2.0.0"
        self.github_repo = "FrancyAlinston/Laptop-Battery-Limiter"
        self.release_channel = "stable"

    def create_widgets(self):
        """Create all GUI widgets"""
        main_frame = ttk.Frame(self.root, style='Dark.TFrame')
        main_frame.pack(fill='both', expand=True, padx=15, pady=15)

        # Title
        title_label = ttk.Label(main_frame, text="🔋 Battery Control Center", style='Title.TLabel')
        title_label.pack(pady=(0, 20))

        # Light mode indicator
        demo_label = ttk.Label(main_frame, text="☀️ Light Mode Demo", style='Accent.TLabel')
        demo_label.pack(pady=(0, 10))

        # Battery Status Card
        self.create_battery_status_card(main_frame)

        # Charging Limit Card
        self.create_charging_limit_card(main_frame)

        # Power Management Card
        self.create_power_management_card(main_frame)

        # Quick Actions Card
        self.create_quick_actions_card(main_frame)

        # Status Bar
        self.create_status_bar(main_frame)

    def create_battery_status_card(self, parent):
        """Create battery status information card"""
        card = ttk.Frame(parent, style='Card.TFrame')
        card.pack(fill='x', pady=(0, 15), padx=5, ipady=15)

        ttk.Label(card, text="⚡ Battery Status", style='Accent.TLabel').pack(pady=(10, 5))

        # Battery level display
        level_frame = ttk.Frame(card, style='Card.TFrame')
        level_frame.pack(fill='x', padx=20, pady=10)

        ttk.Label(level_frame, text="Current Level:", style='Card.TLabel').pack(side='left')
        self.level_label = ttk.Label(level_frame, textvariable=self.current_level, style='Accent.TLabel')
        self.level_label.pack(side='right')

        # Battery status
        status_frame = ttk.Frame(card, style='Card.TFrame')
        status_frame.pack(fill='x', padx=20, pady=5)

        ttk.Label(status_frame, text="Status:", style='Card.TLabel').pack(side='left')
        self.status_label = ttk.Label(status_frame, textvariable=self.battery_status, style='Card.TLabel')
        self.status_label.pack(side='right')

        # Progress bar for battery level
        self.battery_progress = ttk.Progressbar(card, length=350, mode='determinate', style='Success.Horizontal.TProgressbar')
        self.battery_progress.pack(pady=10)
        self.battery_progress['value'] = 85

    def create_charging_limit_card(self, parent):
        """Create charging limit control card"""
        card = ttk.Frame(parent, style='Card.TFrame')
        card.pack(fill='x', pady=(0, 15), padx=5, ipady=15)

        ttk.Label(card, text="🎯 Charging Limit", style='Accent.TLabel').pack(pady=(10, 5))

        # Current limit display
        limit_display_frame = ttk.Frame(card, style='Card.TFrame')
        limit_display_frame.pack(fill='x', padx=20, pady=10)

        ttk.Label(limit_display_frame, text="Current Limit:", style='Card.TLabel').pack(side='left')
        self.limit_display = ttk.Label(limit_display_frame, text="80%", style='Accent.TLabel')
        self.limit_display.pack(side='right')

        # Slider for setting limit
        slider_frame = ttk.Frame(card, style='Card.TFrame')
        slider_frame.pack(fill='x', padx=20, pady=10)

        ttk.Label(slider_frame, text="50%", style='Card.TLabel').pack(side='left')

        self.limit_scale = ttk.Scale(slider_frame,
                                   from_=50, to=100,
                                   orient='horizontal',
                                   variable=self.charge_limit_var,
                                   style='Accent.Horizontal.TScale',
                                   command=self.on_scale_change)
        self.limit_scale.pack(side='left', fill='x', expand=True, padx=10)

        ttk.Label(slider_frame, text="100%", style='Card.TLabel').pack(side='right')

        # Apply button
        apply_btn = ttk.Button(card, text="Apply Charging Limit",
                              command=self.demo_action,
                              style='Accent.TButton')
        apply_btn.pack(pady=10)

    def create_power_management_card(self, parent):
        """Create power management controls"""
        card = ttk.Frame(parent, style='Card.TFrame')
        card.pack(fill='x', pady=(0, 15), padx=5, ipady=15)

        ttk.Label(card, text="⚙️ Power Management", style='Accent.TLabel').pack(pady=(10, 5))

        # Power mode selection
        mode_frame = ttk.Frame(card, style='Card.TFrame')
        mode_frame.pack(fill='x', padx=20, pady=10)

        ttk.Label(mode_frame, text="Power Mode:", style='Card.TLabel').pack(anchor='w')

        mode_buttons_frame = ttk.Frame(mode_frame, style='Card.TFrame')
        mode_buttons_frame.pack(fill='x', pady=5)

        modes = [("Power Saver", "powersave"), ("Balanced", "balanced"), ("Performance", "performance")]
        for mode_name, mode_value in modes:
            btn = ttk.Radiobutton(mode_buttons_frame, text=mode_name,
                                variable=self.power_mode, value=mode_value,
                                style='Card.TRadiobutton',
                                command=self.demo_action)
            btn.pack(side='left', padx=5)

    def create_quick_actions_card(self, parent):
        """Create quick action buttons"""
        card = ttk.Frame(parent, style='Card.TFrame')
        card.pack(fill='x', pady=(0, 15), padx=5, ipady=15)

        ttk.Label(card, text="🚀 Quick Actions", style='Accent.TLabel').pack(pady=(10, 5))

        # Preset buttons
        presets_frame = ttk.Frame(card, style='Card.TFrame')
        presets_frame.pack(fill='x', padx=20, pady=10)

        presets = [
            ("60% Storage", 60),
            ("80% Daily", 80),
            ("100% Full", 100)
        ]

        for i, (text, value) in enumerate(presets):
            btn = ttk.Button(presets_frame, text=text,
                           command=self.demo_action)
            btn.grid(row=0, column=i, padx=5, sticky='ew')
            presets_frame.grid_columnconfigure(i, weight=1)

        # Additional actions
        actions_frame = ttk.Frame(card, style='Card.TFrame')
        actions_frame.pack(fill='x', padx=20, pady=10)

        refresh_btn = ttk.Button(actions_frame, text="🔄 Refresh",
                               command=self.demo_action)
        refresh_btn.pack(side='left', padx=5)

        theme_btn = ttk.Button(actions_frame, text="🎨 Theme",
                              command=self.demo_action)
        theme_btn.pack(side='left', padx=5)

        update_btn = ttk.Button(actions_frame, text="🔍 Check Updates",
                              command=self.demo_action)
        update_btn.pack(side='left', padx=5)

        channel_btn = ttk.Button(actions_frame, text="🔄 Release Channel",
                               command=self.demo_action)
        channel_btn.pack(side='left', padx=5)

    def create_status_bar(self, parent):
        """Create status bar at bottom"""
        status_frame = ttk.Frame(parent, style='Dark.TFrame')
        status_frame.pack(fill='x', pady=(10, 0))

        self.status_text = ttk.Label(status_frame, text="Light Mode Demo - Ready", style='Dark.TLabel')
        self.status_text.pack(side='left')

        self.last_update = ttk.Label(status_frame, text="Updated: " + time.strftime("%H:%M:%S"), style='Dark.TLabel')
        self.last_update.pack(side='right')

    def on_scale_change(self, value):
        """Handle scale value change"""
        limit = int(float(value))
        self.limit_display.config(text=f"{limit}%")

    def demo_action(self):
        """Demo action for buttons"""
        self.status_text.config(text="Light Mode Demo - Action clicked!")
        self.root.after(2000, lambda: self.status_text.config(text="Light Mode Demo - Ready"))

    def update_battery_info(self):
        """Demo battery info"""
        pass

    def start_auto_refresh(self):
        """Demo auto refresh"""
        pass

    def check_theme_change(self):
        """Demo theme check"""
        pass

def main():
    root = tk.Tk()
    app = BatteryControlGUI(root)
    
    # Show info about the demo
    root.after(1000, lambda: messagebox.showinfo(
        "Light Mode Demo", 
        "This is the Universal Battery Control Center in Light Mode!\n\n" +
        "Features:\n" +
        "• Clean white background with subtle shadows\n" +
        "• Material Design color palette\n" +
        "• High contrast for readability\n" +
        "• Professional appearance\n\n" +
        "The real app automatically detects and switches between light and dark modes based on your system theme."
    ))

    root.mainloop()

if __name__ == "__main__":
    main()
