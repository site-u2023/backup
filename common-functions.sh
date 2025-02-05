#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
#
# common-functions.sh
#
# 各種共通処理（ヘルプ表示、カラー出力、システム情報確認、言語選択、確認・通知メッセージの多言語対応など）を提供する。
#
echo common-functions.sh Last update 20250205-1

# === 基本定数の設定 ===
BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/site-u2023/aios/main}"
BASE_DIR="${BASE_DIR:-/tmp/aios}"
SUPPORTED_VERSIONS="${SUPPORTED_VERSIONS:-19 21 22 23 24 24.10.0 SN}"
SUPPORTED_LANGUAGES="${SUPPORTED_LANGUAGES:-en ja zh-cn zh-tw id ko de ru}"
INPUT_LANG="$1"

#########################################################################
# エラーハンドリング関数
#########################################################################
handle_error() {
    local msg="$1"
    echo -e "$(color red_white " ERROR ") $(color red "$msg")" >&2
    exit 1
}

#########################################################################
# ヘルプメッセージ表示関数
#########################################################################
print_help() {
    check_language_support  # 言語設定を確認（必要ならキャッシュを読み込み）
    local lang="${SELECTED_LANGUAGE}"

    case "$lang" in
        ja)
            DESCRIPTION="オープンダブルアールティー専用設定ソフトウェア"
            HELP_OPTION="このヘルプメッセージを表示して終了します。"
            RESET_OPTION="言語と国の設定キャッシュをクリアします。"
            LANGUAGE_ARG="使用する言語コードを指定します。"
            LANGUAGE_NOTE="指定しない場合は、言語選択メニューが表示されます。"
            EXAMPLE1="言語選択メニューを起動します。"
            EXAMPLE2="英語でスクリプトを実行します。"
            EXAMPLE3="キャッシュをクリアして英語でスクリプトを実行します。"
            ;;
        zh-cn)
            DESCRIPTION="欧鹏达布里阿尔提封装配置软件"
            HELP_OPTION="显示此帮助信息并退出。"
            RESET_OPTION="清除语言和国家设置缓存。"
            LANGUAGE_ARG="使用的语言代码。"
            LANGUAGE_NOTE="如果未提供，将显示语言选择菜单。"
            EXAMPLE1="启动语言选择菜单。"
            EXAMPLE2="使用英语运行脚本。"
            EXAMPLE3="清除缓存并使用英语运行脚本。"
            ;;
        en|*)
            DESCRIPTION="Dedicated configuration software for OpenWrt"
            HELP_OPTION="Display this help message and exit."
            RESET_OPTION="Clear cached language and country settings."
            LANGUAGE_ARG="Language code to be used immediately."
            LANGUAGE_NOTE="If not provided, an interactive language selection menu will be displayed."
            EXAMPLE1="Launches the interactive language selection menu."
            EXAMPLE2="Runs the script with English language."
            EXAMPLE3="Clears cache and runs the script with English language."
            ;;
    esac

    cat << EOF
aios - $DESCRIPTION

Usage:
  aios [OPTION] [LANGUAGE]

Options:
  -h, -help, --help       $HELP_OPTION
  -r, -reset, --reset     $RESET_OPTION

Arguments:
  LANGUAGE         $LANGUAGE_ARG
                   $LANGUAGE_NOTE

Supported Languages:
  $SUPPORTED_LANGUAGES

Examples:
  aios
    -> $EXAMPLE1

  aios en
    -> $EXAMPLE2

  aios -r en
    -> $EXAMPLE3
EOF
}

#########################################################################
# ANSI カラーコードを返す関数
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
        "reset") echo "\033[0m" ;;
        *) echo "\033[0m" ;;
    esac
}

#########################################################################
# カラー表示関数
#########################################################################
color() {
    local col
    col=$(color_code_map "$1")
    shift
    echo -e "${col}$*$(color_code_map "reset")"
}

#########################################################################
# OpenWrt バージョンチェック関数
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
# パッケージマネージャーの確認関数
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
# 言語サポートチェック関数
#########################################################################
check_language_support() {
    local selected_language_file="${BASE_DIR}/check_country"

    # キャッシュが無い場合、デフォルト設定
    if [ ! -f "$selected_language_file" ]; then
        echo "en" > "$selected_language_file"
        echo -e "$(color yellow "Language cache not found. Defaulting to English (en).")"
    fi

    # 言語コードの取得とサポート確認
    SELECTED_LANGUAGE=$(cat "$selected_language_file")
    if echo "$SUPPORTED_LANGUAGES" | grep -qw "$SELECTED_LANGUAGE"; then
        echo -e "$(color green "Language supported: $SELECTED_LANGUAGE")"
    else
        echo -e "$(color yellow "Unsupported language detected. Defaulting to English (en).")"
        SELECTED_LANGUAGE="en"
    fi

    export LANG="$SELECTED_LANGUAGE"
}
