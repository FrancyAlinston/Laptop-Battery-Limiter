#!/bin/bash

# Universal Battery Charge Limit Script
# This script sets the battery charging limit for compatible laptops

CHARGE_LIMIT=${1:-80}
THRESHOLD_FILE="/sys/class/power_supply/BAT0/charge_control_end_threshold"
THRESHOLD_ALT_FILE="/sys/class/power_supply/BAT1/charge_control_end_threshold"

# Function to find battery threshold file
find_threshold_file() {
    if [ -f "$THRESHOLD_FILE" ]; then
        echo "$THRESHOLD_FILE"
        return 0
    elif [ -f "$THRESHOLD_ALT_FILE" ]; then
        echo "$THRESHOLD_ALT_FILE"
        return 0
    else
        # Try to find any battery threshold file
        for file in /sys/class/power_supply/BAT*/charge_control_end_threshold; do
            if [ -f "$file" ]; then
                echo "$file"
                return 0
            fi
        done
        return 1
    fi
}

# Find the correct threshold file
THRESHOLD_FILE=$(find_threshold_file)
if [ $? -ne 0 ]; then
    echo "Error: Battery charge control not supported on this system"
    echo "No threshold file found in /sys/class/power_supply/"
    exit 1
fi

# Validate the charge limit value
if ! [[ "$CHARGE_LIMIT" =~ ^[0-9]+$ ]]; then
    echo "Error: Charge limit must be a number"
    exit 1
fi

if [ "$CHARGE_LIMIT" -lt 50 ] || [ "$CHARGE_LIMIT" -gt 100 ]; then
    echo "Error: Charge limit must be between 50 and 100"
    exit 1
fi

# Set the charge limit
echo "Setting battery charge limit to ${CHARGE_LIMIT}%..."
echo "Using threshold file: $THRESHOLD_FILE"

if echo "$CHARGE_LIMIT" > "$THRESHOLD_FILE" 2>/dev/null; then
    echo "Successfully set battery charge limit to ${CHARGE_LIMIT}%"
    echo "Current limit: $(cat $THRESHOLD_FILE 2>/dev/null)%"
else
    echo "Error: Failed to set battery charge limit"
    echo "This may require root privileges or the system may not support this feature"
    exit 1
fi
    exit 1
fi
