#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main/"
BASE_DIR="/tmp/aios/"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"

main_menu() {
    if [ "${SELECTED_LANGUAGE}" = "en" ]; then
        MENU1="Internet settings (Japan Only)" 
        MENU2="Initial System Settings"
        MENU3="Recommended Package Installation"
        MENU4="Ad blocker installation settings"
        MENU5="Access Point Settings"
        MENU6="Other Script Settings"
        MENU00="Exit Script"
        MENU01="Remove script and exit"
        SELECT="Select an option: "
    elif [ "${SELECTED_LANGUAGE}" = "ja" ]; then
        MENU1="インターネット設定"
        MENU2="システム初期設定"
        MENU3="推奨パッケージインストール"  
        MENU4="広告ブロッカーインストール設定" 
        MENU5="アクセスポイント設定"
        MENU6="その他のスクリプト設定"
        MENU00="スクリプト終了"
        MENU01="スクリプト削除終了"
        SELECT1="選択してください: "
    fi

    TARGET1="internet-config.sh"
    TARGET2="system-config.sh"
    TARGET3="package-config.sh"
    TARGET4="ad-dns-blocking-config.sh"
    TARGET5="accesspoint-config.sh"
    TARGET6="etc-config.sh"
    TARGET00="exit_script.sh"
    TARGET01="delete_and_exit.sh"
    
    while :; do
        echo -e "$(color "white" "------------------------------------------------------")"
        echo -e "$(color "blue" "[i]: ${MENU1}")"
        echo -e "$(color "yellow" "[s]: ${MENU2}")"
        echo -e "$(color "green" "[p]: ${MENU3}")"
        echo -e "$(color "magenta" "[b]: ${MENU4}")"
        echo -e "$(color "red" "[a]: ${MENU5}")"
        echo -e "$(color "cyan" "[o]: ${MENU6}")"
        echo -e "$(color "white" "[e]: ${MENU00}")"
        echo -e "$(color "white_black" "[d]: ${MENU01}")"
        echo -e "$(color "white" "------------------------------------------------------")"
        read -p "$(color "white" "${SELECT1}")" option
        case "${option}" in
            "i") menu_option "${MENU1}" "${TARGET1}" "${BASE_URL}${TARGET1}" ;;
            "s") menu_option "${MENU2}" "${TARGET2}" "${BASE_URL}${TARGET2}" ;;
            "p") menu_option "${MENU3}" "${TARGET3}" "${BASE_URL}${TARGET3}" ;;
            "b") menu_option "${MENU4}" "${TARGET4}" "${BASE_URL}${TARGET4}" ;;
            "a") menu_option "${MENU5}" "${TARGET5}" "${BASE_URL}${TARGET5}" ;;
            "o") menu_option "${MENU6}" "${TARGET6}" "${BASE_URL}${TARGET6}" ;;
            "e") exit_end ;;
            "d") delete_and_exit ;;
            *) echo -e "$(color "red" "Invalid option. Please try again.")" ;;
        esac
    done
}

download_common() {
    if [ ! -f "${BASE_DIR}common-functions.sh" ]; then
        wget --no-check-certificate --quiet -O "${BASE_DIR}common-functions.sh" "${BASE_URL}common-functions.sh"

    fi
    # shellcheck source=/dev/null
    . "${BASE_DIR}common-functions.sh"
}

ask_confirmation() {
    local message_key="$1"
    local message

    if [ "${SELECTED_LANGUAGE}" = "en" ]; then
        case "$message_key" in
            "download") message="Execute?" ;;
            "exit") message="Exit?" ;;
            "delete") message="Delete the script and exit?" ;;
            *) message="Execute?" ;;
        esac
    elif [ "${SELECTED_LANGUAGE}" = "ja" ]; then
        case "$message_key" in
            "download") message="実行します" ;;
            "exit") message="終了します" ;;
            "delete") message="スクリプトを削除して終了します" ;;
            *) message="実行します" ;;
        esac
    fi

    echo -e "$(color "white" "${message} [y/n]:")"
    
    while true; do
        read -p "" choice
        case "${choice}" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo -e "$(color "red" "Invalid choice, please enter 'y' or 'n'.")" ;;
        esac
    done
}

download_and_execute() {
    mkdir -p "$BASE_DIR"
    local script_name="$1"
    local url="$2"
    
    if ask_confirmation "download"; then
        if wget --no-check-certificate --quiet -O "${BASE_DIR}${script_name}" "${url}"; then
            echo -e "$(color "green" "Download successful.")"
            . "${BASE_DIR}${script_name}"
        else
            echo -e "$(color "red" "Download failed.")"
        fi
    else
        echo -e "$(color "yellow" "Download aborted.")"
    fi
}


menu_option() {
    local description="$1"
    local script_name="$2"
    local url="$3"
    echo -e "$(color "white" "${description}")"
    download_and_execute "${script_name}" "${url}"
}

exit_end() {
    local description="Exit Script"
    echo -e "$(color "white" "${description}")"
    if ask_confirmation "exit"; then
        exit 0
    else
        echo -e "$(color "yellow" "Exit cancelled.")"
    fi
}

delete_and_exit() {
    local description="Delete and Exit"
    echo -e "$(color "white" "${description}")"
    if ask_confirmation "delete"; then
        rm -rf "${BASE_DIR}" /usr/bin/aios /tmp/aios-config.sh
        echo -e "$(color "green" "Script and configuration deleted.")"
        exit 0
    else
        echo -e "$(color "yellow" "Delete cancelled.")"
    fi
}

display_system_info() {
    local available_memory=$(free | awk '/Mem:/ { print int($4 / 1024) }')
    local available_flash=$(df | awk '/overlayfs:\/overlay/ { print int($4 / 1024) }')
    local usb_devices=$(ls /sys/bus/usb/devices | grep -q usb && echo "Detected" || echo "Not detected")

    echo -e "$(color "white" "Available Memory: ${available_memory} MB")"
    echo -e "$(color "white" "Available Flash Storage: ${available_flash} MB")"
    echo -e "$(color "white" "USB Devices: ${usb_devices}")"
    echo -e "$(color "white" "Scripts directory: ${BASE_DIR}")"
    echo -e "$(color "white" "OpenWrt version: ${RELEASE_VERSION} - Supported")"
    echo -e "$(color "white" "Selected language: ${SELECTED_LANGUAGE}")"
    echo -e "$(color "white" "Downloader: ${PACKAGE_MANAGER}")"
}

download_common
check_common "$1"
display_system_info
main_menu
