#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main/"
BASE_DIR="/tmp/aios/"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"

# メニュー定義
MENU1="インターネット設定"
MENU2="システム初期設定"
MENU3="推奨パッケージインストール"
MENU4="広告ブロッカーインストール設定"
MENU5="アクセスポイント設定"
MENU6="その他のスクリプト設定"
MENU_EXIT="スクリプト終了"
MENU_DELETE_EXIT="スクリプト削除終了"

# メニューと対応するスクリプトの関連付け
MENU_ITEMS=(
    "$MENU1:internet-config.sh"
    "$MENU2:system-config.sh"
    "$MENU3:package-config.sh"
    "$MENU4:ad-dns-blocking-config.sh"
    "$MENU5:accesspoint-config.sh"
    "$MENU6:etc-config.sh"
    "$MENU_EXIT:exit_script"
    "$MENU_DELETE_EXIT:delete_and_exit"
)

download_common() {
    if [ ! -f "${BASE_DIR}common-functions.sh" ]; then
        wget --no-check-certificate -O "${BASE_DIR}common-functions.sh" "${BASE_URL}common-functions.sh"
    fi
    . "${BASE_DIR}common-functions.sh"
}

ask_confirmation() {
    local message="$1"
    local yn_message="${2:-[y/n]}"
    while true; do
        read -p "$(color white "${message} ${yn_message}: ")" choice
        case "${choice}" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo -e "$(color red "無効な入力です。'y' または 'n' を入力してください。")" ;;
        esac
    done
}

download_and_execute() {
    local script_name="$1"
    local description="$2"

    if ask_confirmation "${description}を実行しますか？"; then
        echo -e "$(color blue "ダウンロードと実行を開始します: ${description}")"
        if wget --no-check-certificate -O "${BASE_DIR}${script_name}" "${BASE_URL}${script_name}"; then
            echo -e "$(color green "ダウンロードが成功しました。")"
            sh "${BASE_DIR}${script_name}"
        else
            echo -e "$(color red "ダウンロードに失敗しました。")"
        fi
    else
        echo -e "$(color yellow "${description}をスキップしました。")"
    fi
}

exit_end() {
    if ask_confirmation "スクリプトを終了しますか？"; then
        echo -e "$(color white "スクリプトを終了します。")"
        exit
    else
        echo -e "$(color green "終了をキャンセルしました。")"
    fi
}

delete_and_exit() {
    if ask_confirmation "スクリプトを削除して終了しますか？"; then
        echo -e "$(color red "スクリプトを削除して終了します。")"
        rm -rf "${BASE_DIR}" /usr/bin/aios /tmp/aios-config.sh
        exit
    else
        echo -e "$(color green "削除をキャンセルしました。")"
    fi
}

main_menu() {
    while :; do
        echo -e "$(color white "------------------------------------------------------")"
        i=0
        for entry in "${MENU_ITEMS[@]}"; do
            description="${entry%%:*}"
            key=$(printf "%c" $((97 + i)))  # メニューキー (a, b, c...)
            echo -e "$(color blue "[${key}] ${description}")"
            i=$((i + 1))
        done
        echo -e "$(color white "------------------------------------------------------")"
        read -p "$(color white "選択してください: ")" option

        # 入力をインデックスに変換
        index=$(printf "%d" "'$option")
        index=$((index - 97))

        if [ "$index" -ge 0 ] && [ "$index" -lt "${#MENU_ITEMS[@]}" ]; then
            selected_entry="${MENU_ITEMS[$index]}"
            description="${selected_entry%%:*}"
            script_name="${selected_entry##*:}"
            if [ "$script_name" = "exit_script" ]; then
                exit_end
            elif [ "$script_name" = "delete_and_exit" ]; then
                delete_and_exit
            else
                download_and_execute "$script_name" "$description"
            fi
        else
            echo -e "$(color red "無効なオプションです。もう一度選択してください。")"
        fi
    done
}

download_common
main_menu
