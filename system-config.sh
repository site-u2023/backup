#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
#
# system-config.sh
#
# 本スクリプトは、デバイスの初期設定を行うためのスクリプトです。
# 主な処理内容は以下の通りです：
#  1. 国・ゾーン情報スクリプトのダウンロード
#  2. common-functions.sh のダウンロードと読み込み
#  3. 共通初期化処理 (check_common、country_zone、information) による情報表示
#  4. デバイス名・パスワードの設定 (set_device_name_password)
#  5. Wi-Fi SSID・パスワードの設定 (set_wifi_ssid_password)
#  6. システム全体の設定 (set_device)

# 定数の設定
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="21 22 23 24 SN"
SUPPORTED_LANGUAGES="en ja zh-cn zh-tw"
INPUT_LANG="$1"

#########################################################################
# download_country_zone: 国・ゾーン情報スクリプト (country-zone.sh)
# を BASE_URL からダウンロードする。失敗時は handle_error を呼ぶ。
#########################################################################
download_country_zone() {
    if [ ! -f "${BASE_DIR%/}/country-zone.sh" ]; then
        wget --quiet -O "${BASE_DIR%/}/country-zone.sh" "${BASE_URL}/country-zone.sh" || \
            handle_error "Failed to download country-zone.sh"
    fi
}

#########################################################################
# download_and_execute_common: common-functions.sh をダウンロードし読み込む
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
# information: country_zone で取得済みのゾーン情報 (ZONENAME) を元に
# システム情報を言語に応じて表示する
#########################################################################
information() {
    local lang="$SELECTED_LANGUAGE"
    local country=$(echo "$ZONENAME" | awk '{print $1}')
    local language_package=$(echo "$ZONENAME" | awk '{print $2}')
    local country_code=$(echo "$ZONENAME" | awk '{print $3}')
    local time_zones=$(echo "$ZONENAME" | awk -F';' '{print $2}' | tr ',' '\n')
    local language=$(echo "$ZONENAME" | awk '{print $4}')

    case "$lang" in
        en)
            echo -e "$(color white "Country: $country")"
            echo -e "$(color white "Language Package: $language_package")"
            echo -e "$(color white "Country Code: $country_code")"
            echo -e "$(color white "Time Zones: $time_zones")"
            echo -e "$(color white "Language: $language")"
            ;;
        ja)
            echo -e "$(color white "国名: $country")"
            echo -e "$(color white "言語パッケージ: $language_package")"
            echo -e "$(color white "国コード: $country_code")"
            echo -e "$(color white "タイムゾーン: $time_zones")"
            echo -e "$(color white "言語: $language")"
            ;;
        zh-cn)
            echo -e "$(color white "国家: $country")"
            echo -e "$(color white "语言包: $language_package")"
            echo -e "$(color white "国家代码: $country_code")"
            echo -e "$(color white "时区: $time_zones")"
            echo -e "$(color white "语言: $language")"
            ;;
        zh-tw)
            echo -e "$(color white "國家: $country")"
            echo -e "$(color white "語言包: $language_package")"
            echo -e "$(color white "國家代碼: $country_code")"
            echo -e "$(color white "時區: $time_zones")"
            echo -e "$(color white "語言: $language")"
            ;;
        *)
            handle_error "Unsupported language: $lang"
            ;;
    esac
}

#########################################################################
# メイン処理の開始
#########################################################################
download_country_zone
download_and_execute_common
check_common "$INPUT_LANG"
country_zone
information
set_device_name_password
set_wifi_ssid_password
set_device
