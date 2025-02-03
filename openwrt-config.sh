#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# 202502022215-3
# openwrt-config.sh
#
# このスクリプトは、OpenWrt 用のメインメニューおよびシステム情報表示、
# 各種設定スクリプトの起動などを行うためのメインスクリプトです。
#
# ・国・ゾーン情報スクリプト (country-zone.sh) のダウンロード
# ・共通関数 (common-functions.sh) のダウンロードと読み込み
# ・システム情報の取得と表示
# ・メインメニューの表示とユーザーによる各種オプションの選択
echo openwrt-config.sh Last update 202502031417-8

# 定数の設定
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"
SUPPORTED_LANGUAGES="en ja zh-cn zh-tw id ko de ru"
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

    # USB接続状況に応じて表示
    if lsusb >/dev/null 2>&1; then
        USB_STATUS_RESULT="$USB_STATUS"
    else
        USB_STATUS_RESULT="$USB_STATUS_NOT"
    fi

    full_info=$(country_full_info)
}

XXXXX_get_system_info() {
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
    full_info=$(country_full_info)
}

#########################################################################
# display_info
#  システム情報 (メモリ、フラッシュ、USB 状態、ディレクトリ、OpenWrt バージョン、ゾーン名、ダウンローダー) を
#  言語に応じて表示する。
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
    esac
}

#########################################################################
# main_menu
#  メインメニューを表示し、ユーザーの選択を受け付ける。
#  各メニュー項目の選択に応じて、対応する処理 (menu_option) を呼び出す。
#########################################################################
main_menu() {
    local lang="$SELECTED_LANGUAGE"
    local MENU1 MENU2 MENU3 MENU4 MENU5 MENU6 MENU00 MENU01 MENU02 SELECT1
    local ACTION1 ACTION2 ACTION3 ACTION4 ACTION5 ACTION6 ACTION00 ACTION01 ACTION02
    local TARGET1 TARGET2 TARGET3 TARGET4 TARGET5 TARGET6 TARGET00 TARGET01 TARGET02
    local option

    case "$lang" in
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
            MENU03="リセット"
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
            MENU03="重置"
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
            MENU03="重設"
            SELECT1="選擇一個選項: "
            ;;
        id)
            MENU1="Pengaturan Internet"
            MENU2="Pengaturan Sistem Awal"
            MENU3="Instalasi Paket yang Direkomendasikan"
            MENU4="Pengaturan Instalasi Pemblokir Iklan"
            MENU5="Pengaturan Titik Akses"
            MENU6="Pengaturan Skrip Lainnya"
            MENU00="Keluar dari Skrip"
            MENU01="Hapus skrip dan keluar"
            MENU02="Kode Negara"
            MENU03="Reset"
            SELECT1="Silakan pilih: "
            ;;
        ko)
            MENU1="인터넷 설정"
            MENU2="시스템 초기 설정"
            MENU3="추천 패키지 설치"
            MENU4="광고 차단기 설치 설정"
            MENU5="액세스 포인트 설정"
            MENU6="기타 스크립트 설정"
            MENU00="스크립트 종료"
            MENU01="스크립트 삭제 및 종료"
            MENU02="국가 코드"
            MENU03="리셋"
            SELECT1="옵션을 선택하세요: "
            ;;
        de)
            MENU1="Interneteinstellungen"
            MENU2="Erste Systemeinstellungen"
            MENU3="Empfohlene Paketinstallation"
            MENU4="Einstellungen für Werbeblocker-Installation"
            MENU5="Zugangspunkt-Einstellungen"
            MENU6="Andere Skripteinstellungen"
            MENU00="Skript beenden"
            MENU01="Skript löschen und beenden"
            MENU02="Ländercode"
            MENU03="Zurücksetzen"
            SELECT1="Bitte wählen Sie eine Option: "
            ;;
        ru)
            MENU1="Настройки Интернета"
            MENU2="Первоначальные настройки системы"
            MENU3="Рекомендуемая установка пакетов"
            MENU4="Настройки установки блокировщика рекламы"
            MENU5="Настройки точки доступа"
            MENU6="Другие настройки скриптов"
            MENU00="Выход из скрипта"
            MENU01="Удалить скрипт и выйти"
            MENU02="Код страны"
            MENU03="Сброс"
            SELECT1="Пожалуйста, выберите опцию: "
            ;;
         en|*) # 英語とその他すべての未定義言語の処理
            MENU1="Internet settings (Japan Only)"
            MENU2="Initial System Settings"
            MENU3="Recommended Package Installation"
            MENU4="Ad blocker installation settings"
            MENU5="Access Point Settings"
            MENU6="Other Script Settings"
            MENU00="Exit Script"
            MENU01="Remove script and exit"
            MENU02="country code"
            MENU03="reset"
            SELECT1="Select an option: "
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
    ACTION02="download" ; TARGET02="country-zone.sh"
    ACTION03="download" ; TARGET03="aios --reset"
    
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
        option=$(echo "$option" | awk '{gsub(/Ａ/, "A"); gsub(/ａ/, "a"); gsub(/Ｓ/, "S"); gsub(/ｓ/, "s"); print}') # 入力を半角に変換
        #option=$(echo "$option" | iconv -f UTF-8 -t ASCII//TRANSLIT)
        #option=$(echo "$option" | tr 'Ａ-Ｚａ-ｚ０-９' 'A-Za-z0-9')
        case "${option}" in
            "i") menu_option "${ACTION1}" "${MENU1}" "${TARGET1}" ;;
            "s") menu_option "${ACTION2}" "${MENU2}" "${TARGET2}" ;;
            "p") menu_option "${ACTION3}" "${MENU3}" "${TARGET3}" ;;
            "b") menu_option "${ACTION4}" "${MENU4}" "${TARGET4}" ;;
            "a") menu_option "${ACTION5}" "${MENU5}" "${TARGET5}" ;;
            "o") menu_option "${ACTION6}" "${MENU6}" "${TARGET6}" ;;
            "e") menu_option "${ACTION00}" "${MENU00}" ;;
            "d") menu_option "${ACTION01}" "${MENU01}" ;;
            "cz") menu_option "${ACTION02}" "${MENU02}" "${TARGET02}" ;;
            "reset") menu_option "${ACTION03}" "${MENU03}" "${TARGET03}" ;;
            *) echo -e "$(color "red" "Invalid option. Please try again.")" ;;
        esac
    done
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
