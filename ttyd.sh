#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
#
# ttyd.sh
#
# 本スクリプトは、aios のインストールが完了した後に、ttyd のインストールおよび設定を行うためのスクリプトです。
# ・common-functions.sh をダウンロードして読み込み、共通関数を利用可能にする。
# ・ttyd のインストール状況を確認し、未インストールの場合はインストールを実施する。
# ・ttyd の各種設定 (uci による設定) を行い、ttyd サービスを有効化する。
#

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
        wget --quiet -O "${BASE_DIR}/common-functions.sh" "${BASE_URL}/common-functions.sh" || {
            echo "Failed to download common-functions.sh"
            exit 1
        }
    fi
    # common-functions.sh の読み込みにより、handle_error などの共通関数が利用可能になる
    source "${BASE_DIR}/common-functions.sh" || {
        echo "Failed to source common-functions.sh"
        exit 1
    }
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
# install_ttyd: PACKAGE_MANAGER (APK または OPKG) を元に、ttyd (luci-app-ttyd-<言語>)
#              をインストールする関数
#########################################################################
install_ttyd() {
    local INSTALL_LANGUAGE
    INSTALL_LANGUAGE=$(cat "${BASE_DIR}/check_language")
    
    case "$PACKAGE_MANAGER" in
        "apk")
            echo "Installing ttyd using APK..."
            apk update
            apk add luci-app-ttyd-"$INSTALL_LANGUAGE" || { 
                echo "Failed to install luci-app-ttyd using APK"; 
                exit 1; 
            }
            ttyd_setting
            ;;
        "opkg")
            echo "Installing ttyd using OPKG..."
            opkg update
            opkg install luci-app-ttyd-"$INSTALL_LANGUAGE" || { 
                echo "Failed to install luci-app-ttyd using OPKG"; 
                exit 1; 
            }
            ttyd_setting
            ;;
        *)
            echo "Unsupported package manager. Cannot install ttyd."
            exit 1
            ;;
    esac
}

#########################################################################
# ttyd_setting: uci コマンドを用いて ttyd の設定を行い、
#               ttyd サービスを有効化する関数
#########################################################################
ttyd_setting() {
    # 不要なクライアントオプションの削除
    uci del_list ttyd.@ttyd[0].client_option='theme={"background": "black"}'
    uci del_list ttyd.@ttyd[0].client_option='titleFixed=ttyd'
    uci del_list ttyd.ttyd.client_option='theme={"background": "blue"}'
    uci del_list ttyd.ttyd.client_option='titleFixed=config-software'
    
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
    
    uci commit ttyd
    /etc/init.d/ttyd enable
    /etc/init.d/rpcd start
}

#########################################################################
# メイン処理
#########################################################################
download_common
check_common "$INPUT_LANG"
check_ttyd_installed
