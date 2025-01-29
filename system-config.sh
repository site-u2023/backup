#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="21 22 23 24 SN"

download_common() {
    if [ ! -f "${BASE_DIR}/common-functions.sh" ]; then
        wget --no-check-certificate --quiet -O "${BASE_DIR}/common-functions.sh" "${BASE_URL}/common-functions.sh"

    fi
    source "${BASE_DIR}/common-functions.sh"
}

color_code_map() {
  local color=$1
  case $color in
    "red") echo "\033[1;31m" ;;
    "green") echo "\033[1;32m" ;;
    "yellow") echo "\033[1;33m" ;;
    "blue") echo "\033[1;34m" ;;
    "magenta") echo "\033[1;35m" ;;
    "cyan") echo "\033[1;36m" ;;
    "white") echo "\033[1;37m" ;;
    "red_underline") echo "\033[4;31m" ;;
    "green_underline") echo "\033[4;32m" ;;
    "yellow_underline") echo "\033[4;33m" ;;
    "blue_underline") echo "\033[4;34m" ;;
    "magenta_underline") echo "\033[4;35m" ;;
    "cyan_underline") echo "\033[4;36m" ;;
    "white_underline") echo "\033[4;37m" ;;
    "red_white") echo "\033[1;41m" ;;
    "green_white") echo "\033[1;42m" ;;
    "yellow_white") echo "\033[1;43m" ;;
    "blue_white") echo "\033[1;44m" ;;
    "magenta_white") echo "\033[1;45m" ;;
    "cyan_white") echo "\033[1;46m" ;;
    "white_black") echo "\033[7;40m" ;;
    "reset") echo "\033[0;39m" ;;
    *) echo "\033[0;39m" ;;
  esac
}

set_device_name_password() {
  local device_name password confirmation
  local lang="${SELECTED_LANGUAGE:-en}"
  
  # 言語ごとのメッセージをcaseで定義
  case "$lang" in
    "en")
      msg_device="Enter the new device name: "
      msg_password="Enter the new password: "
      msg_confirm="Are you sure with the following settings? (y/n): "
      msg_success="Password and device name have been successfully updated."
      msg_cancel="Operation has been canceled."
      ;;
    "ja")
      msg_device="新しいデバイス名を入力してください: "
      msg_password="新しいパスワードを入力してください: "
      msg_confirm="以下の内容でよろしいですか？ (y/n): "
      msg_success="パスワードとデバイス名が正常に更新されました。"
      msg_cancel="設定がキャンセルされました。"
      ;;
    *)
      msg_device="Enter the new device name: "
      msg_password="Enter the new password: "
      msg_confirm="Are you sure with the following settings? (y/n): "
      msg_success="Password and device name have been successfully updated."
      msg_cancel="Operation has been canceled."
      ;;
  esac

  echo "Starting device name and password update process..."
  read -p "$msg_device" device_name
  read -s -p "$msg_password" password
  echo
  echo "$msg_confirm"
  echo "Device Name: $device_name"
  echo "Password: $device_name"
  read -p "$msg_confirm" confirmation
  if [ "$confirmation" != "y" ]; then
    echo "$msg_cancel"
    return 1
  fi

  echo "Updating password and device name..."
  ubus call luci setPassword "{ \"username\": \"root\", \"password\": \"$password\" }"
  if [ $? -ne 0 ]; then
    echo "Failed to update password."
    return 1
  fi

  uci set system.@system[0].hostname="$device_name"
  if [ $? -ne 0 ]; then
    echo "Failed to update device name."
    return 1
  fi

  uci commit system
  if [ $? -ne 0 ]; then
    echo "Failed to commit changes."
    return 1
  fi

  echo "$msg_success"
}

set_wifi_ssid_password() {
  local device iface iface_num ssid password enable_device band htmode devices
  local devices_to_enable=""
  local lang="${SELECTED_LANGUAGE:-en}"

  case "$lang" in
    "ja")
      msg_no_devices="Wi-Fiデバイスが見つかりません。終了します。"
      msg_band="デバイス %s (帯域: %s)"
      msg_enter_ssid="SSIDを入力してください: "
      msg_enter_password="パスワードを入力してください (8文字以上): "
      msg_password_invalid="パスワードは8文字以上で入力してください。"
      msg_updated="デバイス %s の設定が更新されました。"
      msg_enable_device="wifi-device %s を有効にしますか？(y/n): "
      ;;
    "en")
      msg_no_devices="No Wi-Fi devices found. Exiting."
      msg_band="Device %s (Band: %s)"
      msg_enter_ssid="Enter SSID: "
      msg_enter_password="Enter password (8 or more characters): "
      msg_password_invalid="Password must be at least 8 characters long."
      msg_updated="Device %s settings have been updated."
      msg_enable_device="Enable wifi-device %s? (y/n): "
      ;;
  esac

  devices=$(uci show wireless | grep 'wifi-device' | cut -d'=' -f1 | cut -d'.' -f2 | sort -u)
  if [ -z "$devices" ]; then
    echo "$msg_no_devices"
    exit 1
  fi

  devices_to_enable=""

  for device in $devices; do
    band=$(uci get wireless.${device}.band 2>/dev/null || echo "unknown")
    htmode=$(uci get wireless.${device}.htmode 2>/dev/null || echo "unknown")  # HTMODEを取得

    printf "$msg_band\n" "$device" "$band"

    echo -n "$(printf "$msg_enable_device" "$device")"
    read enable_device
    if [ "$enable_device" = "y" ]; then
      devices_to_enable="$devices_to_enable $device"
      uci -q delete wireless.${device}.disabled  # エラーメッセージを抑制
    fi

    iface_num=$(echo "$device" | grep -o '[0-9]*')  # radioX のXを抽出
    iface="aios${iface_num}"  # aiosX 形式のインターフェース名に修正

    echo -n "$msg_enter_ssid"
    read ssid
    while true; do
      echo -n "$msg_enter_password"
      read -s password
      echo
      if [ ${#password} -ge 8 ]; then
        break
      else
        echo "$msg_password_invalid"
      fi
    done

    uci set wireless.${iface}=wifi-iface
    uci set wireless.${iface}.device="${device}"
    uci set wireless.${iface}.mode="ap"
    uci set wireless.${iface}.ssid="${ssid}"
    uci set wireless.${iface}.key="${password}"
    uci set wireless.${iface}.htmode="${htmode}"  # 自動取得したHTMODEを適用
    uci set wireless.${iface}.network="lan"
  done

  uci commit wireless
  /etc/init.d/network reload

  for device in $devices_to_enable; do
    printf "$msg_updated\n" "$device"
  done
}

set_device() {
# SSH access interface
uci set dropbear.@dropbear[0].Interface='lan'
uci commit dropbear

# system setup
DESCRIPTION=`cat /etc/openwrt_version` # Description
NOTES=`date` # Remarks
ZOONNAME='UTC'
TIMEZOON='JST-9'

uci set system.@system[0]=system
uci set system.@system[0].hostname=${HOSTNAME}
uci set system.@system[0].description="${DESCRIPTION}"
uci set system.@system[0].zonename=${ZOONNAME}
uci set system.@system[0].timezone=${TIMEZOON}
uci set system.@system[0].conloglevel='6' # Log output level: caution
uci set system.@system[0].cronloglevel='9' # Cron log level: warning
# NTP server
uci set system.ntp.enable_server='1'
uci set system.ntp.use_dhcp='0'
uci set system.ntp.interface='lan'
uci delete system.ntp.server
uci add_list system.ntp.server='0.pool.ntp.org'
uci add_list system.ntp.server='1.pool.ntp.org'
uci add_list system.ntp.server='2.pool.ntp.org' 
uci add_list system.ntp.server='3.pool.ntp.org'
uci commit system
/etc/init.d/system reload
/etc/init.d/sysntpd restart
# note
uci set system.@system[0].notes="${NOTES}"
uci commit system
/etc/init.d/system reload

# Software flow offload
uci set firewall.@defaults[0].flow_offloading='1'
uci commit firewall
# /etc/init.d/firewall restart

# Hardware flow offload
Hardware_flow_offload=`grep 'mediatek' /etc/openwrt_release`
if [ "${Hardware_flow_offload:16:8}" = "mediatek" ]; then
 uci set firewall.@defaults[0].flow_offloading_hw='1'
 uci commit firewall
 # /etc/init.d/firewall restart
fi

# packet steering
uci set network.globals.packet_steering='1'
uci commit network

# custom DNS
# delete
uci -q delete dhcp.lan.dhcp_option
uci -q delete dhcp.lan.dns
# IPV4
uci add_list dhcp.lan.dhcp_option="6,1.1.1.1,8.8.8.8"
uci add_list dhcp.lan.dhcp_option="6,1.0.0.1,8.8.4.4"
# IPV6
uci add_list dhcp.lan.dns="2606:4700:4700::1111"
uci add_list dhcp.lan.dns="2001:4860:4860::8888"
uci add_list dhcp.lan.dns="2606:4700:4700::1001"
uci add_list dhcp.lan.dns="2001:4860:4860::8844"
#
uci set dhcp.@dnsmasq[0].cachesize='2000'
#
uci set dhcp.lan.leasetime='24h'
# set
uci commit dhcp
# /etc/init.d/dnsmasq restart
# /etc/init.d/odhcpd restart
}

download_common
check_common $1
set_device_name_password
set_wifi_ssid_password
