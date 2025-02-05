#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# 初期設定用 all-in-one スクリプト (aios) のセットアップスクリプト
echo aios.sh Last update: 20250205-1

# 定数の設定
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19 21 22 23 24 24.10.0 SN"
INPUT_LANG="$1"

# 共通関数の読み込み
. "${BASE_DIR}/common-functions.sh" || {
    echo "Failed to load common functions."
    exit 1
}

#########################################################################
# delete_aios: 既存の aios 関連ファイルおよびディレクトリを削除して初期化する
#########################################################################
delete_aios() {
    rm -rf "${BASE_DIR}" /usr/bin/aios
    echo "$(color green "Initialized aios")"
}

#########################################################################
# make_directory: 必要なディレクトリ (BASE_DIR) を作成する
#########################################################################
make_directory() {
    mkdir -p "$BASE_DIR" || handle_error "Failed to create directory: $BASE_DIR"
}

#########################################################################
# check_version: OpenWrt バージョンの確認 (common-functions.sh から呼び出し)
#########################################################################
check_openwrt_version() {
    check_version || handle_error "OpenWrt version check failed."
}

#########################################################################
# check_ttyd_installed: ttyd がインストールされているか確認し、未インストールならユーザーにインストール確認
#########################################################################
check_ttyd_installed() {
    local choice
    if ! command -v ttyd >/dev/null 2>&1; then
        echo "$(color yellow "ttyd is not installed.")"
        read -p "Do you want to install ttyd? (y/n, default: n): " choice
        choice=${choice:-n}
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            echo "$(color cyan "Installing ttyd...")"
            wget --quiet -O "${BASE_DIR}/ttyd.sh" "${BASE_URL}/ttyd.sh" || handle_error "Failed to download ttyd installation script."
            sh "${BASE_DIR}/ttyd.sh" "$INPUT_LANG" || handle_error "ttyd installation failed."
        else
            echo "$(color yellow "Skipping ttyd installation.")"
        fi
    else
        echo "$(color green "ttyd is already installed.")"
    fi
}

#########################################################################
# download_country_zone: 国・ゾーン情報スクリプト (country-zone.sh) をダウンロード
#########################################################################
download_country_zone() {
    wget --quiet -O "${BASE_DIR}/country-zone.sh" "${BASE_URL}/country-zone.sh" || handle_error "Failed to download country-zone.sh"
}

#########################################################################
# download_and_execute: aios スクリプトをダウンロード、実行権限を付与後、実行する
#########################################################################
download_and_execute() {
    wget --quiet -O "/usr/bin/aios" "${BASE_URL}/aios" || handle_error "Failed to download aios."
    chmod +x /usr/bin/aios || handle_error "Failed to set execute permissions on /usr/bin/aios"
    
    echo -e "\n$(color green "Installation Complete")"
    echo "$(color cyan "aios has been installed successfully.")"
    echo "$(color yellow "You can now run the 'aios' script anywhere.")"
    
    /usr/bin/aios "$INPUT_LANG" || handle_error "Failed to execute aios script."
}

#########################################################################
# メイン処理
#########################################################################
delete_aios
make_directory
check_openwrt_version
check_ttyd_installed
download_country_zone
download_and_execute
