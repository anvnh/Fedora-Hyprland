#!/bin/bash
scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/globalcontrol.sh"
roconf="${confDir}/rofi/styles/style_${rofiStyle}.rasi"
[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
if [ ! -f "${roconf}" ] ; then
    roconf="$(find "${confDir}/rofi/styles" -type f -name "style_*.rasi" | sort -t '_' -k 2 -n | head -1)"
fi

# Define the wallpaper directory
WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
CURRENT_WALLPAPER_INDEX="$WALLPAPER_DIR/current_wallpaper_index"
CACHE_DIR="$HOME/.cache/rofi-wallpaper"

# Create cache directory if it doesn't exist
mkdir -p "$CACHE_DIR"

# Check if the wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper Selector" "Directory $WALLPAPER_DIR does not exist!"
    exit 1
fi

# Set up rofi styling
wind_border=$(( hypr_border * 1 ))
[ "${hypr_border}" -eq 0 ] && elem_border="10" || elem_border=$(( hypr_border * 2 ))
r_override="window {border: ${hypr_width}px; border-radius: ${wind_border}px;} element {border-radius: ${elem_border}px;}"
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
i_override="$(gsettings get org.gnome.desktop.interface icon-theme | sed "s/'//g")"
i_override="configuration {icon-theme: \"${i_override}\";}"

# Additional style for image preview
Copypreview_style="element { children: [element-icon, element-text]; }
               element-icon { size: 12em; }
               listview { columns: 1; scrollbar: true; fixed-height: false; }
               scrollbar { width: 4px; border: 0; handle-width: 8px; padding: 0; }
               window { width: 30%; }"

# Generate thumbnail entries for rofi
generate_entries() {
    local entries=""
    for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png}; do
        [ -f "$img" ] || continue
        local filename=$(basename "$img")
        entries+="$filename\x00icon\x1f$img\n"
    done
    echo -e "$entries"
}

# Display wallpaper options in rofi with previews
CHOICE=$(generate_entries | rofi -dmenu -p "Select Wallpaper" \
    -theme-str "${r_scale}" \
    -theme-str "${r_override}" \
    -theme-str "${i_override}" \
    -theme-str "${preview_style}" \
    -config "${roconf}" \
    -show-icons \
    -display-icons)

# Exit if no selection is made
[ -z "$CHOICE" ] && exit 0

# Get the selected wallpaper path
SELECTED_WALLPAPER="$WALLPAPER_DIR/$CHOICE"

# Save the current wallpaper index
echo "$CHOICE" > "$CURRENT_WALLPAPER_INDEX"

# Set the wallpaper using available tools
if command -v swww &> /dev/null; then
    swww img "$SELECTED_WALLPAPER" --transition-fps 120 --transition-type center --transition-duration 2
elif command -v hyprctl &> /dev/null; then
    hyprctl hyprpaper preload "$SELECTED_WALLPAPER"
    hyprctl hyprpaper wallpaper "eDP-1,$SELECTED_WALLPAPER"
elif command -v feh &> /dev/null; then
    feh --bg-fill "$SELECTED_WALLPAPER"
else
    notify-send "Wallpaper Selector" "No valid wallpaper tool found (swww, hyprctl, or feh)!"
    exit 1
fi

# Send a notification that the wallpaper has been changed then run generateblurthmb script
notify-send "Wallpaper Changed" "New wallpaper applied: $CHOICE"

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
convert "$SELECTED_WALLPAPER" -blur 0x25 "$BLUR_WALL"

# Create thumbnail
convert "$SELECTED_WALLPAPER" "$THMB_WALL"

# Notify completion
notify-send "Wallpaper Processed" "Blur and Thumbnail have been created!"
