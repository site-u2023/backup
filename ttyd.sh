#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# ttyd.sh
#
# 本スクリプトは、aios のインストール後に ttyd をインストールおよび設定するスクリプトです。
# ・common-functions.sh を読み込んで共通関数を使用。
# ・ttyd のインストールと設定を行い、サービスを有効化。
echo ttyd.sh Last update 20250205-8

# === 定数の設定 ===
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_LANGUAGES="en ja zh-cn zh-tw"
INPUT_LANG="$1"

#########################################################################
# 共通エラー処理関数
#########################################################################
handle_error() {
    echo -e "\033[1;31mERROR:\033[0m $1"
    exit 1
}

#########################################################################
# 共通関数のダウンロードおよび読み込み
#########################################################################
download_common() {
    if [ ! -f "${BASE_DIR}/common-functions.sh" ]; then
        wget --quiet -O "${BASE_DIR}/common-functions.sh" "${BASE_URL}/common-functions.sh" || handle_error "Failed to download common-functions.sh"
    fi
    . "${BASE_DIR}/common-functions.sh" || handle_error "Failed to source common-functions.sh"
}

#########################################################################
# ttyd のインストール状況を確認し、未インストールの場合はインストール
#########################################################################
check_ttyd_installed() {
    if command -v ttyd >/dev/null 2>&1; then
        echo -e "\033[1;32mttyd is already installed.\033[0m"
    else
        echo -e "\033[1;33mttyd is not installed. Proceeding with installation...\033[0m"
        install_ttyd
    fi
}

#########################################################################
# ttyd のインストール
#########################################################################
install_ttyd() {
    # バージョンデータベースを参照し、パッケージマネージャーとステータスを取得
    get_package_manager_and_status

    echo -e "\033[1;34mInstalling ttyd using $PACKAGE_MANAGER...\033[0m"
    case "$PACKAGE_MANAGER" in
        apk)
            apk update
            apk add ttyd || handle_error "Failed to install ttyd using APK."
            ;;
        opkg)
            opkg update
            opkg install ttyd || handle_error "Failed to install ttyd using OPKG."
            ;;
        *)
            handle_error "Unsupported package manager detected."
            ;;
    esac
    ttyd_setting
}

#########################################################################
# ttyd の設定とサービスの有効化
#########################################################################
ttyd_setting() {
    echo -e "\033[1;34mConfiguring ttyd settings...\033[0m"

    # ttyd の基本設定
    uci batch <<EOF
set ttyd.@ttyd[0]=ttyd
set ttyd.@ttyd[0].interface='@lan'
set ttyd.@ttyd[0].command='/bin/login -f root'
set ttyd.@ttyd[0].ipv6='1'
add_list ttyd.@ttyd[0].client_option='theme={"background": "black"}'
add_list ttyd.@ttyd[0].client_option='titleFixed=ttyd'
EOF

    # ttyd の追加インスタンス設定
    uci batch <<EOF
set ttyd.ttyd=ttyd
set ttyd.ttyd.port='8888'
set ttyd.ttyd.interface='@lan'
set ttyd.ttyd.ipv6='1'
set ttyd.ttyd.command='/bin/login -f root'
add_list ttyd.ttyd.client_option='theme={"background": "blue"}'
add_list ttyd.ttyd.client_option='titleFixed=aios'
EOF

    # 設定の反映とサービスの有効化
    uci commit ttyd || handle_error "Failed to commit ttyd settings."
    /etc/init.d/ttyd enable || handle_error "Failed to enable ttyd service."
    /etc/init.d/ttyd restart || handle_error "Failed to restart ttyd service."

    echo -e "\033[1;32mttyd has been configured and started successfully.\033[0m"
}

#########################################################################
# メイン処理
#########################################################################
download_common
check_common "$INPUT_LANG"
check_ttyd_installed
