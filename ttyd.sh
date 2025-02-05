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
download_and_load_common() {
    # まず共通関数をダウンロード
    if [ ! -f "${BASE_DIR}/common-functions.sh" ]; then
        wget --quiet -O "${BASE_DIR}/common-functions.sh" "${BASE_URL}/common-functions.sh" || handle_error "Failed to download common-functions.sh"
    fi

    # 共通関数の読み込み
    . "${BASE_DIR}/common-functions.sh" || handle_error "Failed to source common-functions.sh"
    
    # 必要なファイルの確認（common-functions.sh 読み込み後）
    ensure_file "messages.db"
}

#########################################################################
# 言語サポートの初期化
#########################################################################
initialize_language_support() {
    check_language_common "$INPUT_LANG"  # 言語を確認・選択
}

#########################################################################
# ttyd のインストール
#########################################################################
install_ttyd() {
    get_package_manager_and_status  # パッケージマネージャー確認

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
}

#########################################################################
# ttyd の設定とサービスの有効化
#########################################################################
ttyd_setting() {
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
}

#########################################################################
# メイン処理
#########################################################################
mkdir -p "$BASE_DIR"
download_and_load_common
initialize_language_support
download_supported_versions_db
check_version_common
install_ttyd
ttyd_setting
