#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/site-u2023/aios/main}"
BASE_DIR="${BASE_DIR:-/tmp/aios}"
SUPPORTED_VERSIONS="${SUPPORTED_VERSIONS:-19 21 22 23 24 SN}"

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

check_language() {

    # 言語選択画面を表示
    echo -e "$(color "white" "------------------------------------------------------")"
    echo -e "$(color "white" "Select your language")"
    echo -e "$(color "white" "[en]: English")"
    echo -e "$(color "white" "[ja]: 日本語")"
    echo -e "$(color "white" "[bg]: български")"
    echo -e "$(color "white" "[ca]: Català")"
    echo -e "$(color "white" "[cs]: Čeština")"
    echo -e "$(color "white" "[de]: Deutsch")"
    echo -e "$(color "white" "[el]: Ελληνικά")"
    echo -e "$(color "white" "[es]: Español")"
    echo -e "$(color "white" "[fr]: Français")"
    echo -e "$(color "white" "[he]: עִבְרִית")"
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

    # ユーザーの入力を取得
    read -p "Choose an option: " lang_choice

    # 選択された言語がリストにあるか確認
    SELECTED_LANGUAGE=$(sh /tmp/aios/country-zonename.sh "$lang_choice" | awk '{print $2}')
        if [ -n "$SELECTED_LANGUAGE" ]; then
            echo "$SELECTED_LANGUAGE" > "${BASE_DIR}/check_language"
            normalize_language # 言語の標準化（ja 以外は en 扱い）
        else
            SELECTED_LANGUAGE="en"
            echo "$SELECTED_LANGUAGE" > "${BASE_DIR}/check_language"
            echo "Invalid language selection. Defaulting to 'en'."
        fi

    # 言語に応じたメッセージの出力
    case "$SELECTED_LANGUAGE" in
        "ja") echo -e "$(color "white" "日本語を選択しました。")" ;;
        *) echo -e "$(color "white" "You selected $(echo "$SELECTED_LANGUAGE" | tr '[:lower:]' '[:upper:]') (Processed as English).")" ;;
    esac

echo "check_language: $SELECTED_LANGUAGE"
echo "check_language result: $(cat ${BASE_DIR}/check_language; echo $?)"
}

normalize_language() {
    case "$SELECTED_LANGUAGE" in
        "ja") ;;  # 日本語はそのまま
        *) SELECTED_LANGUAGE="en" ;;  # それ以外は英語扱い
    esac

echo "normalize_language result: $(cat ${BASE_DIR}/check_language; echo $?)"

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

language_parameter() {
    SELECTED_LANGUAGE=$1
    if [ -n "${SELECTED_LANGUAGE}" ]; then
        echo "${SELECTED_LANGUAGE}" > "${BASE_DIR}/check_language"
    fi

echo "language_parameter: $SELECTED_LANGUAGE"
echo "language_parameter result: $(cat ${BASE_DIR}/check_language; echo $?)"
}

check_common() {
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
        
　　# 地域情報の取得
    if [ -f "${BASE_DIR}/check_country" ]; then
        SELECTED_COUNTRY=$(cat "${BASE_DIR}/check_country")
    else
        if [ -n "$1" ]; then
            SELECTED_COUNTRY=$(sh /tmp/aios/country-zonename.sh "$1" | awk '{print $3}')
            echo "${SELECTED_COUNTRY}" > "${BASE_DIR}/check_country"
        else
            SELECTED_COUNTRY="US"
            echo "${SELECTED_COUNTRY}" > "${BASE_DIR}/check_country"
        fi
    fi

    # 言語選択の判定 
    if [ ! -f "${BASE_DIR}/check_language" ]; then
        check_language
    fi  
    [ -z "$SELECTED_LANGUAGE" ] && check_language

    if [ -n "$1" ]; then
        SELECTED_LANGUAGE=$(sh /tmp/aios/country-zonename.sh "$1" | awk '{print $2}')
        if [ -n "$SELECTED_LANGUAGE" ]; then
            echo "$SELECTED_LANGUAGE" > "${BASE_DIR}/check_language"
            normalize_language # 言語の標準化（ja 以外は en 扱い）
        else
            SELECTED_LANGUAGE="en"
            echo "$SELECTED_LANGUAGE" > "${BASE_DIR}/check_language"
            echo "Invalid language selection. Defaulting to 'en'."
        fi
    fi

echo "check_common: $SELECTED_LANGUAGE"
echo "check_common: $(cat ${BASE_DIR}/check_language; echo $?)"
}

ask_confirmation() {
    local message_key="$1"
    local message

    if [ "${SELECTED_LANGUAGE}" = "en" ]; then
        case "$message_key" in
            "download") message="Execute download?" ;;
            "exit") message="Are you sure you want to exit?" ;;
            "delete") message="Are you sure you want to delete the script and exit?" ;;
            *) message="Are you sure?" ;;
        esac
    elif [ "${SELECTED_LANGUAGE}" = "ja" ]; then
        case "$message_key" in
            "download") message="ダウンロードを実行しますか？" ;;
            "exit") message="終了してもよろしいですか？" ;;
            "delete") message="スクリプトを削除して終了しますか？" ;;
            *) message="実行しますか？" ;;
        esac
    fi

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
    local lang="${SELECTED_LANGUAGE:-en}"
    
    if [ "$lang" = "en" ]; then
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
    elif [ "$lang" = "ja" ]; then
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
    fi

    echo -e "$(color "white" "${message}")"
}

menu_option() {
    local action="$1"
    local description="$2"
    local script_name="$3"

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
                    . "${BASE_DIR}/${script_name}"
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
