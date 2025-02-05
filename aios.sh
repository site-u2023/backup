#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
AIOS_SH_VERSION="2025.02.05-rc1"
echo "aios.sh Last update: $AIOS_SH_VERSION"

# =====================================================
#  1) バージョンチェック：スクリプト内で完結
# =====================================================
SUPPORTED_VERSIONS="19.07 21.02 22.03 23.05 24.10.0 SNAPSHOT"

check_version_aios() {
    local current_version
    current_version=$(awk -F"'" '/DISTRIB_RELEASE/ {print $2}' /etc/openwrt_release | cut -d'-' -f1)

    if echo "$SUPPORTED_VERSIONS" | grep -qw "$current_version"; then
        echo "OpenWrt version is supported: $current_version"
    else
        echo "Unsupported OpenWrt version: $current_version"
        exit 1
    fi
}

# =====================================================
#  2) シンプルなエラー処理とカラー表示
# =====================================================
color() {
    case "$1" in
        red)    echo -e "\033[1;31m$2\033[0m" ;;
        green)  echo -e "\033[1;32m$2\033[0m" ;;
        yellow) echo -e "\033[1;33m$2\033[0m" ;;
        cyan)   echo -e "\033[1;36m$2\033[0m" ;;
        *)      echo -e "$2" ;;
    esac
}
handle_error() {
    color red "$1"
    exit 1
}

# =====================================================
#  3) ダウンロード用の汎用関数 (messages.db, common-func などに使う)
# =====================================================
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"

download_script() {
    local destination="$1"
    local remote_file="$2"
    color cyan "Downloading: $remote_file"
    wget --quiet -O "$destination" "${BASE_URL}/${remote_file}" || handle_error "Failed to download: $remote_file"
    color green "Downloaded successfully: $remote_file"
}

# =====================================================
#  4) メイン処理
# =====================================================

# (A) バージョンチェック
check_version_aios

# (B) 環境を初期化
color cyan "Initializing environment..."
rm -rf "$BASE_DIR" && mkdir -p "$BASE_DIR" || handle_error "Failed to create $BASE_DIR"

# (C) messages.db と common-functions.sh をダウンロード
color cyan "Downloading message database..."
download_script "${BASE_DIR}/messages.db" "messages.db"

color cyan "Downloading common-functions.sh..."
download_script "${BASE_DIR}/common-functions.sh" "common-functions.sh"

# (D) 読み込み
. "${BASE_DIR}/common-functions.sh" || handle_error "Failed to source common-functions.sh"

# -----------------------------------------------------
#  ここで共通関数内のバージョン不整合チェックは “warning” にする想定
#  （common-functions.sh 側の handle_error() 第2引数を "warning" にすれば
#   実際にはスクリプト終了させない）
# -----------------------------------------------------

# (E) ttyd インストールの Y/N 判定
#     confirm_action(…) は common-functions.sh 内で定義されているものを使用
if ! command -v ttyd >/dev/null 2>&1; then
    if confirm_action "MSG_INSTALL_PROMPT"; then
        color yellow "ttyd is not installed. Downloading and executing ttyd.sh..."
        download_script "${BASE_DIR}/ttyd.sh" "ttyd.sh"
        sh "${BASE_DIR}/ttyd.sh" || handle_error "Failed to execute ttyd.sh"
    else
        color yellow "Skipping ttyd installation."
    fi
else
    color green "ttyd is already installed."
fi

# (F) aios スクリプトのダウンロード＆実行ファイル化
color cyan "Downloading aios script..."
download_script "/usr/bin/aios" "aios"
chmod +x /usr/bin/aios || handle_error "Failed to chmod /usr/bin/aios"

# (G) 終了メッセージ
color green "All steps completed. You can now run 'aios' command."
