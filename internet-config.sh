#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
#
# internet‑config.sh
#
# このスクリプトは、MAP‑E、DS‑Lite、PPPoE などの各種インターネット接続設定メニューを
# 単一ファイル内で完結させる例です。
#
# ※ 外部の common‑functions.sh からは、color、ask_confirmation、show_notification、check_common
#    などの関数および共通メッセージ管理関数 get_message、そして menu_option を利用します。
#
echo "internet‑config.sh Last update 202502032202‑12"

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
#  国・ゾーン情報スクリプト (country‑zone.sh) を BASE_URL からダウンロードする。
#  ダウンロードに失敗した場合は handle_error を呼び出して終了する。
#########################################################################
download_country_zone() {
    if [ ! -f "${BASE_DIR%/}/country‑zone.sh" ]; then
        wget --quiet -O "${BASE_DIR%/}/country‑zone.sh" "${BASE_URL}/country‑zone.sh" || \
            handle_error "Failed to download country‑zone.sh"
    fi
}

#########################################################################
# download_and_execute_common
#  common‑functions.sh を BASE_URL からダウンロードし、読み込む。
#  失敗した場合は handle_error で終了する。
#########################################################################
download_and_execute_common() {
    if [ ! -f "${BASE_DIR%/}/common‑functions.sh" ]; then
        wget --quiet -O "${BASE_DIR%/}/common‑functions.sh" "${BASE_URL}/common‑functions.sh" || \
            handle_error "Failed to download common‑functions.sh"
    fi

    # shellcheck source=/dev/null
    source "${BASE_DIR%/}/common‑functions.sh" || \
        handle_error "Failed to source common‑functions.sh"
}

#########################################################################
# メインメニュー表示関数 (多言語対応)
#########################################################################
main_menu_internet() {
    # 共通文言は get_message から取得
    title="$(get_message internet_title)"      # 例："インターネット設定" / "Internet Configuration"
    prompt="$(get_message select_prompt)"        # 例："選択してください:" / "Please select:"
    invalid="$(get_message invalid_option)"      # 例："無効なオプションです" / "Invalid option"
    exit_msg="$(get_message exit_message)"       # 例："終了" / "Exit"

    # 固有のメニュー項目は、基本的な文言は直接記述するか、必要に応じて get_message から取得
    menu_m="[m]: MAP‑E設定"
    menu_n="[n]: NURO光 MAP‑E設定"
    menu_t="[t]: DS‑Lite (transix) 設定"
    menu_x="[x]: DS‑Lite (xpass) 設定"
    menu_v="[v]: DS‑Lite (v6connect) 設定"
    menu_p="[p]: PPPoE設定"
    menu_e="[e]: ${exit_msg}"

    # 各メニュー項目のアクションは、共通関数 menu_option 経由で実行するために、ACTION と TARGET を設定
    # ここでは、MAP‑E と DS‑Lite の設定用スクリプトは GitHub からダウンロードして実行します
    ACTION_MAPE="download"
    TARGET_MAPE="https://raw.githubusercontent.com/site-u2023/aios/main/map-e.sh"
    ACTION_NURO="download"
    # NURO光 MAP‑E 設定は、ここでは個別のスクリプト（必要に応じて URL を指定）に変更可能
    TARGET_NURO="https://raw.githubusercontent.com/site-u2023/aios/main/map-e.sh"
    ACTION_DSLITE="download"
    TARGET_DSLITE="https://raw.githubusercontent.com/site-u2023/aios/main/ds-lite.sh"
    ACTION_PPPOE="download"
    TARGET_PPPOE="pppoe-config.sh"  # ※ PPPoE はローカルまたは別途管理

    while :; do
        echo -e "$(color "white" "------------------------------------------------------")"
        echo -e "$(color "blue" "[m]: ${menu_m}")"
        echo -e "$(color "yellow" "[n]: ${menu_n}")"
        echo -e "$(color "green" "[t]: ${menu_t}")"
        echo -e "$(color "magenta" "[x]: ${menu_x}")"
        echo -e "$(color "red" "[v]: ${menu_v}")"
        echo -e "$(color "cyan" "[p]: ${menu_p}")"
        echo -e "$(color "white" "[e]: ${menu_e}")"
        echo -e "$(color "white" "------------------------------------------------------")"
        read -p "$(color "white" "${prompt}")" option

        case "${option}" in
            "m")
                # MAP‑E の設定：menu_option を利用して、TARGET_MAPE のスクリプトをダウンロード・実行
                menu_option "${ACTION_MAPE}" "${menu_m}" "${TARGET_MAPE}"
                ;;
            "n")
                # NURO光 MAP‑E 設定（同一の MAP‑E スクリプトを利用する例）
                menu_option "${ACTION_NURO}" "${menu_n}" "${TARGET_NURO}"
                ;;
            "t")
                # DS‑Lite (transix) 設定：同じ DS‑Lite スクリプトを利用
                menu_option "${ACTION_DSLITE}" "${menu_t}" "${TARGET_DSLITE}"
                ;;
            "x")
                # DS‑Lite (xpass) 設定
                menu_option "${ACTION_DSLITE}" "${menu_x}" "${TARGET_DSLITE}"
                ;;
            "v")
                # DS‑Lite (v6connect) 設定
                menu_option "${ACTION_DSLITE}" "${menu_v}" "${TARGET_DSLITE}"
                ;;
            "p")
                # PPPoE 設定：別途、ローカルの PPPoE 設定スクリプトを利用
                menu_option "${ACTION_PPPOE}" "${menu_p}" "${TARGET_PPPOE}"
                ;;
            "e")
                menu_option "exit" "${exit_msg}"
                return 0 2>/dev/null || exit 0
                ;;
            *) echo -e "$(color "red" "$(get_message invalid_option)")" ;;
        esac
    done
}

#########################################################################
# エントリーポイント
#########################################################################
download_and_execute_common
check_common "$INPUT_LANG"
download_country_zone
country_zone
main_menu_internet
