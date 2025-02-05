#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# ttyd.sh

TTYD_SH_VERSION="2025.02.05-rc1"
echo "ttyd.sh Last update: $TTYD_SH_VERSION"

# === 定数の設定 ===
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
INPUT_LANG="$1"

#########################################################################
# インストールするパッケージの定義
#########################################################################
packages() {
    echo "ttyd luci-app-ttyd"
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
# ttyd の設定とサービスの有効化
#########################################################################
ttyd_setting() {
    if confirm_action "MSG_CONFIRM_SETTINGS"; then
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
check_language_common          # 言語判定
download_supported_versions_db
check_version_common

# パッケージのインストール（言語パックも含めて自動処理）
install_packages $(packages)

# 設定適用
ttyd_setting
