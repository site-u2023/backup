#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_URL="https://raw.githubusercontent.com/site-u2023/config-software2/main/"
BASE_DR="/etc/config-software2/"

# Download and load main colors
wget --no-check-certificate -O "${BASE_DR}main_colors.sh" "${BASE_URL}main_colors.sh"
. "${BASE_DR}main_colors.sh"

# Function to handle downloading and executing scripts
download_and_execute() {
    local script_name="$1"
    local url="$2"
    echo -e "$(color "blue" "Downloading and executing: ${script_name}")"
    
    # Attempt to download the script
    if wget --no-check-certificate -O "${BASE_DR}${script_name}" "${url}"; then
        echo -e "$(color "green" "Download successful.")"
        # Execute the downloaded script
        sh "${BASE_DR}${script_name}"
    else
        echo -e "$(color "red" "Download failed.")"
    fi
}

# Reusable function for menu options with description and script download
menu_option() {
    local description="$1"
    local script_name="$2"
    local url="$3"
    echo -e "$(color "white" "${description}")"
    read -p "$(color "white" "Do you want to proceed? [y/n]: ")" choice
    case "${choice}" in
        "y") download_and_execute "${script_name}" "${url}" ;;
        "n") return ;;
        *) echo -e "$(color "red" "Invalid option. Please try again.")" ;;
    esac
}

# Function to delete the script and exit
delete_and_exit() {
    echo -e "$(color "red" "Deleting script and exiting.")"
    rm -rf "${BASE_DR}" /usr/bin/confsoft
    exit
}

# Check OpenWrt version
check_openwrt_version() {
    local supported_versions="19 21 22 23 24 SN"
    local release=$(grep 'DISTRIB_RELEASE' /etc/openwrt_release | cut -d"'" -f2 | cut -c 1-2)
    if echo "${supported_versions}" | grep -q "${release}"; then
        echo -e "$(color "white" "OpenWrt version: ${release} - Supported")"
    else
        echo -e "$(color "red" "Unsupported OpenWrt version: ${release}")"
        echo -e "$(color "white" "Supported versions: ${supported_versions}")"
        exit 1
    fi
}

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

    echo -e "$(color "white" "Information")"
    echo -e "$(color "white" "Available Memory: ${available_memory} MB")"
    echo -e "$(color "white" "Available Flash Storage: ${available_flash} MB")"
    echo -e "$(color "white" "USB Devices: ${usb_devices}")"
    echo -e "$(color "white" "Directory to install scripts: /etc/config-software/")"
    echo -e "$(color "red_white" "Disclaimer: Use this script at your own risk.")"
}

# Define Language Selections
LANGUAGES='"en" "ja"'
SELECTED_LANGUAGE="en"  # Default language

# Function to select language
select_language() {
    echo -e "$(color "white" "Select your language:")"
    echo -e "$(color "blue" "[e]: English")"
    echo -e "$(color "green" "[j]: 日本語")"
    read -p "$(color "white" "Choose an option [e/j]: ")" lang_choice
    case "${lang_choice}" in
        "e") SELECTED_LANGUAGE="en" ;;
        "j") SELECTED_LANGUAGE="ja" ;;
        *) echo -e "$(color "red" "Invalid choice, defaulting to English.")" ;;
    esac
}

# Function to display the main menu with language selection
main_menu() {
    select_language

    # Set language-dependent text for menu
    if [ "${SELECTED_LANGUAGE}" = "en" ]; then
        MENU0="All-in-One Scripts Menu"
        MENU1="Internet settings (Japan Only)" 
        MENU2="Initial System Settings"
        MENU3="Recommended Package Installation"
        MENU4="Ad blocker installation settings"
        MENU5="Access Point Settings"
        MENU6="Other Script Settings"
        MENU00="Exit Script"
        MENU01="Remove script and exit"
    elif [ "${SELECTED_LANGUAGE}" = "ja" ]; then
        MENU0="オールインワンスクリプトメニュー"
        MENU1="インターネット設定"
        MENU2="システム初期設定"
        MENU3="推奨パッケージインストール"  
        MENU4="広告ブロッカーインストール設定" 
        MENU5="アクセスポイント設定"
        MENU6="その他のスクリプト設定"
        MENU00="スクリプト終了"
        MENU01="スクリプト削除終了"
    fi

    TARGET1="internet-config.sh"
    TARGET2="system-config.sh"
    TARGET3="package-config.sh"
    TARGET4="ad-dns-blocking-config.sh"
    TARGET5="accesspoint-config.sh"
    TARGET6="etc-config.sh"
    TARGET00="exit"
    TARGET01="delete_and_exit"
    
    while :; do
        echo -e "$(color "white" "-------------------------------------------------------")"
        echo -e "$(color "white" "${MENU0}")"
        echo -e "$(color "blue" "[i]: ${MENU1}")"
        echo -e "$(color "yellow" "[s]: ${MENU2}")"
        echo -e "$(color "green" "[p]: ${MENU3}")"
        echo -e "$(color "magenta" "[b]: ${MENU4}")"
        echo -e "$(color "red" "[a]: ${MENU5}")"
        echo -e "$(color "cyan" "[o]: ${MENU6}")"
        echo -e "$(color "white" "[e]: ${MENU00}")"
        echo -e "$(color "white_black" "[d]: ${MENU01}")"
        echo -e "$(color "white" "-------------------------------------------------------")"
        read -p "$(color "white" "Select an option: ")" option
        case "${option}" in
            "i") menu_option "${MENU1}" "${TARGET1}" "${BASE_URL}${TARGET1}?lang=${SELECTED_LANGUAGE}" ;;
            "s") menu_option "${MENU2}" "${TARGET2}" "${BASE_URL}${TARGET2}?lang=${SELECTED_LANGUAGE}" ;;
            "p") menu_option "${MENU3}" "${TARGET3}" "${BASE_URL}${TARGET3}?lang=${SELECTED_LANGUAGE}" ;;
            "b") menu_option "${MENU4}" "${TARGET4}" "${BASE_URL}${TARGET4}?lang=${SELECTED_LANGUAGE}" ;;
            "a") menu_option "${MENU5}" "${TARGET5}" "${BASE_URL}${TARGET5}?lang=${SELECTED_LANGUAGE}" ;;
            "o") menu_option "${MENU6}" "${TARGET6}" "${BASE_URL}${TARGET6}?lang=${SELECTED_LANGUAGE}" ;;
            "e") exit ;;
            "d") delete_and_exit ;;
            *) echo -e "$(color "red" "Invalid option. Please try again.")" ;;
        esac
    done
}

# Execute the necessary functions
check_openwrt_version
color_code
display_system_info
main_menu
