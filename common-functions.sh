#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# 202502022041-9
# common-functions.sh
#
# 各種共通処理（ヘルプ表示、カラー出力、システム情報確認、言語選択、確認・通知メッセージの多言語対応など）を提供する。
#

# 基本定数の設定
BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/site-u2023/aios/main}"
BASE_DIR="${BASE_DIR:-/tmp/aios}"
SUPPORTED_VERSIONS="${SUPPORTED_VERSIONS:-19 21 22 23 24 SN}"
SUPPORTED_LANGUAGES="${SUPPORTED_LANGUAGES:-en}"

#########################################################################
# エラーハンドリング関数
# 引数: エラーメッセージ
# エラー発生時に指定メッセージを赤色で表示し、スクリプトを終了する
#########################################################################
handle_error() {
    local msg="$1"
    echo -e "$(color red "$msg")" >&2
    exit 1
}

#########################################################################
# print_help: ヘルプメッセージを表示する関数
#########################################################################
print_help() {
    cat << 'EOF'
aios - Dedicated configuration software for OpenWrt

Usage:
  aios [OPTION] [LANGUAGE]

Options:
  -h, -help, --help       Display this help message and exit.
  -r, -reset, --reset     Clear cached language and country settings.

Arguments:
  LANGUAGE         Language code to be used immediately.
                   If not provided, an interactive language selection menu will be displayed.

Supported Languages:
  en, ja, zh-cn, zh-tw

Examples:
  aios
    -> Launches the interactive language selection menu.

  aios en
    -> Runs the script with English language.

  aios -r ja
    -> Clears cache and runs the script with Japanese language.
EOF
}

#########################################################################
# color_code_map: カラー名から ANSI エスケープシーケンスを返す関数
# 引数: 色の名前 (例: red, green, reset 等)
#########################################################################
color_code_map() {
    local color="$1"
    case "$color" in
        "red") echo "\033[1;31m" ;;
        "green") echo "\033[1;32m" ;;
        "yellow") echo "\033[1;33m" ;;
        "blue") echo "\033[1;34m" ;;
        "magenta") echo "\033[1;35m" ;;
        "cyan") echo "\033[1;36m" ;;
        "white") echo "\033[1;37m" ;;
        "red_underline") echo "\033[4;31m" ;;
        "green_underline") echo "\033[4;32m" ;;
        "yellow_underline") echo "\033[4;33m" ;;
        "blue_underline") echo "\033[4;34m" ;;
        "magenta_underline") echo "\033[4;35m" ;;
        "cyan_underline") echo "\033[4;36m" ;;
        "white_underline") echo "\033[4;37m" ;;
        "red_white") echo "\033[1;41m" ;;
        "green_white") echo "\033[1;42m" ;;
        "yellow_white") echo "\033[1;43m" ;;
        "blue_white") echo "\033[1;44m" ;;
        "magenta_white") echo "\033[1;45m" ;;
        "cyan_white") echo "\033[1;46m" ;;
        "white_black") echo "\033[7;40m" ;;
        "reset") echo "\033[0;39m" ;;
        *) echo "\033[0;39m" ;;
    esac
}

#########################################################################
# color: 指定した色でメッセージを出力する関数
# 引数1: 色の名前、引数以降: 出力する文字列
#########################################################################
color() {
    local col
    col=$(color_code_map "$1")
    shift
    echo -e "${col}$*$(color_code_map "reset")"
}

#########################################################################
# check_version: OpenWrt のバージョン情報を取得し、対応バージョンか検証する
#########################################################################
check_version() {
    local version
    version=$(awk -F"'" '/DISTRIB_RELEASE/ {print $2}' /etc/openwrt_release | cut -c 1-2) || handle_error "バージョン情報の取得に失敗しました。"
    RELEASE_VERSION="$version"
    echo "${RELEASE_VERSION}" > "${BASE_DIR}/check_version"
    
    if ! echo "${SUPPORTED_VERSIONS}" | grep -qw "${RELEASE_VERSION}"; then
        handle_error "Unsupported OpenWrt version: ${RELEASE_VERSION}\nSupported versions: ${SUPPORTED_VERSIONS}"
    fi
}

#########################################################################
# check_package_manager: パッケージマネージャー (apk/opkg) の存在を確認する
#########################################################################
check_package_manager() {
    if command -v apk >/dev/null 2>&1; then
        PACKAGE_MANAGER="APK"
    elif command -v opkg >/dev/null 2>&1; then
        PACKAGE_MANAGER="OPKG"
    else
        handle_error "No package manager found"
    fi
    echo "${PACKAGE_MANAGER}" > "${BASE_DIR}/check_package_manager"
}

#########################################################################
# check_language: 言語選択メニューを表示し、ユーザーに言語を選択させる
#########################################################################
check_language() {
    local country_data lang_field output
    echo -e "$(color white "------------------------------------------------------")"
    echo -e "$(color white "Select your language")"

    country_data=$(sh "${BASE_DIR}/country-zone.sh" "") || handle_error "country-zone.sh の実行に失敗しました。"

    echo "$country_data" | while IFS= read -r line; do
        [ -z "$line" ] && continue
        lang_field=$(echo "$line" | awk '{print $3}')  # 言語コード
        if [ "$lang_field" != "xx" ]; then
            output=$(echo "$line" | awk '{print $1, $2, $3, $4, $5}')  # 国名、母国語、言語コード、国コード、タイムゾーンを表示
            echo -e "$(color white "$output")"
        fi
    done

    echo -e "$(color white "------------------------------------------------------")"
    read -p "$(color white "Please choose: ")" INPUT_LANG
    process_language_selection "$INPUT_LANG"
    normalize_language
}

#########################################################################
# check_common: 初期化処理（オプション処理、バージョン・パッケージマネージャ確認、言語選択）
#########################################################################
check_common() {
    # オプション処理
    case "$1" in
        -h|-help|--help)
            print_help
            exit 0
            ;;
        --reset|-reset|-r)
            rm -f "${BASE_DIR}/check_language" "${BASE_DIR}/check_country" || handle_error "キャッシュの削除に失敗しました。"
            echo "Language and country cache cleared."
            shift  # 次の引数を処理するためにシフト
            ;;
    esac

    # バージョン情報の取得
    if [ -f "${BASE_DIR}/check_version" ]; then
        RELEASE_VERSION=$(cat "${BASE_DIR}/check_version")
    fi
    [ -z "$RELEASE_VERSION" ] && check_version

    # パッケージマネージャーの取得
    if [ -f "${BASE_DIR}/check_package_manager" ]; then
        PACKAGE_MANAGER=$(cat "${BASE_DIR}/check_package_manager")
    fi
    [ -z "$PACKAGE_MANAGER" ] && check_package_manager  

    # コマンドライン引数で言語指定があれば優先する
    if [ -n "$1" ]; then
        process_language_selection "$1"
    fi

    # キャッシュから言語・国コードを読み込む
    if [ -f "${BASE_DIR}/check_language" ]; then
        SELECTED_LANGUAGE=$(cat "${BASE_DIR}/check_language")
    fi
    if [ -f "${BASE_DIR}/check_country" ]; then
        SELECTED_COUNTRY=$(cat "${BASE_DIR}/check_country")
    fi

    # 言語が未設定の場合、言語選択メニューを表示する
    if [ -z "$SELECTED_LANGUAGE" ]; then
        check_language
    fi

    normalize_language  # 言語の正規化
}

#########################################################################
# menu_option: メインメニューの各オプションに対応する処理を行う
#########################################################################
menu_option() {
    local action="$1"
    local description="$2"
    local script_name="$3"
    local input_lang="$4"
    
    echo -e "$(color white "$description")"

    case "$action" in
        "exit")
            if ask_confirmation "exit"; then
                show_notification "exit"
                exit 0
            else
                show_notification "exit_cancelled"
            fi
            ;;
        "delete")
            if ask_confirmation "delete"; then
                rm -rf "${BASE_DIR}" /usr/bin/aios /tmp/aios.sh || handle_error "削除に失敗しました。"
                show_notification "delete_success"
                exit 0
            else
                show_notification "delete_cancelled"
            fi
            ;;
        "download")
            if ask_confirmation "download"; then
                if wget --quiet -O "${BASE_DIR}/${script_name}" "${BASE_URL}/${script_name}"; then
                    show_notification "download_success"
                    . "${BASE_DIR}/${script_name}" "$input_lang" || handle_error "スクリプトの実行に失敗しました。"
                else
                    show_notification "download_failure"
                fi
            else
                show_notification "download_cancelled"
            fi
            ;;
        *)
            echo -e "$(color red "Unknown action.")"
            ;;
    esac
}

#########################################################################
# get_message: 多言語対応のメッセージを一元管理する関数
# 引数: メッセージキー
#########################################################################
get_message() {
    local key="$1"
    local lang="${SELECTED_LANGUAGE:-en}"
    case "$lang" in
        en)
            case "$key" in
                confirm_default) echo "Are you sure?" ;;
                reenter_prompt)  echo "Do you want to re-enter?" ;;
                choose_prompt)   echo "Please choose: " ;;
                download_success) echo "Download successful." ;;
                download_failure) echo "Download failed." ;;
                exit_cancelled) echo "Exit operation cancelled." ;;
                delete_cancelled) echo "Delete operation cancelled." ;;
                delete_success) echo "Script and configuration deleted." ;;
                download_cancelled) echo "Download operation cancelled." ;;
                exit_complete) echo "Exit operation completed." ;;
                delete_complete) echo "Delete operation completed." ;;
                *) echo "Operation completed." ;;
            esac
            ;;
        ja)
            case "$key" in
                confirm_default) echo "本当に実行しますか？" ;;
                reenter_prompt)  echo "再入力しますか？" ;;
                choose_prompt)   echo "選択してください: " ;;
                download_success) echo "ダウンロードが成功しました。" ;;
                download_failure) echo "ダウンロードに失敗しました。" ;;
                exit_cancelled) echo "終了操作がキャンセルされました。" ;;
                delete_cancelled) echo "削除操作がキャンセルされました。" ;;
                delete_success) echo "スクリプトと設定が削除されました。" ;;
                download_cancelled) echo "ダウンロード操作がキャンセルされました。" ;;
                exit_complete) echo "終了操作が完了しました。" ;;
                delete_complete) echo "削除操作が完了しました。" ;;
                *) echo "操作が完了しました。" ;;
            esac
            ;;
        zh-cn)
            case "$key" in
                confirm_default) echo "您确定吗？" ;;
                reenter_prompt)  echo "您要重新输入吗？" ;;
                choose_prompt)   echo "请选择: " ;;
                download_success) echo "下载成功。" ;;
                download_failure) echo "下载失败。" ;;
                exit_cancelled) echo "退出操作已取消。" ;;
                delete_cancelled) echo "删除操作已取消。" ;;
                delete_success) echo "脚本和配置已删除。" ;;
                download_cancelled) echo "下载操作已取消。" ;;
                exit_complete) echo "退出操作已完成。" ;;
                delete_complete) echo "删除操作已完成。" ;;
                *) echo "操作已完成。" ;;
            esac
            ;;
        zh-tw)
            case "$key" in
                confirm_default) echo "您確定嗎？" ;;
                reenter_prompt)  echo "您要重新輸入嗎？" ;;
                choose_prompt)   echo "請選擇: " ;;
                download_success) echo "下載成功。" ;;
                download_failure) echo "下載失敗。" ;;
                exit_cancelled) echo "退出操作已取消。" ;;
                delete_cancelled) echo "刪除操作已取消。" ;;
                delete_success) echo "腳本和配置已刪除。" ;;
                download_cancelled) echo "下載操作已取消。" ;;
                exit_complete) echo "退出操作已完成。" ;;
                delete_complete) echo "刪除操作已完成。" ;;
                *) echo "操作已完成。" ;;
            esac
            ;;
        *)
            case "$key" in
                confirm_default) echo "Are you sure?" ;;
                reenter_prompt)  echo "Do you want to re-enter?" ;;
                choose_prompt)   echo "Please choose: " ;;
                download_success) echo "Download successful." ;;
                download_failure) echo "Download failed." ;;
                exit_cancelled) echo "Exit operation cancelled." ;;
                delete_cancelled) echo "Delete operation cancelled." ;;
                delete_success) echo "Script and configuration deleted." ;;
                download_cancelled) echo "Download operation cancelled." ;;
                exit_complete) echo "Exit operation completed." ;;
                delete_complete) echo "Delete operation completed." ;;
                *) echo "Operation completed." ;;
            esac
            ;;
    esac
}

#########################################################################
# ask_confirmation: 確認プロンプトを表示し、ユーザーの入力 (y/n) を待つ
#########################################################################
ask_confirmation() {
    local prompt
    prompt=$(get_message confirm_default)
    local choice
    while true; do
        read -p "$(color white "$prompt [y/n]: ")" choice
        case "$choice" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo -e "$(color white "Invalid choice, please enter 'y' or 'n'.")" ;;
        esac
    done
}

#########################################################################
# show_notification: 通知メッセージを表示する関数
#########################################################################
show_notification() {
    local key="$1"
    local message
    message=$(get_message "$key")
    echo -e "$(color white "$message")"
}

#########################################################################
# normalize_language: キャッシュの言語コードがサポート対象か検証し、
#                      サポート外の場合はデフォルト (en) に上書きする
#########################################################################
normalize_language() {
    local CHECK_LANGUAGE READ_LANGUAGE
    CHECK_LANGUAGE="${BASE_DIR}/check_language"
    if [ -f "$CHECK_LANGUAGE" ]; then
        READ_LANGUAGE=$(cat "$CHECK_LANGUAGE")
    fi

    SELECTED_LANGUAGE=""
    for lang in $SUPPORTED_LANGUAGES; do
        if [ "$READ_LANGUAGE" = "$lang" ]; then
            SELECTED_LANGUAGE="$READ_LANGUAGE"
            break
        fi
    done

    if [ -z "$SELECTED_LANGUAGE" ]; then
        SELECTED_LANGUAGE="en"
        echo "Language not supported. Defaulting to English (en)."
        echo "$SELECTED_LANGUAGE" > "${BASE_DIR}/check_language"
    fi
}

#########################################################################
# process_language_selection: ユーザー入力の言語コードから有効な候補を選択する
#########################################################################
process_language_selection() {
    local INPUT_LANG="$1" found_entries found_entry new_input choice num_matches
    while true; do
        INPUT_LANG=$(echo "$INPUT_LANG" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        # 言語コードが含まれる行を正確にフィルタリング
        found_entries=$(sh "${BASE_DIR}/country-zone.sh" | grep -i "\b${INPUT_LANG}\b")

        # 該当エントリがない場合の処理
        if [ -z "$found_entries" ]; then
            echo "No matching entry found."
            read -p "$(color white "Do you want to re-enter? [y/n]: ")" choice
            case "$choice" in
                [Yy])
                    read -p "$(color white "Please re-enter language: ")" new_input
                    INPUT_LANG="$new_input"
                    continue
                    ;;
                *)
                    echo "Defaulting to English (en)."
                    found_entries=$(sh "${BASE_DIR}/country-zone.sh" | grep -i "\ben\b")
            esac
        fi

        # 複数候補があれば番号選択
        num_matches=$(echo "$found_entries" | wc -l)
        if [ "$num_matches" -gt 1 ]; then
            echo "Multiple matches found. Please select:"
            local i=1
            echo "$found_entries" | while IFS= read -r line; do
                echo "[$i] $line"
                i=$((i+1))
            done
            echo "[0] Re-enter language"
            read -p "$(color white "Enter the number of your choice: ")" choice
            if [ "$choice" = "0" ]; then
                read -p "$(color white "Please re-enter language: ")" new_input
                INPUT_LANG="$new_input"
                continue
            fi
            found_entry=$(echo "$found_entries" | sed -n "${choice}p")
            if [ -z "$found_entry" ]; then
                echo "Invalid selection. Please re-enter."
                read -p "$(color white "Please re-enter language: ")" new_input
                INPUT_LANG="$new_input"
                continue
            fi
        else
            found_entry="$found_entries"
        fi

        break  # 有効な候補が取得できたのでループを抜ける
    done

    # フィールド抽出の修正
    SELECTED_LANGUAGE=$(echo "$found_entry" | awk '{print $3}')  # 言語コード
    SELECTED_COUNTRY=$(echo "$found_entry" | awk '{print $4}')   # 国コード
        
    echo "$SELECTED_LANGUAGE" > "${BASE_DIR}/check_language"
    echo "$SELECTED_COUNTRY" > "${BASE_DIR}/check_country"

    echo "Selected Language: $SELECTED_LANGUAGE"
    echo "Selected Country: $SELECTED_COUNTRY"
}

#########################################################################
# country_zone: 国・ゾーン情報を取得する関数
# country-zonename.sh および country-timezone.sh を利用してゾーン名、タイムゾーン、言語情報を取得する
#########################################################################

country_zone() {
    local country_file="${BASE_DIR}/country-zone.sh"
    local country=$(cat "${BASE_DIR}/check_country")

    ZONENAME=$(sh "$country_file" "$country" "name")
    DISPLAYNAME=$(sh "$country_file" "$country" "display")
    LANGUAGE=$(sh "$country_file" "$country" "lang")
    COUNTRYCODE=$(sh "$country_file" "$country" "code")
    TIMEZONE_CITIES=$(sh "$country_file" "$country" "cities")
    TIMEZONE_OFFSETS=$(sh "$country_file" "$country" "offsets")
}

country_full_info() {
    local country_file="${BASE_DIR}/country-zone.sh"
    local country=$(cat "${BASE_DIR}/check_country")

    sh "$country_file" "$country" "all"
}
