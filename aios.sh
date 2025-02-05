#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
echo aios.sh Last update: 20250205-13

# 定数の設定
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
    color red "$(get_message 'MSG_ERROR_OCCURRED'): $1"
    exit 1
}

#########################################################################
# download_script: ファイルをダウンロードする汎用関数
#########################################################################
download_script() {
    local destination="$1"
    local remote_file="$2"
    color cyan "$(get_message 'MSG_DOWNLOAD_START'): $remote_file"
    wget --quiet -O "$destination" "${BASE_URL}/${remote_file}" || handle_error "$(get_message 'MSG_DOWNLOAD_FAIL'): $remote_file"
    color green "$(get_message 'MSG_DOWNLOAD_SUCCESS'): $remote_file"
}

#########################################################################
# get_message: 多言語対応メッセージ取得関数
#########################################################################
get_message() {
    local key="$1"
    local lang="${SELECTED_LANGUAGE:-ja}"  # デフォルトは日本語

    # メッセージDBから対応メッセージを取得
    local message=$(grep "^${lang}|${key}=" "${BASE_DIR}/messages.db" | cut -d'=' -f2-)

    # 見つからない場合、英語のデフォルトメッセージを使用
    if [ -z "$message" ]; then
        message=$(grep "^en|${key}=" "${BASE_DIR}/messages.db" | cut -d'=' -f2-)
    fi

    # 最後にキーそのものを返す（デフォルト）
    [ -z "$message" ] && echo "$key" || echo "$message"
}

#########################################################################
# バージョン確認関数 (依存無し)
#########################################################################
check_version_aios() {
    local current_version
    current_version=$(awk -F"'" '/DISTRIB_RELEASE/ {print $2}' /etc/openwrt_release)

    if echo "$SUPPORTED_VERSIONS" | grep -qw "$current_version"; then
        color green "$(get_message 'MSG_VERSION_SUPPORTED'): $current_version"
    else
        handle_error "$(get_message 'MSG_VERSION_UNSUPPORTED'): $current_version"
    fi
}

#########################################################################
# 共通関数のダウンロードと読み込み
#########################################################################
load_common_functions() {
    color cyan "$(get_message 'MSG_DOWNLOAD_COMMON_START')"
    download_script "${BASE_DIR}/common-functions.sh" "common-functions.sh"
    . "${BASE_DIR}/common-functions.sh" || handle_error "$(get_message 'MSG_DOWNLOAD_COMMON_FAIL')"
    color green "$(get_message 'MSG_DOWNLOAD_COMMON_SUCCESS')"
}

#########################################################################
# ttyd のインストール確認
#########################################################################
check_ttyd_installed() {
    if command -v ttyd >/dev/null 2>&1; then
        color green "ttyd is already installed."
    else
        color yellow "ttyd is not installed. Downloading and executing ttyd.sh..."
        download_script "${BASE_DIR}/ttyd.sh" "ttyd.sh"
        sh "${BASE_DIR}/ttyd.sh" || handle_error "Failed to execute ttyd.sh"
    fi
}

#########################################################################
# aios スクリプトのダウンロードと実行
#########################################################################
download_and_run_aios() {
    color cyan "$(get_message 'MSG_DOWNLOAD_AIOS_START')"
    download_script "/usr/bin/aios" "aios"
    chmod +x /usr/bin/aios || handle_error "$(get_message 'MSG_EXECUTE_AIOS_FAIL')"

    color green "$(get_message 'MSG_DOWNLOAD_AIOS_SUCCESS')"
    color cyan "$(get_message 'MSG_EXECUTE_AIOS_START')"
    /usr/bin/aios "$INPUT_LANG" \
        && color green "$(get_message 'MSG_EXECUTE_AIOS_SUCCESS')" \
        || handle_error "$(get_message 'MSG_EXECUTE_AIOS_FAIL')"
}

#########################################################################
# ディレクトリの初期化
#########################################################################
initialize_environment() {
    rm -rf "${BASE_DIR}" /usr/bin/aios
    mkdir -p "$BASE_DIR" || handle_error "Failed to create directory: $BASE_DIR"
    color green "Initialized aios environment."
}

#########################################################################
# メイン処理
#########################################################################
initialize_environment
check_version_aios
load_common_functions
check_ttyd_installed
download_and_run_aios
