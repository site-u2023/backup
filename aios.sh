#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# 初期設定用 all-in-one スクリプト (aios) のセットアップスクリプト
echo aios.sh Last update: 20250205-2

# 定数の設定
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19 21 22 23 24 24.10.0 SN"
INPUT_LANG="$1"

#########################################################################
# handle_error: エラー処理関数
#########################################################################
handle_error() {
    local msg="$1"
    echo -e "\033[31mERROR: $msg\033[0m" >&2
    exit 1
}

#########################################################################
# check_version_direct: OpenWrt バージョンを直接チェック
#########################################################################
check_version_direct() {
    if [ ! -f /etc/openwrt_release ]; then
        handle_error "/etc/openwrt_release not found. This script is for OpenWrt."
    fi

    local current_version
    current_version=$(awk -F"'" '/DISTRIB_RELEASE/ {print $2}' /etc/openwrt_release | cut -c 1-5)

    if echo "${SUPPORTED_VERSIONS}" | grep -qw "${current_version}"; then
        echo -e "\033[32mOpenWrt version ${current_version} is supported.\033[0m"
    else
        handle_error "Unsupported OpenWrt version: ${current_version}. Supported versions are: ${SUPPORTED_VERSIONS}"
    fi

    echo "${current_version}" > "${BASE_DIR}/check_version"
}

#########################################################################
# delete_aios: 既存の aios 関連ファイルを削除
#########################################################################
delete_aios() {
    rm -rf "${BASE_DIR}" /usr/bin/aios
    echo -e "\033[32mInitialized aios.\033[0m"
}

#########################################################################
# make_directory: 必要なディレクトリを作成
#########################################################################
make_directory() {
    mkdir -p "$BASE_DIR" || handle_error "Failed to create directory: $BASE_DIR"
}

#########################################################################
# download_country_zone: 国・ゾーン情報スクリプトをダウンロード
#########################################################################
download_country_zone() {
    wget --quiet -O "${BASE_DIR}/country-zone.sh" "${BASE_URL}/country-zone.sh" || handle_error "Failed to download country-zone.sh"
}

#########################################################################
# download_and_execute: aios メインスクリプトをダウンロードして実行
#########################################################################
download_and_execute() {
    wget --quiet -O "/usr/bin/aios" "${BASE_URL}/aios" || handle_error "Failed to download aios."
    chmod +x /usr/bin/aios || handle_error "Failed to set execute permissions on /usr/bin/aios"

    echo -e "\n\033[32mInstallation Complete\033[0m"
    echo -e "\033[36maios has been installed successfully.\033[0m"
    echo -e "\033[33mYou can now run the 'aios' script anywhere.\033[0m"

    /usr/bin/aios "$INPUT_LANG" || handle_error "Failed to execute aios script."
}

#########################################################################
# メイン処理
#########################################################################
delete_aios
make_directory
check_version_direct  # ここで直接バージョンチェック
download_country_zone
download_and_execute
