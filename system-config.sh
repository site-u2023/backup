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

download_country_timezone() {
    if [ ! -f "${BASE_DIR}/country_timezone" ]; then
        wget --no-check-certificate --quiet -O "${BASE_DIR}/country_timezone.sh" "${BASE_URL}/country_timezone.sh"

    fi
}

set_device_name_password() {
  local device_name password confirmation
  local lang="${SELECTED_LANGUAGE:-en}"
  
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
  echo "Password: $msg_password"
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
  local device iface iface_num ssid password enable_band band htmode devices network
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
      msg_select_band="デバイス %s のバンド %s を有効にしますか？(y/n): "
      msg_confirm="設定内容: SSID = %s, パスワード = %s。これで良いですか？ (y/n): "
      msg_reenter="もう一度入力してください。"
      msg_invalid="無効な入力です。y または n を入力してください。"
      ;;
    "en")
      msg_no_devices="No Wi-Fi devices found. Exiting."
      msg_band="Device %s (Band: %s)"
      msg_enter_ssid="Enter SSID: "
      msg_enter_password="Enter password (8 or more characters): "
      msg_password_invalid="Password must be at least 8 characters long."
      msg_updated="Device %s settings have been updated."
      msg_select_band="Enable band %s on device %s? (y/n): "
      msg_confirm="Configuration: SSID = %s, Password = %s. Is this correct? (y/n): "
      msg_reenter="Please re-enter the information."
      msg_invalid="Invalid input. Please enter 'y' or 'n'."
      ;;
  esac

  devices=$(uci show wireless | grep 'wifi-device' | cut -d'=' -f1 | cut -d'.' -f2 | sort -u)
  if [ -z "$devices" ]; then
    echo "$msg_no_devices"
    exit 1
  fi

  devices_to_enable=""

  for device in $devices; do
    band=$(uci get wireless.${device}.band 2>/dev/null)
    htmode=$(uci get wireless.${device}.htmode 2>/dev/null)

    printf "$msg_band\n" "$device" "$band"

    echo -n "$(printf "$msg_select_band" "$device" "$band")"
    read enable_band
    if [ "$enable_band" != "y" ]; then
      continue
    fi

    iface_num=$(echo "$device" | grep -o '[0-9]*')
    iface="aios${iface_num}"

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

    while true; do
      printf "$msg_confirm\n" "$ssid" "$password"
      read confirm
      if [ "$confirm" == "y" ]; then
        break
      elif [ "$confirm" == "n" ]; then
        echo "$msg_reenter"
        break
      else
        echo "$msg_invalid"
      fi
    done

    uci set wireless.${iface}="wifi-iface"
    uci set wireless.${iface}.device="${device:-aios}"
    uci set wireless.${iface}.mode='ap'
    uci set wireless.${iface}.ssid="${ssid:-openwrt}"
    uci set wireless.${iface}.key="${password:-password}"
    uci set wireless.${iface}.encryption="${encryption:-sae-mixed}"
    uci set wireless.${iface}.network='lan'
    uci -q delete wireless.${device}.disabled

    devices_to_enable="$devices_to_enable $device"
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
#uci set system.@system[0].hostname=${HOSTNAME}
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
read -p " Press any key (Reboot the device)"
reboot
}

download_common
download_country_timezone
check_common $1
sh ${BASE_DIR}/country_timezone.sh ${SELECTED_LANGUAGE}
set_device_name_password
set_wifi_ssid_password
