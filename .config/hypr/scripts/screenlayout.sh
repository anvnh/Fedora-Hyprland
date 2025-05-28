#!/usr/bin/env sh

#// Set variables
scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/globalcontrol.sh"
roconf="${confDir}/rofi/styles/style_${rofiStyle}.rasi"

[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10

if [ ! -f "${roconf}" ] ; then
    roconf="$(find "${confDir}/rofi/styles" -type f -name "style_*.rasi" | sort -t '_' -k 2 -n | head -1)"
fi

#// Set Rofi theme
wind_border=$(( hypr_border * 1 ))
[ "${hypr_border}" -eq 0 ] && elem_border="10" || elem_border=$(( hypr_border * 2 ))
r_override="window {border: ${hypr_width}px; border-radius: ${wind_border}px;} element {border-radius: ${elem_border}px;}"
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
i_override="$(gsettings get org.gnome.desktop.interface icon-theme | sed "s/'//g")"
i_override="configuration {icon-theme: \"${i_override}\";}"

#// Screen layout selection
CHOICE=$(echo -e "Mirror Screen\nExtend to left\nExtend to right\nExtend to top\nExtend to bottom\n \n\n<span size='large'><b>Press ESC to exit</b></span>" | \
    rofi -dmenu -markup-rows -p "Select screen layout" \
    -theme-str "${r_scale}" -theme-str "${r_override}" -theme-str "${i_override}" -config "${roconf}")

[[ -z "$CHOICE" ]] && exit 0 # Exit if no selection

case "$CHOICE" in
    "Mirror Screen")
        hyprctl keyword monitor "HDMI-A-1,1920x1080@60,0x0,1"
        hyprctl keyword monitor "eDP-1,1920x1080@60,0x0,1"
        ;;
    "Extend to right")
        hyprctl keyword monitor "HDMI-A-1,1920x1080@60,1920x0,1"
        hyprctl keyword monitor "eDP-1,1920x1080@60,0,1"
        ;;
    "Extend to left")
        hyprctl keyword monitor "HDMI-A-1,1920x1080@60,0x0,1"
        hyprctl keyword monitor "eDP-1,1920x1080@60,1920x0,1"
        ;;
    "Extend to top")
        hyprctl keyword monitor "HDMI-A-1,1920x1080@60,0x0,1"
        hyprctl keyword monitor "eDP-1,1920x1080@60,0x1080,1"
        ;;
    "Extend to bottom")
        hyprctl keyword monitor "HDMI-A-1,1920x1080@60,0x1080,1"
        hyprctl keyword monitor "eDP-1,1920x1080@60,0x0,1"
        ;;
esac


#// Select workspace range for each monitor
WORKSPACE_MAIN=$(seq 1 10 | rofi -dmenu -p "Workspaces for eDP-1?" \
    -theme-str "${r_scale}" -theme-str "${r_override}" -theme-str "${i_override}" -config "${roconf}")
WORKSPACE_EXT=$(seq 1 10 | rofi -dmenu -p "Workspaces for HDMI-A-1?" \
    -theme-str "${r_scale}" -theme-str "${r_override}" -theme-str "${i_override}" -config "${roconf}")

#// Assign workspaces
[[ -z "$WORKSPACE_MAIN" ]] && exit 0
for i in $(seq 1 "$WORKSPACE_MAIN"); do
    hyprctl keyword workspace "$i, monitor:eDP-1"
done

[[ -z "$WORKSPACE_EXT" ]] && exit 0
for i in $(seq $((WORKSPACE_MAIN + 1)) "$WORKSPACE_EXT"); do
    hyprctl keyword workspace "$i, monitor:HDMI-A-1"
done

#// Notify user
notify-send "✅ Screen Layout Applied" \
    "Layout: $CHOICE\nWorkspaces eDP-1: 1-$WORKSPACE_MAIN\nWorkspaces HDMI-A-1: $((WORKSPACE_MAIN + 1))-$WORKSPACE_EXT"
