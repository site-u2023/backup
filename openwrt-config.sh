#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
#
# openwrt-config.sh
#
# このスクリプトは、OpenWrt 用のメインメニューおよびシステム情報表示、
# 各種設定スクリプトの起動などを行うためのメインスクリプトです。
#
# ・国・ゾーン情報スクリプト (country-zone.sh) のダウンロード
# ・共通関数 (common-functions.sh) のダウンロードと読み込み
# ・システム情報の取得と表示
# ・メインメニューの表示とユーザーによる各種オプションの選択

# 定数の設定
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"
SUPPORTED_LANGUAGES="en ja zh-cn zh-tw"
INPUT_LANG="$1"

#########################################################################
# download_country_zone
#  国・ゾーン情報スクリプト (country-zone.sh)
#  を BASE_URL からダウンロードする。ダウンロードに失敗した場合は
#  handle_error を呼び出して終了する。
#########################################################################
download_country_zone() {
    if [ ! -f "${BASE_DIR%/}/country-zone.sh" ]; then
        wget --quiet -O "${BASE_DIR%/}/country-zone.sh" "${BASE_URL}/country-zone.sh" || \
            handle_error "Failed to download country-zone.sh"
    fi
}

#########################################################################
# download_and_execute_common
#  common-functions.sh を BASE_URL からダウンロードし、読み込む。
#  失敗した場合は handle_error で終了する。
#########################################################################
download_and_execute_common() {
    if [ ! -f "${BASE_DIR%/}/common-functions.sh" ]; then
        wget --quiet -O "${BASE_DIR%/}/common-functions.sh" "${BASE_URL}/common-functions.sh" || \
            handle_error "Failed to download common-functions.sh"
    fi

    source "${BASE_DIR%/}/common-functions.sh" || \
        handle_error "Failed to source common-functions.sh"
}

#########################################################################
# get_system_info
#  システムのメモリ、フラッシュ、USB 状態などの情報を取得し、
#  グローバル変数 MEM_USAGE、FLASH_INFO、USB_STATUS_XXX に設定する。
#########################################################################
get_system_info() {
    local _mem_total _mem_free
    _mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2 / 1024 " MB"}')
    _mem_free=$(grep MemAvailable /proc/meminfo | awk '{print $2 / 1024 " MB"}')
    MEM_USAGE="${_mem_free} / ${_mem_total}"

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

#########################################################################
# display_info
#  システム情報 (メモリ、フラッシュ、USB 状態、ディレクトリ、OpenWrt バージョン、ゾーン名、ダウンローダー) を
#  言語に応じて表示する。
#########################################################################
display_info() {
    local lang="$SELECTED_LANGUAGE"
    
    case "$lang" in
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

#########################################################################
# メイン処理の開始
#  以下の処理を順次実行して、システム情報表示およびメインメニューを起動する。
#########################################################################
download_country_zone
download_and_execute_common
check_common "$INPUT_LANG"
country_zone
get_system_info
display_info
main_menu
