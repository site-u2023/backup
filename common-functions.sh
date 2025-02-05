#!/bin/sh
# License: CC0
# OpenWrt >= 19.07, Compatible with 24.10.0
echo common-functions.sh Last update: 20250205-2

# === 基本定数の設定 ===
BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/site-u2023/aios/main}"
BASE_DIR="${BASE_DIR:-/tmp/aios}"
SUPPORTED_VERSIONS="${SUPPORTED_VERSIONS:-19 21 22 23 24 24.10.0 SN}"
SUPPORTED_LANGUAGES="${SUPPORTED_LANGUAGES:-en ja zh-cn zh-tw id ko de ru}"

# === カラー表示関数 ===
color() {
    case "$1" in
        red) echo "\033[31m$2\033[0m" ;;
        green) echo "\033[32m$2\033[0m" ;;
        yellow) echo "\033[33m$2\033[0m" ;;
        cyan) echo "\033[36m$2\033[0m" ;;
        *) echo "$2" ;;
    esac
}

#########################################################################
# バージョンチェック関数
#########################################################################
check_version() {
    local current_version
    current_version=$(awk -F"'" '/DISTRIB_RELEASE/ {print $2}' /etc/openwrt_release | cut -c 1-5)

    if echo "$SUPPORTED_VERSIONS" | grep -qw "$current_version"; then
        echo -e "$(color green "OpenWrt version $current_version is supported.")"
    else
        echo -e "$(color red "Unsupported OpenWrt version: $current_version. Exiting.")"
        exit 1
    fi
}

#########################################################################
# 言語サポートチェック
#########################################################################
check_language_support() {
    local language_file="${BASE_DIR}/check_language"

    # 言語キャッシュがない場合、デフォルト言語を設定
    if [ ! -f "$language_file" ]; then
        echo "en" > "$language_file"
        echo -e "$(color yellow "Language cache not found. Defaulting to English (en).")"
    fi

    local selected_language
    selected_language=$(cat "$language_file")

    # サポートされている言語か確認
    if echo "$SUPPORTED_LANGUAGES" | grep -qw "$selected_language"; then
        echo -e "$(color green "Language supported: $selected_language")"
    else
        echo -e "$(color yellow "Unsupported language detected. Defaulting to English (en).")"
        selected_language="en"
    fi

    export LANG="$selected_language"
}

#########################################################################
# Y/N 判定関数
#########################################################################
confirm_settings() {
    read -p "Apply these settings? [Y/n]: " confirm
    confirm=${confirm:-Y}

    if [ "$confirm" != "Y" ] && [ "$confirm" != "y" ]; then
        echo -e "$(color yellow "Settings were not applied. Returning to selection.")"
        return 1
    fi
    echo -e "$(color green "Settings applied successfully.")"
    return 0
}

#########################################################################
# 汎用ファイルダウンロード関数
#########################################################################
download_file() {
    local file_url="$1"
    local destination="$2"
    
    wget --quiet -O "$destination" "${file_url}?cache_bust=$(date +%s)"
    if [ $? -eq 0 ]; then
        echo -e "$(color green "Downloaded: $file_url")"
    else
        echo -e "$(color red "Failed to download: $file_url")"
        exit 1
    fi
}

#########################################################################
# 国とタイムゾーンの選択
#########################################################################
select_country_and_timezone() {
    local country_file="${BASE_DIR}/country-zone.sh"

    if [ ! -f "$country_file" ]; then
        download_file "${BASE_URL}/country-zone.sh" "$country_file"
    fi

    echo -e "$(color cyan "Select a country for language and timezone configuration.")"
    sh "$country_file" | nl -w2 -s'. '

    read -p "Enter the number or country name (partial matches allowed): " selection
    local matched_country
    matched_country=$(sh "$country_file" | grep -i "$selection")

    if [ -z "$matched_country" ]; then
        echo -e "$(color red "No matching country found.")"
        return 1
    fi

    local language_code
    language_code=$(echo "$matched_country" | awk '{print $3}')
    echo "$language_code" > "${BASE_DIR}/check_language"

    echo -e "$(color green "Selected Language: $language_code")"
    confirm_settings || select_country_and_timezone
}

#########################################################################
# 選択された国と言語の詳細情報を表示
#########################################################################
country_full_info() {
    local country_info_file="${BASE_DIR}/country-zone.sh"
    local selected_language_code=$(cat "${BASE_DIR}/check_language")

    if [ -f "$country_info_file" ]; then
        grep -w "$selected_language_code" "$country_info_file"
    else
        echo -e "$(color red "Country information not found.")"
    fi
}

# === 初期化処理 ===
check_version
check_language_support
