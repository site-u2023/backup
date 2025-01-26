#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

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
}

check_package_manager() {
    if command -v apk >/dev/null 2>&1; then
        PACKAGE_MANAGER="apk"
    elif command -v opkg >/dev/null 2>&1; then
        PACKAGE_MANAGER="opkg"
    else
        echo "No package manager found"
        exit 1
    fi
}

check_common() {
if [ -z "$RELEASE_VERSION" ]; then
    check_version    
fi

if [ -z "$SELECTED_LANGUAGE" ]; then
    if [[ "$1" != "ja" && "$1" != "en" ]]; then
        check_language    
    fi
fi

if [ -z "$PACKAGE_MANAGER" ]; then
    check_package_manager
fi
}
