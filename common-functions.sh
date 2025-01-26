#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

BASE_DIR="/tmp/aios/"

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

check_common2() {
    if [ -f "${BASE_DIR}check_version" ]; then
        RELEASE_VERSION=$(cat ${BASE_DIR}check_version)
    fi
    
    if [ -f "${BASE_DIR}check_language" ]; then
        SELECTED_LANGUAGE=$(cat ${BASE_DIR}check_language)
    fi
    
    if [ -f "${BASE_DIR}check_package_manager" ]; then
        PACKAGE_MANAGER=$(cat ${BASE_DIR}check_package_manager)
    fi

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

check_common22() {
    # ファイルが存在すれば、それぞれの変数に値を設定
    for file in "${BASE_DIR}check_version" "${BASE_DIR}check_language" "${BASE_DIR}check_package_manager"; do
        if [ -f "$file" ]; then
            var_name=$(basename "$file")
            var_name="${var_name%.*}"  # 拡張子を除去して変数名にする
            eval "$var_name=$(cut -d'=' -f2 < "$file")"
        fi
    done

    # それぞれの変数が設定されていない場合は、対応する関数を実行
    [ -z "$RELEASE_VERSION" ] && check_version
    [ -z "$SELECTED_LANGUAGE" ] && { [[ "$1" != "ja" && "$1" != "en" ]] && check_language; }
    [ -z "$PACKAGE_MANAGER" ] && check_package_manager
}

# チェックと設定をまとめた汎用関数
load_check_value() {
    local file="$1"
    local var_name="$2"

    # ファイルが存在し、内容が空でない場合に変数を設定
    if [ -f "$file" ] && [ -s "$file" ]; then
        eval "$var_name=$(cat "$file")"
    fi
}

check_common() {
    # 変数に対応するファイルパスを指定
    local version_file="${BASE_DIR}check_version"
    local language_file="${BASE_DIR}check_language"
    local package_manager_file="${BASE_DIR}check_package_manager"

    # 各変数を読み込み、設定がなければチェック
    load_check_value "$version_file" "RELEASE_VERSION"
    load_check_value "$language_file" "SELECTED_LANGUAGE"
    load_check_value "$package_manager_file" "PACKAGE_MANAGER"

    # RELEASE_VERSIONが設定されていない場合、check_versionを実行
    if [ -z "$RELEASE_VERSION" ]; then
        echo "Checking OpenWrt version..."
        check_version
    fi

    # SELECTED_LANGUAGEが設定されていない場合、または引数で指定されている場合のみcheck_languageを実行
    if [ -z "$SELECTED_LANGUAGE" ] || [[ "$SELECTED_LANGUAGE" != "ja" && "$SELECTED_LANGUAGE" != "en" ]]; then
        echo "Checking language selection..."
        if [[ "$1" == "ja" || "$1" == "en" ]]; then
            SELECTED_LANGUAGE="$1"
        else
            check_language
        fi
    fi

    # PACKAGE_MANAGERが設定されていない場合、check_package_managerを実行
    if [ -z "$PACKAGE_MANAGER" ]; then
        echo "Checking package manager..."
        check_package_manager
    fi
}
