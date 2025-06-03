#!/bin/bash
clear # To clear the terminal screen

# Variable username/repo
repo="anvnh/Fedora-Hyprland"

# Download folder
download_folder="$HOME/.hyprDotfiles"

# Create the download folder if it doesn't exist
# if [ ! -d "$download_folder" ]; then
#     mkdir -p "$download_folder"
# fi

# Get the latest release tag from repo
get_latest_release() {
    curl --silent "https://api.github.com/repos/$repo/releases/latest" | # Get latest release from GitHub api
        grep '"tag_name":' |                                             # Get tag line
        sed -E 's/.*"([^"]+)".*/\1/'                                     # Pluck JSON value
}

# Get the latest zip file of the repo
get_latest_zip() {
    curl --silent "https://api.github.com/repos/$repo/releases/latest" | # Get latest release from GitHub api
        grep '"zipball_url":' |                                          # Get tag line
        sed -E 's/.*"([^"]+)".*/\1/'                                     # Pluck JSON value
}

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

# Required packages for the installer
packages=(
    "wget"
    "unzip"
    "rsync"
    "git"
    "figlet"
)

latest_version=$(get_latest_release)

# Some colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NONE='\033[0m'
RED='\033[0;31m'

# Header
echo -e "${BLUE}Hyprland Installer for Fedora${NONE}"
cat <<"EOF"
 ___           _        _ _
|_ _|_ __  ___| |_ __ _| | | ___ _ __
 | || '_ \/ __| __/ _` | | |/ _ \ '__|
 | || | | \__ \ || (_| | | |  __/ |
|___|_| |_|___/\__\__,_|_|_|\___|_|
EOF

echo "anvnh Dotfiles for Hyprland"
echo -e "Version: ${GREEN}${latest_version}${NONE}"

while true; do
    read -p "Do you want to start the installation now? (yes/no): " yn
    case $yn in
        [Yy]*)
            echo ":: Installation started"
            echo
            break
            ;;
        [Nn]*)
            echo ":: Installation canceled"
            exit
            break
            ;;
        *)
            echo ":: Please answer yes or no."
            ;;
    esac
done

# If exists the download folder, remove it then create a new one
# This is to ensure that the latest version is downloaded
if [ -d "$download_folder" ]; then
    echo ":: Removing old download folder"
    rm -rf "$download_folder"
fi
mkdir -p "$download_folder"

# Install required packages
echo ":: Checking that required packages are installed..."
_installPackages "${packages[@]}"

bash <(curl -s https://raw.githubusercontent.com/anvnh/Fedora-Hyprland/scripts/fedora/special/gum.sh)

# Select the dotfiles version
echo -e "${GREEN}Select the dotfiles version to install:${NONE}"
echo -e "- anvnh Dotfiles for Hyprland $latest_version"

version=$(gum choose "latest" "cancel")

if [ "$version" == "latest" ]; then
    echo ":: Installing Main Release"
    echo
    git clone --depth 1 https://github.com/"$repo".git "$download_folder" || {
        echo -e "${RED}Error: Failed to clone the repository.${NONE}"
        exit 1
    }
elif [ "$version" == "cancel" ]; then
    echo ":: Setup canceled"
    exit 130
else
    echo ":: Setup canceled"
    exit 130
fi
echo ":: Download complete."
echo

# cd into the dotfiles folder
cd $download_folder/scripts/fedora/bin/

gum spin --spinner dot --title "Starting the installation now..." -- sleep 3
