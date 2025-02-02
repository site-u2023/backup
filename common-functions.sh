#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/site-u2023/aios/main}"
BASE_DIR="${BASE_DIR:-/tmp/aios}"
SUPPORTED_VERSIONS="${SUPPORTED_VERSIONS:-19 21 22 23 24 SN}"
SUPPORTED_LANGUAGES="${SUPPORTED_LANGUAGES:-en}"

print_help() {
    cat << 'EOF'
aios - Dedicated configuration software for OpenWrt

Usage:
  aios [OPTION] [LANGUAGE]

Options:
  -h, -help, --help       Display this help message and exit.
  -r, -reset, --reset
                   Clear cached language and country settings.

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

color_code_map() {
  local color=$1
  case $color in
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

color() {
  local color=$(color_code_map "$1")
  shift
  echo -e "${color}$*$(color_code_map "reset")"
}

check_version() {
    RELEASE_VERSION=$(awk -F"'" '/DISTRIB_RELEASE/ {print $2}' /etc/openwrt_release | cut -c 1-2)
    
    echo "${RELEASE_VERSION}" > "${BASE_DIR}/check_version"
    
    if ! echo "${SUPPORTED_VERSIONS}" | grep -qw "${RELEASE_VERSION}"; then
        echo "Unsupported OpenWrt version: ${RELEASE_VERSION}"
        echo "Supported versions: ${SUPPORTED_VERSIONS}"
        exit 1
    fi
}

check_package_manager() {
    if command -v apk >/dev/null 2>&1; then
        PACKAGE_MANAGER="APK"
        echo "${PACKAGE_MANAGER}" > ${BASE_DIR}/check_package_manager
    elif command -v opkg >/dev/null 2>&1; then
        PACKAGE_MANAGER="OPKG"
        echo "${PACKAGE_MANAGER}" > ${BASE_DIR}/check_package_manager
    else
        echo "No package manager found"
        exit 1
    fi
}

check_language() {
    echo -e "$(color white "------------------------------------------------------")"
    echo -e "$(color white "Select your language")"

    # country-zonename.sh を実行して全データを取得（引数は空文字）
    country_data=$(sh "${BASE_DIR}/country-zonename.sh" "")

    # 取得したデータを1行ずつ処理して表示
    echo "$country_data" | while IFS= read -r line; do
        [ -z "$line" ] && continue
        lang_field=$(echo "$line" | awk '{print $2}')
        if [ "$lang_field" != "xx" ]; then
            output=$(echo "$line" | awk '{print $NF, $1, $2, $3}')
            echo -e "$(color white "$output")"
        fi
    done

    echo -e "$(color white "------------------------------------------------------")"
    read -p "$(color white "$(get_message choose_prompt)")" INPUT_LANG
    process_language_selection "$INPUT_LANG"
    normalize_language
}

check_common() {
    case "$1" in
        -h|-help|--help)
            print_help
            exit 0
            ;;
        --reset|-reset|-r)
            rm -f "${BASE_DIR}/check_language" "${BASE_DIR}/check_country"
            echo "Language and country cache cleared."
            shift  # 次の引数（言語コード）を処理するためにシフト
            ;;
    esac

    # バージョン情報の取得
    if [ -f "${BASE_DIR}/check_version" ]; then
        RELEASE_VERSION=$(cat "${BASE_DIR}/check_version")
    fi
    [ -z "$RELEASE_VERSION" ] && check_version

    # パッケージ情報の取得
    if [ -f "${BASE_DIR}/check_package_manager" ]; then
        PACKAGE_MANAGER=$(cat "${BASE_DIR}/check_package_manager")
    fi
    [ -z "$PACKAGE_MANAGER" ] && check_package_manager  

    # コマンドライン引数で言語が指定されている場合、それを優先
    if [ -n "$1" ]; then
        process_language_selection "$1"
    fi

    # キャッシュが存在する場合、読み込み
    if [ -f "${BASE_DIR}/check_language" ]; then
        SELECTED_LANGUAGE=$(cat "${BASE_DIR}/check_language")
    fi
    if [ -f "${BASE_DIR}/check_country" ]; then
        SELECTED_COUNTRY=$(cat "${BASE_DIR}/check_country")
    fi

    # 言語が未設定の場合はユーザーに選択を促す
    if [ -z "$SELECTED_LANGUAGE" ]; then
        check_language
    fi

    normalize_language  # 言語の正規化（最後に実行）
}

menu_option() {
    local action="$1"
    local description="$2"
    local script_name="$3"
    local INPUT_LANG="$4"  
    
    echo -e "$(color "white" "${description}")"

    case "${action}" in
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
                rm -rf "${BASE_DIR}" /usr/bin/aios /tmp/aios.sh
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
                    . "${BASE_DIR}/${script_name}" "$INPUT_LANG"
                else
                    show_notification "download_failure"
                fi
            else
                show_notification "download_cancelled"
            fi
            ;;
        *)
            echo -e "$(color "red" "Unknown action.")"
            ;;
    esac
}

#############################
# 共通のメッセージ取得関数 #
#############################
get_message() {
    local key="$1"
    local lang="${SELECTED_LANGUAGE:-en}"  # SELECTED_LANGUAGE が未設定の場合は英語をデフォルト
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
            # デフォルトは英語
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

###########################
# 確認プロンプト関数 (共通) #
###########################
ask_confirmation() {
    local prompt="$(get_message confirm_default)"
    while true; do
        read -p "$(color white "$prompt [y/n]: ")" choice
        case "$choice" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo -e "$(color white "Invalid choice, please enter 'y' or 'n'.")" ;;
        esac
    done
}

###########################
# 通知表示関数 (共通)     #
###########################
show_notification() {
    local key="$1"
    local message="$(get_message "$key")"
    echo -e "$(color white "$message")"
}

############################################
# 言語選択処理（再入力なども含む）         #
############################################
process_language_selection() {
    while true; do
        # 入力値の前後の空白を除去
        INPUT_LANG=$(echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        echo "Input Language: $INPUT_LANG"

        # country-zonename.sh を実行して該当エントリを取得
        found_entries=$(sh "${BASE_DIR}/country-zonename.sh" "$INPUT_LANG")

        # 該当エントリが空またはエラーを含む場合、再入力を促す
        if [ -z "$found_entries" ] || echo "$found_entries" | grep -qi "not found"; then
            echo "No matching entry found."
            read -p "$(color white "$(get_message reenter_prompt) [y/n]: ")" answer
            case "$answer" in
                [Yy])
                    read -p "$(color white "Please re-enter language: ")" new_input
                    set -- "$new_input"
                    continue
                    ;;
                *)
                    echo "Defaulting to English (en)."
                    found_entries=$(sh "${BASE_DIR}/country-zonename.sh" "en")
                    # 続行して候補採用へ
            esac
        fi

        # 複数候補があれば、番号付きで選択させる
        num_matches=$(echo "$found_entries" | grep -c '^')
        if [ "$num_matches" -gt 1 ]; then
            echo "Multiple matches found. Please select:"
            i=1
            echo "$found_entries" | while IFS= read -r line; do
                echo "[$i] $line"
                i=$((i+1))
            done
            echo "[0] Re-enter language"
            read -p "$(color white "Enter the number of your choice: ")" choice
            if [ "$choice" = "0" ]; then
                read -p "$(color white "Please re-enter language: ")" new_input
                set -- "$new_input"
                continue
            fi
            found_entry=$(echo "$found_entries" | sed -n "${choice}p")
            if [ -z "$found_entry" ]; then
                echo "Invalid selection. Please re-enter."
                read -p "$(color white "Please re-enter language: ")" new_input
                set -- "$new_input"
                continue
            fi
        else
            found_entry="$found_entries"
        fi

        # 最終チェック（万一エラーが含まれていたら再入力）
        if echo "$found_entry" | grep -qi "not found"; then
            echo "No valid entry selected."
            read -p "$(color white "$(get_message reenter_prompt) [y/n]: ")" answer
            case "$answer" in
                [Yy])
                    read -p "$(color white "Please re-enter language: ")" new_input
                    set -- "$new_input"
                    continue
                    ;;
                *)
                    echo "Defaulting to English (en)."
                    found_entry=$(sh "${BASE_DIR}/country-zonename.sh" "en")
            esac
        fi

        break  # 有効な候補が取得できたのでループを抜ける
    done

    # 取得した行から各フィールドを抽出（データ形式例: <国名> <言語コード> <国コード> ... <母国語>）
    SELECTED_LANGUAGE=$(echo "$found_entry" | awk '{print $2}')
    SELECTED_COUNTRY=$(echo "$found_entry" | awk '{print $3}')

    # キャッシュに保存
    echo "$SELECTED_LANGUAGE" > "${BASE_DIR}/check_language"
    echo "$SELECTED_COUNTRY" > "${BASE_DIR}/check_country"

    echo "Selected Language: $SELECTED_LANGUAGE"
    echo "Selected Country (after script): $SELECTED_COUNTRY"
}

############################################
# normalize_language の処理（主にメニュー用） #
############################################
normalize_language() {
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

country_zone() {
    ZONENAME="$(sh ${BASE_DIR}/country-zonename.sh "$(cat ${BASE_DIR}/check_country)")"
    TIMEZONE="$(sh ${BASE_DIR}/country-timezone.sh "$(cat ${BASE_DIR}/check_country)")"
    LANGUAGE=$(echo "$ZONENAME" | awk '{print $NF}')
}
