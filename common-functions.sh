#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/site-u2023/aios/main/}"
BASE_DIR="${BASE_DIR:-/tmp/aios/}"
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
RELEASE_VERSION=$(grep 'DISTRIB_RELEASE' /etc/openwrt_release | cut -d"'" -f2 | cut -c 1-2)
echo "${RELEASE_VERSION}" > ${BASE_DIR}check_version
    if ! echo "${SUPPORTED_VERSIONS}" | grep -q "${RELEASE_VERSION}"; then
        echo "Unsupported OpenWrt version: ${RELEASE_VERSION}"
        echo "Supported versions: ${SUPPORTED_VERSIONS}"
        exit 1
    fi
}

check_language() {
while true; do
    echo -e "$(color "white" "------------------------------------------------------")"
    echo -e "$(color "white" "Select your language")"
    echo -e "$(color "blue" "[en]: English")"
    echo -e "$(color "red" "[ja]: 日本語")"
    echo -e "$(color "white" "------------------------------------------------------")"
    read -p "Choose an option [en/ja]: " lang_choice
    case "${lang_choice}" in
        "en") SELECTED_LANGUAGE="en"; break ;;
        "ja") SELECTED_LANGUAGE="ja"; break ;;
         *) echo "Invalid choice." ;;
   esac
done
echo "${SELECTED_LANGUAGE}" > ${BASE_DIR}check_language
}

check_package_manager() {
    if command -v apk >/dev/null 2>&1; then
        PACKAGE_MANAGER="apk"
        echo "${PACKAGE_MANAGER}" > ${BASE_DIR}check_package_manager
    elif command -v opkg >/dev/null 2>&1; then
        PACKAGE_MANAGER="opkg"
        echo "${PACKAGE_MANAGER}" > ${BASE_DIR}check_package_manager
    else
        echo "No package manager found"
        exit 1
    fi
}

language_parameter() {
SELECTED_LANGUAGE=$1
if [ -n "${SELECTED_LANGUAGE}" ]; then
  echo "${SELECTED_LANGUAGE}" > "${BASE_DIR}check_language"
fi
}

check_common() {
  if [ -f "${BASE_DIR}check_version" ]; then
    RELEASE_VERSION=$(cat "${BASE_DIR}check_version")
  fi
  [ -z "$RELEASE_VERSION" ] && check_version

  if [ -n "$1" ] && { [ "$1" = "ja" ] || [ "$1" = "en" ]; }; then
    SELECTED_LANGUAGE="$1"
    echo "${SELECTED_LANGUAGE}" > "${BASE_DIR}check_language"
  elif [ -f "${BASE_DIR}check_language" ]; then
    SELECTED_LANGUAGE=$(cat "${BASE_DIR}check_language")
  fi
  [ -z "${SELECTED_LANGUAGE}" ] && check_language

  if [ -f "${BASE_DIR}check_package_manager" ]; then
    PACKAGE_MANAGER=$(cat "${BASE_DIR}check_package_manager")
  fi
  [ -z "$PACKAGE_MANAGER" ] && check_package_manager
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
            *) echo -e "$(color "red_white" "Invalid choice, please enter 'y' or 'n'.")" ;;
        esac
    done
}

show_notification() {
    local message_key="$1"
    local message

    if [ "${SELECTED_LANGUAGE}" = "en" ]; then
        case "$message_key" in
            "download_success") message="Download successful." ;;
            "download_failure") message="Download failed." ;;
            "exit_cancelled") message="Exit operation cancelled." ;;  # 修正
            "delete_cancelled") message="Delete operation cancelled." ;;  # 修正
            "delete_success") message="Script and configuration deleted." ;;
            *) message="Operation completed." ;;
        esac
    elif [ "${SELECTED_LANGUAGE}" = "ja" ]; then
        case "$message_key" in
            "download_success") message="ダウンロードが成功しました。" ;;
            "download_failure") message="ダウンロードに失敗しました。" ;;
            "exit_cancelled") message="終了操作がキャンセルされました。" ;;  # 修正
            "delete_cancelled") message="削除操作がキャンセルされました。" ;;  # 修正
            "delete_success") message="スクリプトと設定が削除されました。" ;;
            *) message="操作が完了しました。" ;;
        esac
    fi

    echo -e "$(color "green_white" "${message}")"
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
                show_notification "exit_cancelled"  # 修正されたメッセージ
            fi
            ;;
        "delete")
            if ask_confirmation "delete"; then
                rm -rf "${BASE_DIR}" /usr/bin/aios /tmp/aios-config.sh
                show_notification "delete_success"
                exit 0
            else
                show_notification "delete_cancelled"  # 修正されたメッセージ
            fi
            ;;
        "download")
            if ask_confirmation "download"; then
                if wget --no-check-certificate --quiet -O "${BASE_DIR}${script_name}" "${BASE_URL}${script_name}"; then
                    show_notification "download_success"
                    . "${BASE_DIR}${script_name}"
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
