#!/bin/sh
# License: CC0
# OpenWrt >= 19.07, Compatible with 24.10.0
echo common-functions.sh Last update: 20250205-6

# === 基本定数の設定 ===
BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/site-u2023/aios/main}"
BASE_DIR="${BASE_DIR:-/tmp/aios}"
SUPPORTED_VERSIONS="${SUPPORTED_VERSIONS:-19.07 21.02 22.03 23.05 24.10.0 SNAPSHOT}"
SUPPORTED_LANGUAGES="${SUPPORTED_LANGUAGES:-en ja zh-cn zh-tw id ko de ru}"

#########################################################################
# color: ANSI エスケープシーケンスを使って色付きメッセージを出力する関数
# 引数1: 色の名前 (例: red, green, blue_white など)
# 引数2以降: 出力するメッセージ
#########################################################################

color() {
    local color_code
    color_code=$(color_code_map "$1")
    shift
    echo -e "${color_code}$*$(color_code_map "reset")"
}

#########################################################################
# color_code_map: カラー名から ANSI エスケープシーケンスを返す関数
# 引数: 色の名前
#########################################################################

color_code_map() {
    local color="$1"
    case "$color" in
        "red") echo "\033[1;31m" ;;
        "green") echo "\033[1;32m" ;;
        "yellow") echo "\033[1;33m" ;;
        "blue") echo "\033[1;34m" ;;
        "magenta") echo "\033[1;35m" ;;
        "cyan") echo "\033[1;36m" ;;
        "white") echo "\033[1;37m" ;;
        "red_underline") echo "\033[4;31m" ;;
        "green_underline") echo "\033[4;32m" ;;
        "yellow_underline") echo "\033[4;33m" ;;
        "blue_underline") echo "\033[4;34m" ;;
        "magenta_underline") echo "\033[4;35m" ;;
        "cyan_underline") echo "\033[4;36m" ;;
        "white_underline") echo "\033[4;37m" ;;
        "red_white") echo "\033[1;41m" ;;
        "green_white") echo "\033[1;42m" ;;
        "yellow_white") echo "\033[1;43m" ;;
        "blue_white") echo "\033[1;44m" ;;
        "magenta_white") echo "\033[1;45m" ;;
        "cyan_white") echo "\033[1;46m" ;;
        "white_black") echo "\033[7;40m" ;;
        "reset") echo "\033[0;39m" ;;
        *) echo "\033[0;39m" ;;  # デフォルトでリセット
    esac
}

#########################################################################
# handle_error: エラー処理
#########################################################################
handle_error() {
    echo -e "\033[31mERROR:\033[0m $1"
    exit 1
}

#########################################################################
# download_version_db: バージョンデータベースのダウンロード
#########################################################################
download_version_db() {
    wget --quiet -O "${BASE_DIR}/versions-common.db" "${BASE_URL}/versions-common.db" || handle_error "Failed to download versions-common.db"
}

#########################################################################
# check_version_common: common-functions.sh用の詳細なバージョンチェック関数
# - ローカルの SUPPORTED_VERSIONS と supported_versions.db の両方を参照
#########################################################################
check_version_common() {
    local version_file="${BASE_DIR}/supported_versions.db"
    local current_version

    # OpenWrtバージョン取得
    current_version=$(awk -F"'" '/DISTRIB_RELEASE/ {print $2}' /etc/openwrt_release)

    # データベースファイルが存在しない場合、エラー
    if [ ! -f "$version_file" ]; then
        echo -e "$(color red "ERROR: Supported versions database not found at $version_file.")"
        exit 1
    fi

    # スナップショットやRCバージョンは柔軟に許可
    if echo "$current_version" | grep -Eq 'RC[0-9]+$|SNAPSHOT$'; then
        echo -e "$(color green "Pre-release version ($current_version) detected. Proceeding.")"
        return 0
    fi

    # ローカル SUPPORTED_VERSIONS または DB に一致するかチェック
    if echo "$SUPPORTED_VERSIONS" | grep -qw "$current_version" || grep -qw "$current_version" "$version_file"; then
        echo -e "$(color green "OpenWrt version $current_version is supported.")"
    else
        echo -e "$(color red "ERROR: Unsupported OpenWrt version: $current_version.")"
        echo -e "$(color yellow "Refer to $version_file for supported versions.")"
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

#########################################################################
# get_package_manager_and_status: バージョンDBを参照し、適切なパッケージマネージャーとステータスを取得
#########################################################################
get_package_manager_and_status() {
    local openwrt_version
    openwrt_version=$(awk -F"'" '/DISTRIB_RELEASE/{print $2}' /etc/openwrt_release)

    # バージョン情報の取得
    version_info=$(grep "^${openwrt_version}=" "${BASE_DIR}/supported_versions.db")

    # バージョン情報が見つかった場合
    if [ -n "$version_info" ]; then
        PACKAGE_MANAGER=$(echo "$version_info" | cut -d'=' -f2 | cut -d'|' -f1)
        VERSION_STATUS=$(echo "$version_info" | cut -d'|' -f2)
    else
        # SNAPSHOT バージョンは常に apk を使用
        if echo "$openwrt_version" | grep -q "SNAPSHOT"; then
            PACKAGE_MANAGER="apk"
            VERSION_STATUS="snapshot"
        else
            handle_error "Unsupported OpenWrt version: $openwrt_version"
        fi
    fi
}


# === 初期化処理 ===
check_version
check_language_support
