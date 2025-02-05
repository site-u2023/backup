#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# 初期設定用 all-in-one スクリプト (aios)
echo aios.sh Last update: 20250205-3

# 定数の設定
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
INPUT_LANG="$1"

# 内部バージョンデータベース
SUPPORTED_VERSIONS_AI0S="
19.07
21.02
22.03
23.05
24.10.0
SN
"

#########################################################################
# handle_error: エラー処理
#########################################################################
handle_error() {
    echo -e "\033[31mERROR:\033[0m $1"
    exit 1
}

#########################################################################
# check_version: OpenWrt バージョンの確認
#########################################################################
check_version() {
    local current_version
    current_version=$(awk -F"'" '/DISTRIB_RELEASE/ {print $2}' /etc/openwrt_release)

    if echo "$SUPPORTED_VERSIONS_AI0S" | grep -qw "$current_version"; then
        echo -e "\033[32mOpenWrt version $current_version is supported.\033[0m"
        echo "$current_version" > "${BASE_DIR}/check_version"
    else
        handle_error "Unsupported OpenWrt version: $current_version. Supported versions are: $SUPPORTED_VERSIONS_AI0S"
    fi
}

#########################################################################
# download_common_functions: 共通関数のダウンロード
#########################################################################
download_common_functions() {
    wget --quiet -O "${BASE_DIR}/common-functions.sh" "${BASE_URL}/common-functions.sh" || handle_error "Failed to download common-functions.sh"
}

#########################################################################
# download_and_execute: aios メインスクリプトのダウンロードと実行
#########################################################################
download_and_execute() {
    wget --quiet -O "/usr/bin/aios" "${BASE_URL}/aios" || handle_error "Failed to download aios."
    chmod +x /usr/bin/aios || handle_error "Failed to set execute permissions on /usr/bin/aios"

    echo -e "\n\033[32mInstallation Complete\033[0m"
    echo "You can now run the 'aios' script anywhere."

    /usr/bin/aios "$INPUT_LANG" || handle_error "Failed to execute aios script."
}

#########################################################################
# メイン処理
#########################################################################
mkdir -p "$BASE_DIR"
check_version
download_common_functions
download_and_execute
