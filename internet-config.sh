#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
#
# internet-config.sh
#
# このスクリプトは、MAP-E、DS-Lite、PPPoE などの各種インターネット接続設定メニューを
# 単一ファイル内で完結させる例です。
#
# ※ 外部の common-functions.sh からは、color、ask_confirmation、show_notification、check_common
#    などの関数および共通メッセージ管理関数 get_message、menu_option を利用します。
#
echo "internet-config.sh Last update 202502032202-14"

#-----------------------------------------------------------------
# 基本設定
#-----------------------------------------------------------------
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"
SUPPORTED_LANGUAGES="en ja zh-cn zh-tw id ko de ru"
INPUT_LANG="$1"

#########################################################################
# download_country_zone
#  国・ゾーン情報スクリプト (country-zone.sh) を BASE_URL からダウンロードする。
#  ダウンロードに失敗した場合は handle_error を呼び出して終了する。
#########################################################################
download_country_zone() {
    if [ ! -f "${BASE_DIR%/}/country-zone.sh" ]; then
        wget --quiet -O "${BASE_DIR%/}/country-zone.sh" "${BASE_URL}/country-zone.sh" || \
            handle_error "Failed to download country-zone.sh"
    fi
}

#########################################################################
# download_and_execute_common
#  common-functions.sh を BASE_URL からダウンロードし、読み込む。
#  失敗した場合は handle_error で終了する。
#########################################################################
download_and_execute_common() {
    if [ ! -f "${BASE_DIR%/}/common-functions.sh" ]; then
        wget --quiet -O "${BASE_DIR%/}/common-functions.sh" "${BASE_URL}/common-functions.sh" || \
            handle_error "Failed to download common-functions.sh"
    fi

    # shellcheck source=/dev/null
    source "${BASE_DIR%/}/common-functions.sh" || \
        handle_error "Failed to source common-functions.sh"
}

#-----------------------------------------------------------------
# 外部ファイルの読み込みと初期化
#-----------------------------------------------------------------
download_and_execute_common
check_common "$INPUT_LANG"
download_country_zone
country_zone

#########################################################################
# main_menu_internet
#  メインメニューを表示し、ユーザーの選択を受け付ける。（多言語対応）
#########################################################################
main_menu_internet() {
    # 共通文言は get_message から取得
    title="$(get_message internet_title)"          # 例："インターネット設定"
    prompt="$(get_message select_prompt)"            # 例："選択してください:"
    invalid="$(get_message invalid_option)"          # 例："無効なオプションです"
    exit_msg="$(get_message menu_exit)"              # 例："スクリプト終了"

    # 固有のメニュー項目は get_message のキーを利用（ここではそれぞれ固定）
    menu_m="[m]: $(get_message menu_map_e)"
    menu_n="[n]: $(get_message menu_nuro)"
    menu_t="[t]: $(get_message menu_transix)"
    menu_x="[x]: $(get_message menu_xpass)"
    menu_v="[v]: $(get_message menu_v6connect)"
    menu_p="[p]: $(get_message menu_pppoe)"
    menu_e="[e]: ${exit_msg}"

    # 各メニュー項目のアクション・ターゲットの設定
    ACTION_MAPE="download"
    TARGET_MAPE="https://raw.githubusercontent.com/site-u2023/aios/main/map-e.sh"
    ACTION_NURO="download"
    TARGET_NURO="https://raw.githubusercontent.com/site-u2023/aios/main/map-e.sh"
    ACTION_DSLITE="download"
    TARGET_DSLITE="https://raw.githubusercontent.com/site-u2023/aios/main/ds-lite.sh"
    ACTION_PPPOE="download"
    TARGET_PPPOE="pppoe-config.sh"  # ※ PPPoE はローカルまたは別途管理

    while :; do
        echo -e "$(color "white" "------------------------------------------------------")"
        echo -e "$(color "blue" "$menu_m")"
        echo -e "$(color "yellow" "$menu_n")"
        echo -e "$(color "green" "$menu_t")"
        echo -e "$(color "magenta" "$menu_x")"
        echo -e "$(color "red" "$menu_v")"
        echo -e "$(color "cyan" "$menu_p")"
        echo -e "$(color "white" "$menu_e")"
        echo -e "$(color "white" "------------------------------------------------------")"
        read -p "$(color "white" "$prompt")" option

        case "${option}" in
            "m")
                menu_option "${ACTION_MAPE}" "${menu_m}" "${TARGET_MAPE}"
                ;;
            "n")
                menu_option "${ACTION_NURO}" "${menu_n}" "${TARGET_NURO}"
                ;;
            "t")
                menu_option "${ACTION_DSLITE}" "${menu_t}" "${TARGET_DSLITE}"
                ;;
            "x")
                menu_option "${ACTION_DSLITE}" "${menu_x}" "${TARGET_DSLITE}"
                ;;
            "v")
                menu_option "${ACTION_DSLITE}" "${menu_v}" "${TARGET_DSLITE}"
                ;;
            "p")
                menu_option "${ACTION_PPPOE}" "${menu_p}" "${TARGET_PPPOE}"
                ;;
            "e")
                menu_option "exit" "${exit_msg}"
                return 0 2>/dev/null || exit 0
                ;;
            *)
                echo -e "$(color "red" "$(get_message invalid_option)")"
                ;;
        esac
    done
}

#########################################################################
# エントリーポイント
#########################################################################
get_system_info
display_info
main_menu_internet
