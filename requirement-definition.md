要件定義 (AIOS - All in One Script)
Last update: 2025-02-05-7

1. プロジェクト概要
プロジェクト名:
All in One Script (AIOS)

概要:
OpenWrt 環境向けの統合管理スクリプト群。初期設定からデバイス管理、ネットワーク設定、DNSフィルタリングまでを一元管理。各スクリプトは個別でも利用可能で、共通関数による多言語対応を実装。軽量かつ柔軟な構成を特徴とし、保守性と拡張性を両立。

2. 参照リンク
新スクリプト群 (AIOS):

GitHub - aios
README.md - aios
旧スクリプト群 (config-software):

GitHub - config-software
README.md - config-software
Qiita 記事:

Qiita - AIOS 解説
3. スクリプト構成
arduino
コピーする
編集する
aios.sh                  ← 初期設定とメインエントリーポイント
  ├── ttyd.sh            ← オプション的コンソールUI
  ├── common-functions.sh← 共通関数と多言語対応のecho管理
  ├── country-zone.sh    ← 国と言語・タイムゾーンデータベース
  ├── openwrt-config.sh  ← メインメニュー（各種設定スクリプトへのリンク）
       ├── system-config.sh     ← デバイス、WiFi初期設定
       ├── internet-config.sh   ← インターネット回線設定
       ├── dns-adblocker.sh     ← DNS＆広告ブロッカー設定
       └── 他スクリプト...
4. 定数と環境変数の設定
コモンファイル (common-functions.sh) 内の基本定数:

sh
コピーする
編集する
#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

# 基本定数の設定
BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/site-u2023/aios/main}"
BASE_DIR="${BASE_DIR:-/tmp/aios}"
SUPPORTED_VERSIONS="${SUPPORTED_VERSIONS:-19.07 21.02 22.03 23.05 24.10.0 SNAPSHOT}"
SUPPORTED_LANGUAGES="${SUPPORTED_LANGUAGES:-en ja zh-cn zh-tw id ko de ru}"
各スクリプト内の定数設定（個別に異なる場合あり）:

sh
コピーする
編集する
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19.07 21.02 22.03 23.05 24.10.0 SNAPSHOT"  # ファイルごとに異なる可能性あり
SUPPORTED_LANGUAGES="en ja zh-cn zh-tw id ko de ru"  # ファイルごとに異なる可能性あり
INPUT_LANG="$1"
5. スクリプト動作要件
各スクリプトは、AIOS メニューからの利用と単独実行の両方をサポート。
言語、バージョン、ダウンローダのチェックは常に common-functions.sh で共通化。
個別の echo メッセージは各スクリプト内で管理し、共通の echo はコモンファイルで管理。
言語対応は LuCI の全言語を考慮。翻訳された分のみ対応し、未翻訳言語はデフォルトで en を使用。
6. 各スクリプトの役割
aios.sh:
初期設定用。最小限の依存関係で実行し、バージョンチェックを行う（common-functions.sh を使用しない）。
$1 で言語をチェック。指定がない場合はデータベースから言語を選択、もしくはキャッシュを利用。
言語決定後、キャッシュに保存。
ttyd.sh:
aios をクライアントのコンソール UI として利用するオプションスクリプト。
aios (メインスクリプト):
スクリプト群のダウンロードと実行を担当。リンクファイルは常に最新をダウンロード。
言語チェック、バージョンチェック、ダウンローダーチェック（opkg から apk への移行も考慮）。
country-zone.sh:
国名、母国語（LuCI 言語識別）、短縮国名（WiFi 設定）、ゾーンネーム（デバイス設定）、タイムゾーンのデータベース。
common-functions.sh:
共通関数（メッセージ出力、YN 判定、ファイルダウンロードなど）を提供。
多言語対応の echo も管理。
openwrt-config.sh:
メインメニュー。各種設定スクリプトへのリンク。
その他スクリプト:
system-config.sh: デバイス、WiFi 初期設定
internet-config.sh: 各種インターネット回線自動設定
dns-adblocker.sh: DNS フィルタリングと広告ブロッカー設定
7. バージョンチェックのルール
バージョンチェックの責任範囲:
aios.sh:
初期セットアップスクリプトとして、最小限の依存関係でバージョンチェックを実行。コモンファイルに依存しない。

common-functions.sh:
各スクリプトファイルの共通処理用に check_version_common 関数 を提供。これは aios メインスクリプトや個別スクリプトでの使用 を想定。

バージョンチェック用のファイル名と保存場所:
キャッシュファイル名: check_version
保存先ディレクトリ: ${BASE_DIR}/check_version
内容: /etc/openwrt_release から取得したバージョン番号（例: 19.07, 24.10.0）
対応するバージョンリスト:
環境変数名: SUPPORTED_VERSIONS
定義場所:
aios.sh: SUPPORTED_VERSIONS="19.07 21.02 22.03 23.05 24.10.0 SNAPSHOT"
common-functions.sh: 同様の内容を定義、または aios.sh から引き継ぎ。
8. バージョン管理構成
バージョンデータベースファイル:
versions-aios.db: aios.sh 用（直接スクリプト内に定義）
versions-common.db: common-functions.sh と他のスクリプト用（ダウンロード形式）
スクリプト別バージョンチェック方針:
aios.sh:
スクリプト内でバージョンを保持し、最速でバージョンチェックを実行。コモンファイルに依存しない。

common-functions.sh:
versions-common.db をダウンロードし、詳細なバージョンチェックを実行。

9. 柔軟なバージョン管理のルール
指定バージョン以上の受け入れ

SUPPORTED_VERSIONS="19.07" と設定した場合、19.07-1, 19.07-9, 19.07-RC1 なども許可されます。
特定バージョン以降の受け入れ

SUPPORTED_VERSIONS="19.07-9" の場合、19.07-9, 19.07-10, 19.07-RC1 は許可されますが、19.07-8 以前のバージョンは拒否されます。
RC版とSNAPSHOTの扱い

RC (Release Candidate) バージョンは自動的に許可されます（例: 21.02-RC1）。
SNAPSHOT バージョンは常に許可されます。
10. コモン関数の命名規則と一覧
命名規則
関数名は機能ごとにプレフィックスを付け、役割を明確にします。

check_: 状態確認系の関数（例: check_version_common, check_language_common）
download_: ファイルダウンロード系の関数（例: download_common_functions, download_country_zone）
handle_: エラー処理および制御系の関数（例: handle_error, handle_exit）
configure_: 設定変更系の関数（例: configure_ttyd, configure_network）
print_: 表示・出力系の関数（例: print_banner, print_help, print_colored_message）
コモン関数一覧
関数名	説明	呼び出し元スクリプト
check_version_common	OpenWrt バージョンの確認。キャッシュされたバージョン情報を使用。	aios, ttyd.sh, system-config.sh
check_language_common	言語キャッシュの確認および設定。	aios, ttyd.sh, internet-config.sh
download_common_functions	common-functions.sh のダウンロードと読み込み。	aios.sh, ttyd.sh, 他全て
download_country_zone	country-zone.sh（国・タイムゾーンデータ）のダウンロード。	aios, system-config.sh
handle_error	エラーメッセージの表示とスクリプトの終了。	全スクリプト
handle_exit	正常終了時の処理。	全スクリプト
configure_ttyd	ttyd の設定と有効化。	ttyd.sh
print_banner	多言語対応のバナー表示。	aios, openwrt-config.sh
print_colored_message	カラーコードを利用したメッセージ表示。	全スクリプト
更新方針
関数名の変更は、要件定義のアップデートと全スクリプトへの反映を伴う。
新規関数追加時も要件定義への追加が必須。
