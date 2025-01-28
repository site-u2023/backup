#!/bin/sh

# 共通関数: 入力プロンプトと確認
prompt_input() {
  local prompt="$1"
  local var_name="$2"
  local min_length="$3"
  local max_length="$4"

  while true; do
    echo -e "$prompt"
    read -p " > " input
    if [ -n "$min_length" ] && [ ${#input} -lt "$min_length" ]; then
      echo "入力は${min_length}文字以上である必要があります。"
      continue
    fi
    if [ -n "$max_length" ] && [ ${#input} -gt "$max_length" ]; then
      echo "入力は${max_length}文字以下である必要があります。"
      continue
    fi
    eval "$var_name=\"$input\""
    read -p "この内容でよろしいですか？ [y/n/r]: " confirm
    case "$confirm" in
      y) break ;;
      n) continue ;;
      r) return 1 ;;
    esac
  done
  return 0
}

# ホスト名設定
set_hostname() {
  echo -e "\033[1;34mデバイスのホスト名を設定してください。\033[0;39m"
  if prompt_input "ホスト名を入力してください" "hostname"; then
    echo "設定されたホスト名: $hostname"
    set_password
  else
    set_hostname
  fi
}

# パスワード設定
set_password() {
  echo -e "\033[1;33mデバイスのパスワードを設定してください。\033[0;39m"
  if prompt_input "パスワードを入力してください (8〜63文字)" "password" 8 63; then
    echo "パスワードが設定されました。"
    set_country
  else
    set_password
  fi
}

# 国コード設定
set_country() {
  wget --no-check-certificate -O /etc/config-software/country_codes \
    https://raw.githubusercontent.com/site-u2023/config-software/main/country_codes
  cat /etc/config-software/country_codes

  echo -e "\033[1;35mWi-Fiの国コードを設定してください。\033[0;39m"
  if prompt_input "国コードを入力してください (例: JP)" "country_code"; then
    echo "設定された国コード: $country_code"
    set_wifi_settings "A"
  else
    set_country
  fi
}

# Wi-Fi設定の汎用処理
set_wifi_settings() {
  local wifi_no="$1"

  if [ -z "$(eval echo \${WIFI_NO_${wifi_no}})" ]; then
    return
  fi

  echo -e "\033[1;32mWi-Fi $wifi_no のSSIDを設定してください。\033[0;39m"
  if prompt_input "Wi-Fi ${wifi_no} SSIDを入力してください" "wifi_ssid_${wifi_no}"; then
    echo "設定されたSSID: $(eval echo \$wifi_ssid_${wifi_no})"

    echo -e "\033[1;36mWi-Fi $wifi_no のパスワードを設定してください。\033[0;39m"
    if prompt_input "Wi-Fi ${wifi_no} パスワードを入力してください (8〜63文字)" "wifi_password_${wifi_no}" 8 63; then
      echo "設定されたパスワード: $(eval echo \$wifi_password_${wifi_no})"
      next_wifi=$(printf "%s\n" "$wifi_no" | tr 'A-Z' 'B-ZA')
      set_wifi_settings "$next_wifi"
    else
      set_wifi_settings "$wifi_no"
    fi
  else
    set_wifi_settings "$wifi_no"
  fi
}

# 初期設定の開始
set_hostname
