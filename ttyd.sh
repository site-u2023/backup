#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

is_ttyd_installed() {
  if opkg list-installed | grep -qw 'luci-app-ttyd'; then
    return 0
  else
    return 1
  fi
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

OPENWRT_RELEAS=$(grep 'DISTRIB_RELEASE' /etc/openwrt_release | cut -d"'" -f2 | cut -c 1-2)

SUPPORTED_VERSIONS="19 21 22 23 24"
if echo "$SUPPORTED_VERSIONS" | grep -qw "$OPENWRT_RELEAS"; then
  if is_ttyd_installed; then
    echo "luci-app-ttyd is already installed."
  else
    echo "Installing luci-app-ttyd..."
    opkg update
    opkg install luci-app-ttyd
    ttyd_setting
  fi
elif [ "$OPENWRT_RELEAS" = "SN" ]; then
  if apk info | grep -qw 'luci-app-ttyd'; then
    echo "luci-app-ttyd is already installed."
  else
    echo "Installing luci-app-ttyd..."
    apk update
    apk add luci-app-ttyd
    ttyd_setting
  fi
else
  echo "Unsupported OpenWrt version: $OPENWRT_RELEAS"
fi
