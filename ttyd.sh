#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# ttyd.sh

TTYD_SH_VERSION="2025.02.05-rc1"
echo "ttyd.sh Last update: $TTYD_SH_VERSION"

# === 定数の設定 ===
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_LANGUAGES="en ja zh-cn zh-tw"
INPUT_LANG="$1"

#########################################################################
# 共通エラー処理関数
#########################################################################
handle_error() {
    local msg=$(get_message "MSG_ERROR_OCCURRED" "$SELECTED_LANGUAGE")
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
# ttyd のインストール確認
#########################################################################
check_ttyd_installed() {
    if command -v ttyd >/dev/null 2>&1; then
        echo -e "\033[1;32mttyd is already installed.\033[0m"
    else
        local install_prompt=$(get_message "MSG_INSTALL_PROMPT" "$SELECTED_LANGUAGE")
        if confirm_action "$install_prompt"; then
            install_ttyd
        else
            echo -e "$(color yellow "$(get_message 'MSG_INSTALL_CANCEL' "$SELECTED_LANGUAGE")")"
        fi
    fi
}

#########################################################################
# ttyd のインストール
#########################################################################
#########################################################################
# ttyd のインストール
#########################################################################
install_ttyd() {
    get_package_manager_and_status  # パッケージマネージャー確認

    # インストールするパッケージ一覧をここで管理
    local PACKAGES="ttyd luci-app-ttyd"

    # 言語が日本語なら日本語パッケージを追加
    if [ "$SELECTED_LANGUAGE" = "ja" ]; then
        PACKAGES="$PACKAGES luci-i18n-ttyd-ja"
    fi

    # 一括インストール
    install_packages $PACKAGES

    ttyd_setting  # ttyd 設定を適用
}

#########################################################################
# ttyd の設定とサービスの有効化
#########################################################################
ttyd_setting() {
    local config_prompt=$(get_message "MSG_CONFIRM_SETTINGS" "$SELECTED_LANGUAGE")
    if confirm_action "$config_prompt"; then
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

        echo -e "\033[1;32m$(get_message 'MSG_SETTINGS_APPLIED' "$SELECTED_LANGUAGE")\033[0m"
    else
        echo -e "\033[1;33m$(get_message 'MSG_SETTINGS_CANCEL' "$SELECTED_LANGUAGE")\033[0m"
    fi
}

#########################################################################
# メイン処理
#########################################################################
download_common
check_language_common         # 言語判定をここで呼び出す
download_supported_versions_db
check_version_common
check_ttyd_installed
ttyd_setting
