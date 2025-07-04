#!/bin/bash

# ASUS Battery GUI Launcher
# Handles authentication and launches the GUI

# Check if pkexec is available for GUI authentication
if command -v pkexec >/dev/null 2>&1; then
    export DISPLAY=${DISPLAY:-:0}
    export XAUTHORITY=${XAUTHORITY:-$HOME/.Xauthority}
fi

# Launch the GUI
python3 /usr/local/bin/battery-gui
