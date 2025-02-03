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
#    などの関数および共通メッセージ管理関数 get_message を利用します。
#
echo "internet‑config.sh Last update 202502032202‑11"

#-----------------------------------------------------------------
# 基本設定
#-----------------------------------------------------------------
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"
SUPPORTED_LANGUAGES="en ja zh-cn zh-tw id ko de ru"
INPUT_LANG="$1"
# ※ LINKED 変数がセットされている場合は、openwrt‑config.sh からリンクで呼ばれているとみなす

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

#-----------------------------------------------------------------
# 外部ファイルの読み込みと初期化
#-----------------------------------------------------------------
download_and_execute_common
check_common "$INPUT_LANG"
download_country_zone
country_zone

#########################################################################
# ※ 以前は独自の get_message_Internet_config を定義していましたが、
#     共通の get_message を利用するため、削除しています。
#########################################################################

#########################################################################
# メインメニュー表示関数 (多言語対応)
#########################################################################
main_menu_internet() {
    # 共通文言は get_message 関数から取得
    title="$(get_message internet_title)"      # 例："インターネット設定" / "Internet Configuration"
    prompt="$(get_message select_prompt)"        # 例："選択してください:" / "Please select:"
    invalid="$(get_message invalid_option)"      # 例："無効なオプションです" / "Invalid option"
    exit_msg="$(get_message exit_message)"       # 例："終了" / "Exit"

    # インターネット接続固有の各メニュー項目（必要に応じて各自修正）
    menu_m="[m]: MAP‑E設定"
    menu_n="[n]: NURO光 MAP‑E設定"
    menu_t="[t]: DS‑Lite (transix) 設定"
    menu_x="[x]: DS‑Lite (xpass) 設定"
    menu_v="[v]: DS‑Lite (v6connect) 設定"
    menu_p="[p]: PPPoE設定"
    menu_e="[e]: ${exit_msg}"

    while :; do
        echo -e "$(color 'white' "-----------------------------------------------")"
        echo -e "$(color 'white' "$title")"
        echo -e "$(color 'blue'   "$menu_m")"
        echo -e "$(color 'yellow' "$menu_n")"
        echo -e "$(color 'green'  "$menu_t")"
        echo -e "$(color 'magenta' "$menu_x")"
        echo -e "$(color 'red'    "$menu_v")"
        echo -e "$(color 'cyan'   "$menu_p")"
        echo -e "$(color 'white' "$menu_e")"
        echo -e "$(color 'white' "-----------------------------------------------")"

        printf "%s" "$prompt"
        read option
        case "$option" in
            m) handle_map_e_menu ;;
            n) handle_nuro_map ;;
            t) handle_ds_lite_transix_menu ;;
            x) handle_ds_lite_xpass_menu ;;
            v) handle_ds_lite_v6connect_menu ;;
            p) handle_pppoe_menu ;;
            e)
                case "$SELECTED_LANGUAGE" in
                    en) echo "Exiting" ;;
                    *)  echo "スクリプト終了" ;;
                esac
                return 0 2>/dev/null || exit 0
                ;;
            *) echo -e "$(color 'red' "$invalid")" ;;
        esac
    done
}

#########################################################################
# 以下、各サブメニュー実装（インターネット接続固有の内容）
#########################################################################

# MAP‑E メニュー (例: OCNバーチャルコネクト)
handle_map_e_menu() {
    case "$SELECTED_LANGUAGE" in
        en)
            submenu_title="MAP‑E Configuration (OCN Virtual Connect etc.)"
            option1="[1]: Automatic MAP‑E Configuration"
            option2="[2]: Remove Automatic MAP‑E Configuration"
            option3="[3]: Multiple MAP‑E Configuration"
            option4="[4]: Remove Multiple MAP‑E Configuration"
            option_back="[r]: Back"
            prompt="Please select: "
            invalid="Invalid option"
            ;;
        *)
            submenu_title="MAP‑E設定 (OCNバーチャルコネクトなど)"
            option1="[1]: 自動MAP‑E設定"
            option2="[2]: 自動MAP‑E設定の削除"
            option3="[3]: 複数MAP‑E設定"
            option4="[4]: 複数MAP‑E設定の削除"
            option_back="[r]: 戻る"
            prompt="選択してください: "
            invalid="無効なオプションです"
            ;;
    esac

    while :; do
        echo -e "$(color 'white' "-----------------------------------------------")"
        echo -e "$(color 'white' "$submenu_title")"
        echo -e "$(color 'blue'   "$option1")"
        echo -e "$(color 'yellow' "$option2")"
        echo -e "$(color 'green'  "$option3")"
        echo -e "$(color 'magenta' "$option4")"
        echo -e "$(color 'white' "$option_back")"
        echo -e "$(color 'white' "-----------------------------------------------")"
        printf "%s" "$prompt"
        read opt
        case "$opt" in
            1) echo -e "$(color 'white' "MAP‑E自動設定を実行しました。")" ;;
            2) echo -e "$(color 'white' "MAP‑E自動設定の削除を実行しました。")" ;;
            3) echo -e "$(color 'white' "複数MAP‑E設定を実行しました。")" ;;
            4) echo -e "$(color 'white' "複数MAP‑E設定の削除を実行しました。")" ;;
            r) break ;;
            *) echo -e "$(color 'red' "$invalid")" ;;
        esac
    done
}

# NURO光 MAP‑E メニュー
handle_nuro_map() {
    case "$SELECTED_LANGUAGE" in
        en)
            submenu_title="NURO MAP‑E Configuration"
            prompt="Do you want to execute NURO MAP‑E configuration?"
            ;;
        *)
            submenu_title="NURO光 MAP‑E設定"
            prompt="NURO光 MAP‑E設定を実行しますか？"
            ;;
    esac

    echo -e "$(color 'white' "$submenu_title")"
    # 共通関数 ask_confirmation を利用
    if ask_confirmation; then
        echo -e "$(color 'white' "$submenu_title を実行しました。")"
    else
        echo -e "$(color 'white' "$(get_message cancelled_message)")"
    fi
}

# DS‑Lite (transix) メニュー
handle_ds_lite_transix_menu() {
    case "$SELECTED_LANGUAGE" in
        en)
            submenu_title="DS‑Lite (transix) Configuration"
            option1="[1]: Execute East configuration"
            option2="[2]: Execute West configuration"
            option_back="[r]: Back"
            prompt="Please select: "
            invalid="Invalid option"
            ;;
        *)
            submenu_title="DS‑Lite (transix) 設定"
            option1="[1]: 東日本設定実行"
            option2="[2]: 西日本設定実行"
            option_back="[r]: 戻る"
            prompt="選択してください: "
            invalid="無効なオプションです"
            ;;
    esac

    while :; do
        echo -e "$(color 'white' "-----------------------------------------------")"
        echo -e "$(color 'white' "$submenu_title")"
        echo -e "$(color 'blue'   "$option1")"
        echo -e "$(color 'yellow' "$option2")"
        echo -e "$(color 'white' "$option_back")"
        echo -e "$(color 'white' "-----------------------------------------------")"
        printf "%s" "$prompt"
        read opt
        case "$opt" in
            1) echo -e "$(color 'white' "$submenu_title: 東日本設定を実行しました。")" ;;
            2) echo -e "$(color 'white' "$submenu_title: 西日本設定を実行しました。")" ;;
            r) break ;;
            *) echo -e "$(color 'red' "$invalid")" ;;
        esac
    done
}

# DS‑Lite (xpass) メニュー
handle_ds_lite_xpass_menu() {
    case "$SELECTED_LANGUAGE" in
        en)
            submenu_title="DS‑Lite (xpass) Configuration"
            prompt="Do you want to execute DS‑Lite (xpass) configuration?"
            ;;
        *)
            submenu_title="DS‑Lite (xpass) 設定"
            prompt="DS‑Lite (xpass)設定を実行しますか？"
            ;;
    esac

    echo -e "$(color 'white' "$submenu_title")"
    if ask_confirmation; then
        echo -e "$(color 'white' "$submenu_title を実行しました。")"
    else
        echo -e "$(color 'white' "$(get_message cancelled_message)")"
    fi
}

# DS‑Lite (v6connect) メニュー
handle_ds_lite_v6connect_menu() {
    case "$SELECTED_LANGUAGE" in
        en)
            submenu_title="DS‑Lite (v6connect) Configuration"
            prompt="Do you want to execute DS‑Lite (v6connect) configuration?"
            ;;
        *)
            submenu_title="DS‑Lite (v6connect) 設定"
            prompt="DS‑Lite (v6connect)設定を実行しますか？"
            ;;
    esac

    echo -e "$(color 'white' "$submenu_title")"
    if ask_confirmation; then
        echo -e "$(color 'white' "$submenu_title を実行しました。")"
    else
        echo -e "$(color 'white' "$(get_message cancelled_message)")"
    fi
}

# PPPoE メニュー
handle_pppoe_menu() {
    case "$SELECTED_LANGUAGE" in
        en)
            submenu_title="PPPoE Configuration"
            # 入力プロンプトは、共通の get_message で管理する "input_prompt" キーを利用
            opt4="[4]: Please enter your username:"
            opt6="[6]: Please enter your password:"
            option_back="[r]: Back"
            prompt="Please select: "
            invalid="Invalid option"
            ;;
        *)
            submenu_title="PPPoE設定"
            opt4="[4]: $(get_message input_prompt) (ユーザー名)"
            opt6="[6]: $(get_message input_prompt) (パスワード)"
            option_back="[r]: 戻る"
            prompt="選択してください: "
            invalid="無効なオプションです"
            ;;
    esac

    while :; do
        echo -e "$(color 'white' "-----------------------------------------------")"
        echo -e "$(color 'white' "$submenu_title")"
        echo -e "$(color 'cyan' "$opt4")"
        echo -e "$(color 'green' "$opt6")"
        echo -e "$(color 'white' "$option_back")"
        echo -e "$(color 'white' "-----------------------------------------------")"
        printf "%s" "$prompt"
        read opt
        case "$opt" in
            4) pppoe_config_ipv4 ;;
            6) pppoe_config_ipv4_ipv6 ;;
            r) break ;;
            *) echo -e "$(color 'red' "$invalid")" ;;
        esac
    done
}

# PPPoE IPv4 設定処理 (仮実装)
pppoe_config_ipv4() {
    printf "%s " "$(get_message input_prompt) (ユーザー名)"
    read username
    printf "%s " "$(get_message input_prompt) (パスワード)"
    read password
    echo "IPv4設定: ユーザー名 [$username] / パスワード [$password] を実行しました。"
}

# PPPoE IPv4/IPv6 設定処理 (仮実装)
pppoe_config_ipv4_ipv6() {
    printf "%s " "$(get_message input_prompt) (ユーザー名)"
    read username6
    printf "%s " "$(get_message input_prompt) (パスワード)"
    read password6
    echo "IPv4/IPv6設定: ユーザー名 [$username6] / パスワード [$password6] を実行しました。"
}

#########################################################################
# エントリーポイント
#########################################################################
main_menu_internet
