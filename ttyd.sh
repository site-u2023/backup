#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# ttyd.sh
#
# 本スクリプトは、aios のインストール後に ttyd をインストールおよび設定するスクリプトです。
# ・common-functions.sh を読み込んで共通関数を使用。
# ・ttyd のインストールと設定を行い、サービスを有効化。
TTYD_VERSION="2025.02.05-rc1"
echo "aios Last update: $TTYD_VERSION"

# === 定数の設定 ===
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_LANGUAGES="en ja zh-cn zh-tw"
INPUT_LANG="$1"

#########################################################################
# 共通エラー処理関数
#########################################################################
handle_error() {
    local msg=$(get_message "error_occurred" "$SELECTED_LANGUAGE")
    echo -e "\033[1;31mERROR:\033[0m $msg: $1"
    exit 1
}

#########################################################################
# 共通関数のダウンロードおよび読み込み
#########################################################################
download_common() {
    if [ ! -f "${BASE_DIR}/common-functions.sh" ]; then
        wget --quiet -O "${BASE_DIR}/common-functions.sh" "${BASE_URL}/common-functions.sh" || handle_error "Failed to download common-functions.sh"
    fi
    . "${BASE_DIR}/common-functions.sh" || handle_error "Failed to source common-functions.sh"
}

#########################################################################
# 言語サポートの初期化
#########################################################################
initialize_language_support() {
    download_language_files  # 言語ファイルをダウンロード
    check_language_common "$INPUT_LANG"  # 言語を確認・選択
}

#########################################################################
# ttyd のインストール確認
#########################################################################
check_ttyd_installed() {
    if command -v ttyd >/dev/null 2>&1; then
        echo -e "\033[1;32mttyd is already installed.\033[0m"
    else
        local install_prompt=$(get_message "install_prompt" "$SELECTED_LANGUAGE")
        if confirm_settings "$install_prompt"; then
            install_ttyd
        else
            handle_exit "$(get_message 'install_cancel' "$SELECTED_LANGUAGE")"
        fi
    fi
}

#########################################################################
# ttyd のインストール
#########################################################################
install_ttyd() {
    get_package_manager_and_status  # ダウンローダーの確認

    echo -e "\033[1;34mInstalling ttyd using $PACKAGE_MANAGER...\033[0m"
    case "$PACKAGE_MANAGER" in
        apk)
            apk update || handle_error "Failed to update APK."
            apk add ttyd || handle_error "Failed to install ttyd using APK."
            ;;
        opkg)
            opkg update || handle_error "Failed to update OPKG."
            opkg install ttyd || handle_error "Failed to install ttyd using OPKG."
            ;;
        *)
            handle_error "Unsupported package manager detected."
            ;;
    esac
    ttyd_setting
}

#########################################################################
# ttyd の設定とサービスの有効化
#########################################################################
ttyd_setting() {
    local config_prompt=$(get_message "apply_settings_prompt" "$SELECTED_LANGUAGE")
    if confirm_settings "$config_prompt"; then
        echo -e "\033[1;34mApplying ttyd settings...\033[0m"

        uci batch <<EOF
set ttyd.@ttyd[0]=ttyd
set ttyd.@ttyd[0].interface='@lan'
set ttyd.@ttyd[0].command='/bin/login -f root'
set ttyd.@ttyd[0].ipv6='1'
add_list ttyd.@ttyd[0].client_option='theme={"background": "black"}'
add_list ttyd.@ttyd[0].client_option='titleFixed=ttyd'
EOF

        uci commit ttyd || handle_error "Failed to commit ttyd settings."
        /etc/init.d/ttyd enable || handle_error "Failed to enable ttyd service."
        /etc/init.d/ttyd restart || handle_error "Failed to restart ttyd service."

        echo -e "\033[1;32m$(get_message 'settings_applied' "$SELECTED_LANGUAGE")\033[0m"
    else
        handle_exit "$(get_message 'settings_cancel' "$SELECTED_LANGUAGE")"
    fi
}

#########################################################################
# メイン処理
#########################################################################
download_common
download_supported_versions_db
check_language_common
download_language_messages
initialize_language_support
check_version_common
check_ttyd_installed
