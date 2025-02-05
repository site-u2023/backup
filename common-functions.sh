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
# handle_error: エラーおよび警告メッセージの処理
# 引数1: メッセージ
# 引数2: エラーレベル ('fatal' または 'warning')
#########################################################################
handle_error() {
    local message="$1"
    local level="${2:-fatal}"  # デフォルトは致命的エラー

    if [ "$level" = "warning" ]; then
        color yellow "$(get_message 'MSG_VERSION_MISMATCH_WARNING'): $message"
    else
        color red "$(get_message 'MSG_ERROR_OCCURRED'): $message"
        exit 1
    fi
}

#########################################################################
# エラーハンドリング強化
#########################################################################
load_common_functions() {
    if [ ! -f "${BASE_DIR}/common-functions.sh" ]; then
        ensure_file "common-functions.sh"
    fi

    if ! grep -q "COMMON_FUNCTIONS_SH_VERSION" "${BASE_DIR}/common-functions.sh"; then
        handle_error "Invalid common-functions.sh file structure."
    fi

    . "${BASE_DIR}/common-functions.sh" || handle_error "Failed to load common-functions.sh"
    check_version_compatibility
}

#########################################################################
# ensure_file: ファイルの存在確認と自動ダウンロード（警告対応）
#########################################################################
ensure_file() {
    local file_name="$1"
    local file_path="${BASE_DIR}/${file_name}"

    if [ ! -f "$file_path" ]; then
        handle_error "$(get_message 'MSG_FILE_NOT_FOUND_WARNING'): $file_name" "warning"
        download_file "$file_name" "$file_path"
    fi
}

#########################################################################
# check_version_compatibility: バージョン互換性チェック（警告対応）
#########################################################################
check_version_compatibility() {
    REQUIRED_VERSION="$AIOS_VERSION"

    # common-functions.sh のバージョンチェック
    COMMON_FUNCTIONS_VERSION=$(grep "^COMMON_FUNCTIONS_SH_VERSION=" "${BASE_DIR}/common-functions.sh" | cut -d'=' -f2 | tr -d '"')
    if [ "$COMMON_FUNCTIONS_VERSION" != "$REQUIRED_VERSION" ]; then
        handle_error "common-functions.sh version mismatch: $COMMON_FUNCTIONS_VERSION (Required: $REQUIRED_VERSION)" "warning"
    fi

    # messages.db のバージョンチェック（ダブルクオートを削除）
    MESSAGES_DB_VERSION=$(grep "^version=" "${BASE_DIR}/messages.db" | cut -d'=' -f2 | tr -d '"')
    if [ "$MESSAGES_DB_VERSION" != "$REQUIRED_VERSION" ]; then
        handle_error "messages.db version mismatch: $MESSAGES_DB_VERSION (Required: $REQUIRED_VERSION)" "warning"
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

        # サポート言語リストを表示
        i=1
        for lang in $SUPPORTED_LANGUAGES; do
            echo "$i) $lang"
            i=$((i+1))
        done

        # 入力受付ループ
        while true; do
            read -p "Enter number or language (e.g., en, ja): " input

            # 数字入力の場合
            if echo "$input" | grep -qE '^[0-9]+$'; then
                lang=$(echo $SUPPORTED_LANGUAGES | cut -d' ' -f$input)
            else
                # iconv を使わずに大文字小文字変換のみ
                input_normalized=$(echo "$input" | tr '[:upper:]' '[:lower:]')
                lang=$(echo "$SUPPORTED_LANGUAGES" | tr '[:upper:]' '[:lower:]' | grep -wo "$input_normalized")
            fi

            # 有効な言語かどうか確認
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
# confirm_action: Y/N 判定関数
# 引数1: 確認メッセージキー（多言語対応）
# 使用例: confirm_action 'MSG_INSTALL_PROMPT'
#########################################################################
confirm_action() {
    local prompt_message
    prompt_message=$(get_message "$1" "$SELECTED_LANGUAGE")

    # メッセージが取得できなければデフォルトメッセージを使用
    [ -z "$prompt_message" ] && prompt_message="Do you want to proceed? [Y/n]:"

    while true; do
        read -p "$prompt_message " confirm
        confirm=${confirm:-Y}  # デフォルトは "Y"

        case "$confirm" in
            [Yy]|[Yy][Ee][Ss]|はい|ハイ)
                echo -e "$(color green "$(get_message 'MSG_SETTINGS_APPLIED' "$SELECTED_LANGUAGE")")"
                return 0
                ;;
            [Nn]|[Nn][Oo]|いいえ|イイエ)
                echo -e "$(color yellow "$(get_message 'MSG_SETTINGS_CANCEL' "$SELECTED_LANGUAGE")")"
                return 1
                ;;
            *)
                echo -e "$(color red "$(get_message 'MSG_INVALID_SELECTION' "$SELECTED_LANGUAGE")")"
                ;;
        esac
    done
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
        # パッケージマネージャーの存在確認
        if command -v opkg >/dev/null 2>&1 && opkg list | grep -q "^ttyd - "; then
            PACKAGE_MANAGER="opkg"
        elif command -v apk >/dev/null 2>&1 && apk search ttyd >/dev/null 2>&1; then
            PACKAGE_MANAGER="apk"
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
# handle_exit: 正常終了メッセージを表示してスクリプトを終了する関数
# 引数: 終了時に表示するメッセージ
#########################################################################
handle_exit() {
    local message="$1"
    color yellow "$message"
    exit 0
}

#########################################################################
# install_packages: パッケージをインストールし、言語パックも適用
# 引数: インストールするパッケージ名のリスト
#########################################################################
install_packages() {
    local packages="$*"
    local manager="$PACKAGE_MANAGER"

    echo -e "\033[1;34mInstalling packages: $packages using $manager...\033[0m"

    # 最初の1回だけアップデートを実行
    if [ -z "$UPDATE_DONE" ]; then
        case "$manager" in
            apk)  apk update || handle_error "Failed to update APK." ;;
            opkg) opkg update || handle_error "Failed to update OPKG." ;;
            *)    handle_error "Unsupported package manager detected." ;;
        esac
        UPDATE_DONE=1
    fi

    # 各パッケージを個別にインストール
    for pkg in $packages; do
        attempt_package_install "$pkg"
    done
}

#########################################################################
# attempt_package_install: 個別パッケージのインストールおよび言語パック適用
# 引数: インストールするパッケージ名
#########################################################################
attempt_package_install() {
    local pkg="$1"

    if $PACKAGE_MANAGER list | grep -q "^$pkg - "; then
        $PACKAGE_MANAGER install $pkg && echo -e "$(color green "Successfully installed: $pkg")" || \
        echo -e "$(color yellow "Failed to install: $pkg. Continuing...")"

        # 言語パッケージの自動インストール
        install_language_pack "$pkg"
    else
        echo -e "$(color yellow "Package not found: $pkg. Skipping...")"
    fi
}

#########################################################################
# install_language_pack: 言語パッケージの存在確認とインストール
# 例: luci-app-ttyd → luci-app-ttyd-ja (存在すればインストール)
#########################################################################
install_language_pack() {
    local base_pkg="$1"
    local lang_pkg="${base_pkg}-i18n-${SELECTED_LANGUAGE}"

    if $PACKAGE_MANAGER list | grep -q "^$lang_pkg - "; then
        $PACKAGE_MANAGER install $lang_pkg && echo -e "$(color green "Language pack installed: $lang_pkg")" || \
        echo -e "$(color yellow "Failed to install language pack: $lang_pkg. Continuing...")"
    else
        echo -e "$(color cyan "Language pack not found for: $base_pkg. Skipping language pack...")"
    fi
}

#########################################################################
# 初期化処理: バージョン確認、言語設定、メッセージDBのダウンロード
#########################################################################
download_supported_versions_db
download_messages_db
check_version_common
check_language_common


