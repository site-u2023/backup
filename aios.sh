#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# 初期設定用 all-in-one スクリプト (aios) のセットアップスクリプト
echo aios.sh Last update: 20250205-4

# === 定数の設定 ===
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19.07 21.02 22.03 23.05 24.10.0 SNAPSHOT"
INPUT_LANG="$1"

#########################################################################
# color: 簡易カラー出力関数（エラーメッセージ表示用）
#########################################################################
color() {
    case "$1" in
        red) echo "\033[1;31m$2\033[0m" ;;
        green) echo "\033[1;32m$2\033[0m" ;;
        yellow) echo "\033[1;33m$2\033[0m" ;;
        *) echo "$2" ;;
    esac
}

#########################################################################
# check_version_aios: aios.sh専用のシンプルなバージョンチェック関数
#########################################################################
check_version_aios() {
    # OpenWrtバージョン取得
    local current_version
    current_version=$(awk -F"'" '/DISTRIB_RELEASE/ {print $2}' /etc/openwrt_release)

    # サポートされているバージョンと比較
    if echo "$SUPPORTED_VERSIONS" | grep -qw "$current_version"; then
        echo -e "\033[1;32mOpenWrt version $current_version is supported.\033[0m"
    else
        echo -e "\033[1;31mERROR: Unsupported OpenWrt version: $current_version.\033[0m"
        echo -e "\033[1;33mSupported versions are: $SUPPORTED_VERSIONS\033[0m"
        exit 1
    fi
}

#########################################################################
# delete_aios: 既存の aios 関連ファイルおよびディレクトリを削除して初期化する
#########################################################################
delete_aios() {
    rm -rf "${BASE_DIR}" /usr/bin/aios
    echo "$(color green "Initialized aios.")"
}

#########################################################################
# make_directory: 必要なディレクトリ (BASE_DIR) を作成する
#########################################################################
make_directory() {
    mkdir -p "$BASE_DIR" || {
        echo "$(color red "Failed to create directory: $BASE_DIR")"
        exit 1
    }
}

#########################################################################
# download_and_execute: aios メインスクリプトをダウンロードし実行
#########################################################################
download_and_execute() {
    wget --quiet -O "/usr/bin/aios" "${BASE_URL}/aios" || {
        echo "$(color red "Failed to download aios.")"
        exit 1
    }
    chmod +x /usr/bin/aios || {
        echo "$(color red "Failed to set execute permissions on /usr/bin/aios")"
        exit 1
    }

    echo -e "\n$(color green "Installation Complete.")"
    echo "$(color cyan "aios has been installed successfully.")"
    echo "$(color yellow "You can now run the 'aios' script anywhere.")"

    /usr/bin/aios "$INPUT_LANG" || {
        echo "$(color red "Failed to execute aios script.")"
        exit 1
    }
}

#########################################################################
# メイン処理
#########################################################################
delete_aios
make_directory
check_version
download_and_execute
