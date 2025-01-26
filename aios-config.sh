#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# This script is specifically designed for the initial setup of an all-in-one script.

# 環境変数で再実行を防止
if [ "$AIOS_RUNNING" = "true" ]; then
    echo "The script is already running. Exiting to avoid a loop."
    exit 1
fi

# 実行中のフラグを設定
export AIOS_RUNNING=true

SELECTED_LANGUAGE=$1
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main/"
BASE_DIR="/tmp/aios/"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"

mkdir -p "$BASE_DIR" || {
    echo "Failed to create BASE_DIR: $BASE_DIR"
    exit 1
}

RELEASE_VERSION=$(grep 'DISTRIB_RELEASE' /etc/openwrt_release | cut -d"'" -f2 | cut -c 1-2)
if ! echo "${SUPPORTED_VERSIONS}" | grep -q "${RELEASE_VERSION}"; then
    echo "Unsupported OpenWrt version: ${RELEASE_VERSION}"
    echo "Supported versions: ${SUPPORTED_VERSIONS}"
    exit 1
fi

check_ttyd_installed() {
    if command -v ttyd >/dev/null 2>&1; then
        echo "ttyd is already installed."
    else
        echo "ttyd is not installed."
        wget --no-check-certificate -O "${BASE_DIR}ttyd.sh" "${BASE_URL}ttyd.sh"
        sh "${BASE_DIR}ttyd.sh"
    fi
}

# 言語選択処理
select_language() {
    while true; do
        echo "Select your language:"
        echo "[en]: English"
        echo "[ja]: 日本語"
        read -p "Please enter your choice: " LANGUAGE_CHOICE
        # 入力のトリム（前後の空白を削除）
        LANGUAGE_CHOICE=$(echo "$LANGUAGE_CHOICE" | tr -d '[:space:]')
        echo "You selected: $LANGUAGE_CHOICE"  # デバッグ用に選択された内容を表示

        if [ "$LANGUAGE_CHOICE" = "en" ]; then
            SELECTED_LANGUAGE="en"
            break
        elif [ "$LANGUAGE_CHOICE" = "ja" ]; then
            SELECTED_LANGUAGE="ja"
            break
        else
            echo "Invalid choice. Please select a valid option."
        fi
    done
}

# 言語選択が指定されていない場合に呼び出し
if [ -z "$SELECTED_LANGUAGE" ]; then
    select_language
fi

# スクリプトのダウンロードと実行
wget --no-check-certificate -O "/usr/bin/aios" "${BASE_URL}aios"
chmod +x /usr/bin/aios

# 言語とバージョンを保存
echo "${SELECTED_LANGUAGE}" > "${BASE_DIR}check_language"
echo "${RELEASE_VERSION}" > "${BASE_DIR}check_version"

# ttydインストール確認
check_ttyd_installed

# aiosスクリプト実行
aios
