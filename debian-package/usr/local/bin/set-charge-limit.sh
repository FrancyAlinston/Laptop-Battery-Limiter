#!/bin/bash

# Universal Battery Charge Limit Script
# This script sets the battery charging limit for compatible laptops

CHARGE_LIMIT=${1:-80}
THRESHOLD_FILE="/sys/class/power_supply/BAT0/charge_control_end_threshold"

# Check if the threshold file exists
if [ ! -f "$THRESHOLD_FILE" ]; then
    echo "Error: Battery charge control not supported on this system"
    echo "File not found: $THRESHOLD_FILE"
    exit 1
fi

# Validate the charge limit value
if [ "$CHARGE_LIMIT" -lt 50 ] || [ "$CHARGE_LIMIT" -gt 100 ]; then
    echo "Error: Charge limit must be between 50 and 100"
    exit 1
fi

# Set the charge limit
echo "Setting battery charge limit to ${CHARGE_LIMIT}%..."
echo "$CHARGE_LIMIT" > "$THRESHOLD_FILE"

if [ $? -eq 0 ]; then
    echo "Successfully set battery charge limit to ${CHARGE_LIMIT}%"
    echo "Current limit: $(cat $THRESHOLD_FILE)%"
else
    echo "Error: Failed to set battery charge limit"
    exit 1
fi
