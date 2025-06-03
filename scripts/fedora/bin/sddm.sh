#!/bin/bash

# Astronaut theme for SDDM
# Repo: https://github.com/Keyitdev/sddm-astronaut-theme

# Check if packages are installed
_isInstalled() {
    package="$1"
    check=$(yum list installed | grep $package)
    if [ -z "$check" ]; then
        echo 1 #'1' means 'false' in Bash
        return #false
    else
        echo 0 #'0' means 'true' in Bash
        return #true
    fi
}

# Install required packages
_installPackages() {
    toInstall=()
    for pkg; do
        if [[ $(_isInstalled "${pkg}") == 0 ]]; then
            echo "${pkg} is already installed."
            continue
        fi
        toInstall+=("${pkg}")
    done
    if [[ "${toInstall[@]}" == "" ]]; then
        # echo "All dnf (or rpm) packages are already installed.";
        return
    fi
    printf "Package not installed:\n%s\n" "${toInstall[@]}"
    sudo dnf install --assumeyes "${toInstall[@]}"
}

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

# Required packages for sddm
packages=(
    "sddm"
    "qt6-qtsvg"
    "qt6-qtvirtualkeyboard"
    "qt6-qtmultimedia"
)

# Install required packages
_installPackages "${packages[@]}"

# Clone the repository
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"
sudo git clone -b master --depth 1 https://github.com/keyitdev/sddm-astronaut-theme.git /usr/share/sddm/themes/sddm-astronaut-theme

# Copy font to /usr/share/fonts
sudo cp -r /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/

# Edit /etc/sddm.conf
echo "[Theme]
Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf

# Edit /etc/sddm.conf.d/virtualkbd.conf
echo "[General]
InputMethod=qtvirtualkeyboard" | sudo tee /etc/sddm.conf.d/virtualkbd.conf

# Previewing
# sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sddm-astronaut-theme/

# Select theme
select_theme

