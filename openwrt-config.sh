#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# 202502031417-10
# openwrt-config.sh
#
# このスクリプトは、OpenWrt 用のメインメニューおよびシステム情報表示、
# 各種設定スクリプトの起動などを行うためのメインスクリプトです。
#
# ・国・ゾーン情報スクリプト (country-zone.sh) のダウンロード
# ・共通関数 (common-functions.sh) のダウンロードと読み込み
# ・システム情報の取得と表示
# ・メインメニューの表示とユーザーによる各種オプションの選択
echo "openwrt-config.sh Last update 202502031417-14"

# 定数の設定
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"
SUPPORTED_LANGUAGES="en ja zh-cn zh-tw id ko de ru"
INPUT_LANG="$1"

#########################################################################
# download_country_zone
#  国・ゾーン情報スクリプト (country-zone.sh) を BASE_URL からダウンロードする。
#  ダウンロードに失敗した場合は handle_error を呼び出して終了する。
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
#  システム情報 (メモリ、フラッシュ、USB 状態等) を取得し、グローバル変数に設定する。
#########################################################################
get_system_info() {
    local _mem_total _mem_free
    _mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2 / 1024 " MB"}')
    _mem_free=$(grep MemAvailable /proc/meminfo | awk '{print $2 / 1024 " MB"}')
    MEM_USAGE="${_mem_free} / ${_mem_total}"
    FLASH_INFO=$(df -h | grep '/overlay' | head -n 1 | awk '{print $4 " / " $2}')

    local lang="$SELECTED_LANGUAGE"
    case "$lang" in
        ja)
            USB_STATUS="検出済み"
            USB_STATUS_NOT="未検出"
            ;;
        zh-cn)
            USB_STATUS="已检测"
            USB_STATUS_NOT="未检测"
            ;;
        zh-tw)
            USB_STATUS="已檢測"
            USB_STATUS_NOT="未檢測"
            ;;
        id)
            USB_STATUS="Terdeteksi"
            USB_STATUS_NOT="Tidak Terdeteksi"
            ;;
        ko)
            USB_STATUS="감지됨"
            USB_STATUS_NOT="감지되지 않음"
            ;;
        de)
            USB_STATUS="Erkannt"
            USB_STATUS_NOT="Nicht erkannt"
            ;;
        ru)
            USB_STATUS="Обнаружено"
            USB_STATUS_NOT="Не обнаружено"
            ;;
        en|*)
            USB_STATUS="Detected"
            USB_STATUS_NOT="Not Detected"
            ;;
    esac

    if lsusb >/dev/null 2>&1; then
        USB_STATUS_RESULT="$USB_STATUS"
    else
        USB_STATUS_RESULT="$USB_STATUS_NOT"
    fi

    full_info=$(country_full_info)
}

#########################################################################
# display_info
#  システム情報を各言語に応じて表示する。
#########################################################################
display_info() {
    local lang="$SELECTED_LANGUAGE"
    
    case "$lang" in
        ja)
            echo -e "$(color "white" "揮発性主記憶装置 (残量/総容量): ${MEM_USAGE}")"
            echo -e "$(color "white" "不揮発性半導体記憶装置 (残量/総容量): ${FLASH_INFO}")"
            echo -e "$(color "white" "汎用直列伝送路: ${USB_STATUS_JA}")"
            echo -e "$(color "white" "統一資源位置指定子: ${BASE_URL}")"
            echo -e "$(color "white" "階層式記録素子構造: ${BASE_DIR}")"
            echo -e "$(color "white" "オープンダブルアールティー世代: ${RELEASE_VERSION}")"
            echo -e "$(color "white" "国家・言語・地域標準時: $full_info")"
            echo -e "$(color "white" "自動取得処理装置名: ${PACKAGE_MANAGER}")"
            ;;
        zh-cn)
            echo -e "$(color "white" "易失性主存储装置 (剩余/总容量): ${MEM_USAGE}")"
            echo -e "$(color "white" "非易失性半导体存储装置 (剩余/总容量): ${FLASH_INFO}")"
            echo -e "$(color "white" "通用串行传输路径: ${USB_STATUS_ZH_CN}")"
            echo -e "$(color "white" "统一资源定位符: ${BASE_URL}")"
            echo -e "$(color "white" "分层式记录单元结构: ${BASE_DIR}")"
            echo -e "$(color "white" "欧鹏达布里阿尔提版本: ${RELEASE_VERSION}")"
            echo -e "$(color "white" "国家・语言・区域标准时间: $full_info")"
            echo -e "$(color "white" "自动检索处理装置名称: ${PACKAGE_MANAGER}")"
            ;;
        zh-tw)
            echo -e "$(color "white" "揮發性主記憶體裝置 (剩餘/總容量): ${MEM_USAGE}")"
            echo -e "$(color "white" "非揮發性半導體記憶體裝置 (剩餘/總容量): ${FLASH_INFO}")"
            echo -e "$(color "white" "通用串列傳輸路徑: ${USB_STATUS_ZH_TW}")"
            echo -e "$(color "white" "統一資源定位符: ${BASE_URL}")"
            echo -e "$(color "white" "階層式記錄元件結構: ${BASE_DIR}")"
            echo -e "$(color "white" "歐彭達布里阿爾提版本: ${RELEASE_VERSION}")"
            echo -e "$(color "white" "國家・語言・區域標準時間: $full_info")"
            echo -e "$(color "white" "自動取得處理裝置名稱: ${PACKAGE_MANAGER}")"
            ;;
        id)
            echo -e "$(color "white" "Memori Utama Volatil (Sisa/Total): ${MEM_USAGE}")"
            echo -e "$(color "white" "Penyimpanan Semikonduktor Non-Volatil (Sisa/Total): ${FLASH_INFO}")"
            echo -e "$(color "white" "Jalur Transmisi Serial Universal: ${USB_STATUS_ID}")"
            echo -e "$(color "white" "Penentu Lokasi Sumber Daya Seragam: ${BASE_URL}")"
            echo -e "$(color "white" "Struktur Unit Perekaman Berjenjang: ${BASE_DIR}")"
            echo -e "$(color "white" "Versi Open Double R T: ${RELEASE_VERSION}")"
            echo -e "$(color "white" "Pengaturan Standar Waktu Negara-Bahasa-Wilayah: $full_info")"
            echo -e "$(color "white" "Nama Perangkat Pengambil Otomatis: ${PACKAGE_MANAGER}")"
            ;;
        ko)
            echo -e "$(color "white" "휘발성 주기억 장치 (남은 용량/총 용량): ${MEM_USAGE}")"
            echo -e "$(color "white" "비휘발성 반도체 저장 장치 (남은 용량/총 용량): ${FLASH_INFO}")"
            echo -e "$(color "white" "범용 직렬 전송 경로: ${USB_STATUS_KO}")"
            echo -e "$(color "white" "통합 자원 위치 지정자: ${BASE_URL}")"
            echo -e "$(color "white" "계층형 기록 장치 구조: ${BASE_DIR}")"
            echo -e "$(color "white" "오픈더블알티 버전: ${RELEASE_VERSION}")"
            echo -e "$(color "white" "국가・언어・지역 표준시: $full_info")"
            echo -e "$(color "white" "자동 취득 처리 장치: ${PACKAGE_MANAGER}")"
            ;;
        de)
            echo -e "$(color "white" "Flüchtiger Hauptspeicher (Frei/Gesamt): ${MEM_USAGE}")"
            echo -e "$(color "white" "Nichtflüchtiger Halbleiterspeicher (Frei/Gesamt): ${FLASH_INFO}")"
            echo -e "$(color "white" "Universelle Serielle Übertragungsstrecke: ${USB_STATUS_DE}")"
            echo -e "$(color "white" "Einheitlicher Ressourcen-Lokalisierer: ${BASE_URL}")"
            echo -e "$(color "white" "Hierarchische Aufzeichnungsstruktur: ${BASE_DIR}")"
            echo -e "$(color "white" "Open Double R T Version: ${RELEASE_VERSION}")"
            echo -e "$(color "white" "Nationale-Sprachliche-Regionale Zeiteinstellungen: $full_info")"
            echo -e "$(color "white" "Automatische Abrufverarbeitungseinheit: ${PACKAGE_MANAGER}")"
            ;;
        ru)
            echo -e "$(color "white" "Оперативное запоминающее устройство (Свободно/Всего): ${MEM_USAGE}")"
            echo -e "$(color "white" "Неволатильное полупроводниковое хранилище (Свободно/Всего): ${FLASH_INFO}")"
            echo -e "$(color "white" "Универсальная последовательная передача: ${USB_STATUS_RU}")"
            echo -e "$(color "white" "Унифицированный указатель ресурса: ${BASE_URL}")"
            echo -e "$(color "white" "Иерархическая структура записей: ${BASE_DIR}")"
            echo -e "$(color "white" "Версия Оупен Дабл Ар Ти: ${RELEASE_VERSION}")"
            echo -e "$(color "white" "Национальные-Языковые-Региональные настройки времени: $full_info")"
            echo -e "$(color "white" "Автоматизированное устройство получения данных: ${PACKAGE_MANAGER}")"
            ;;
        en|*)
            echo -e "$(color "white" "Volatile Primary Memory (Free/Total): ${MEM_USAGE}")"
            echo -e "$(color "white" "Non-Volatile Semiconductor Storage (Free/Total): ${FLASH_INFO}")"
            echo -e "$(color "white" "Universal Serial Bus: ${USB_STATUS_EN}")"
            echo -e "$(color "white" "Uniform Resource Locator: ${BASE_URL}")"
            echo -e "$(color "white" "Hierarchical File Structure: ${BASE_DIR}")"
            echo -e "$(color "white" "OpenWrt Generation: ${RELEASE_VERSION}")"
            echo -e "$(color "white" "Nation-Language-Regional Standard Time: $full_info")"
            echo -e "$(color "white" "Automated Retrieval Utility: ${PACKAGE_MANAGER}")"
            ;;
    esac
}

#########################################################################
# main_menu
#  メインメニューを表示し、ユーザーの選択を受け付ける。
#########################################################################
#########################################################################
# main_menu
#  メインメニューを表示し、ユーザーの選択を受け付ける。
#########################################################################
main_menu() {
    local lang="$SELECTED_LANGUAGE"
    # 各固定文言はキー名として保持（resolve は menu_option 内または表示時に get_message で取得）
    MENU1="internet_title"
    MENU2="menu_system"
    MENU3="menu_package"
    MENU4="menu_adblock"
    MENU5="menu_ap"
    MENU6="menu_other"
    MENU00="menu_exit"
    MENU01="menu_delete"
    MENU02="country_code"
    MENU03="reset"
    SELECT1="select_prompt"

    local ACTION1 ACTION2 ACTION3 ACTION4 ACTION5 ACTION6 ACTION00 ACTION01 ACTION02 ACTION03
    local TARGET1 TARGET2 TARGET3 TARGET4 TARGET5 TARGET6 TARGET02 TARGET03
    local option

    ACTION1="download" ; TARGET1="internet-config.sh"
    ACTION2="download" ; TARGET2="system-config.sh"
    ACTION3="download" ; TARGET3="package-config.sh"
    ACTION4="download" ; TARGET4="ad-dns-blocking-config.sh"
    ACTION5="download" ; TARGET5="accesspoint-config.sh"
    ACTION6="download" ; TARGET6="etc-config.sh"
    ACTION00="exit"
    ACTION01="delete"
    ACTION02="download" ; TARGET02="country-zone.sh"
    ACTION03="download" ; TARGET03="aios --reset"

    while :; do
        echo -e "$(color "white" "------------------------------------------------------")"
        # 表示用に各キーの文言を取得
        echo -e "$(color "blue" "[i]: $(get_message "$MENU1")")"
        echo -e "$(color "yellow" "[s]: $(get_message "$MENU2")")"
        echo -e "$(color "green" "[p]: $(get_message "$MENU3")")"
        echo -e "$(color "magenta" "[b]: $(get_message "$MENU4")")"
        echo -e "$(color "red" "[a]: $(get_message "$MENU5")")"
        echo -e "$(color "cyan" "[o]: $(get_message "$MENU6")")"
        echo -e "$(color "white" "[e]: $(get_message "$MENU00")")"
        echo -e "$(color "white_black" "[d]: $(get_message "$MENU01")")"
        echo -e "$(color "white" "------------------------------------------------------")"
        read -p "$(color "white" "$(get_message "$SELECT1")")" option

        case "${option}" in
            "i") menu_option "${ACTION1}" "$MENU1" "${TARGET1}" ;;
            "s") menu_option "${ACTION2}" "$MENU2" "${TARGET2}" ;;
            "p") menu_option "${ACTION3}" "$MENU3" "${TARGET3}" ;;
            "b") menu_option "${ACTION4}" "$MENU4" "${TARGET4}" ;;
            "a") menu_option "${ACTION5}" "$MENU5" "${TARGET5}" ;;
            "o") menu_option "${ACTION6}" "$MENU6" "${TARGET6}" ;;
            "e") menu_option "${ACTION00}" "$MENU00" ;;
            "d") menu_option "${ACTION01}" "$MENU01" ;;
            "cz") menu_option "${ACTION02}" "$MENU02" "${TARGET02}" ;;
            "reset") menu_option "${ACTION03}" "$MENU03" "${TARGET03}" ;;
            *) echo -e "$(color "red" "$(get_message invalid_option)")" ;;
        esac
    done
}

#########################################################################
# エントリーポイント
#########################################################################
download_country_zone
download_and_execute_common
check_common "$INPUT_LANG"
country_zone
get_system_info
display_info
main_menu
