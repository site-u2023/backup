#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"
SUPPORTED_LANGUAGES="en ja zh-cn zh-tw"
INPUT_LANG="$1"

download_common() {
if [ ! -f "${BASE_DIR}/common-functions.sh" ]; then
  wget --quiet -O "${BASE_DIR}/common-functions.sh" "${BASE_URL}/common-functions.sh"
fi
source "${BASE_DIR}/common-functions.sh"
}

check_ttyd_installed() {
    if command -v ttyd >/dev/null 2>&1; then
        echo "ttyd is already installed."
    else
        echo "ttyd is not installed."
        install_ttyd
    fi
}

install_ttyd() {
local INSTALL_LANGUAGE=$(cat "${BASE_DIR}/check_language")

    case "$PACKAGE_MANAGER" in
        "apk")
            echo "Installing ttyd using APK..."
            apk update
            apk add luci-app-ttyd-"$INSTALL_LANGUAGE" || { echo "Failed to install luci-app-ttyd"; exit 1; }
            ttyd_setting
            ;;
        "opkg")
            echo "Installing ttyd using OPKG..."
            opkg update
            opkg install luci-app-ttyd-"$INSTALL_LANGUAGE" || { echo "Failed to install luci-app-ttyd"; exit 1; }
            ttyd_setting
            ;;
        *)
            echo "Unsupported package manager. Cannot install ttyd."
            exit 1
            ;;
    esac
}

ttyd_setting() {
uci del_list ttyd.@ttyd[0].client_option='theme={"background": "black"}'
uci del_list ttyd.@ttyd[0].client_option='titleFixed=ttyd'
uci del_list ttyd.ttyd.client_option='theme={"background": "blue"}'
uci del_list ttyd.ttyd.client_option='titleFixed=config-software'

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

download_common
check_common "$INPUT_LANG"
check_ttyd_installed
