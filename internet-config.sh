#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
#
# internet-config.sh
#
# This script provides a menu for configuring various internet connections such as MAP-E, DS-Lite,
# or PPPoE. It is designed to work with the existing "common-functions.sh" in the aios environment.
#
# Multi-language support (ja / en) is now included in this file.
#
#-----------------------------------------------------------------
# 多言語対応メッセージ定義
#-----------------------------------------------------------------
# 使用する言語を環境変数LANGで指定 (例: LANG=en)。未指定の場合は日本語(ja)がデフォルトとなる。
echo openwrt-config.sh Last update 202502032202-1

# 定数の設定
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"
SUPPORTED_LANGUAGES="en ja zh-cn zh-tw id ko de ru"
INPUT_LANG="$1"

get_message() {
    key="$1"
    case "$CURRENT_LANG" in
        ja)
            case "$key" in
                internet_config_title) echo "インターネット設定" ;;
                menu_map_e) echo "MAP-E設定" ;;
                menu_nuro) echo "NURO光 MAP-E設定" ;;
                menu_transix) echo "DS-Lite transix設定" ;;
                menu_xpass) echo "DS-Lite xpass設定" ;;
                menu_v6connect) echo "DS-Lite v6connect設定" ;;
                menu_pppoe) echo "PPPoE設定" ;;
                menu_exit) echo "終了" ;;
                menu_select_prompt) echo "選択してください: " ;;
                invalid_option) echo "無効なオプションです" ;;
                map_e_auto) echo "自動MAP-E設定" ;;
                map_e_remove) echo "自動MAP-E設定の削除" ;;
                map_e_multi) echo "複数MAP-E設定" ;;
                map_e_multi_remove) echo "複数MAP-E設定の削除" ;;
                map_e_auto_confirm) echo "自動MAP-E設定を実行しますか？" ;;
                map_e_auto_revert) echo "自動MAP-E設定を元に戻しますか？" ;;
                map_e_multi_confirm) echo "複数MAP-E設定を実行しますか？" ;;
                map_e_multi_revert) echo "複数MAP-E設定を元に戻しますか？" ;;
                download_failure) echo "ダウンロードに失敗しました" ;;
                download_cancelled) echo "ダウンロードはキャンセルされました" ;;
                nuro_map_confirm) echo "NURO光 MAP-E設定を実行しますか？" ;;
                ds_lite_transix_east_confirm) echo "DS-Lite (transix) 東日本設定を実行しますか？" ;;
                ds_lite_transix_west_confirm) echo "DS-Lite (transix) 西日本設定を実行しますか？" ;;
                ds_lite_transix_revert) echo "DS-Lite (transix) 設定を元に戻しますか？" ;;
                ds_lite_xpass_confirm) echo "DS-Lite (xpass) 設定を実行しますか？" ;;
                ds_lite_v6connect_confirm) echo "DS-Lite (v6connect) 設定を実行しますか？" ;;
                pppoe_input_id) echo "ユーザー名を入力してください" ;;
                pppoe_input_pass) echo "パスワードを入力してください" ;;
                pppoe_input_id_v6) echo "IPv6用ユーザー名を入力してください" ;;
                pppoe_input_pass_v6) echo "IPv6用パスワードを入力してください" ;;
                pppoe_confirm) echo "設定を実行しますか？" ;;
                pppoe_revert4_confirm) echo "PPPoE (IPv4) 設定を元に戻しますか？" ;;
                pppoe_revert6_confirm) echo "PPPoE (IPv4/IPv6) 設定を元に戻しますか？" ;;
                ask_reboot) echo "再起動しますか？" ;;
                menu_exit_done) echo "終了します" ;;
                menu_back) echo "戻る" ;;
                *) echo "未定義のメッセージ: $key" ;;
            esac
            ;;
        en)
            case "$key" in
                internet_config_title) echo "Internet Configuration" ;;
                menu_map_e) echo "MAP-E Configuration" ;;
                menu_nuro) echo "NURO MAP-E Configuration" ;;
                menu_transix) echo "DS-Lite transix Configuration" ;;
                menu_xpass) echo "DS-Lite xpass Configuration" ;;
                menu_v6connect) echo "DS-Lite v6connect Configuration" ;;
                menu_pppoe) echo "PPPoE Configuration" ;;
                menu_exit) echo "Exit" ;;
                menu_select_prompt) echo "Please select: " ;;
                invalid_option) echo "Invalid option" ;;
                map_e_auto) echo "Automatic MAP-E Configuration" ;;
                map_e_remove) echo "Remove Automatic MAP-E Configuration" ;;
                map_e_multi) echo "Multiple MAP-E Configuration" ;;
                map_e_multi_remove) echo "Remove Multiple MAP-E Configuration" ;;
                map_e_auto_confirm) echo "Do you want to execute automatic MAP-E configuration?" ;;
                map_e_auto_revert) echo "Do you want to revert automatic MAP-E configuration?" ;;
                map_e_multi_confirm) echo "Do you want to execute multiple MAP-E configuration?" ;;
                map_e_multi_revert) echo "Do you want to revert multiple MAP-E configuration?" ;;
                download_failure) echo "Download failed" ;;
                download_cancelled) echo "Download cancelled" ;;
                nuro_map_confirm) echo "Do you want to execute NURO MAP-E configuration?" ;;
                ds_lite_transix_east_confirm) echo "Do you want to execute DS-Lite (transix) East configuration?" ;;
                ds_lite_transix_west_confirm) echo "Do you want to execute DS-Lite (transix) West configuration?" ;;
                ds_lite_transix_revert) echo "Do you want to revert DS-Lite (transix) configuration?" ;;
                ds_lite_xpass_confirm) echo "Do you want to execute DS-Lite (xpass) configuration?" ;;
                ds_lite_v6connect_confirm) echo "Do you want to execute DS-Lite (v6connect) configuration?" ;;
                pppoe_input_id) echo "Please enter your username" ;;
                pppoe_input_pass) echo "Please enter your password" ;;
                pppoe_input_id_v6) echo "Please enter your IPv6 username" ;;
                pppoe_input_pass_v6) echo "Please enter your IPv6 password" ;;
                pppoe_confirm) echo "Do you want to execute the configuration?" ;;
                pppoe_revert4_confirm) echo "Do you want to revert PPPoE (IPv4) configuration?" ;;
                pppoe_revert6_confirm) echo "Do you want to revert PPPoE (IPv4/IPv6) configuration?" ;;
                ask_reboot) echo "Do you want to reboot?" ;;
                menu_exit_done) echo "Exiting" ;;
                menu_back) echo "Back" ;;
                *) echo "Undefined message: $key" ;;
            esac
            ;;
        *)
            echo "Unsupported language: $CURRENT_LANG"
            ;;
    esac
}

#-----------------------------------------------------------------
# 基本設定
#-----------------------------------------------------------------
BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/site-u2023/aios/main}"
BASE_DIR="${BASE_DIR:-/tmp/aios}"

# ※ 以下の共通関数 (color, ask_confirmation, show_notification, check_common 等) は
#     コモンファイルへ分離する予定です。現状は仮実装・ダミー関数となります。

color() {
    # 仮の色付け処理: 第一引数で色指定、第二引数でメッセージ
    # 実際の環境に合わせて修正してください
    echo "$2"
}

ask_confirmation() {
    # 仮の確認ダイアログ: get_messageで表示した後、"y"の場合は真を返す
    prompt="$(get_message "$1") [y/n]: "
    printf "%s" "$prompt"
    read ans
    [ "$ans" = "y" ]
}

show_notification() {
    # 仮の通知表示: メッセージIDに対応するメッセージを表示
    echo "$(get_message "$1")"
}

check_common() {
    # 仮の多言語初期化などの処理
    :
}

#-----------------------------------------------------------------
# download_and_execute_common
#   ダウンロード＆読み込み (common-functions.sh) -- 既存のAIOS共通ファイル
#-----------------------------------------------------------------
download_and_execute_common() {
    if [ ! -f "${BASE_DIR}/common-functions.sh" ]; then
        wget --quiet -O "${BASE_DIR}/common-functions.sh" "${BASE_URL}/common-functions.sh" || {
            echo "Failed to download common-functions.sh"
            exit 1
        }
    fi
    # shellcheck source=/dev/null
    . "${BASE_DIR}/common-functions.sh" || {
        echo "Failed to source common-functions.sh"
        exit 1
    }
}

#-----------------------------------------------------------------
# main_menu_internet
#   インターネット接続メニューを表示するメイン関数
#-----------------------------------------------------------------
main_menu_internet() {
    local option
    while :; do
        echo -e "$(color "white" "-----------------------------------------------")"
        echo -e "$(color "white" "$(get_message internet_config_title)")"
        echo -e "$(color "blue"   "[m]: $(get_message menu_map_e)")"       # MAP-E
        echo -e "$(color "yellow" "[n]: $(get_message menu_nuro)")"        # NURO光 MAP-E
        echo -e "$(color "green"  "[t]: $(get_message menu_transix)")"    # DS-Lite: transix
        echo -e "$(color "magenta" "[x]: $(get_message menu_xpass)")"      # DS-Lite: xpass
        echo -e "$(color "red"    "[v]: $(get_message menu_v6connect)")"  # DS-Lite: v6connect
        echo -e "$(color "cyan"   "[p]: $(get_message menu_pppoe)")"      # PPPoE
        echo -e "$(color "white"  "[q]: $(get_message menu_exit)")"       # 終了
        echo -e "$(color "white" "-----------------------------------------------")"

        read -p "$(color "white" "$(get_message menu_select_prompt)")" option

        case "$option" in
            m) handle_map_e_menu ;;       # MAP-E関係
            n) handle_nuro_map ;;         # NURO光MAP-E
            t) handle_ds_lite_transix ;;  # DS-Lite: transix
            x) handle_ds_lite_xpass ;;    # DS-Lite: xpass
            v) handle_ds_lite_v6connect ;;# DS-Lite: v6connect
            p) handle_pppoe_menu ;;       # PPPoE
            q) echo -e "$(color "white" "$(get_message menu_exit_done)")"; exit 0 ;;
            *) echo -e "$(color "red" "$(get_message invalid_option)")" ;;
        esac
    done
}

#-----------------------------------------------------------------
# handle_map_e_menu
#   MAP-E回線の設定メニュー (例: OCNバーチャルコネクト等)
#-----------------------------------------------------------------
handle_map_e_menu() {
    local option
    while :; do
        echo -e "$(color "white" "----- MAP-E (OCNバーチャルコネクトなど) -----")"
        echo -e "$(color "blue"   "[1]: $(get_message map_e_auto)")"
        echo -e "$(color "yellow" "[2]: $(get_message map_e_remove)")"
        echo -e "$(color "green"  "[3]: $(get_message map_e_multi)")"
        echo -e "$(color "magenta" "[4]: $(get_message map_e_multi_remove)")"
        echo -e "$(color "white"  "[r]: $(get_message menu_back)")"

        read -p "$(color "white" "$(get_message menu_select_prompt)")" option
        case "$option" in
            1) confirm_map_e_auto ;;
            2) revert_map_e_auto  ;;
            3) confirm_map_e_multi ;;
            4) revert_map_e_multi ;;
            r) break ;;
            *) echo -e "$(color "red" "$(get_message invalid_option)")" ;;
        esac
    done
}

confirm_map_e_auto() {
    if ask_confirmation "map_e_auto_confirm"; then
        # ダウンロード & 実行(例: map-e-config.sh)
        if wget --quiet -O "${BASE_DIR}/map-e-config.sh" "${BASE_URL}/map-e-config.sh"; then
            . "${BASE_DIR}/map-e-config.sh" || {
                echo -e "$(color "red" "map-e-config.sh execution failed")"
                return
            }
        else
            echo -e "$(color "red" "$(get_message download_failure)")"
        fi
    else
        show_notification "download_cancelled"
    fi
}

revert_map_e_auto() {
    if ask_confirmation "map_e_auto_revert"; then
        echo -e "$(color "white" "$(get_message map_e_auto_revert)")"
        # 例: 以前の設定ファイルを復元
        # cp /etc/config/network.old /etc/config/network
        # ...
        ask_reboot
    else
        show_notification "download_cancelled"
    fi
}

confirm_map_e_multi() {
    if ask_confirmation "map_e_multi_confirm"; then
        echo -e "$(color "white" "$(get_message map_e_multi)")"
        # 例: マルチセッション対応スクリプトの実行
        ask_reboot
    else
        show_notification "download_cancelled"
    fi
}

revert_map_e_multi() {
    if ask_confirmation "map_e_multi_revert"; then
        echo -e "$(color "white" "$(get_message map_e_multi_revert)")"
        # 例: マルチセッション対応設定の復元
        ask_reboot
    else
        show_notification "download_cancelled"
    fi
}

#-----------------------------------------------------------------
# handle_nuro_map
#   NURO光 MAP-E設定
#-----------------------------------------------------------------
handle_nuro_map() {
    if ask_confirmation "nuro_map_confirm"; then
        # ダウンロード & 実行(例: nuro-map.sh)
        if wget --quiet -O "${BASE_DIR}/nuro-map.sh" "${BASE_URL}/nuro-map.sh"; then
            . "${BASE_DIR}/nuro-map.sh" || {
                echo -e "$(color "red" "nuro-map.sh execution failed")"
                return
            }
        else
            echo -e "$(color "red" "$(get_message download_failure)")"
        fi
    else
        show_notification "download_cancelled"
    fi
}

#-----------------------------------------------------------------
# handle_ds_lite_transix, handle_ds_lite_xpass, handle_ds_lite_v6connect
#   DS-Lite系メニュー: transix / xpass / v6connect
#-----------------------------------------------------------------
handle_ds_lite_transix() {
    local option
    while :; do
        echo -e "$(color "white" "----- DS-Lite: transix -----")"
        echo -e "$(color "blue"   "[1]: $(get_message ds_lite_transix_east_confirm)")"
        echo -e "$(color "yellow" "[2]: $(get_message ds_lite_transix_west_confirm)")"
        echo -e "$(color "red"    "[b]: $(get_message ds_lite_transix_revert)")"
        echo -e "$(color "white"  "[r]: $(get_message menu_back)")"

        read -p "$(color "white" "$(get_message menu_select_prompt)")" option
        case "$option" in
            1) ds_lite_transix_east ;;
            2) ds_lite_transix_west ;;
            b) revert_ds_lite_transix ;;
            r) break ;;
            *) echo -e "$(color "red" "$(get_message invalid_option)")" ;;
        esac
    done
}

ds_lite_transix_east() {
    if ask_confirmation "ds_lite_transix_east_confirm"; then
        # DS-Lite (transix) 東日本設定実行例
        ask_reboot
    else
        show_notification "download_cancelled"
    fi
}

ds_lite_transix_west() {
    if ask_confirmation "ds_lite_transix_west_confirm"; then
        # DS-Lite (transix) 西日本設定実行例
        ask_reboot
    else
        show_notification "download_cancelled"
    fi
}

revert_ds_lite_transix() {
    if ask_confirmation "ds_lite_transix_revert"; then
        # DS-Lite (transix) 設定の復元例
        ask_reboot
    else
        show_notification "download_cancelled"
    fi
}

handle_ds_lite_xpass() {
    if ask_confirmation "ds_lite_xpass_confirm"; then
        # DS-Lite (xpass) 設定実行例
        ask_reboot
    else
        show_notification "download_cancelled"
    fi
}

handle_ds_lite_v6connect() {
    if ask_confirmation "ds_lite_v6connect_confirm"; then
        # DS-Lite (v6connect) 設定実行例
        ask_reboot
    else
        show_notification "download_cancelled"
    fi
}

#-----------------------------------------------------------------
# handle_pppoe_menu
#   PPPoEメニュー
#-----------------------------------------------------------------
handle_pppoe_menu() {
    local option
    while :; do
        echo -e "$(color "white" "----- PPPoE -----")"
        echo -e "$(color "cyan"  "[4]: $(get_message pppoe_input_id)")"
        echo -e "$(color "green" "[6]: $(get_message pppoe_input_id_v6)")"
        echo -e "$(color "red"   "[b]: $(get_message pppoe_revert4_confirm)")"
        echo -e "$(color "magenta" "[w]: $(get_message pppoe_revert6_confirm)")"
        echo -e "$(color "white"  "[r]: $(get_message menu_back)")"

        read -p "$(color "white" "$(get_message menu_select_prompt)")" option
        case "$option" in
            4) pppoe_id_v4 ;;
            6) pppoe_id_v4v6 ;;
            b) revert_pppoe_v4 ;;
            w) revert_pppoe_v4v6 ;;
            r) break ;;
            *) echo -e "$(color "red" "$(get_message invalid_option)")" ;;
        esac
    done
}

pppoe_id_v4() {
    echo -e "$(color "white" "$(get_message pppoe_input_id)")"
    read -p "UserName (IPv4): " input_str_ID
    echo -e "$(color "white" "$(get_message pppoe_input_pass)")"
    read -p "Password (IPv4): " input_str_PASS
    echo -e "$(color "white" "IPv4-ID: ${input_str_ID} / IPv4-Pass: ${input_str_PASS}")"
    if ask_confirmation "pppoe_confirm"; then
        # PPPoE設定実行例 (例: pppoe-config.sh)
        ask_reboot
    else
        show_notification "download_cancelled"
    fi
}

pppoe_id_v4v6() {
    echo -e "$(color "white" "$(get_message pppoe_input_id)")"
    read -p "UserName (IPv4): " input_str_ID4
    echo -e "$(color "white" "$(get_message pppoe_input_pass)")"
    read -p "Password (IPv4): " input_str_PASS4
    echo -e "$(color "white" "$(get_message pppoe_input_id_v6)")"
    read -p "UserName (IPv6): " input_str_ID6
    echo -e "$(color "white" "$(get_message pppoe_input_pass_v6)")"
    read -p "Password (IPv6): " input_str_PASS6

    echo -e "$(color "white" "IPv4-ID: ${input_str_ID4} / IPv4-Pass: ${input_str_PASS4}")"
    echo -e "$(color "white" "IPv6-ID: ${input_str_ID6} / IPv6-Pass: ${input_str_PASS6}")"
    if ask_confirmation "pppoe_confirm"; then
        # PPPoE (IPv4/IPv6)設定実行例 (例: pppoe6-config.sh)
        ask_reboot
    else
        show_notification "download_cancelled"
    fi
}

revert_pppoe_v4() {
    if ask_confirmation "pppoe_revert4_confirm"; then
        # PPPoE (IPv4) 設定復元例
        ask_reboot
    else
        show_notification "download_cancelled"
    fi
}

revert_pppoe_v4v6() {
    if ask_confirmation "pppoe_revert6_confirm"; then
        # PPPoE (IPv4/IPv6) 設定復元例
        ask_reboot
    else
        show_notification "download_cancelled"
    fi
}

#-----------------------------------------------------------------
# ask_reboot:
#   再起動するかどうかの共通処理
#-----------------------------------------------------------------
ask_reboot() {
    echo -e "$(color "white" "$(get_message ask_reboot)")"
    read -p "$(color "white" "[y/n]: ")" ans
    if [ "$ans" = "y" ]; then
        reboot
    fi
}

#-----------------------------------------------------------------
# mainエントリポイント
#-----------------------------------------------------------------
download_and_execute_common

# check_common で多言語選択などの初期化を実施 (仮実装)
check_common "$1"

# メインメニューの起動
main_menu_internet
