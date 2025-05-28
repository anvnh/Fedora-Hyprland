#!/bin/bash
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_message "Starting"

kill_waybar() {
    log_message "Attempting to kill existing waybar instances..."

    # Try graceful shutdown first
    if pgrep waybar > /dev/null; then
        killall waybar
        sleep 1
    fi

    # Force kill if any instances remain
    if pgrep waybar > /dev/null; then
        log_message "Forcing shutdown of remaining waybar instances..."
        killall -9 waybar
        sleep 1
    fi

    killall waybar
    
    log_message "Successfully killed all waybar instances"
}

# Function to start waybar
start_waybar() {
    log_message "Starting waybar..."
    waybar &> /dev/null &
    
    # Check if waybar started successfully
    sleep 2
    if ! pgrep waybar > /dev/null; then
        log_message "Error: Failed to start waybar"
        exit 1
    fi
    
    log_message "Waybar started successfully"
}

# Main execution
main() {
    kill_waybar
    start_waybar
}

main
