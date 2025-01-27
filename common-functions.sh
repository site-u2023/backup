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
    "white_black") echo "\033[7;40m" ;;
    "red_white") echo "\033[6;41m" ;;
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
            "download") message="Execute?" ;;
            "exit") message="Exit?" ;;
            "delete") message="Delete the script and exit?" ;;
            *) message="Execute?" ;;
        esac
    elif [ "${SELECTED_LANGUAGE}" = "ja" ]; then
        case "$message_key" in
            "download") message="実行します" ;;
            "exit") message="終了します" ;;
            "delete") message="スクリプトを削除して終了します" ;;
            *) message="実行します" ;;
        esac
    fi

    while true; do
        read -p "$(color "white" "${message} [y/n]: ")" choice
        case "${choice}" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo -e "$(color "red" "Invalid choice, please enter 'y' or 'n'.")" ;;
        esac
    done
}

download_and_execute() {
    mkdir -p "$BASE_DIR"
    local script_name="$1"
    local url="$2"
    
    if ask_confirmation "download"; then
        if wget --no-check-certificate --quiet -O "${BASE_DIR}${script_name}" "${url}"; then
            echo -e "$(color "green" "Download successful.")"
            . "${BASE_DIR}${script_name}"
        else
            echo -e "$(color "red" "Download failed.")"
        fi
    else
        echo -e "$(color "yellow" "Download aborted.")"
    fi
}
