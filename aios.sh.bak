#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
#
# 初期設定用 all-in-one スクリプト (aios) のセットアップスクリプト
#
# ・既存の aios 関連ファイルの削除
# ・必要なディレクトリの作成
# ・OpenWrt バージョンのチェック
# ・ttyd のインストール確認（未インストールの場合はインストール促し）
# ・aios スクリプトのダウンロードおよび実行
#

# 定数の設定
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"
INPUT_LANG="$1"

#########################################################################
# delete_aios: 既存の aios 関連ファイルおよびディレクトリを削除して初期化する
#########################################################################
delete_aios() {
    rm -rf "${BASE_DIR}" /usr/bin/aios
    echo "Initialized aios"
}

#########################################################################
# make_directory: 必要なディレクトリ (BASE_DIR) を作成する
#########################################################################
make_directory() {
    mkdir -p "$BASE_DIR"
}

#########################################################################
# check_version: /etc/openwrt_release から OpenWrt のバージョンを取得し、
#                対応バージョンか検証する。対応の場合はバージョン情報をキャッシュに保存する。
#########################################################################
check_version() {
    local RELEASE_VERSION
    RELEASE_VERSION=$(awk -F"'" '/DISTRIB_RELEASE/ {print $2}' /etc/openwrt_release | cut -c 1-2)
    if echo "${SUPPORTED_VERSIONS}" | grep -qw "${RELEASE_VERSION}"; then
        echo "${RELEASE_VERSION}" > "${BASE_DIR}/check_version"
    else
        echo "Unsupported OpenWrt version: ${RELEASE_VERSION}"
        echo "Supported versions: ${SUPPORTED_VERSIONS}"
        exit 1
    fi
}

#########################################################################
# check_ttyd_installed: ttyd がインストールされているか確認し、未インストールの場合は
#                       インストールするかどうかをユーザーに促す。
#########################################################################
check_ttyd_installed() {
    local choice
    if ! command -v ttyd >/dev/null 2>&1; then
        echo "ttyd is not installed."
        read -p "Do you want to install ttyd? (y/n, default: n): " choice
        choice=${choice:-n}
        case "$choice" in
            [Yy]*)
                echo "Installing ttyd..."
                wget --quiet -O "${BASE_DIR}/ttyd.sh" "${BASE_URL}/ttyd.sh" || {
                    echo "Failed to download ttyd installation script."
                    exit 1
                }
                if [ ! -f "${BASE_DIR}/ttyd.sh" ]; then
                    echo "Error: ttyd installation script not found."
                    exit 1
                fi
                # ※ 以下の RELEASE_VERSION の扱いは、必要に応じて修正してください
                local RELEASE_VERSION
                RELEASE_VERSION="${RELEASE_VERSION}" sh "${BASE_DIR}/ttyd.sh" "$SELECTED_LANGUAGE"
                ;;
            *)
                echo "Skipping ttyd installation."
                ;;
        esac
    fi
}

#########################################################################
# download_and_execute: aios スクリプトを /usr/bin/ にダウンロードし、
#                         実行権限を付与後、実行する
#########################################################################
download_and_execute() {
    wget --quiet -O "/usr/bin/aios" "${BASE_URL}/aios" || {
        echo "Failed to download aios."
        exit 1
    }
    chmod +x /usr/bin/aios || {
        echo "Failed to set execute permissions on /usr/bin/aios"
        exit 1
    }
    echo -e "\nInstallation Complete"
    echo "aios has been installed successfully."
    echo "You can now run the 'aios' script anywhere."
    /usr/bin/aios "$INPUT_LANG" || {
        echo "Failed to execute aios script."
        exit 1
    }
}

#########################################################################
# メイン処理
#########################################################################
delete_aios
make_directory
check_version
check_ttyd_installed
download_and_execute
