#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
echo aios.sh Last update: 20250205-18

# === 定数の設定 ===
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19.07 21.02 22.03 23.05 24.10.0 SNAPSHOT"
INPUT_LANG="$1"

#########################################################################
# 簡易カラー出力関数（エラー用）
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
# エラーハンドリング関数
#########################################################################
handle_error() {
    color red "ERROR: $1"
    exit 1
}

#########################################################################
# 初期バージョンチェック（common-functions.sh を使用しない）
#########################################################################
check_version_aios() {
    local current_version
    current_version=$(awk -F"'" '/DISTRIB_RELEASE/ {print $2}' /etc/openwrt_release)

    if echo "$SUPPORTED_VERSIONS" | grep -qw "$current_version"; then
        color green "OpenWrt version $current_version is supported."
    else
        handle_error "Unsupported OpenWrt version: $current_version"
    fi
}

#########################################################################
# 共通関数とメッセージDBのダウンロードと読み込み
#########################################################################
load_common_functions() {
    wget --quiet -O "${BASE_DIR}/common-functions.sh" "${BASE_URL}/common-functions.sh" \
        || handle_error "Failed to download common-functions.sh"

    . "${BASE_DIR}/common-functions.sh" || handle_error "Failed to source common-functions.sh"
}

#########################################################################
# 言語選択（キャッシュ確認 + メッセージDB利用）
#########################################################################
initialize_language() {
    check_language_common "$INPUT_LANG"      # 言語キャッシュ確認 (common function)
    download_messages_db                      # メッセージDBのダウンロード (common function)
}

#########################################################################
# ttyd のインストール確認とYN判定
#########################################################################
check_and_install_ttyd() {
    if command -v ttyd >/dev/null 2>&1; then
        color green "$(get_message 'MSG_INSTALL_SUCCESS' "$SELECTED_LANGUAGE"): ttyd"
    else
        color yellow "$(get_message 'MSG_INSTALL_PROMPT' "$SELECTED_LANGUAGE") ttyd"
        
        # === Y/N判定 (common function) ===
        if confirm_settings; then
            download_file "ttyd.sh" "${BASE_DIR}/ttyd.sh"   # ダウンロード関数 (common function)
            sh "${BASE_DIR}/ttyd.sh" "$SELECTED_LANGUAGE" || handle_error "Failed to execute ttyd.sh"
        else
            color yellow "$(get_message 'MSG_INSTALL_CANCEL' "$SELECTED_LANGUAGE"): ttyd"
        fi
    fi
}

#########################################################################
# aios のダウンロードと実行
#########################################################################
download_and_run_aios() {
    download_file "aios" "/usr/bin/aios"  # ダウンロード関数 (common function)
    chmod +x /usr/bin/aios || handle_error "Failed to set execute permissions on /usr/bin/aios"

    color green "$(get_message 'MSG_INSTALL_SUCCESS' "$SELECTED_LANGUAGE"): aios"
    /usr/bin/aios "$SELECTED_LANGUAGE" || handle_error "Failed to execute aios script."
}

#########################################################################
# メイン処理
#########################################################################
check_version_aios
load_common_functions
initialize_language
check_and_install_ttyd
download_and_run_aios
