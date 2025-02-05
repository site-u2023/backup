#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
echo aios.sh Last update: 20250205-15

# === 定数の設定 ===
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19.07 21.02 22.03 23.05 24.10.0 SNAPSHOT"
INPUT_LANG="$1"

#########################################################################
# 簡易カラー出力関数
#########################################################################
color() {
    case "$1" in
        red) echo "\033[1;31m$2\033[0m" ;;
        green) echo "\033[1;32m$2\033[0m" ;;
        yellow) echo "\033[1;33m$2\033[0m" ;;
        cyan) echo "\033[1;36m$2\033[0m" ;;
        *) echo "$2" ;;
    esac
}

#########################################################################
# 汎用エラーハンドリング関数
#########################################################################
handle_error() {
    color red "$(get_message 'MSG_ERROR_OCCURRED' "$SELECTED_LANGUAGE"): $1"
    exit 1
}

#########################################################################
# 汎用ファイルダウンロード関数
#########################################################################
download_file() {
    local destination="$1"
    local remote_file="$2"
    wget --quiet -O "$destination" "${BASE_URL}/${remote_file}" || handle_error "$(get_message 'MSG_DOWNLOAD_FAIL' "$SELECTED_LANGUAGE"): ${remote_file}"
}

#########################################################################
# 初期バージョンチェック
#########################################################################
check_version_aios() {
    local current_version
    current_version=$(awk -F"'" '/DISTRIB_RELEASE/ {print $2}' /etc/openwrt_release)

    if echo "$SUPPORTED_VERSIONS" | grep -qw "$current_version"; then
        color green "$(get_message 'MSG_VERSION_SUPPORTED' "$SELECTED_LANGUAGE"): $current_version"
    else
        handle_error "$(get_message 'MSG_VERSION_UNSUPPORTED' "$SELECTED_LANGUAGE"): $current_version"
    fi
}

#########################################################################
# common-functions.sh のダウンロードと読み込み
#########################################################################
load_common_functions() {
    if [ ! -f "${BASE_DIR}/common-functions.sh" ]; then
        download_file "${BASE_DIR}/common-functions.sh" "common-functions.sh"
    fi
    . "${BASE_DIR}/common-functions.sh" || handle_error "Failed to source common-functions.sh"
}

#########################################################################
# ttyd のインストール確認と実行
#########################################################################
install_ttyd() {
    color yellow "$(get_message 'MSG_INSTALL_PROMPT' "$SELECTED_LANGUAGE")"
    download_file "${BASE_DIR}/ttyd.sh" "ttyd.sh"
    sh "${BASE_DIR}/ttyd.sh" "$SELECTED_LANGUAGE" || handle_error "Failed to execute ttyd.sh"
}

#########################################################################
# aios メインスクリプトのダウンロードと実行
#########################################################################
download_and_run_aios() {
    download_file "/usr/bin/aios" "aios"
    chmod +x /usr/bin/aios || handle_error "Failed to set execute permissions on /usr/bin/aios"

    color green "$(get_message 'MSG_INSTALL_SUCCESS' "$SELECTED_LANGUAGE")"
    /usr/bin/aios "$SELECTED_LANGUAGE" || handle_error "Failed to execute aios script."
}

#########################################################################
# メイン処理
#########################################################################
check_version_aios
load_common_functions
check_language_common "$INPUT_LANG"
install_ttyd
download_and_run_aios
