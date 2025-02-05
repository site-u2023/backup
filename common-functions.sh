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
# check_version_common: OpenWrt バージョンの確認とキャッシュ
#########################################################################
check_version_common() {
    if [ -f "${BASE_DIR}/check_version" ]; then
        current_version=$(cat "${BASE_DIR}/check_version")
    else
        current_version=$(awk -F"'" '/DISTRIB_RELEASE/ {print $2}' /etc/openwrt_release)
        echo "$current_version" > "${BASE_DIR}/check_version"
    fi

    if grep -q "^${current_version}$" "${BASE_DIR}/supported_versions.db"; then
        echo -e "\033[1;32mOpenWrt version ${current_version} is supported.\033[0m"
    else
        handle_error "Unsupported OpenWrt version: ${current_version}"
    fi
}

#########################################################################
# check_language_common: 言語キャッシュの確認および設定
#########################################################################
check_language_common() {
    if [ -f "${BASE_DIR}/language_cache" ]; then
        SELECTED_LANGUAGE=$(cat "${BASE_DIR}/language_cache")
    else
        echo -e "\033[1;32mSelect your language:\033[0m"
        select lang in $SUPPORTED_LANGUAGES; do
            if echo "$SUPPORTED_LANGUAGES" | grep -qw "$lang"; then
                SELECTED_LANGUAGE="$lang"
                echo "$SELECTED_LANGUAGE" > "${BASE_DIR}/language_cache"
                break
            else
                echo -e "\033[1;31mInvalid selection. Try again.\033[0m"
            fi
        done
    fi
    echo -e "\033[1;32mLanguage supported: $SELECTED_LANGUAGE\033[0m"
}

#########################################################################
# download_supported_versions_db: バージョンデータベースのダウンロード
#########################################################################
download_supported_versions_db() {
    if [ ! -f "${BASE_DIR}/supported_versions.db" ]; then
        wget --quiet -O "${BASE_DIR}/supported_versions.db" "${BASE_URL}/supported_versions.db" || handle_error "Failed to download supported_versions.db"
    fi
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
# get_package_manager_and_status: パッケージマネージャーの確認とキャッシュ
#########################################################################
get_package_manager_and_status() {
    if [ -f "${BASE_DIR}/downloader_cache" ]; then
        PACKAGE_MANAGER=$(cat "${BASE_DIR}/downloader_cache")
    else
        if command -v apk >/dev/null 2>&1; then
            PACKAGE_MANAGER="apk"
        elif command -v opkg >/dev/null 2>&1; then
            PACKAGE_MANAGER="opkg"
        else
            handle_error "No supported package manager (apk or opkg) found."
        fi
        echo "$PACKAGE_MANAGER" > "${BASE_DIR}/downloader_cache"
    fi
}

#########################################################################
# get_message: 多言語対応メッセージ取得関数
# 引数: $1 = メッセージキー, $2 = 言語コード (オプション, デフォルトは 'en')
#########################################################################
get_message() {
    local key="$1"
    local lang="${2:-en}"
    
    # 言語ファイルが存在する場合は読み込む
    if [ -f "${BASE_DIR}/messages_${lang}.sh" ]; then
        . "${BASE_DIR}/messages_${lang}.sh"
    else
        # 言語ファイルが存在しない場合は英語をデフォルトとする
        . "${BASE_DIR}/messages_en.sh"
    fi

    # メッセージキーに対応する変数を取得
    local message_var="MSG_${key}"
    
    # メッセージが存在すれば表示、存在しなければデフォルトエラー
    if [ -n "${!message_var}" ]; then
        echo "${!message_var}"
    else
        echo "Unknown message key: $key"
    fi
}

# === 初期化処理 ===
check_version_common
check_language_support
