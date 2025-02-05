#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# 202502031417-10
# openwrt-config.sh
#
# このスクリプトは、OpenWrt 用のメインメニューおよびシステム情報表示、
# 各種設定スクリプトの起動などを行うためのメインスクリプトです。
#
# ・国・ゾーン情報スクリプト (country-zone.sh) のダウンロード
# ・共通関数 (common-functions.sh) のダウンロードと読み込み
# ・システム情報の取得と表示
# ・メインメニューの表示とユーザーによる各種オプションの選択
echo openwrt-config.sh Last update: 20250205-1

# 定数の設定
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"
SUPPORTED_LANGUAGES="en ja zh-cn zh-tw id ko de ru"
INPUT_LANG="$1"

# メインメニュー表示関数
show_main_menu() {
    clear
    echo -e "$(color cyan "------------------------------------------------------")"
    echo -e "$(color green "   Dedicated configuration software for OpenWrt")"
    echo -e "$(color cyan "------------------------------------------------------")"
    echo -e "$(color yellow "[1]") Internet Settings"
    echo -e "$(color yellow "[2]") System Initialization"
    echo -e "$(color yellow "[3]") Recommended Package Installation"
    echo -e "$(color yellow "[4]") Ad Blocker Installation Settings"
    echo -e "$(color yellow "[5]") Access Point Settings"
    echo -e "$(color yellow "[6]") Other Script Settings"
    echo -e "$(color yellow "[7]") Exit Script"
    echo -e "$(color cyan "------------------------------------------------------")"
    
    read -p "Please make a selection [1-7]: " menu_choice
    
    case $menu_choice in
        1) configure_internet ;;
        2) initialize_system ;;
        3) install_recommended_packages ;;
        4) setup_ad_blocker ;;
        5) configure_access_point ;;
        6) other_script_settings ;;
        7) echo -e "$(color green "Exiting script. Goodbye!")"; exit 0 ;;
        *) echo -e "$(color red "Invalid selection. Please try again.")"; sleep 2; show_main_menu ;;
    esac
}

# === 初期化処理 ===
check_version
check_language_support

# === メイン実行 ===
while true; do
    show_main_menu
done
