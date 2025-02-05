#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
echo aios.sh Last update: 20250205-14

# === 定数の設定 ===
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19.07 21.02 22.03 23.05 24.10.0 SNAPSHOT"
INPUT_LANG="$1"

#########################################################################
# color: 簡易カラー出力関数（エラーメッセージ表示用）
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
# handle_error: 汎用エラーハンドリング関数
#########################################################################
handle_error() {
    color red "ERROR: $1"
    exit 1
}

#########################################################################
# download_file: 汎用ファイルダウンロード関数
# 引数: $1 = 保存先ファイル名, $2 = ダウンロード元のリモートファイル名
#########################################################################
download_file() {
    local destination="$1"
    local remote_file="$2"
    wget --quiet -O "$destination" "${BASE_URL}/${remote_file}" || handle_error "Failed to download ${remote_file}"
}

#########################################################################
# check_version_aios: aios.sh専用のシンプルなバージョンチェック関数
#########################################################################
check_version_aios() {
    local current_version
    current_version=$(awk -F"'" '/DISTRIB_RELEASE/ {print $2}' /etc/openwrt_release)

    if echo "$SUPPORTED_VERSIONS" | grep -qw "$current_version"; then
        color green "OpenWrt version $current_version is supported."
    else
        color red "Unsupported OpenWrt version: $current_version."
        color yellow "Supported versions are: $SUPPORTED_VERSIONS"
        exit 1
    fi
}

#########################################################################
# download_and_source_common: common-functions.sh のダウンロードおよび読み込み
#########################################################################
download_and_source_common() {
    if [ ! -f "${BASE_DIR}/common-functions.sh" ]; then
        download_file "${BASE_DIR}/common-functions.sh" "common-functions.sh"
    fi
    . "${BASE_DIR}/common-functions.sh" || handle_error "Failed to source common-functions.sh"
}

#########################################################################
# delete_aios: 既存の aios ファイル削除
#########################################################################
delete_aios() {
    rm -rf "${BASE_DIR}" /usr/bin/aios
    color green "AIOS environment initialized."
}

#########################################################################
# make_directory: 必要なディレクトリ作成
#########################################################################
make_directory() {
    mkdir -p "$BASE_DIR" || handle_error "Failed to create directory: $BASE_DIR"
}

#########################################################################
# check_language_common: 言語キャッシュの確認および設定 (common を使用)
#########################################################################
set_language() {
    check_language_common "$INPUT_LANG"
}

#########################################################################
# check_ttyd_installed: ttyd のインストール確認とダウンロード
#########################################################################
check_ttyd_installed() {
    if command -v ttyd >/dev/null 2>&1; then
        color green "$(get_message 'ttyd_already_installed' "$SELECTED_LANGUAGE")"
    else
        color yellow "$(get_message 'ttyd_not_installed' "$SELECTED_LANGUAGE")"
        download_file "${BASE_DIR}/ttyd.sh" "ttyd.sh"
        sh "${BASE_DIR}/ttyd.sh" "$SELECTED_LANGUAGE" || handle_error "Failed to execute ttyd.sh"
    fi
}

#########################################################################
# download_aios_script: aios メインスクリプトのダウンロード
#########################################################################
download_aios_script() {
    download_file "/usr/bin/aios" "aios"
    chmod +x /usr/bin/aios || handle_error "Failed to set execute permissions on /usr/bin/aios"

    color green "$(get_message 'installation_complete' "$SELECTED_LANGUAGE")"
    color cyan "$(get_message 'aios_ready' "$SELECTED_LANGUAGE")"
}

#########################################################################
# メイン処理
#########################################################################
delete_aios
make_directory
check_version_aios       # バージョンチェックはコモンを使わずシンプルに実施
download_and_source_common  # バージョンチェック後に common-functions.sh を使用
set_language
check_ttyd_installed
download_aios_script
