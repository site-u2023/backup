#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# 202502022341-1
# ttyd.sh
#
# 本スクリプトは、aios のインストールが完了した後に、ttyd のインストールおよび設定を行うためのスクリプトです。
# ・common-functions.sh をダウンロードして読み込み、共通関数を利用可能にする。
# ・ttyd のインストール状況を確認し、未インストールの場合はインストールを実施する。
# ・ttyd の各種設定 (uci による設定) を行い、ttyd サービスを有効化する。

# 定数の設定
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"
SUPPORTED_LANGUAGES="en ja zh-cn zh-tw"
INPUT_LANG="$1"

#########################################################################
# download_common: common-functions.sh をダウンロードし、読み込む関数
#########################################################################
download_common() {
    if [ ! -f "${BASE_DIR}/common-functions.sh" ]; then
        wget --quiet -O "${BASE_DIR}/common-functions.sh" "${BASE_URL}/common-functions.sh" || handle_error "Failed to download common-functions.sh"
    fi
    source "${BASE_DIR}/common-functions.sh" || handle_error "Failed to source common-functions.sh"
}

#########################################################################
# check_ttyd_installed: ttyd がインストールされているか確認し、
#                        インストールされていなければ install_ttyd() を呼び出す関数
#########################################################################
check_ttyd_installed() {
    if command -v ttyd >/dev/null 2>&1; then
        echo "ttyd is already installed."
    else
        echo "ttyd is not installed."
        install_ttyd
    fi
}

#########################################################################
# install_ttyd: PACKAGE_MANAGER (APK または OPKG) を元に、ttyd (luci-app-ttyd)
#              をインストールする関数
#########################################################################
install_ttyd() {
    local INSTALL_LANGUAGE
    if [ -n "$INPUT_LANG" ]; then
        INSTALL_LANGUAGE="$INPUT_LANG"
    elif [ -f "${BASE_DIR}/check_language" ]; then
        INSTALL_LANGUAGE=$(cat "${BASE_DIR}/check_language")
    else
        INSTALL_LANGUAGE="en"  # デフォルトは英語
    fi

    echo "Selected language for installation: $INSTALL_LANGUAGE"

    case "$PACKAGE_MANAGER" in
        "APK")
            echo "Installing ttyd using APK..."
            apk update || handle_error "APK update failed."
            apk add luci-app-ttyd || handle_error "Failed to install luci-app-ttyd using APK."
            ttyd_setting
            ;;
        "OPKG")
            echo "Installing ttyd using OPKG..."
            opkg update || handle_error "OPKG update failed."
            opkg install luci-app-ttyd || handle_error "Failed to install luci-app-ttyd using OPKG."
            ttyd_setting
            ;;
        *)
            handle_error "Unsupported package manager. Cannot install ttyd."
            ;;
    esac
}

#########################################################################
# ttyd_setting: uci コマンドを用いて ttyd の設定を行い、
#               ttyd サービスを有効化する関数
#########################################################################
ttyd_setting() {
    echo "Configuring ttyd settings..."

    # 不要なクライアントオプションの削除
    uci -q del_list ttyd.@ttyd[0].client_option='theme={"background": "black"}'
    uci -q del_list ttyd.@ttyd[0].client_option='titleFixed=ttyd'
    uci -q del_list ttyd.ttyd.client_option='theme={"background": "blue"}'
    uci -q del_list ttyd.ttyd.client_option='titleFixed=config-software'

    # ttyd の設定
    uci set ttyd.@ttyd[0]=ttyd
    uci set ttyd.@ttyd[0].interface='@lan'
    uci set ttyd.@ttyd[0].command='/bin/login -f root'
    uci set ttyd.@ttyd[0].ipv6='1'
    uci add_list ttyd.@ttyd[0].client_option='theme={"background": "black"}'
    uci add_list ttyd.@ttyd[0].client_option='titleFixed=ttyd'

    uci set ttyd.ttyd=ttyd
    uci set ttyd.ttyd.port='8888'
    uci set ttyd.ttyd.interface='@lan'
    uci set ttyd.ttyd.ipv6='1'
    uci set ttyd.ttyd.command='confsoft'
    uci add_list ttyd.ttyd.client_option='theme={"background": "blue"}'
    uci add_list ttyd.ttyd.client_option='titleFixed=config-software'

    # 設定の反映とサービスの有効化
    uci commit ttyd || handle_error "Failed to commit ttyd settings."
    /etc/init.d/ttyd enable || handle_error "Failed to enable ttyd service."
    /etc/init.d/rpcd start || handle_error "Failed to start rpcd service."

    echo "ttyd has been configured and started successfully."
}

#########################################################################
# メイン処理
#########################################################################
download_common
check_common "$INPUT_LANG"
check_ttyd_installed
