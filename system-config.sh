#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
#
# system-config.sh
#
# 本スクリプトは、デバイスの初期設定を行うためのスクリプトです。
# 主な処理内容は以下の通りです：
#  1. 国・ゾーン情報スクリプトのダウンロード
#  2. common-functions.sh のダウンロードと読み込み
#  3. 共通初期化処理 (check_common、country_zone、information) による情報表示
#  4. デバイス名・パスワードの設定 (set_device_name_password)
#  5. Wi-Fi SSID・パスワードの設定 (set_wifi_ssid_password)
#  6. システム全体の設定 (set_device)
echo 202520202319-24

# 定数の設定
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="21 22 23 24 SN"
SUPPORTED_LANGUAGES="en ja zh-cn zh-tw"
INPUT_LANG="$1"

#########################################################################
# download_country_zone: 国・ゾーン情報スクリプトのダウンロード
#########################################################################
download_country_zone() {
    if [ ! -f "${BASE_DIR%/}/country-zone.sh" ]; then
        wget --quiet -O "${BASE_DIR%/}/country-zone.sh" "${BASE_URL}/country-zone.sh" || \
            handle_error "Failed to download country-zone.sh"
    fi
}

#########################################################################
# download_and_execute_common: common-functions.sh をダウンロードし読み込む
#########################################################################
download_and_execute_common() {
    if [ ! -f "${BASE_DIR%/}/common-functions.sh" ]; then
        wget --quiet -O "${BASE_DIR%/}/common-functions.sh" "${BASE_URL}/common-functions.sh" || \
            handle_error "Failed to download common-functions.sh"
    fi

    source "${BASE_DIR%/}/common-functions.sh" || \
        handle_error "Failed to source common-functions.sh"
}

#########################################################################
# select_timezone: 複数のタイムゾーンから選択
#########################################################################
select_timezone() {
    local available_cities available_timezones selected_timezone selected_zone

    # 都市名とタイムゾーンの情報を取得
    available_cities=$(sh /tmp/aios/country-zone.sh "$SELECTED_COUNTRY" "cities")
    available_timezones=$(sh /tmp/aios/country-zone.sh "$SELECTED_COUNTRY" "offsets")

    # Bash特有の<<<を使わず、echoとパイプで代用
    echo "$available_cities" | IFS=',' read -ra city_array
    echo "$available_timezones" | IFS=',' read -ra timezone_array

    echo "Available Time Zones:"
    for i in "${!city_array[@]}"; do
        echo "[$((i+1))] ${city_array[$i]} - ${timezone_array[$i]}"
    done

    read -p "Select the time zone by number: " selected_index

    # 選択したゾーンネームとタイムゾーンを取得
    selected_zone="${city_array[$((selected_index-1))]}"
    selected_timezone="${timezone_array[$((selected_index-1))]}"

    if [ -z "$selected_zone" ] || [ -z "$selected_timezone" ]; then
        echo "Invalid selection. Defaulting to the first time zone."
        selected_zone="${city_array[0]}"
        selected_timezone="${timezone_array[0]}"
    fi

    # 選択結果の表示
    echo "Selected Time Zone: $selected_zone - $selected_timezone"
    TIMEZONE="$selected_timezone"
    ZONENAME="$selected_zone"
}

#########################################################################
# information: country_zone で取得済みのゾーン情報を元にシステム情報を表示する
#########################################################################
information() {
    local lang="$SELECTED_LANGUAGE"
    local country_data

    # 選択された言語に基づいて国情報を取得
    country_data=$(sh /tmp/aios/country-zone.sh "$SELECTED_COUNTRY" "all")

    # データの分割と抽出
    country_name=$(echo "$country_data" | awk '{print $1}')
    display_name=$(echo "$country_data" | awk '{print $2}')
    language_code=$(echo "$country_data" | awk '{print $3}')
    country_code=$(echo "$country_data" | awk '{print $4}')
    cities=$(echo "$country_data" | awk -F';' '{print $1}' | cut -d' ' -f5-)
    timezones=$(echo "$country_data" | awk -F';' '{print $2}')

    case "$lang" in
        en)
            echo -e "$(color white "Country: $country_name")"
            echo -e "$(color white "Display Name: $display_name")"
            echo -e "$(color white "Language Code: $language_code")"
            echo -e "$(color white "Country Code: $country_code")"
            echo -e "$(color white "Zone Names and Time Zones:")"
            ;;
        ja)
            echo -e "$(color white "国名: $country_name")"
            echo -e "$(color white "表示名: $display_name")"
            echo -e "$(color white "言語コード: $language_code")"
            echo -e "$(color white "国コード: $country_code")"
            echo -e "$(color white "タイムゾーン: $timezones")"
            ;;
        zh-cn)
            echo -e "$(color white "国家: $country_name")"
            echo -e "$(color white "显示名称: $display_name")"
            echo -e "$(color white "语言代码: $language_code")"
            echo -e "$(color white "国家代码: $country_code")"
            echo -e "$(color white "时区: $timezones")"
            ;;
        zh-tw)
            echo -e "$(color white "國家: $country_name")"
            echo -e "$(color white "顯示名稱: $display_name")"
            echo -e "$(color white "語言代碼: $language_code")"
            echo -e "$(color white "國家代碼: $country_code")"
            echo -e "$(color white "時區: $timezones")"
            ;;
        *)
            handle_error "Unsupported language: $lang"
            
            # <<< の代わりに echo とパイプを使用
            echo "$cities" | IFS=',' read -ra city_array
            echo "$timezones" | IFS=',' read -ra timezone_array

            for i in "${!city_array[@]}"; do
                echo -e "$(color white "${city_array[$i]} - ${timezone_array[$i]}")"
            done
            ;;
    esac
}

#########################################################################
# set_device_name_password: デバイス名とパスワードの設定を行う
# ユーザーから入力を受け、確認後、ubus および uci で更新する
#########################################################################
set_device_name_password() {
    local device_name password confirmation
    local lang msg_device msg_password msg_confirm msg_success msg_cancel

    lang="$SELECTED_LANGUAGE"
    case "$lang" in
        en)
            msg_device="Enter the new device name: "
            msg_password="Enter the new password: "
            msg_confirm="Are you sure with the following settings? (y/n): "
            msg_success="Password and device name have been successfully updated."
            msg_cancel="Operation has been canceled."
            ;;
        ja)
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
    # 確認プロンプトは共通の ask_confirmation() も利用できるが、ここは独自の確認文言を使用
    echo "Device Name: $device_name"
    echo "Password: $password"
    read -p "$msg_confirm" confirmation
    if [ "$confirmation" != "y" ]; then
        echo "$msg_cancel"
        return 1
    fi

    echo "Updating password and device name..."
    ubus call luci setPassword "{ \"username\": \"root\", \"password\": \"$password\" }" || {
        echo "Failed to update password."
        return 1
    }

    uci set system.@system[0].hostname="$device_name" || {
        echo "Failed to update device name."
        return 1
    }

    uci commit system || {
        echo "Failed to commit changes."
        return 1
    }

    echo "$msg_success"
}

#########################################################################
# set_wifi_ssid_password: Wi-Fi の SSID とパスワードを設定する
# 各 Wi-Fi デバイスごとにユーザー入力を受け、uci コマンドで更新する
#########################################################################
set_wifi_ssid_password() {
    local device iface iface_num ssid password enable_band band htmode devices
    local wifi_country_code=$(echo "$ZONENAME" | awk '{print $4}')
    local lang msg_no_devices msg_band msg_enter_ssid msg_enter_password msg_password_invalid
    local msg_updated msg_select_band msg_confirm msg_reenter msg_invalid
    
    lang="$SELECTED_LANGUAGE"
    case "$lang" in
        ja)
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
        en)
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
        *)
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

    for device in $devices; do
        band=$(uci get wireless."$device".band 2>/dev/null)
        htmode=$(uci get wireless."$device".htmode 2>/dev/null)

        printf "$msg_band\n" "$device" "$band"
        printf "$msg_select_band" "$device" "$band"
        read enable_band
        if [ "$enable_band" != "y" ]; then
            continue
        fi

        iface_num=$(echo "$device" | grep -o '[0-9]*')
        iface="aios${iface_num}"

        printf "$msg_enter_ssid"
        read ssid
        while true; do
            printf "$msg_enter_password"
            read -s password
            echo
            if [ "${#password}" -ge 8 ]; then
                break
            else
                echo "$msg_password_invalid"
            fi
        done

        while true; do
            printf "$msg_confirm\n" "$ssid" "$password"
            read confirm
            if [ "$confirm" = "y" ]; then
                break
            elif [ "$confirm" = "n" ]; then
                echo "$msg_reenter"
                break
            else
                echo "$msg_invalid"
            fi
        done

        uci set wireless."$iface"="wifi-iface"
        uci set wireless."$iface".device="${device:-aios}"
        uci set wireless."$iface".mode='ap'
        uci set wireless."$iface".ssid="${ssid:-openwrt}"
        uci set wireless."$iface".key="${password:-password}"
        uci set wireless."$iface".encryption="${encryption:-sae-mixed}"
        uci set wireless."$iface".network='lan'
        uci set wireless."$device".country="$wifi_country_code"
        uci -q delete wireless."$device".disabled

        devices_to_enable="$devices_to_enable $device"
    done

    uci commit wireless
    /etc/init.d/network reload

    for device in $devices_to_enable; do
        printf "$msg_updated\n" "$device"
    done
}

#########################################################################
# set_device: デバイス全体の設定を行い、最終的にリブートを実行する
#  ※ SSH ドロップベア設定、システム設定、NTP サーバ設定、ファイアウォール・パケットスティアリング、
#     カスタム DNS 設定などを uci コマンドで行う。
#########################################################################
set_device() {
    # SSH アクセス用のインターフェース設定
    uci set dropbear.@dropbear[0].Interface='lan'
    uci commit dropbear

    # システム基本設定
    local DESCRIPTION NOTES _zonename _timezone
    DESCRIPTION=$(cat /etc/openwrt_version) || DESCRIPTION="Unknown"
    NOTES=$(date) || NOTES="No date"
    # ZONENAME, TIMEZONE は country_zone で取得済み、TIMEZONE は select_timezone で選択
    _zonename=$(echo "$ZONENAME" | awk '{print $1}' 2>/dev/null || echo "Unknown")
    _timezone="${TIMEZONE:-UTC}"

    echo "Applying zonename settings: $_zonename"
    echo "Applying timezone settings: $_timezone"

    uci set system.@system[0]=system
    #uсi set system.@system[0].hostname=${HOSTNAME}  # 必要に応じてコメント解除
    uci set system.@system[0].description="${DESCRIPTION}"
    uci set system.@system[0].zonename="$_zonename"
    uci set system.@system[0].timezone="$_timezone"
    uci set system.@system[0].conloglevel='6'
    uci set system.@system[0].cronloglevel='9'
    # NTP サーバ設定
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
    # ノート設定
    uci set system.@system[0].notes="${NOTES}"
    uci commit system
    /etc/init.d/system reload

    # ソフトウェアフローオフロード
    uci set firewall.@defaults[0].flow_offloading='1'
    uci commit firewall

    # ハードウェアフローオフロード（mediatek 判定）
    local Hardware_flow_offload
    Hardware_flow_offload=$(grep 'mediatek' /etc/openwrt_release)
    if [ "${Hardware_flow_offload:16:8}" = "mediatek" ]; then
        uci set firewall.@defaults[0].flow_offloading_hw='1'
        uci commit firewall
    fi

    # パケットステアリング
    uci set network.globals.packet_steering='1'
    uci commit network

    # カスタム DNS 設定
    uci -q delete dhcp.lan.dhcp_option
    uci -q delete dhcp.lan.dns
    # IPV4 DNS
    uci add_list dhcp.lan.dhcp_option="6,1.1.1.1,8.8.8.8"
    uci add_list dhcp.lan.dhcp_option="6,1.0.0.1,8.8.4.4"
    # IPV6 DNS
    uci add_list dhcp.lan.dns="2606:4700:4700::1111"
    uci add_list dhcp.lan.dns="2001:4860:4860::8888"
    uci add_list dhcp.lan.dns="2606:4700:4700::1001"
    uci add_list dhcp.lan.dns="2001:4860:4860::8844"
    uci set dhcp.@dnsmasq[0].cachesize='2000'
    uci set dhcp.lan.leasetime='24h'
    uci commit dhcp

    # ネットワークサービスの再起動
    #/etc/init.d/dnsmasq restart
    #/etc/init.d/odhcpd restart

    read -p "Press any key to reboot the device"
    reboot
}

#########################################################################
# メイン処理の開始
#########################################################################
download_country_zone
download_and_execute_common
check_common "$INPUT_LANG"
country_zone
information
select_timezone
#set_device_name_password
#set_wifi_ssid_password
#set_device
