#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"

main_menu() {
    local lang="${SELECTED_LANGUAGE:-en}" 
    local MENU1 MENU2 MENU3 MENU4 MENU5 MENU6 MENU00 MENU01 SELECT1
    local ACTION1 ACTION2 ACTION3 ACTION4 ACTION5 ACTION6 ACTION00 ACTION01
    local TARGET1 TARGET2 TARGET3 TARGET4 TARGET5 TARGET6 TARGET00 TARGET01
    local option

    case "$lang" in
        "en")
            MENU1="Internet settings (Japan Only)" 
            MENU2="Initial System Settings"
            MENU3="Recommended Package Installation"
            MENU4="Ad blocker installation settings"
            MENU5="Access Point Settings"
            MENU6="Other Script Settings"
            MENU00="Exit Script"
            MENU01="Remove script and exit"
            SELECT1="Select an option: "
            ;;
        "ja")
            MENU1="インターネット設定"
            MENU2="システム初期設定"
            MENU3="推奨パッケージインストール"  
            MENU4="広告ブロッカーインストール設定" 
            MENU5="アクセスポイント設定"
            MENU6="その他のスクリプト設定"
            MENU00="スクリプト終了"
            MENU01="スクリプト削除終了"
            SELECT1="選択してください: "
            ;;
        *)
            echo "Invalid language selected: $lang"
            exit 1
            ;;
    esac

    ACTION1="download" ; TARGET1="internet-config.sh"
    ACTION2="download" ; TARGET2="system-config.sh"
    ACTION3="download" ; TARGET3="package-config.sh"
    ACTION4="download" ; TARGET4="ad-dns-blocking-config.sh"
    ACTION5="download" ; TARGET5="accesspoint-config.sh"
    ACTION6="download" ; TARGET6="etc-config.sh"
    ACTION00="exit"
    ACTION01="delete"
    
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
            "i") menu_option "${ACTION1}" "${MENU1}" "${TARGET1}" ;;
            "s") menu_option "${ACTION2}" "${MENU2}" "${TARGET2}" ;;
            "p") menu_option "${ACTION3}" "${MENU3}" "${TARGET3}" ;;
            "b") menu_option "${ACTION4}" "${MENU4}" "${TARGET4}" ;;
            "a") menu_option "${ACTION5}" "${MENU5}" "${TARGET5}" ;;
            "o") menu_option "${ACTION6}" "${MENU6}" "${TARGET6}" ;;
            "e") menu_option "${ACTION00}" "${MENU00}" ;;
            "d") menu_option "${ACTION01}" "${MENU01}" ;;
            "c") color_code ;;
            *) echo -e "$(color "red" "Invalid option. Please try again.")" ;;
        esac
    done
}

download_common() {
    if [ ! -f "${BASE_DIR}/common-functions.sh" ]; then
        wget --no-check-certificate --quiet -O "${BASE_DIR}/common-functions.sh" "${BASE_URL}/common-functions.sh"
    fi
    source "${BASE_DIR}/common-functions.sh"
}

display_system_info() {
    local lang="${SELECTED_LANGUAGE:-en}" 
    local available_memory=$(free | awk '/Mem:/ { print int($4 / 1024) }')
    local available_flash=$(df | awk '/overlayfs:\/overlay/ { print int($4 / 1024) }')
    local usb_devices=$(ls /sys/bus/usb/devices | grep -q usb && echo "Detected" || echo "Not detected")

    # 言語ごとのメッセージを定義
    declare -A messages
    messages["en_memory"]="Available Memory: ${available_memory} MB"
    messages["en_flash"]="Available Flash Storage: ${available_flash} MB"
    messages["en_usb"]="USB Devices: ${usb_devices}"
    messages["en_dir"]="Scripts directory: ${BASE_DIR}"
    messages["en_version"]="OpenWrt version: ${RELEASE_VERSION} - Supported"
    messages["en_language"]="Selected language: ${SELECTED_LANGUAGE}"
    messages["en_downloader"]="Downloader: ${PACKAGE_MANAGER}"

    messages["ja_memory"]="利用可能メモリ: ${available_memory} MB"
    messages["ja_flash"]="利用可能フラッシュストレージ: ${available_flash} MB"
    messages["ja_usb"]="USBデバイス: ${usb_devices}"
    messages["ja_dir"]="スクリプトディレクトリ: ${BASE_DIR}"
    messages["ja_version"]="OpenWrt バージョン: ${RELEASE_VERSION} - サポートされています"
    messages["ja_language"]="選択された言語: ${SELECTED_LANGUAGE}"
    messages["ja_downloader"]="ダウンローダー: ${PACKAGE_MANAGER}"

    # 他の言語を追加する際は、上記の形式で追加していく

    # 言語別の表示
    case "$lang" in
        "en"|"ja")  # サポートする言語を追加していける
            echo -e "$(color "white" "${messages[${lang}_memory]}")"
            echo -e "$(color "white" "${messages[${lang}_flash]}")"
            echo -e "$(color "white" "${messages[${lang}_usb]}")"
            echo -e "$(color "white" "${messages[${lang}_dir]}")"
            echo -e "$(color "white" "${messages[${lang}_version]}")"
            echo -e "$(color "white" "${messages[${lang}_language]}")"
            echo -e "$(color "white" "${messages[${lang}_downloader]}")"
            ;;
        *)
            echo "Invalid language selected: $lang"
            exit 1
            ;;
    esac
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

download_common
check_common "$1"
display_system_info
main_menu
