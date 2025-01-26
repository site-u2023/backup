#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

# Color settings
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
    *) echo "\033[0;39m" ;;  # Fallback to reset
  esac
}

# Generic color function
color() {
  local color=$(color_code_map "$1")
  shift
  echo -e "${color}$*$(color_code_map "reset")"
}

check_version() {
RELEASE_VERSION=$(grep 'DISTRIB_RELEASE' /etc/openwrt_release | cut -d"'" -f2 | cut -c 1-2)
    if echo "${SUPPORTED_VERSIONS}" | grep -q "${RELEASE_VERSION}"; then
        echo -e "$(color "white" "OpenWrt version: "${RELEASE_VERSION}" - Supported")"
    else
        echo -e "$(color "red" "Unsupported OpenWrt version: ${RELEASE_VERSION}")"
        echo -e "$(color "white" "Supported versions: ${SUPPORTED_VERSIONS}")"
        exit 1
    fi
}

check_language() {
    if [ "$LANGUAGE" = "en" ]; then
        SELECTED_LANGUAGE="en"
    elif [ "$LANGUAGE" = "ja" ]; then
        SELECTED_LANGUAGE="ja"
    else
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
    fi
}

check_common() {
if [ -z "$RELEASE_VERSION" ]; then
    check_version
else 
    echo -e "$(color "white" "OpenWrt version: "${RELEASE_VERSION}" - Supported")"
fi
LANGUAGES='"en" "ja"'
if [ -z "$SELECTED_LANGUAGE" ]; then
    check_language
else
    echo -e "$(color "white" "Select language: "${SELECTED_LANGUAGE}"")"
fi
}

get_package_manager() {
    if command -v apk >/dev/null 2>&1; then
        echo "apk"
    elif command -v opkg >/dev/null 2>&1; then
        echo "opkg"
    else
        echo "none"
    fi
}
