#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
echo aios.sh Last update: 20250205-6

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
# download_script: ファイルをダウンロードする汎用関数
# 引数: $1 = 保存先ファイル名, $2 = ダウンロード元のリモートファイル名
#########################################################################
download_script() {
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
        color red "ERROR: Unsupported OpenWrt version: $current_version."
        color yellow "Supported versions are: $SUPPORTED_VERSIONS"
        exit 1
    fi
}

#########################################################################
# check_ttyd_installed: ttyd がインストールされているか確認し、未インストールならダウンロード＆実行
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
# delete_aios: 既存の aios 関連ファイルおよびディレクトリを削除して初期化する
#########################################################################
delete_aios() {
    rm -rf "${BASE_DIR}" /usr/bin/aios
    color green "Initialized aios."
}

#########################################################################
# make_directory: 必要なディレクトリ (BASE_DIR) を作成する
#########################################################################
make_directory() {
    mkdir -p "$BASE_DIR" || handle_error "Failed to create directory: $BASE_DIR"
}

#########################################################################
# download_and_execute: aios メインスクリプトをダウンロードして実行
#########################################################################
download_and_execute() {
    download_script "/usr/bin/aios" "aios"
    chmod +x /usr/bin/aios || handle_error "Failed to set execute permissions on /usr/bin/aios"

    color green "Installation Complete."
    color cyan "aios has been installed successfully."
    color yellow "You can now run the 'aios' script anywhere."

    /usr/bin/aios "$INPUT_LANG" || handle_error "Failed to execute aios script."
}

#########################################################################
# メイン処理
#########################################################################
delete_aios
make_directory
check_version_aios
check_ttyd_installed
download_and_execute
