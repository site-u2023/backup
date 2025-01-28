#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main/"
BASE_DIR="/tmp/aios/"
SUPPORTED_VERSIONS="21 22 23 24 SN"

download_common() {
    if [ ! -f "${BASE_DIR}common-functions.sh" ]; then
        wget --no-check-certificate --quiet -O "${BASE_DIR}common-functions.sh" "${BASE_URL}common-functions.sh"

    fi
    source "${BASE_DIR}common-functions.sh"
}

set_device_name_password() {
  local password device_name confirmation
  local lang="${SELECTED_LANGUAGE:-en}"  # デフォルトは英語
  local msg_device msg_password msg_confirm msg_success msg_cancel

  if [ "$lang" = "ja" ]; then
    msg_device="新しいデバイス名を入力してください: "
    msg_password="新しいパスワードを入力してください: "
    msg_confirm="以下の内容でよろしいですか？ (y/n): "
    msg_success="パスワードとデバイス名が正常に更新されました。"
    msg_cancel="設定がキャンセルされました。"
  else
    msg_device="Enter the new device name: "
    msg_password="Enter the new password: "
    msg_confirm="Are you sure with the following settings? (y/n): "
    msg_success="Password and device name have been successfully updated."
    msg_cancel="Operation has been canceled."
  fi

  echo "Starting device name and password update process..."
  read -p "$msg_device" device_name
  echo "Device Name entered: $device_name"

  read -s -p "$msg_password" password
  echo "Password entered: (hidden)"  # パスワードは表示しない

  echo "$msg_confirm"
  echo "Device Name: $device_name"
  echo "Password: (hidden)"

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

set_wifi_ssid_password() {
  local devices section device band ssid password confirm
  local lang="${SELECTED_LANGUAGE:-en}"  # デフォルトは英語

  # メッセージ定義
  local msg_no_devices msg_section_disabled msg_band msg_enter_ssid
  local msg_enter_password msg_password_invalid msg_settings msg_confirm
  local msg_updated msg_canceled

  if [ "$lang" = "ja" ]; then
    msg_no_devices="Wi-Fiデバイスが見つかりません。終了します。"
    msg_section_disabled="セクション %s は無効です。無効を解除します。"
    msg_band="デバイス %s (帯域: %s)"
    msg_enter_ssid="SSIDを入力してください: "
    msg_enter_password="パスワードを入力してください (8文字以上): "
    msg_password_invalid="パスワードは8文字以上で入力してください。"
    msg_settings="以下の設定を行います:\nデバイス: %s\n帯域: %s\nSSID: %s\nパスワード: %s"
    msg_confirm="この設定で進行しますか？(y/n): "
    msg_updated="デバイス %s の設定が更新されました。"
    msg_canceled="デバイス %s の設定がキャンセルされました。"
  else
    msg_no_devices="No Wi-Fi devices found. Exiting."
    msg_section_disabled="Section %s is disabled. Enabling it."
    msg_band="Device %s (Band: %s)"
    msg_enter_ssid="Enter SSID: "
    msg_enter_password="Enter password (minimum 8 characters): "
    msg_password_invalid="Password must be at least 8 characters long."
    msg_settings="Applying the following settings:\nDevice: %s\nBand: %s\nSSID: %s\nPassword: %s"
    msg_confirm="Proceed with these settings? (y/n): "
    msg_updated="Settings for device %s have been updated."
    msg_canceled="Settings for device %s have been canceled."
  fi

  # Wi-Fiデバイスリスト取得
  devices=$(uci show wireless | grep 'wifi-device' | cut -d'=' -f1 | cut -d'.' -f2 | sort -u)
  if [ -z "$devices" ]; then
    echo "$msg_no_devices"
    exit 1
  fi

  # 無効なWi-Fiセクションを有効化
  for section in $(uci show wireless | grep "disabled='1'" | cut -d'.' -f2 | sort -u); do
    printf "$msg_section_disabled\n" "$section"
    uci delete wireless.${section}.disabled
  done

  uci commit wireless
  /etc/init.d/network reload

  # 各デバイスの設定
  for device in $devices; do
    band=$(uci get wireless.${device}.band 2>/dev/null || echo "unknown")

    printf "$msg_band\n" "$device" "$band"
    read -p "$msg_enter_ssid" ssid
    while true; do
      read -s -p "$msg_enter_password" password
      echo
      if [ ${#password} -ge 8 ]; then
        break
      else
        echo "$msg_password_invalid"
      fi
    done

    printf "$msg_settings\n" "$device" "$band" "$ssid" "$password"
    read -p "$msg_confirm" confirm

    if [ "$confirm" = "y" ]; then
      # Wi-Fiデバイスの設定更新
      uci set wireless.${device}.ssid="$ssid"
      uci set wireless.${device}.key="$password"
      uci commit wireless
      /etc/init.d/network reload
      printf "$msg_updated\n" "$device"
    else
      printf "$msg_canceled\n" "$device"
    fi
  done
}

# 実行
download_common
check_common $1
set_device_name_password
set_wifi_ssid_password
