#! /bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_URL="https://raw.githubusercontent.com/site-u2023/config-software2/main/"
BASE_DR="/etc/config-software/"

# Download and load main colors
wget --no-check-certificate -O "${BASE_DR}main_colors.sh" "${BASE_URL}main_colors.sh"
. "${BASE_DR}main_colors.sh"

# Function to handle downloading and executing scripts
download_and_execute() {
    local script_name="$1"
    local url="$2"
    echo "$(color "blue" "Downloading and executing: ${script_name}")"
    
    # Attempt to download the script
    if wget --no-check-certificate -O "${BASE_DR}${script_name}" "${url}"; then
        echo "$(color "green" "Download successful.")"
        # Execute the downloaded script
        sh "${BASE_DR}${script_name}"
    else
        echo "$(color "red" "Download failed.")"
    fi
}

# Reusable function for menu options with description and script download
menu_option() {
    local description="$1"
    local script_name="$2"
    local url="$3"
    echo "$(color "white" "${description}")"
    read -p "$(color "white" "Do you want to proceed? [y/n]: ")" choice
    case "${choice}" in
        "y") download_and_execute "${script_name}" "${url}" ;;
        "n") return ;;
        *) echo "$(color "red" "Invalid option. Please try again.")" ;;
    esac
}

# Function to delete the script and exit
delete_and_exit() {
    echo "$(color "red" "Deleting script and exiting.")"
    rm -rf "${BASE_DR}" /usr/bin/confsoft
    exit
}

# Check OpenWrt version
check_openwrt_version() {
    local supported_versions="19 21 22 23 24"
    local release=$(grep 'DISTRIB_RELEASE' /etc/openwrt_release | cut -d"'" -f2 | cut -c 1-2)
    if echo "${supported_versions}" | grep -q "${release}"; then
        echo "$(color "white" "OpenWrt version: ${release} - Supported")"
    else
        echo "$(color "red" "Unsupported OpenWrt version: ${release}")"
        echo "$(color "white" "Supported versions: ${supported_versions}")"
        exit 1
    fi
}

# モニター確認用
color_code() {
for i in `seq 30 38` `seq 40 47` ; do
    for j in 0 1 2 3 4 5 6 7 ; do
        printf "\033[${j};${i}m"
        printf " ${j};${i} "
        printf "\033[0;39;49m"
        printf " "
    done
    printf "\n"
done
}

# Function to display system information
display_system_info() {
    local available_memory=$(free | awk '/Mem:/ { print int($4 / 1024) }')
    local available_flash=$(df | awk '/overlayfs:\/overlay/ { print int($4 / 1024) }')
    local usb_devices=$(ls /sys/bus/usb/devices | grep -q usb && echo "Detected" || echo "Not detected")

    echo "$(color "white" "OpenWrt-Config Information")"
    echo "$(color "white" "Available Memory: ${available_memory} MB")"
    echo "$(color "white" "Available Flash Storage: ${available_flash} MB")"
    echo "$(color "white" "USB Devices: ${usb_devices}")"
    echo "$(color "red_white" "Disclaimer: Use this script at your own risk.")"
}

# Menu options
MENU0="OpenWrt Configuration Menu"          
MENU1="Internet Configuration (Japan Only)" ; TARGET1="internet-config.sh" 
MENU2="Initial system setup"                ; TARGET2="system-config.sh"
MENU3="Install recommended packages"        ; TARGET3="package-config.sh" 
MENU4="Install and Configure Ad Blocker"    ; TARGET4="ad-dns-blocking-config.sh"
MENU5="Configure access point"              ; TARGET5="accesspoint-config.sh"
MENU6="Execute other scripts"               ; TARGET6="etc-config.sh"
MENU7="Exit the Script"                     ; TARGET7="exit"
MENU8="Delete scripts and exit"             ; TARGET8="delete_and_exit"

# Main menu with user interaction
main_menu() {
    while :; do
        echo "$(color "white" "-------------------------------------------------------")"
        echo "$(color "white" "${MENU0}")"
        echo "$(color "blue" "[i]: ${MENU1}")"
        echo "$(color "yellow" "[s]: ${MENU2}")"
        echo "$(color "green" "[p]: ${MENU3}")"
        echo "$(color "magenta" "[b]: ${MENU4}")"
        echo "$(color "red" "[a]: ${MENU5}")"
        echo "$(color "cyan" "[o]: ${MENU6}")"
        echo "$(color "white" "[e]: ${MENU7}")"
        echo "$(color "white_black" "[d]: ${MENU8}")"
        echo "$(color "white" "-------------------------------------------------------")"
        read -p "$(color "white" "Select an option: ")" option
        case "${option}" in
            "i") menu_option "${MENU1}" "${TARGET1}" "${BASE_URL}${TARGET1}" ;;
            "s") menu_option "${MENU2}" "${TARGET2}" "${BASE_URL}${TARGET2}" ;;
            "p") menu_option "${MENU3}" "${TARGET3}" "${BASE_URL}${TARGET3}" ;;
            "b") menu_option "${MENU4}" "${TARGET4}" "${BASE_URL}${TARGET4}" ;;
            "a") menu_option "${MENU5}" "${TARGET5}" "${BASE_URL}${TARGET5}" ;;
            "o") menu_option "${MENU6}" "${TARGET6}" "${BASE_URL}${TARGET6}" ;;
            "e") menu_option "${MENU7}" "${TARGET7}" "${TARGET7}" ;;
            "d") menu_option "${MENU8}" "${TARGET8}" "${TARGET8}" ;;
            *) echo "$(color "red" "Invalid option. Please try again.")" ;;  # 無効な選択肢
        esac
    done
}

# Execute the necessary functions
check_openwrt_version
color_code
display_system_info
main_menu
