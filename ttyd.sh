#!/bin/sh
# ttyd.sh

TTYD_SH_VERSION="2025.02.05-rc1"
echo "ttyd.sh Last update: $TTYD_SH_VERSION"

BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
INPUT_LANG="$1"

# インストール対象パッケージ
packages() {
    echo "ttyd luci-app-ttyd"
}

download_common() {
    if [ ! -f "${BASE_DIR}/common-functions.sh" ]; then
        wget --quiet -O "${BASE_DIR}/common-functions.sh" \
            "${BASE_URL}/common-functions.sh" || handle_error "Failed to download common-functions.sh"
    fi
    . "${BASE_DIR}/common-functions.sh" || handle_error "Failed to source common-functions.sh"
}

###############################################################################
# 1) TTYDインストールの前に確認 (confirm_action 'MSG_INSTALL_PROMPT')
#    同意 (Y) ならインストール → 設定まで一気に行う
###############################################################################
install_and_configure_ttyd() {
    # 「ttydをインストールしますか？」と尋ねる
    if confirm_action "MSG_INSTALL_PROMPT"; then
        echo -e "\033[1;34mInstalling ttyd...\033[0m"
        install_packages $(packages)

        # インストール後、必ず設定を適用する（二度目のY/Nは不要）
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
        color yellow "Skipping ttyd installation (and configuration)..."
        return 1  # キャンセル
    fi
}

#################################
# メイン処理
#################################
download_common

# $1 (INPUT_LANG) が指定されていれば SELECTED_LANGUAGE を上書き
[ -n "$INPUT_LANG" ] && SELECTED_LANGUAGE="$INPUT_LANG"

check_language_common
download_supported_versions_db
check_version_common

# (A) インストールするかどうか確認 → 「はい」の場合のみインストール＋設定を実行
install_and_configure_ttyd
