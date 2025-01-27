#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main/"
BASE_DIR="/tmp/aios/"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"

download_common() {
    if [ ! -f "${BASE_DIR}common-functions.sh" ]; then
        wget --no-check-certificate -O "${BASE_DIR}common-functions.sh" "${BASE_URL}common-functions.sh"
    fi
    # shellcheck source=/dev/null
    source "${BASE_DIR}common-functions.sh"
}

ask_confirmation() {
    local message="$1"
    while true; do
        if [ "${SELECTED_LANGUAGE}" = "ja" ]; then
            read -p "$(color "white" "${message} [y/n]: ")" choice
        else
            read -p "$(color "white" "${message} [y/n]: ")" choice
        fi
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
    
    echo -e "$(color "blue" "Downloading and executing: ${script_name}")"
    
    if ask_confirmation "$(if [ "${SELECTED_LANGUAGE}" = "ja" ]; then echo "このスクリプトをダウンロードして実行しますか？"; else echo "Do you want to download and execute ${script_name}?"; fi)"; then
        if wget --no-check-certificate -O "${BASE_DIR}${script_name}" "${url}"; then
            echo -e "$(color "green" "Download successful.")"
            sh "${BASE_DIR}${script_name}"
        else
            echo -e "$(color "red" "Download failed.")"
        fi
    else
        echo -e "$(color "yellow" "Download aborted.")"
    fi
}

exit_end() {
    if ask_confirmation "$(if [ "${SELECTED_LANGUAGE}" = "ja" ]; then echo "本当にスクリプトを終了しますか？"; else echo "Are you sure you want to exit the script?"; fi)"; then
        echo -e "$(color "white" "Exiting script.")"
        exit 0
    else
        echo -e "$(color "green" "Aborted exit.")"
    fi
}

delete_and_exit() {
    if ask_confirmation "$(if [ "${SELECTED_LANGUAGE}" = "ja" ]; then echo "スクリプトを削除して終了しますか？"; else echo "Are you sure you want to delete the script and exit?"; fi)"; then
        echo -e "$(color "red" "Deleting script and exiting.")"
        rm -rf "${BASE_DIR}" /usr/bin/aios /tmp/aios-config.sh
        exit 0
    else
        echo -e "$(color "green" "Aborted deletion.")"
    fi
}

display_system_info() {
    local available_memory=$(free | awk '/Mem:/ { print int($4 / 1024) }')
    local available_flash=$(df | awk '/overlayfs:\/overlay/ { print int($4 / 1024) }')
    local usb_devices=$(ls /sys/bus/usb/devices | grep -q usb && echo "Detected" || echo "Not detected")

    if [ "${SELECTED_LANGUAGE}" = "ja" ]; then
        INFO1="利用可能メモリー"
        INFO2="利用可能フラッシュストレージ"
        INFO3="USBデバイス"
        INFO4="スクリプトディレクトリ"
        INFO5="OpenWrtバージョン"
        INFO6="選択言語"
        INFO7="ダウンローダー"
    else
        INFO1="Available Memory"
        INFO2="Available Flash Storage"
        INFO3="USB Devices"
        INFO4="Scripts directory"
        INFO5="OpenWrt version"
        INFO6="Selected language"
        INFO7="Downloader"
    fi

    echo -e "$(color "white" "${INFO1}: ${available_memory} MB")"
    echo -e "$(color "white" "${INFO2}: ${available_flash} MB")"
    echo -e "$(color "white" "${INFO3}: ${usb_devices}")"
    echo -e "$(color "white" "${INFO4}: ${BASE_DIR}")"
    echo -e "$(color "white" "${INFO5}: ${RELEASE_VERSION} - Supported")"
    echo -e "$(color "white" "${INFO6}: ${SELECTED_LANGUAGE}")"
    echo -e "$(color "white" "${INFO7}: ${PACKAGE_MANAGER})"
}

menu_option() {
    local description="$1"
    local script_name="$2"
    local url="$3"
    echo -e "$(color "white" "${description}")"
    download_and_execute "${script_name}" "${url}"
}

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
        SELECT_PROMPT="Select an option"
    elif [ "${SELECTED_LANGUAGE}" = "ja" ]; then
        MENU1="インターネット設定"
        MENU2="システム初期設定"
        MENU3="推奨パッケージインストール"
        MENU4="広告ブロッカーインストール設定"
        MENU5="アクセスポイント設定"
        MENU6="その他のスクリプト設定"
        MENU00="スクリプト終了"
        MENU01="スクリプト削除終了"
        SELECT_PROMPT="オプションを選択してください"
    fi

    TARGET1="internet-config.sh"
    TARGET2="system-config.sh"
    TARGET3="package-config.sh"
    TARGET4="ad-dns-blocking-config.sh"
    TARGET5="accesspoint-config.sh"
    TARGET6="etc-config.sh"
    TARGET00="exit_script"
    TARGET01="delete_and_exit"
    
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
        read -p "$(color "white" "${SELECT_PROMPT}: ")" option
        case "${option}" in
            "i") menu_option "${MENU1}" "${TARGET1}" "${BASE_URL}${TARGET1}" ;;
            "s") menu_option "${MENU2}" "${TARGET2}" "${BASE_URL}${TARGET2}" ;;
            "p") menu_option "${MENU3}" "${TARGET3}" "${BASE_URL}${TARGET3}" ;;
            "b") menu_option "${MENU4}" "${TARGET4}" "${BASE_URL}${TARGET4}" ;;
            "a") menu_option "${MENU5}" "${TARGET5}" "${BASE_URL}${TARGET5}" ;;
            "o") menu_option "${MENU6}" "${TARGET6}" "${BASE_URL}${TARGET6}" ;;
            "e") menu_option "${MENU00}" "${TARGET00}" "${BASE_URL}${TARGET00}" ;;
            "d") menu_option "${MENU01}" "${TARGET01}" "${BASE_URL}${TARGET01}" ;;
            *) echo -e "$(color "red" "Invalid option. Please try again.")" ;;
        esac
    done
}

download_common
check_common "$1"
display_system_info
main_menu
