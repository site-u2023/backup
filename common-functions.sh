#!/bin/sh
# License: CC0
# OpenWrt >= 19.07, Compatible with 24.10.0
echo Last update: 20250205-1

# === 基本定数の設定 ===
BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/site-u2023/aios/main}"
BASE_DIR="${BASE_DIR:-/tmp/aios}"
SUPPORTED_VERSIONS="${SUPPORTED_VERSIONS:-19 21 22 23 24 24.10.0 SN}"
SUPPORTED_LANGUAGES="${SUPPORTED_LANGUAGES:-en ja zh-cn zh-tw id ko de ru}"

# === 共通関数 ===

# カラー表示用
color() {
    case "$1" in
        red) echo "\033[31m$2\033[0m" ;;
        green) echo "\033[32m$2\033[0m" ;;
        yellow) echo "\033[33m$2\033[0m" ;;
        *) echo "$2" ;;
    esac
}

# バージョンチェック関数
check_version() {
    current_version=$(cat /etc/openwrt_version)
    if echo "$SUPPORTED_VERSIONS" | grep -qw "$current_version"; then
        echo -e "$(color green "OpenWrt version $current_version is supported.")"
    else
        echo -e "$(color red "Unsupported OpenWrt version: $current_version. Exiting.")"
        exit 1
    fi
}

# 言語サポートチェック
check_language_support() {
    local selected_language_file="${BASE_DIR}/check_country"

    if [ ! -f "$selected_language_file" ]; then
        echo "en" > "$selected_language_file"
        echo -e "$(color yellow "Language cache not found. Defaulting to English (en).")"
    fi

    selected_language=$(cat "$selected_language_file")

    if echo "$SUPPORTED_LANGUAGES" | grep -qw "$selected_language"; then
        echo -e "$(color green "Language supported: $selected_language")"
    else
        echo -e "$(color yellow "Unsupported language detected. Defaulting to English (en).")"
        selected_language="en"
    fi

    export LANG="$selected_language"
}

# Y/N 判定
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

# ファイルダウンロード関数
download_file() {
    local file_url="$1"
    local destination="$2"
    
    wget -O "$destination" "$file_url?cache_bust=$(date +%s)"
    if [ $? -eq 0 ]; then
        echo -e "$(color green "Downloaded: $file_url")"
    else
        echo -e "$(color red "Failed to download: $file_url")"
        exit 1
    fi
}

# === 初期化処理 ===
check_version
check_language_support
