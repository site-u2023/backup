#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"
SUPPORTED_LANGUAGES="en ja zh-cn zh-tw"

download_country_zone() {
    if [ ! -f "${BASE_DIR%/}/country-timezone.sh" ]; then
        wget --quiet -O "${BASE_DIR%/}/country-timezone.sh" "${BASE_URL}/country-timezone.sh" || {
            echo "Failed to download country-timezone.sh"
            exit 1
        }
    fi

    if [ ! -f "${BASE_DIR%/}/country-zonename.sh" ]; then
        wget --quiet -O "${BASE_DIR%/}/country-zonename.sh" "${BASE_URL}/country-zonename.sh" || {
            echo "Failed to download country-zonename.sh"
            source "${BASE_DIR%/}/common-functions.sh"
            exit 1
        }
    fi
}

download_and_execute_common() {
    if [ ! -f "${BASE_DIR%/}/common-functions.sh" ]; then
        wget --quiet -O "${BASE_DIR%/}/common-functions.sh" "${BASE_URL}/common-functions.sh" || {
            echo "Failed to download common-functions.sh"
            exit 1
        }
    fi

    source "${BASE_DIR%/}/common-functions.sh" || {
        echo "Failed to source common-functions.sh"
        exit 1
    }
}

get_system_info() {
    MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2 / 1024 " MB"}')
    MEM_FREE=$(grep MemAvailable /proc/meminfo | awk '{print $2 / 1024 " MB"}')
    MEM_USAGE="${MEM_FREE} / ${MEM_TOTAL}"

    FLASH_INFO=$(df -h | grep '/overlay' | head -n 1 | awk '{print $4 " / " $2}')

    if lsusb >/dev/null 2>&1; then
        USB_STATUS_EN="Detected"
        USB_STATUS_JA="検出済み"
        USB_STATUS_ZH_CN="已检测"
        USB_STATUS_ZH_TW="已檢測"
    else
        USB_STATUS_EN="Not Detected"
        USB_STATUS_JA="未検出"
        USB_STATUS_ZH_CN="未检测"
        USB_STATUS_ZH_TW="未檢測"
    fi
}

display_info() {
    case "$SELECTED_LANGUAGE" in
        en)
            echo -e "$(color "white" "Memory (Free/Total): ${MEM_USAGE}")"
            echo -e "$(color "white" "Flash (Free/Total): ${FLASH_INFO}")"
            echo -e "$(color "white" "USB: ${USB_STATUS_EN}")"
            echo -e "$(color "white" "Directory: ${BASE_DIR}")"
            echo -e "$(color "white" "OpenWrt Version: ${RELEASE_VERSION}")"
            echo -e "$(color "white" "Zonename: ${ZONENAME}")"
            echo -e "$(color "white" "Downloader: ${PACKAGE_MANAGER}")"
            ;;
        ja)
            echo -e "$(color "white" "メモリ (残量/総容量): ${MEM_USAGE}")"
            echo -e "$(color "white" "フラッシュ (残量/総容量): ${FLASH_INFO}")"
            echo -e "$(color "white" "USB: ${USB_STATUS_JA}")"
            echo -e "$(color "white" "ディレクトリ: ${BASE_DIR}")"
            echo -e "$(color "white" "OpenWrtバージョン: ${RELEASE_VERSION}")"
            echo -e "$(color "white" "ゾーン名: ${ZONENAME}")"
            echo -e "$(color "white" "ダウンローダー: ${PACKAGE_MANAGER}")"
            ;;
        zh-cn)
            echo -e "$(color "white" "内存 (剩余/总计): ${MEM_USAGE}")"
            echo -e "$(color "white" "闪存 (剩余/总计): ${FLASH_INFO}")"
            echo -e "$(color "white" "USB: ${USB_STATUS_ZH_CN}")"
            echo -e "$(color "white" "目录: ${BASE_DIR}")"
            echo -e "$(color "white" "OpenWrt版本: ${RELEASE_VERSION}")"
            echo -e "$(color "white" "区域名称: ${ZONENAME}")"
            echo -e "$(color "white" "下载器: ${PACKAGE_MANAGER}")"
            ;;
        zh-tw)
            echo -e "$(color "white" "記憶體 (剩餘/總計): ${MEM_USAGE}")"
            echo -e "$(color "white" "快閃記憶體 (剩餘/總計): ${FLASH_INFO}")"
            echo -e "$(color "white" "USB: ${USB_STATUS_ZH_TW}")"
            echo -e "$(color "white" "目錄: ${BASE_DIR}")"
            echo -e "$(color "white" "OpenWrt版本: ${RELEASE_VERSION}")"
            echo -e "$(color "white" "區域名稱: ${ZONENAME}")"
            echo -e "$(color "white" "下載器: ${PACKAGE_MANAGER}")"
            ;;
        *)
            echo -e "$(color "white" "Memory (Free/Total): ${MEM_USAGE}")"
            echo -e "$(color "white" "Flash (Free/Total): ${FLASH_INFO}")"
            echo -e "$(color "white" "USB: ${USB_STATUS_EN}")"
            echo -e "$(color "white" "Directory: ${BASE_DIR}")"
            echo -e "$(color "white" "OpenWrt Version: ${RELEASE_VERSION}")"
            echo -e "$(color "white" "Zonename: ${ZONENAME}")"
            echo -e "$(color "white" "Downloader: ${PACKAGE_MANAGER}")"
            ;;
    esac
}

main_menu() {
    local lang="$SELECTED_LANGUAGE" 
    local MENU1 MENU2 MENU3 MENU4 MENU5 MENU6 MENU00 MENU01 MENU02 SELECT1
    local ACTION1 ACTION2 ACTION3 ACTION4 ACTION5 ACTION6 ACTION00 ACTION01 ACTION02
    local TARGET1 TARGET2 TARGET3 TARGET4 TARGET5 TARGET6 TARGET00 TARGET01 TARGET02
    local option
    
    case "$lang" in
        en)
            MENU1="Internet settings (Japan Only)"
            MENU2="Initial System Settings"
            MENU3="Recommended Package Installation"
            MENU4="Ad blocker installation settings"
            MENU5="Access Point Settings"
            MENU6="Other Script Settings"
            MENU00="Exit Script"
            MENU01="Remove script and exit"
            MENU02="country code"
            SELECT1="Select an option: "
            ;;
        ja)
            MENU1="インターネット設定"
            MENU2="システム初期設定"
            MENU3="推奨パッケージインストール"
            MENU4="広告ブロッカーインストール設定"
            MENU5="アクセスポイント設定"
            MENU6="その他のスクリプト設定"
            MENU00="スクリプト終了"
            MENU01="スクリプト削除終了"
            MENU02="カントリーコード"
            SELECT1="選択してください: "
            ;;
        zh-cn)
            MENU1="互联网设置 (陕西一地区)"
            MENU2="系统初始设置"
            MENU3="推荐安装包"
            MENU4="广告拦截器设置"
            MENU5="访问点设置"
            MENU6="其他脚本设置"
            MENU00="退出脚本"
            MENU01="删除脚本并退出"
            MENU02="国码"
            SELECT1="选择一个选项: "
            ;;
        zh-tw)
            MENU1="網路設定 (日本限定)"
            MENU2="系統初始設定"
            MENU3="推薦包對應"
            MENU4="廣告防錯設定"
            MENU5="連線點設定"
            MENU6="其他脚本設定"
            MENU00="退出脚本"
            MENU01="移除脚本並退出"
            MENU02="國碼"
            SELECT1="選擇一個選項: "
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
    ACTION02="download" ; TARGET02="country_timezone.sh"

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
            "cc") menu_option "${ACTION02}" "${MENU02}" "${TARGET02}" ;;
            *) echo -e "$(color "red" "Invalid option. Please try again.")" ;;
        esac
    done
}

download_country_zone
download_and_execute_common
check_common "$1"
country_zone
get_system_info
display_info
main_menu
