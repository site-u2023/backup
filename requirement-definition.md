# 要件定義 (AIOS - All in One Script)
**Last update:** 2025-02-05-3

---

## 1. プロジェクト概要

**プロジェクト名:**  
**All in One Script (AIOS)**

**概要:**  
OpenWrt 環境向けの統合管理スクリプト群。初期設定からデバイス管理、ネットワーク設定、DNSフィルタリングまでを一元管理。各スクリプトは個別でも利用可能で、共通関数による多言語対応を実装。軽量かつ柔軟な構成を特徴とし、保守性と拡張性を両立。

---

## 2. 参照リンク

**新スクリプト群 (AIOS):**  
- [GitHub - aios](https://github.com/site-u2023/aios/blob/main/)  
- [README.md - aios](https://github.com/site-u2023/aios/blob/main/README.md)

**旧スクリプト群 (config-software):**  
- [GitHub - config-software](https://github.com/site-u2023/config-software)  
- [README.md - config-software](https://github.com/site-u2023/config-software/blob/main/README.md)

**Qiita 記事:**  
- [Qiita - AIOS 解説](https://qiita.com/site_u/items/c6a50aa6dea965b5a774)

---

## 3. スクリプト構成

```
aios.sh                  ← 初期設定とメインエントリーポイント
  ├── ttyd.sh            ← オプション的コンソールUI
  ├── common-functions.sh← 共通関数と多言語対応のecho管理
  ├── country-zone.sh    ← 国と言語・タイムゾーンデータベース
  ├── openwrt-config.sh  ← メインメニュー（各種設定スクリプトへのリンク）
       ├── system-config.sh     ← デバイス、WiFi初期設定
       ├── internet-config.sh   ← インターネット回線設定
       ├── dns-adblocker.sh     ← DNS＆広告ブロッカー設定
       └── 他スクリプト...
```

---

## 4. 定数と環境変数の設定

**コモンファイル (`common-functions.sh`) 内の基本定数:**

```sh
#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

# 基本定数の設定
BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/site-u2023/aios/main}"
BASE_DIR="${BASE_DIR:-/tmp/aios}"
SUPPORTED_VERSIONS="${SUPPORTED_VERSIONS:-19 21 22 23 24 SN}"
SUPPORTED_LANGUAGES="${SUPPORTED_LANGUAGES:-en}"
```

**各スクリプト内の定数設定（個別に異なる場合あり）:**

```sh
BASE_URL="https://raw.githubusercontent.com/site-u2023/aios/main"
BASE_DIR="/tmp/aios"
SUPPORTED_VERSIONS="19 21 22 23 24 SN"  # ファイルごとに異なる可能性あり
SUPPORTED_LANGUAGES="en ja zh-cn zh-tw id ko de ru"  # ファイルごとに異なる可能性あり
INPUT_LANG="$1"
```

---

## 5. スクリプト動作要件

- **各スクリプトは、AIOS メニューからの利用と単独実行の両方をサポート。**
- **言語、バージョン、ダウンローダのチェックは常に `common-functions.sh` で共通化。**
- **個別の echo メッセージは各スクリプト内で管理し、共通の echo はコモンファイルで管理。**
- **言語対応は LuCI の全言語を考慮。翻訳された分のみ対応し、未翻訳言語はデフォルトで `en` を使用。**

---

## 6. 各スクリプトの役割

### **`aios.sh`:**  
- 初期設定用。最小限の依存関係で実行し、バージョンチェックを行う（`common-functions.sh` を使用しない）。  
- `$1` で言語をチェック。指定がない場合はデータベースから言語を選択、もしくはキャッシュを利用。  
- 言語決定後、キャッシュに保存。

### **`ttyd.sh`:**  
- `aios` をクライアントのコンソール UI として利用するオプションスクリプト。

### **`aios` (メインスクリプト):**  
- スクリプト群のダウンロードと実行を担当。リンクファイルは常に最新をダウンロード。  
- 言語チェック、バージョンチェック、ダウンローダーチェック（`opkg` から `apk` への移行も考慮）。

### **`country-zone.sh`:**  
- 国名、母国語（LuCI 言語識別）、短縮国名（WiFi 設定）、ゾーンネーム（デバイス設定）、タイムゾーンのデータベース。

### **`common-functions.sh`:**  
- **共通関数（メッセージ出力、YN 判定、ファイルダウンロードなど）を提供。**  
- **多言語対応の echo も管理。**

### **`openwrt-config.sh`:**  
- メインメニュー。各種設定スクリプトへのリンク。

### **その他スクリプト:**
- **`system-config.sh`**: デバイス、WiFi 初期設定  
- **`internet-config.sh`**: 各種インターネット回線自動設定  
- **`dns-adblocker.sh`**: DNS フィルタリングと広告ブロッカー設定  

---

## 7. バージョンチェックのルール

### **バージョンチェックの責任範囲:**

- **`aios.sh`:**  
  初期セットアップスクリプトとして、最小限の依存関係でバージョンチェックを実行。コモンファイルに依存しない。

- **`common-functions.sh`:**  
  各スクリプトファイルの共通処理用に **`check_version` 関数** を提供。これは **`aios` メインスクリプトや個別スクリプトでの使用** を想定。

---

### **バージョンチェック用のファイル名と保存場所:**

- **キャッシュファイル名:** `check_version`  
- **保存先ディレクトリ:** `${BASE_DIR}/check_version`  
- **内容:** `/etc/openwrt_release` から取得したバージョン番号（例: `19`, `24`, `24.10.0`）

---

### **対応するバージョンリスト:**

- **環境変数名:** `SUPPORTED_VERSIONS`
- **定義場所:**  
  - `aios.sh`: `SUPPORTED_VERSIONS="19 21 22 23 24 24.10.0 SN"`  
  - `common-functions.sh`: 同様の内容を定義、または `aios.sh` から引き継ぎ。

---

## 8. バージョンチェックの要件定義

### **バージョンチェックファイルの管理:**

- **ファイル名:** `check_version`
- **保存場所:** `${BASE_DIR}`（デフォルト `/tmp/aios`）
- **内容:** `/etc/openwrt_release` から取得したバージョン番号（例: `19`, `24`, `24.10.0`）

---

### **スクリプトごとのバージョンチェック方針:**

- **`aios.sh`:**  
  - 依存なしで直接 `/etc/openwrt_release` からバージョンを取得・検証。  
  - サポート外のバージョンなら即座にスクリプトを終了。

- **`common-functions.sh`:**  
  - `check_version` 関数を提供し、キャッシュされたバージョン情報を優先して使用。  
  - キャッシュが存在しない場合は `aios.sh` のバージョンチェックを再実行。

---

### **バージョン互換性:**

- **対応バージョン:**  
  - `19.07`  
  - `21.02`  
  - `22.03`  
  - `23.05`  
  - `24.10.0`  
  - `SN`

- **環境変数:** `SUPPORTED_VERSIONS` にて管理。必要に応じてバージョン追加が可能。

---

## 9. バージョン管理構成

### **バージョンデータベースファイル:**

- **`versions-aios.db`:** `aios.sh` 用（直接スクリプト内に定義）  
- **`versions-common.db`:** `common-functions.sh` と他のスクリプト用（ダウンロード形式）

---

### **スクリプト別バージョンチェック方針:**

- **`aios.sh`:**  
  スクリプト内でバージョンを保持し、最速でバージョンチェックを実行。コモンファイルに依存しない。

- **`common-functions.sh`:**  
  `versions-common.db` をダウンロードし、詳細なバージョンチェックを実行。

## バージョンチェック機能の改良 (20250205-4)

### 柔軟なバージョン管理のルール

1. **指定バージョン以上の受け入れ**
   - `SUPPORTED_VERSIONS="19.07"` と設定した場合、`19.07-1`, `19.07-9`, `19.07-RC1` なども許可されます。

2. **特定バージョン以降の受け入れ**
   - `SUPPORTED_VERSIONS="19.07-9"` の場合、`19.07-9`, `19.07-10`, `19.07-RC1` は許可されますが、`19.07-8` 以前のバージョンは拒否されます。

3. **RC版とSNAPSHOTの扱い**
   - `RC` (Release Candidate) バージョンは自動的に許可されます（例: `21.02-RC1`）。
   - `SNAPSHOT` バージョンは常に許可されます。

### 実装方法

`aios.sh` および `common-functions.sh` の `check_version` 関数に、上記のルールを適用しました。プレフィックスマッチングにより、バージョンが柔軟に認識されるようになります。

### 例

```sh
# 例1: SUPPORTED_VERSIONS="19.07"
# 許可されるバージョン: 19.07, 19.07-1, 19.07-9, 19.07-RC1

# 例2: SUPPORTED_VERSIONS="19.07-9"
# 許可されるバージョン: 19.07-9, 19.07-10, 19.07-RC1
# 拒否されるバージョン: 19.07-8, 19.07


---

### バージョンチェックの詳細ルール（2025-02-05 追加）

1. **バージョンチェック関数の2重構成:**
   - **aios.sh**: `check_version_aios` を使用。最小限のローカル変数 `SUPPORTED_VERSIONS` で判定。
   - **common-functions.sh**: `check_version_common` を使用。`supported_versions.db` とローカルの `SUPPORTED_VERSIONS` を参照。

2. **柔軟なバージョン管理:**
   - `SUPPORTED_VERSIONS="19.07 21.02 22.03 23.05 24.10.0 SNAPSHOT"` の場合、
     - **19.07** 系のバージョン（例: 19.07-1, 19.07.9）もサポート。
     - **SNAPSHOT** と **RC**（例: 24.10.0-rc1）も自動的に許可。

3. **バージョンデータベースの活用:**
   - `supported_versions.db` にすべての公式バージョンを記録し、スクリプト全体で一元管理。
