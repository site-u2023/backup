#!/bin/sh
# OpenWrt Configuration Main Menu
echo openwrt-config.sh Last update 202502041600-1

# 共通関数の読み込み
. "/tmp/aios/common-functions.sh" || {
    echo "Failed to load common functions."
    exit 1
}

#########################################################################
# メインメニュー表示関数
#########################################################################
show_main_menu() {
    clear
    echo -e "$(color cyan "------------------------------------------------------")"
    echo -e "$(color green "   Dedicated Configuration Software for OpenWrt")"
    echo -e "$(color cyan "------------------------------------------------------")"
    echo -e "$(color yellow "[1]") Internet Settings"
    echo -e "$(color yellow "[2]") System Initialization"
    echo -e "$(color yellow "[3]") Recommended Package Installation"
    echo -e "$(color yellow "[4]") Ad Blocker Installation Settings"
    echo -e "$(color yellow "[5]") Access Point Settings"
    echo -e "$(color yellow "[6]") Other Script Settings"
    echo -e "$(color yellow "[7]") Select Country and Timezone"
    echo -e "$(color yellow "[8]") Exit Script"
    echo -e "$(color cyan "------------------------------------------------------")"
    
    read -p "Please make a selection [1-8]: " menu_choice
    
    case $menu_choice in
        1) configure_internet ;;
        2) initialize_system ;;
        3) install_recommended_packages ;;
        4) setup_ad_blocker ;;
        5) configure_access_point ;;
        6) other_script_settings ;;
        7) select_country_and_timezone ;;  # 国とタイムゾーン選択関数の呼び出し
        8) echo -e "$(color green "Exiting script. Goodbye!")"; exit 0 ;;
        *) echo -e "$(color red "Invalid selection. Please try again.")"; sleep 2; show_main_menu ;;
    esac
}

#########################################################################
# 各メニューの処理（必要に応じて別スクリプトに分割）
#########################################################################
configure_internet() {
    echo -e "$(color blue "Launching Internet Settings...")"
    # internet-config.sh を実行
    sh "/tmp/aios/internet-config.sh"
}

initialize_system() {
    echo -e "$(color blue "Initializing System...")"
    # system-config.sh を実行
    sh "/tmp/aios/system-config.sh"
}

# 他の設定関数も同様に追加

#########################################################################
# メイン処理
#########################################################################
show_main_menu
