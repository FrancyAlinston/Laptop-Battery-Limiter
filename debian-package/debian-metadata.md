# Universal Battery Limiter - Debian Package Metadata

## Package Information
- **Package Name**: universal-battery-limiter
- **Version**: 2.0.0
- **Section**: utils
- **Priority**: optional
- **Architecture**: all
- **Maintainer**: FrancyAlinston <francyalen@gmail.com>
- **Homepage**: https://github.com/FrancyAlinston/Laptop-Battery-Limiter

## Dependencies
- python3 (>= 3.6)
- python3-gi
- python3-gi-cairo
- gir1.2-gtk-3.0
- gir1.2-appindicator3-0.1
- gir1.2-notify-0.7
- python3-tk
- policykit-1

## Version Control
- **Git Repository**: https://github.com/FrancyAlinston/Laptop-Battery-Limiter.git
- **Browse**: https://github.com/FrancyAlinston/Laptop-Battery-Limiter
- **Standards Version**: 4.6.0

## Package Description
Battery charge limit management for all compatible laptops

A comprehensive battery charge limit management tool for all compatible laptops with multiple interfaces including CLI, GUI, and system tray integration.

Features:
- Interactive CLI with colored output and presets
- Modern GUI application with dark theme
- System tray indicator for quick access
- Battery status monitoring
- Support for 50-100% charge limits
- Quick preset options (60%, 70%, 80%, 90%, 100%)
- Proper privilege handling with PolicyKit
- Auto-start on login
- Universal compatibility with all laptop brands

This package provides a professional battery management solution for laptops from various manufacturers including Lenovo, HP, Dell, ASUS, Acer, MSI, and many others that support ACPI battery charge control.

## Installation
```bash
# Direct installation from .deb file
sudo dpkg -i universal-battery-limiter_2.0.0_all.deb
sudo apt-get install -f  # Fix dependencies if needed

# From repository (if added to APT sources)
sudo apt update
sudo apt install universal-battery-limiter
```

## Files Installed
- /usr/local/bin/battery-cli - Command-line interface
- /usr/local/bin/battery-gui - GUI application
- /usr/local/bin/battery-indicator - System tray indicator
- /usr/local/bin/battery-limit - Direct limit setter
- /usr/local/bin/set-charge-limit.sh - Helper script
- /etc/xdg/autostart/universal-battery-limiter.desktop - Auto-start entry
- /etc/sudoers.d/universal-battery-limiter - Sudo configuration
- /usr/share/doc/universal-battery-limiter/ - Documentation

## Changelog
universal-battery-limiter (2.0.0) stable; urgency=low

  * Version 2.0.0 release
  * Universal rebranding from ASUS-specific to all laptops
  * Enhanced GUI with theme support
  * Modern Ubuntu 24.04 styling
  * Improved system tray integration
  * Professional packaging and installation
  * See GitHub releases for detailed changelog

## Copyright
Copyright 2025 FrancyAlinston <francyalen@gmail.com>

This package is free software; you can redistribute it and/or modify it under the terms of the MIT License.

## Support
- **Issues**: https://github.com/FrancyAlinston/Laptop-Battery-Limiter/issues
- **Documentation**: https://github.com/FrancyAlinston/Laptop-Battery-Limiter/blob/main/README.md
- **Contact**: francyalen@gmail.com
