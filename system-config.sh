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

# 無限ループの開始
main_menu() {
while :
do
  echo -e " \033[1;37mSystem setup started\033[0;39m"
  echo -e " \033[1;37mBasic Settings\033[0;39m"
  echo -e " \033[1;34mDevice Hostname\033[0;39m"
  echo -e " \033[1;33mDevice Password\033[0;39m"

  # Wi-Fi設定ファイルの存在確認と作成
  if [ ! -f /etc/config/wireless ]; then
    touch /etc/config/wireless
  fi

  # Wi-Fi情報の取得と分類
  declare -A WIFI_MAP
  uci show wireless | grep "band=" | while read line; do
    RADIO=$(echo "$line" | cut -d'.' -f2)
    BAND=$(echo "$line" | grep -oP "band='\K[^']+")
    WIFI_MAP["$RADIO"]="$BAND"
  done

  # Wi-Fi情報の表示
  for RADIO in "${!WIFI_MAP[@]}"; do
    BAND="${WIFI_MAP[$RADIO]}"
    case "$BAND" in
      "2g") BAND_LABEL="2G";;
      "5g") BAND_LABEL="5G";;
      "6g") BAND_LABEL="6G";;
      *) BAND_LABEL="UNKNOWN";;
    esac
    echo -e " \033[1;32mWi-Fi $RADIO $BAND_LABEL SSID\033[0;39m"
    echo -e " \033[1;36mWi-Fi $RADIO $BAND_LABEL Password\033[0;39m"
  done

  # GUEST Wi-Fiの設定確認
  if [[ " ${WIFI_MAP[@]} " =~ "5g" ]]; then
    echo -e " \033[1;41mWi-Fi GUEST\033[0;39m"
    echo -e " \033[1;41mTWT (Target Wake Time)\033[0;39m"
    echo -e " \033[1;41mDFS Check NEW\033[0;39m"
  fi

  # ユーザーの選択肢
  read -p " Please select key [y or q]: " num
  case "$num" in
    "y") _func_HOSTNAME ;;
    "q") exit ;;
  esac
done
}

download_common
check_common "$1"
main_menu
