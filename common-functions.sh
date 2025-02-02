#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/site-u2023/aios/main}"
BASE_DIR="${BASE_DIR:-/tmp/aios}"
SUPPORTED_VERSIONS="${SUPPORTED_VERSIONS:-19 21 22 23 24 SN}"
SUPPORTED_LANGUAGES="${SUPPORTED_LANGUAGES:-en ja}"

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

check_common() {
    # --reset オプションが渡された場合、キャッシュをクリア
    if [ "$1" = "--reset" ]; then
        rm -f "${BASE_DIR}/check_language" "${BASE_DIR}/check_country"
        echo "Language and country cache cleared."
        shift  # 次の引数（言語コード）を処理するためにシフト
    fi

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

process_language_selection() {
    INPUT_LANG=$(echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -d '\n')
    echo "Input Language: $INPUT_LANG"

    found_entries=$(sh /tmp/aios/country-timezone.sh "$INPUT_LANG")
    num_matches=$(echo "$found_entries" | wc -l)

    if [ "$num_matches" -gt 1 ]; then
        echo "Multiple matches found. Please select:"
        i=1
        echo "$found_entries" | while IFS= read -r line; do
            echo "$i) $line"
            i=$((i+1))
        done
        read -p "Enter the number of your choice: " choice
        found_entry=$(echo "$found_entries" | sed -n "${choice}p")
    else
        found_entry="$found_entries"
    fi

    # 言語と国の選択処理
    SELECTED_LANGUAGE=$(echo "$found_entry" | awk '{print $2}')
    SELECTED_COUNTRY=$(echo "$found_entry" | awk '{print $3}')

    # 選択結果の保存
    echo "$SELECTED_LANGUAGE" > "${BASE_DIR}/check_language"
    echo "$SELECTED_COUNTRY" > "${BASE_DIR}/check_country"

    echo "Selected Language: $SELECTED_LANGUAGE"
    echo "Selected Country (after script): $SELECTED_COUNTRY"

    # 選択完了後、即座にリターンして二重呼び出しを防ぐ
    return
}

check_language() {
    echo -e "$(color "white" "------------------------------------------------------")"
    echo -e "$(color "white" "Select your language")"
    echo -e "$(color "white" "[en]: English")"
    echo -e "$(color "white" "[ja]: 日本語")"
    echo -e "$(color "white" "[bg]: български")"
    echo -e "$(color "white" "[ca]: Catal\u00e0")"
    echo -e "$(color "white" "[cs]: Čeština")"
    echo -e "$(color "white" "[de]: Deutsch")"
    echo -e "$(color "white" "[el]: Ελληνικά")"
    echo -e "$(color "white" "[es]: Español")"
    echo -e "$(color "white" "[fr]: Français")"
    echo -e "$(color "white" "[he]: עִבְרִת)"  # ※必要に応じて修正してください
    echo -e "$(color "white" "[hi]: हिंदी")"
    echo -e "$(color "white" "[hu]: Magyar")"
    echo -e "$(color "white" "[it]: Italiano")"
    echo -e "$(color "white" "[ko]: 한국어")"
    echo -e "$(color "white" "[mr]: मराठी")"
    echo -e "$(color "white" "[ms]: Bahasa Melayu")"
    echo -e "$(color "white" "[no]: Norsk")"
    echo -e "$(color "white" "[pl]: Polski")"
    echo -e "$(color "white" "[pt]: Português")"
    echo -e "$(color "white" "[pt-br]: Português do Brasil")"
    echo -e "$(color "white" "[ro]: Română")"
    echo -e "$(color "white" "[ru]: Русский")"
    echo -e "$(color "white" "[sk]: Slovenčina")"
    echo -e "$(color "white" "[sv]: Svenska")"
    echo -e "$(color "white" "[tr]: Türkçe")"
    echo -e "$(color "white" "[uk]: Українська")"
    echo -e "$(color "white" "[vi]: Tiếng Việt")"
    echo -e "$(color "white" "[zh-cn]: 简体中文")"
    echo -e "$(color "white" "[zh-tw]: 繁體中文")"
    echo -e "$(color "white" "[ar]: العربية")"
    echo -e "$(color "white" "[bn]: বাংলা")"
    echo -e "$(color "white" "[da]: Dansk")"
    echo -e "$(color "white" "[fi]: Suomi")"
    echo -e "$(color "white" "[nl]: Nederlands")"
    echo -e "$(color "white" "[xx]: otherwise")"
    echo -e "$(color "white" "------------------------------------------------------")"

    read -p "Choose an option: " INPUT_LANG
    process_language_selection "$INPUT_LANG"

    normalize_language
}

normalize_language() {
    CHECK_LANGUAGE="${BASE_DIR}/check_language"
    if [ -f "$CHECK_LANGUAGE" ]; then
        READ_LANGUAGE=$(cat "$CHECK_LANGUAGE")
    fi

    for lang in $SUPPORTED_LANGUAGES; do
        if [ "$READ_LANGUAGE" = "$lang" ]; then
            SELECTED_LANGUAGE="$READ_LANGUAGE"
            return
        fi
    done
    SELECTED_LANGUAGE="en"
}

language_parameter() {
    SELECTED_LANGUAGE=$1
    if [ -n "${SELECTED_LANGUAGE}" ]; then
        echo "${SELECTED_LANGUAGE}" > "${BASE_DIR}/check_language"
    fi
}

ask_confirmation() {
    local message_key="$1"
    local message

    case "${SELECTED_LANGUAGE}" in
        en)
            case "$message_key" in
                "download") message="Execute download?" ;;
                "exit") message="Are you sure you want to exit?" ;;
                "delete") message="Are you sure you want to delete the script and exit?" ;;
                *) message="Are you sure?" ;;
            esac
            ;;
        ja)
            case "$message_key" in
                "download") message="ダウンロードを実行しますか？" ;;
                "exit") message="終了してもよろしいですか？" ;;
                "delete") message="スクリプトを削除して終了しますか？" ;;
                *) message="実行しますか？" ;;
            esac
            ;;
        zh-cn)
            case "$message_key" in
                "download") message="要执行下载吗？" ;;
                "exit") message="您确定要退出吗？" ;;
                "delete") message="您确定要删除脚本并退出吗？" ;;
                *) message="您确定吗？" ;;
            esac
            ;;
        zh-tw)
            case "$message_key" in
                "download") message="要執行下載嗎？" ;;
                "exit") message="您確定要退出嗎？" ;;
                "delete") message="您確定要刪除腳本並退出嗎？" ;;
                *) message="您確定嗎？" ;;
            esac
            ;;
        *)
            case "$message_key" in
                "download") message="Execute download?" ;;
                "exit") message="Are you sure you want to exit?" ;;
                "delete") message="Are you sure you want to delete the script and exit?" ;;
                *) message="Are you sure?" ;;
            esac
            ;;
    esac

    while true; do
        read -p "$(color "white" "${message} [y/n]: ")" choice
        case "${choice}" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo -e "$(color "white" "Invalid choice, please enter 'y' or 'n'.")" ;;
        esac
    done
}

show_notification() {
    local message_key="$1"
    local message

    case "${SELECTED_LANGUAGE}" in
        en)
            case "$message_key" in
                "download_success") message="Download successful." ;;
                "download_failure") message="Download failed." ;;
                "exit_cancelled") message="Exit operation cancelled." ;;
                "delete_cancelled") message="Delete operation cancelled." ;;
                "delete_success") message="Script and configuration deleted." ;;
                "download_cancelled") message="Download operation cancelled." ;;
                "exit") message="Exit operation completed." ;;
                "delete") message="Delete operation completed." ;;
                *) message="Operation completed." ;;
            esac
            ;;
        ja)
            case "$message_key" in
                "download_success") message="ダウンロードが成功しました。" ;;
                "download_failure") message="ダウンロードに失敗しました。" ;;
                "exit_cancelled") message="終了操作がキャンセルされました。" ;;
                "delete_cancelled") message="削除操作がキャンセルされました。" ;;
                "delete_success") message="スクリプトと設定が削除されました。" ;;
                "download_cancelled") message="ダウンロード操作がキャンセルされました。" ;;
                "exit") message="終了操作が完了しました。" ;;
                "delete") message="削除操作が完了しました。" ;;
                *) message="操作が完了しました。" ;;
            esac
            ;;
        zh-cn)
            case "$message_key" in
                "download_success") message="下载成功。" ;;
                "download_failure") message="下载失败。" ;;
                "exit_cancelled") message="退出操作已取消。" ;;
                "delete_cancelled") message="删除操作已取消。" ;;
                "delete_success") message="脚本和配置已删除。" ;;
                "download_cancelled") message="下载操作已取消。" ;;
                "exit") message="退出操作已完成。" ;;
                "delete") message="删除操作已完成。" ;;
                *) message="操作已完成。" ;;
            esac
            ;;
        zh-tw)
            case "$message_key" in
                "download_success") message="下載成功。" ;;
                "download_failure") message="下載失敗。" ;;
                "exit_cancelled") message="退出操作已取消。" ;;
                "delete_cancelled") message="刪除操作已取消。" ;;
                "delete_success") message="腳本和配置已刪除。" ;;
                "download_cancelled") message="下載操作已取消。" ;;
                "exit") message="退出操作已完成。" ;;
                "delete") message="刪除操作已完成。" ;;
                *) message="操作已完成。" ;;
            esac
            ;;
        *)
            case "$message_key" in
                "download_success") message="Download successful." ;;
                "download_failure") message="Download failed." ;;
                "exit_cancelled") message="Exit operation cancelled." ;;
                "delete_cancelled") message="Delete operation cancelled." ;;
                "delete_success") message="Script and configuration deleted." ;;
                "download_cancelled") message="Download operation cancelled." ;;
                "exit") message="Exit operation completed." ;;
                "delete") message="Delete operation completed." ;;
                *) message="Operation completed." ;;
            esac
            ;;
    esac

    echo -e "$(color "white" "${message}")"
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

country_zone() {
    ZONENAME="$(sh ${BASE_DIR}/country-zonename.sh "$(cat ${BASE_DIR}/check_country)")"
    TIMEZONE="$(sh ${BASE_DIR}/country-timezone.sh "$(cat ${BASE_DIR}/check_country)")"
    LANGUAGE=$(echo "$ZONENAME" | awk '{print $NF}')
}
