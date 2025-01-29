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

set_device_name_password() {
  local password device_name confirmation
  local lang="${SELECTED_LANGUAGE:-en}"
  
  # 言語ごとのメッセージを定義
  declare -A messages
  messages["en_device"]="Enter the new device name: "
  messages["en_password"]="Enter the new password: "
  messages["en_confirm"]="Are you sure with the following settings? (y/n): "
  messages["en_success"]="Password and device name have been successfully updated."
  messages["en_cancel"]="Operation has been canceled."

  messages["ja_device"]="新しいデバイス名を入力してください: "
  messages["ja_password"]="新しいパスワードを入力してください: "
  messages["ja_confirm"]="以下の内容でよろしいですか？ (y/n): "
  messages["ja_success"]="パスワードとデバイス名が正常に更新されました。"
  messages["ja_cancel"]="設定がキャンセルされました。"

  # 他の言語を追加する際は、上記の形式で追加していける

  # メッセージの取得
  local msg_device="${messages[${lang}_device]}"
  local msg_password="${messages[${lang}_password]}"
  local msg_confirm="${messages[${lang}_confirm]}"
  local msg_success="${messages[${lang}_success]}"
  local msg_cancel="${messages[${lang}_cancel]}"

  echo "Starting device name and password update process..."
  read -p "$msg_device" device_name
  echo "Device Name entered: $device_name"

  read -s -p "$msg_password" password
  echo "Password entered: $device_name"

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
  local lang="${SELECTED_LANGUAGE:-en}"

  # 言語ごとのメッセージを定義
  declare -A messages
  messages["en_no_devices"]="No Wi-Fi devices found. Exiting."
  messages["en_section_disabled"]="Section %s is disabled. Enabling it."
  messages["en_band"]="Device %s (Band: %s)"
  messages["en_enter_ssid"]="Enter SSID: "
  messages["en_enter_password"]="Enter password (minimum 8 characters): "
  messages["en_password_invalid"]="Password must be at least 8 characters long."
  messages["en_settings"]="Applying the following settings:\nDevice: %s\nBand: %s\nSSID: %s\nPassword: %s"
  messages["en_confirm"]="Proceed with these settings? (y/n): "
  messages["en_updated"]="Settings for device %s have been updated."
  messages["en_canceled"]="Settings for device %s have been canceled."

  messages["ja_no_devices"]="Wi-Fiデバイスが見つかりません。終了します。"
  messages["ja_section_disabled"]="セクション %s は無効です。無効を解除します。"
  messages["ja_band"]="デバイス %s (帯域: %s)"
  messages["ja_enter_ssid"]="SSIDを入力してください: "
  messages["ja_enter_password"]="パスワードを入力してください (8文字以上): "
  messages["ja_password_invalid"]="パスワードは8文字以上で入力してください。"
  messages["ja_settings"]="以下の設定を行います:\nデバイス: %s\n帯域: %s\nSSID: %s\nパスワード: %s"
  messages["ja_confirm"]="この設定で進行しますか？(y/n): "
  messages["ja_updated"]="デバイス %s の設定が更新されました。"
  messages["ja_canceled"]="デバイス %s の設定がキャンセルされました。"

  # メッセージの取得
  local msg_no_devices="${messages[${lang}_no_devices]}"
  local msg_section_disabled="${messages[${lang}_section_disabled]}"
  local msg_band="${messages[${lang}_band]}"
  local msg_enter_ssid="${messages[${lang}_enter_ssid]}"
  local msg_enter_password="${messages[${lang}_enter_password]}"
  local msg_password_invalid="${messages[${lang}_password_invalid]}"
  local msg_settings="${messages[${lang}_settings]}"
  local msg_confirm="${messages[${lang}_confirm]}"
  local msg_updated="${messages[${lang}_updated]}"
  local msg_canceled="${messages[${lang}_canceled]}"

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

download_common
check_common $1
set_device_name_password
set_wifi_ssid_password
