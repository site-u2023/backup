#!/bin/sh
# License: CC0
# OpenWrt >= 19.07, Compatible with 24.10.0
COMMON_FUNCTIONS_SH_VERSION="2025.02.05-rc1"
echo "common-functions.sh Last update: $COMMON_FUNCTIONS_SH_VERSION"

# === 基本定数の設定 ===
BASE_WGET="wget --quiet -O"
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
# 共通関数バージョン互換性チェック
#########################################################################
check_version_compatibility() {
    REQUIRED_VERSION="2025.02.0"

    if [ "$COMMON_FUNCTIONS_VERSION" != "$REQUIRED_VERSION" ]; then
        handle_error "$(get_message 'MSG_VERSION_UNSUPPORTED' "$SELECTED_LANGUAGE"): common-functions.sh ($COMMON_FUNCTIONS_VERSION). Required: $REQUIRED_VERSION"
    fi

    # messages.db のバージョンチェック
    MESSAGES_DB_VERSION=$(grep "^version=" "${BASE_DIR}/messages.db" | cut -d'=' -f2)
    if [ "$MESSAGES_DB_VERSION" != "$REQUIRED_VERSION" ]; then
        handle_error "$(get_message 'MSG_VERSION_UNSUPPORTED' "$SELECTED_LANGUAGE"): messages.db ($MESSAGES_DB_VERSION). Required: $REQUIRED_VERSION"
    fi
}

#########################################################################
# print_banner: 言語に応じたバナー表示 (messages.db からメッセージ取得)
#########################################################################
print_banner() {
    local msg
    msg=$(get_message 'MSG_BANNER' "$SELECTED_LANGUAGE")

    echo
    echo -e "\033[1;35m                    ii i                              \033[0m"
    echo -e "\033[1;34m         aaaa      iii       oooo      sssss          \033[0m"
    echo -e "\033[1;36m            aa      ii      oo  oo    ss              \033[0m"
    echo -e "\033[1;32m         aaaaa      ii      oo  oo     sssss          \033[0m"
    echo -e "\033[1;33m        aa  aa      ii      oo  oo         ss         \033[0m"
    echo -e "\033[1;31m         aaaaa     iiii      oooo     ssssss          \033[0m"
    echo
    echo -e "\033[1;37m$msg\033[0m"
}

#########################################################################
# download_version_db: バージョンデータベースのダウンロード
#########################################################################
download_version_db() {
    ${BASE_WGET} "${BASE_DIR}/versions-common.db" "${BASE_URL}/versions-common.db" \
    || handle_error "Failed to download versions-common.db"

}

#########################################################################
# バージョン確認とパッケージマネージャーの取得関数
#########################################################################
check_version_common() {
    local version_file="${BASE_DIR}/check_version"
    local supported_versions_db="${BASE_DIR}/supported_versions.db"

    # バージョンデータベースが存在するか確認
    if [ ! -f "$supported_versions_db" ]; then
        download_supported_versions_db || handle_error "$(get_message 'download_fail' "$SELECTED_LANGUAGE"): supported_versions.db"
    fi

    # キャッシュされたバージョンが存在するか確認
    if [ -f "$version_file" ]; then
        CURRENT_VERSION=$(cat "$version_file")
    else
        # バージョン情報を /etc/openwrt_release から取得
        CURRENT_VERSION=$(awk -F"'" '/DISTRIB_RELEASE/ {print $2}' /etc/openwrt_release)
        echo "$CURRENT_VERSION" > "$version_file"
    fi

    # バージョンがサポートされているか確認
    if grep -q "^$CURRENT_VERSION=" "$supported_versions_db"; then
        PACKAGE_MANAGER=$(grep "^$CURRENT_VERSION=" "$supported_versions_db" | cut -d'=' -f2 | cut -d'|' -f1)
        VERSION_STATUS=$(grep "^$CURRENT_VERSION=" "$supported_versions_db" | cut -d'=' -f2 | cut -d'|' -f2)

        echo -e "\033[1;32m$(get_message 'version_supported' "$SELECTED_LANGUAGE"): $CURRENT_VERSION ($VERSION_STATUS)\033[0m"
    else
        handle_error "$(get_message 'unsupported_version' "$SELECTED_LANGUAGE"): $CURRENT_VERSION"
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
        PS3="Please enter your choice: "

        i=1
        for lang in $SUPPORTED_LANGUAGES; do
            echo "$i) $lang"
            i=$((i+1))
        done

        while true; do
            read -p "Enter number or language (e.g., en, ja): " input
            if echo "$input" | grep -qE '^[0-9]+$'; then
                lang=$(echo $SUPPORTED_LANGUAGES | cut -d' ' -f$input)
            else
                input_normalized=$(echo "$input" | tr '[:upper:]' '[:lower:]' | iconv -f utf-8 -t utf-8 -c)
                lang=$(echo $SUPPORTED_LANGUAGES | tr '[:upper:]' '[:lower:]' | grep -o "\b$input_normalized\b")
            fi

            if [ -n "$lang" ]; then
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
# download_language_files: 必要な言語ファイルをダウンロード
#########################################################################
download_language_files() {
    for lang in $SUPPORTED_LANGUAGES; do
        if [ ! -f "${BASE_DIR}/messages_${lang}.sh" ]; then
            ${BASE_WGET} "${BASE_DIR}/messages_${lang}.sh" "${BASE_URL}/messages_${lang}.sh" || {
                echo "Failed to download language file: messages_${lang}.sh"
            }
        fi
    done
}

#########################################################################
# download_supported_versions_db: バージョンデータベースのダウンロード
#########################################################################
download_supported_versions_db() {
    if [ ! -f "${BASE_DIR}/supported_versions.db" ]; then
        ${BASE_WGET} "${BASE_DIR}/supported_versions.db" "${BASE_URL}/supported_versions.db" || handle_error "Failed to download supported_versions.db"
    fi
}

#########################################################################
# download_messages_db: 選択された言語のメッセージファイルをダウンロード
#########################################################################
download_messages_db() {
    if [ ! -f "${BASE_DIR}/messages.db" ]; then
        ${BASE_WGET} "${BASE_DIR}/messages.db" "${BASE_URL}/messages.db" || handle_error "Failed to download messages.db"
    fi
}


#########################################################################
# Y/N 判定関数
#########################################################################
check_language_common() {
    if [ -f "${BASE_DIR}/language_cache" ]; then
        SELECTED_LANGUAGE=$(cat "${BASE_DIR}/language_cache")
    else
        echo -e "\033[1;32mSelect your language:\033[0m"
        i=1

        # サポート言語リストの表示
        for lang in $SUPPORTED_LANGUAGES; do
            echo "$i) $lang"
            i=$((i+1))
        done

        # 入力受付ループ
        while true; do
            read -p "Enter number or language (e.g., en, ja): " input

            # 数字が入力された場合
            if echo "$input" | grep -qE '^[0-9]+$'; then
                lang=$(echo $SUPPORTED_LANGUAGES | cut -d' ' -f$input)
            else
                # 大文字小文字の区別なし & 2バイト文字も処理
                input_normalized=$(echo "$input" | tr '[:upper:]' '[:lower:]' | iconv -f utf-8 -t utf-8 -c)
                lang=$(echo $SUPPORTED_LANGUAGES | tr '[:upper:]' '[:lower:]' | grep -o "\b$input_normalized\b")
            fi

            # 有効な言語かチェック
            if [ -n "$lang" ]; then
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
# 汎用ファイルダウンロード関数
#########################################################################
download_file() {
    local file_url="$1"
    local destination="$2"
    
    ${BASE_WGET} "$destination" "${file_url}?cache_bust=$(date +%s)"
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
# パッケージマネージャー判定関数（apk / opkg 対応）
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
            handle_error "$(get_message 'no_package_manager_found' "$SELECTED_LANGUAGE")"
        fi
        echo "$PACKAGE_MANAGER" > "${BASE_DIR}/downloader_cache"
    fi
    echo -e "\033[1;32m$(get_message 'detected_package_manager' "$SELECTED_LANGUAGE"): $PACKAGE_MANAGER\033[0m"
}

#########################################################################
# get_message: 多言語対応メッセージ取得関数
# 引数: $1 = メッセージキー, $2 = 言語コード (オプション, デフォルトは 'ja')
#########################################################################
get_message() {
    local key="$1"
    local lang="${SELECTED_LANGUAGE:-jn}"  # デフォルトは英語（RCは日本語）

    # メッセージDBが存在しない場合のエラーハンドリング
    if [ ! -f "${BASE_DIR}/messages.db" ]; then
        echo "Message database not found. Defaulting to key: $key"
        return
    fi

    # メッセージDBから対応メッセージを取得
    local message=$(grep "^${lang}|${key}=" "${BASE_DIR}/messages.db" | cut -d'=' -f2-)

    # 見つからない場合、英語のデフォルトメッセージを使用
    if [ -z "$message" ]; then
        message=$(grep "^en|${key}=" "${BASE_DIR}/messages.db" | cut -d'=' -f2-)
    fi

    # 見つからない場合はキーそのものを返す
    [ -z "$message" ] && echo "$key" || echo "$message"
}

#########################################################################
# 初期化処理: バージョン確認、言語設定、メッセージDBのダウンロード
#########################################################################
download_supported_versions_db
download_messages_db
check_version_common
check_language_common


