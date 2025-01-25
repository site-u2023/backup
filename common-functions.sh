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
        echo "OpenWrt version: "${RELEASE_VERSION}" - Supported"
    else
        echo "Unsupported OpenWrt version: ${RELEASE_VERSION}"
        echo "Supported versions: ${SUPPORTED_VERSIONS}"
        exit 1
    fi
}

check_language() {
if [ "$LANGUAGE" = "en" ]; then
    SELECTED_LANGUAGE="en"
elif [ "$LANGUAGE" = "ja" ]; then
    SELECTED_LANGUAGE="ja"
else
    echo -e "$(color "white" "------------------------------------------------------")"
    echo -e "$(color "white" "Select your language")"
    echo -e "$(color "blue" "[e]: English")"
    echo -e "$(color "red" "[j]: 日本語")"
    echo -e "$(color "white" "------------------------------------------------------")"
    read -p "Choose an option [e/j]: " lang_choice
    case "${lang_choice}" in
        "e") SELECTED_LANGUAGE="en" ;;
        "j") SELECTED_LANGUAGE="ja" ;;
        *) 
            echo "Invalid choice, defaulting to English."
            SELECTED_LANGUAGE="en"
            ;;
    esac
fi
}

check_common() {
LANGUAGES='"en" "ja"'
if [ -z "$SELECTED_LANGUAGE" ]; then
    check_language
fi
if [ -z "$RELEASE_VERSION" ]; then
    check_version
fi
}

color_code() {
    for i in `seq 30 38` `seq 40 47` ; do
        for j in 0 1 2 3 4 5 6 7 ; do
            printf "\033[${j};${i}m"
            printf " ${j};${i} "
            printf "\033[0;39;49m"
            printf " "
        done
        printf "\n"
    done
}
