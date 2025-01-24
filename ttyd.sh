#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

OPENWRT_RELEAS=$(grep 'DISTRIB_RELEASE' /etc/openwrt_release | cut -d"'" -f2 | cut -c 1-2)
SUPPORTED_VERSIONS="19 21 22 23 24"
if echo "$SUPPORTED_VERSIONS" | grep -qw "$OPENWRT_RELEAS"; then
  opkg update
  opkg install luci-app-ttyd
elif [ "$OPENWRT_RELEAS" = "SN" ]; then
  apk update
  apk add luci-app-ttyd
fi
   
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
