select_theme(){
    path_to_metadata="/usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop"
    text="ConfigFile=Themes/"

    line=$(grep $text "$path_to_metadata")

    themes="astronaut black_hole cyberpunk hyprland_kath jake_the_dog japanese_aesthetic pixel_sakura pixel_sakura_static post-apocalyptic_hacker purple_leaves"
    
    echo -e "${green}[*] Select theme (enter number e.g. astronaut - 1).${no_color}"
    echo -e "${green}[*] 0. Other (choose if you created your own theme)."
    echo -e "${green}[*] 1. Astronaut                   2. Black hole${no_color}"
    echo -e "${green}[*] 3. Cyberpunk                   4. Hyprland Kath (animated)${no_color}"
    echo -e "${green}[*] 5. Jake the dog (animated)     6. Japanese aesthetic${no_color}"
    echo -e "${green}[*] 7. Pixel sakura (animated)     8. Pixel sakura (static)${no_color}"
    echo -e "${green}[*] 9. Post-apocalyptic hacker    10. Purple leaves${no_color}"
    read -p "[*] Your choice: " new_number
    
    if [ "$new_number" -eq 0 ] 2>/dev/null;then
        echo -e "${green}[*] Enter name of the config file (without .conf).${no_color}"
        read -p "[*] Theme name: " answer
        selected_theme="$answer"
    elif [ "$new_number" -ge 1 ] 2>/dev/null && [ "$new_number" -le 10 ] 2>/dev/null; then
        set -- $themes
        selected_theme=$(echo "$@" | cut -d ' ' -f $(("new_number")))
        echo -e "${green}[*] You selected: $selected_theme ${no_color}"
    else
        echo -e "${red}[*] Error: invalid number or input.${no_color}"
        exit
    fi

    modified_line="$text$selected_theme.conf"

    sudo sed -i "s|^$text.*|$modified_line|" $path_to_metadata
    echo -e "${green}[*] Changed: $line -> $modified_line${no_color}"
}


select_theme
