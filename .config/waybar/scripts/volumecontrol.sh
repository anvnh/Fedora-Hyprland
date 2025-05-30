#!/bin/bash

# Default values
STEP=5  # Default volume adjustment step (percentage)
MAX_VOL=100
NOTIFICATION_ID=9993

# Function to show volume notification
show_notification() {
    local volume=$(pamixer --get-volume)
    local muted=$(pamixer --get-mute)
    local icon
    
    if [ "$muted" = "true" ]; then
        icon="audio-volume-muted"
        msg="Volume: Muted"
    else
        if [ "$volume" -eq 0 ]; then
            icon="audio-volume-muted"
        elif [ "$volume" -lt 30 ]; then
            icon="audio-volume-low"
        elif [ "$volume" -lt 70 ]; then
            icon="audio-volume-medium"
        else
            icon="audio-volume-high"
        fi
        msg="Volume: ${volume}%"
    fi
    
    dunstify -a "changeVolume" -u low -i "$icon" -r "$NOTIFICATION_ID" "$msg" \
        -h int:value:"$volume"
}

# Function to handle volume control
volume_control() {
    case "$1" in
        i|increase)
            # Increase volume
            pamixer -u # Unmute first
            pamixer -i ${STEP} --allow-boost
            ;;
        d|decrease)
            # Decrease volume
            pamixer -u # Unmute first
            pamixer -d ${STEP}
            ;;
        m|mute)
            # Toggle mute
            pamixer -t
            ;;
        *)
            echo "Usage: $0 -o [i|d|m]"
            echo "  i: increase volume"
            echo "  d: decrease volume"
            echo "  m: toggle mute"
            exit 1
            ;;
    esac
    
    show_notification
}

# Parse command line arguments
while getopts ":o:" opt; do
    case ${opt} in
        o)
            operation=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

# Check if operation is provided
if [ -z "$operation" ]; then
    echo "No operation specified"
    exit 1
fi

# Execute volume control
volume_control "$operation"
