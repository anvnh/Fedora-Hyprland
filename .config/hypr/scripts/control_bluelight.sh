#!/bin/bash

# Path to store current temperature
TEMP_FILE="$HOME/.config/hypr/current_temp"

# Default temperature if not set
DEFAULT_TEMP=6000
STEP=500  # Change by 500K each time
MIN_TEMP=2000  # Minimum temperature
MAX_TEMP=6500  # Maximum temperature

# Read current temperature or use default
if [ -f "$TEMP_FILE" ]; then
    CURRENT_TEMP=$(cat "$TEMP_FILE")
else
    CURRENT_TEMP=$DEFAULT_TEMP
fi

# Check the argument: "up" to increase, "down" to decrease
case "$1" in
    "up")
        NEW_TEMP=$((CURRENT_TEMP + STEP))
        if [ "$NEW_TEMP" -gt "$MAX_TEMP" ]; then
            NEW_TEMP="$MAX_TEMP"
        fi
        ;;
    "down")
        NEW_TEMP=$((CURRENT_TEMP - STEP))
        if [ "$NEW_TEMP" -lt "$MIN_TEMP" ]; then
            NEW_TEMP="$MIN_TEMP"
        fi
        ;;
    *)
        echo "Usage: $0 {up|down}"
        exit 1
        ;;
esac

# Apply new temperature with hyprsunset
hyprctl hyprsunset temperature "$NEW_TEMP"

# Save new temperature
echo "$NEW_TEMP" > "$TEMP_FILE"
