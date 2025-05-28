#!/bin/bash

# Define cache directory
CACHE_DIR="$HOME/.cache/hyde"
mkdir -p "$CACHE_DIR"

# Check if wallpaper has been selected
if [ -z "$SELECTED_WALLPAPER" ] || [ ! -f "$SELECTED_WALLPAPER" ]; then
    notify-send "Wallpaper Processor" "No valid wallpaper found!"
    exit 1
fi

# Paths for output images
BLUR_WALL="$CACHE_DIR/wall.blur"
THMB_WALL="$CACHE_DIR/wall.thmb"

# Create blurred wallpaper
convert "$SELECTED_WALLPAPER" -blur 0x10 "$BLUR_WALL"

# Create thumbnail
convert "$SELECTED_WALLPAPER" -resize 200x200 "$THMB_WALL"

# Notify completion
notify-send "Wallpaper Processed" "Blur and Thumbnail have been created!"
