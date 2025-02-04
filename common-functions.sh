#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# 
# common-functions.sh
#
# 各種共通処理（ヘルプ表示、カラー出力、システム情報確認、言語選択、確認・通知メッセージの多言語対応など）を提供する。
#
echo common-functions.sh Last update 202502031310-34

# 基本定数の設定
BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/site-u2023/aios/main}"
BASE_DIR="${BASE_DIR:-/tmp/aios}"
SUPPORTED_VERSIONS="${SUPPORTED_VERSIONS:-19 21 22 23 24 SN}"
SUPPORTED_LANGUAGES="${SUPPORTED_LANGUAGES:-en}"

#########################################################################
# エラーハンドリング関数
# 引数: エラーメッセージ
# エラー発生時に指定メッセージを赤色で表示し、スクリプトを終了する
#########################################################################
handle_error() {
    local msg="$1"
    echo -e "$(color red_white " ERROR ") $(color red "$msg")" >&2
    exit 1
}

#########################################################################
# print_help: ヘルプメッセージを表示する関数
#########################################################################
print_help() {
    # 言語設定を確認（必要ならキャッシュを読み込み）
    check_common

    # SELECTED_LANGUAGE から言語コードを取得
    local lang="${SELECTED_LANGUAGE}"

    # 各言語ごとにメッセージを変数として定義
    case "$lang" in
        ja)
            DESCRIPTION="オープンダブルアールティー専用設定ソフトウェア"
            HELP_OPTION="このヘルプメッセージを表示して終了します。"
            RESET_OPTION="言語と国の設定キャッシュをクリアします。"
            LANGUAGE_ARG="使用する言語コードを指定します。"
            LANGUAGE_NOTE="指定しない場合は、言語選択メニューが表示されます。"
            EXAMPLE1="言語選択メニューを起動します。"
            EXAMPLE2="英語でスクリプトを実行します。"
            EXAMPLE3="キャッシュをクリアして英語でスクリプトを実行します。"
            ;;
        zh-cn)
            DESCRIPTION="欧鹏达布里阿尔提封装配置软件"
            HELP_OPTION="显示此帮助信息并退出。"
            RESET_OPTION="清除语言和国家设置缓存。"
            LANGUAGE_ARG="立即使用的语言代码。"
            LANGUAGE_NOTE="如果未提供，将显示语言选择菜单。"
            EXAMPLE1="启动语言选择菜单。"
            EXAMPLE2="使用英语运行脚本。"
            EXAMPLE3="清除缓存并使用英语运行脚本。"
            ;;
        zh-tw)
            DESCRIPTION="歐彭達布里阿爾提專用設定軟體"
            HELP_OPTION="顯示此幫助訊息並退出。"
            RESET_OPTION="清除語言和國家設定快取。"
            LANGUAGE_ARG="立即使用的語言代碼。"
            LANGUAGE_NOTE="如果未提供，將顯示語言選擇選單。"
            EXAMPLE1="啟動語言選擇選單。"
            EXAMPLE2="以英文執行腳本。"
            EXAMPLE3="清除快取並以英文執行腳本。"
            ;;
        id)
            DESCRIPTION="Perangkat lunak konfigurasi khusus untuk OpenWrt"
            HELP_OPTION="Tampilkan pesan bantuan ini dan keluar."
            RESET_OPTION="Hapus cache pengaturan bahasa dan negara."
            LANGUAGE_ARG="Kode bahasa yang akan digunakan segera."
            LANGUAGE_NOTE="Jika tidak diberikan, menu pemilihan bahasa akan ditampilkan."
            EXAMPLE1="Menjalankan menu pemilihan bahasa."
            EXAMPLE2="Menjalankan skrip dalam bahasa Inggris."
            EXAMPLE3="Menghapus cache dan menjalankan skrip dalam bahasa Inggris."
            ;;
        ko)
            DESCRIPTION="OpenWrt 전용 설정 소프트웨어"
            HELP_OPTION="이 도움말 메시지를 표시하고 종료합니다."
            RESET_OPTION="언어 및 국가 설정 캐시를 삭제합니다."
            LANGUAGE_ARG="즉시 사용할 언어 코드."
            LANGUAGE_NOTE="지정하지 않으면 언어 선택 메뉴가 표시됩니다."
            EXAMPLE1="언어 선택 메뉴를 실행합니다."
            EXAMPLE2="영어로 스크립트를 실행합니다."
            EXAMPLE3="캐시를 삭제하고 영어로 스크립트를 실행합니다."
            ;;
        de)
            DESCRIPTION="Spezielle Konfigurationssoftware für OpenWrt"
            HELP_OPTION="Diese Hilfemeldung anzeigen und beenden."
            RESET_OPTION="Zwischengespeicherte Sprach- und Ländereinstellungen löschen."
            LANGUAGE_ARG="Sprachcode, der sofort verwendet wird."
            LANGUAGE_NOTE="Falls nicht angegeben, wird ein Sprachwahlmenü angezeigt."
            EXAMPLE1="Startet das Sprachwahlmenü."
            EXAMPLE2="Führt das Skript in englischer Sprache aus."
            EXAMPLE3="Löscht den Cache und führt das Skript in englischer Sprache aus."
            ;;
        ru)
            DESCRIPTION="Специализированное программное обеспечение для настройки OpenWrt"
            HELP_OPTION="Показать это справочное сообщение и выйти."
            RESET_OPTION="Очистить кэш настроек языка и страны."
            LANGUAGE_ARG="Код языка для немедленного использования."
            LANGUAGE_NOTE="Если не указано, будет отображено меню выбора языка."
            EXAMPLE1="Запуск меню выбора языка."
            EXAMPLE2="Запуск скрипта на английском языке."
            EXAMPLE3="Очистка кэша и запуск скрипта на английском языке."
            ;;
        en|*)
            DESCRIPTION="Dedicated configuration software for OpenWrt"
            HELP_OPTION="Display this help message and exit."
            RESET_OPTION="Clear cached language and country settings."
            LANGUAGE_ARG="Language code to be used immediately."
            LANGUAGE_NOTE="If not provided, an interactive language selection menu will be displayed."
            EXAMPLE1="Launches the interactive language selection menu."
            EXAMPLE2="Runs the script with English language."
            EXAMPLE3="Clears cache and runs the script with English language."
            ;;
    esac

    # heredocで変数を展開
    cat << EOF
aios - $DESCRIPTION

Usage:
  aios [OPTION] [LANGUAGE]

Options:
  -h, -help, --help       $HELP_OPTION
  -r, -reset, --reset     $RESET_OPTION

Arguments:
  LANGUAGE         $LANGUAGE_ARG
                   $LANGUAGE_NOTE

Supported Languages:
  en, ja, zh-cn, zh-tw, id, ko, de, ru

Examples:
  aios
    -> $EXAMPLE1

  aios en
    -> $EXAMPLE2

  aios -r en
    -> $EXAMPLE3
EOF
}

#########################################################################
# color_code_map: カラー名から ANSI エスケープシーケンスを返す関数
# 引数: 色の名前 (例: red, green, reset 等)
#########################################################################
color_code_map() {
    local color="$1"
    case "$color" in
        "red") echo "\033[1;31m" ;;
        "green") echo "\033[1;32m" ;;
        "yellow") echo "\033[1;33m" ;;
        "blue") echo "\033[1;34m" ;;
        "magenta") echo "\033[1;35m" ;;
        "cyan") echo "\033[1;36m" ;;
        "white") echo "\033[1;37m" ;;
        "red_underline") echo "\033[4;31m" ;;
        "green_underline") echo "\033[4;32m" ;;
        "yellow_underline") echo "\033[4;33m" ;;
        "blue_underline") echo "\033[4;34m" ;;
        "magenta_underline") echo "\033[4;35m" ;;
        "cyan_underline") echo "\033[4;36m" ;;
        "white_underline") echo "\033[4;37m" ;;
        "red_white") echo "\033[1;41m" ;;
        "green_white") echo "\033[1;42m" ;;
        "yellow_white") echo "\033[1;43m" ;;
        "blue_white") echo "\033[1;44m" ;;
        "magenta_white") echo "\033[1;45m" ;;
        "cyan_white") echo "\033[1;46m" ;;
        "white_black") echo "\033[7;40m" ;;
        "reset") echo "\033[0;39m" ;;
        *) echo "\033[0;39m" ;;
    esac
}

#########################################################################
# color: 指定した色でメッセージを出力する関数
# 引数1: 色の名前、引数以降: 出力する文字列
#########################################################################
color() {
    local col
    col=$(color_code_map "$1")
    shift
    echo -e "${col}$*$(color_code_map "reset")"
}

#########################################################################
# check_version: OpenWrt のバージョン情報を取得し、対応バージョンか検証する
#########################################################################
check_version() {
    local version
    version=$(awk -F"'" '/DISTRIB_RELEASE/ {print $2}' /etc/openwrt_release | cut -c 1-2) || handle_error "バージョン情報の取得に失敗しました。"
    RELEASE_VERSION="$version"
    echo "${RELEASE_VERSION}" > "${BASE_DIR}/check_version"
    
    if ! echo "${SUPPORTED_VERSIONS}" | grep -qw "${RELEASE_VERSION}"; then
        handle_error "Unsupported OpenWrt version: ${RELEASE_VERSION}\nSupported versions: ${SUPPORTED_VERSIONS}"
    fi
}

#########################################################################
# check_package_manager: パッケージマネージャー (apk/opkg) の存在を確認する
#########################################################################
check_package_manager() {
    if command -v apk >/dev/null 2>&1; then
        PACKAGE_MANAGER="APK"
    elif command -v opkg >/dev/null 2>&1; then
        PACKAGE_MANAGER="OPKG"
    else
        handle_error "No package manager found"
    fi
    echo "${PACKAGE_MANAGER}" > "${BASE_DIR}/check_package_manager"
}

#########################################################################
# check_language: 言語選択メニューを表示し、ユーザーに言語を選択させる
#########################################################################
check_language() {
    local country_data lang_field output
    echo -e "$(color white "------------------------------------------------------")"

    # country-zone.sh からデータ取得
    country_data=$(sh "${BASE_DIR}/country-zone.sh" "") || handle_error "Failed to execute country-zone.sh."

    # 国、言語、コード、タイムゾーンを表示
    echo "$country_data" | while IFS= read -r line; do
        [ -z "$line" ] && continue
        lang_field=$(echo "$line" | awk '{print $3}')
        if [ "$lang_field" != "xx" ]; then
            output=$(echo "$line" | awk '{print $1, $2, $3, $4, $5}')
            echo -e "$(color white "$output")"
        fi
    done

    echo -e "$(color white "------------------------------------------------------")"
    echo -e "$(color white "Select a country for language and timezone configuration.")"

    while true; do
        read -p "$(color cyan "Please enter country, language, or timezone: ")" INPUT_LANG
        process_language_selection "$INPUT_LANG"

        # 設定適用の確認
        if ask_confirmation "Apply these settings?"; then
            echo -e "$(color green "Settings applied successfully.")"
            break
        else
            echo -e "$(color yellow "Let's try again.")"
        fi
    done
}

XXXXX_1_check_language() {
    local country_data lang_field output
    echo -e "$(color white "------------------------------------------------------")"

    country_data=$(sh "${BASE_DIR}/country-zone.sh" "") || handle_error "country-zone.sh の実行に失敗しました。"

    echo "$country_data" | while IFS= read -r line; do
        [ -z "$line" ] && continue
        lang_field=$(echo "$line" | awk '{print $3}')  # 言語コード
        if [ "$lang_field" != "xx" ]; then
            output=$(echo "$line" | awk '{print $1, $2, $3, $4, $5}')  # 国名、母国語、言語コード、国コード、タイムゾーンを表示
            echo -e "$(color white "$output")"
        fi
    done

    echo -e "$(color white "------------------------------------------------------")"
    echo -e "$(color white "Select a country for language and timezone configuration.")"
    read -p "$(color white "Please choose: ")" INPUT_LANG
    process_language_selection "$INPUT_LANG"
    normalize_language
}

#########################################################################
# select_timezone_for_country: 国コードに基づき、タイムゾーンを選択
# 引数: 国コード
# 戻り値: 選択されたタイムゾーン
#########################################################################
select_timezone() {
    local country_code="$1"
    local timezone_data timezones timezone_choice

    # タイムゾーン情報を取得
    timezone_data=$(grep -i -w "$country_code" "${BASE_DIR}/country-zone.sh" | awk '{print $5}')

    # BusyBox 互換: カンマ区切りを配列に変換
    timezones=()
    while IFS= read -r line; do
        timezones+=("$line")
    done < <(echo "$timezone_data" | tr ',' '\n')

    # 複数タイムゾーンがある場合の処理
    if [ "${#timezones[@]}" -gt 1 ]; then
        echo -e "$(color cyan "Multiple timezones found for $country_code. Please select:")"
        local i=1
        for tz in "${timezones[@]}"; do
            echo "[$i] $tz"
            ((i++))
        done
        echo "[0] Cancel"

        while true; do
            read -p "$(color white "Enter the number of your timezone choice: ")" timezone_choice
            if [[ "$timezone_choice" =~ ^[0-9]+$ ]] && [ "$timezone_choice" -ge 0 ] && [ "$timezone_choice" -le "${#timezones[@]}" ]; then
                if [ "$timezone_choice" -eq 0 ]; then
                    echo -e "$(color yellow "Timezone selection cancelled.")"
                    return 1
                fi
                SELECTED_TIMEZONE="${timezones[$((timezone_choice - 1))]}"
                break
            else
                echo -e "$(color red "Invalid selection. Please enter a valid number.")"
            fi
        done
    else
        # タイムゾーンが1つしかない場合は自動選択
        SELECTED_TIMEZONE="${timezones[0]}"
    fi

    echo "$SELECTED_TIMEZONE" > "${BASE_DIR}/check_timezone"
    echo -e "$(color green "Selected Timezone: $SELECTED_TIMEZONE")"
}

#########################################################################
# check_common: 初期化処理（オプション処理、バージョン・パッケージマネージャ確認、言語選択）
#########################################################################
check_common() {
    # オプション処理
    case "$1" in
        -h|-help|--help)
            print_help
            exit 0
            ;;
        --reset|-reset|-r)
            rm -f "${BASE_DIR}/check_language" "${BASE_DIR}/check_country" || handle_error "キャッシュの削除に失敗しました。"
            echo "Language and country cache cleared."
            shift  # 次の引数を処理するためにシフト
            ;;
    esac

    # バージョン情報の取得
    if [ -f "${BASE_DIR}/check_version" ]; then
        RELEASE_VERSION=$(cat "${BASE_DIR}/check_version")
    fi
    [ -z "$RELEASE_VERSION" ] && check_version

    # パッケージマネージャーの取得
    if [ -f "${BASE_DIR}/check_package_manager" ]; then
        PACKAGE_MANAGER=$(cat "${BASE_DIR}/check_package_manager")
    fi
    [ -z "$PACKAGE_MANAGER" ] && check_package_manager  

    # コマンドライン引数で言語指定があれば優先する
    if [ -n "$1" ]; then
        process_language_selection "$1"
    fi

    # キャッシュから言語・国コードを読み込む
    if [ -f "${BASE_DIR}/check_language" ]; then
        SELECTED_LANGUAGE=$(cat "${BASE_DIR}/check_language")
    fi
    if [ -f "${BASE_DIR}/check_country" ]; then
        SELECTED_COUNTRY=$(cat "${BASE_DIR}/check_country")
    fi

    # 言語が未設定の場合、言語選択メニューを表示する
    if [ -z "$SELECTED_LANGUAGE" ]; then
        check_language
    fi

    normalize_language  # 言語の正規化
}

#########################################################################
# menu_option: メインメニューの各オプションに対応する処理を行う
#########################################################################
menu_option() {
    local action="$1"
    local label="$2"
    local target="$3"

    case "$action" in
        "download")
            handle_download "$target"
            ;;
        "return")
            handle_return "$label"
            ;;
        "command")
            handle_command "$target"
            ;;
        "exit")
            handle_exit
            ;;
        "delete")
            handle_delete "$target"
            ;;
        *)
            echo -e "$(color red "$(get_message "invalid_option")")"
            ;;
    esac
}

handle_download() {
    local target="$1"

    # 常に最新バージョンをダウンロード
    echo -e "$(color cyan "$(get_message "downloading"): ${target}")"
    wget --quiet -O "${BASE_DIR}/${target}" "${BASE_URL}/${target}"

    if [ $? -eq 0 ]; then
        echo -e "$(color green "$(get_message "download_success"): ${target}")"
        
        # ダウンロード後の実行確認
        if ask_confirmation "$(get_message "confirm_execute") ${target}?"; then
            sh "${BASE_DIR}/${target}"
        else
            echo -e "$(color yellow "$(get_message "execute_cancelled")")"
        fi
    else
        echo -e "$(color red "$(get_message "download_failed"): ${target}")"
    fi
}

handle_return() {
    local label="$1"
    
    if ask_confirmation "$(get_message "confirm_return") $label?"; then
        echo -e "$(color green "$(get_message "return_success") $label")"
        # ここで必要な戻り処理を追加可能
    else
        echo -e "$(color yellow "$(get_message "return_cancelled")")"
    fi
}

handle_command() {
    local target="$1"

    if ask_confirmation "$(get_message "confirm_execute") $target?"; then
        sh -c "$target"
        if [ $? -eq 0 ]; then
            echo -e "$(color green "$(get_message "execute_success"): $target")"
        else
            echo -e "$(color red "$(get_message "execute_failed"): $target")"
        fi
    else
        echo -e "$(color yellow "$(get_message "execute_cancelled")")"
    fi
}

handle_exit() {
    if ask_confirmation "$(get_message "confirm_exit")"; then
        echo -e "$(color green "$(get_message "exit_success")")"
        exit 0
    else
        echo -e "$(color yellow "$(get_message "exit_cancelled")")"
    fi
}

handle_delete() {
    local target="$1"

    if ask_confirmation "$(get_message "confirm_delete") ${target}?"; then
        if rm -f "${BASE_DIR}/${target}"; then
            echo -e "$(color green "$(get_message "delete_success"): ${target}")"
        else
            echo -e "$(color red "$(get_message "delete_failed"): ${target}")"
        fi
    else
        echo -e "$(color yellow "$(get_message "delete_cancelled")")"
    fi
}

XXXXX_menu_option() {
    local action="$1"
    local description="$2"
    local script_name="$3"
    local input_lang="$4"
    
    echo -e "$(color white "$description")"

    case "$action" in
        "exit")
            if ask_confirmation "exit"; then
                show_notification "exit"
                exit 0
            else
                show_notification "exit_cancelled"
            fi
            ;;
        "delete")
            if ask_confirmation "delete"; then
                rm -rf "${BASE_DIR}" /usr/bin/aios /tmp/aios.sh || handle_error "削除に失敗しました。"
                show_notification "delete_success"
                exit 0
            else
                show_notification "delete_cancelled"
            fi
            ;;
        "download")
            if ask_confirmation "download"; then
                if wget --quiet -O "${BASE_DIR}/${script_name}" "${BASE_URL}/${script_name}"; then
                    show_notification "download_success"
                    . "${BASE_DIR}/${script_name}" "$input_lang" || handle_error "スクリプトの実行に失敗しました。"
                else
                    show_notification "download_failure"
                fi
            else
                show_notification "download_cancelled"
            fi
            ;;
        *)
            echo -e "$(color red "Unknown action.")"
            ;;
    esac
}

#########################################################################
# get_message: 多言語対応のメッセージを一元管理する関数
# 引数: メッセージキー
#########################################################################
get_message() {
    local lang="$SELECTED_LANGUAGE"
    local key="$1"
    case "$lang" in
        ja)
            case "$key" in
                # --- メインメニュー関連 ---
                internet_title)       echo "インターネット設定" ;;
                menu_system)          echo "システム初期設定" ;;
                menu_package)         echo "推奨パッケージインストール" ;;
                menu_adblock)         echo "広告ブロッカーインストール設定" ;;
                menu_ap)              echo "アクセスポイント設定" ;;
                menu_other)           echo "その他のスクリプト設定" ;;
                menu_exit)            echo "スクリプト終了" ;;
                menu_delete)          echo "スクリプト削除終了" ;;
                country_code)         echo "カントリーコード" ;;
                reset)                echo "リセット" ;;
                select_prompt)        echo "選択してください:" ;;
                invalid_option)       echo "無効なオプションです" ;;
                input_prompt)         echo "入力してください:" ;;

                # --- 実行・確認メッセージ ---
                confirm_default)      echo "本当に実行しますか？" ;;
                confirm_execute)      echo "このスクリプトを実行しますか" ;;
                confirm_exit)         echo "終了してもよろしいですか？" ;;
                confirm_overwrite)    echo "ファイルは既に存在します。上書きしますか？" ;;
                confirm_delete)       echo "本当に削除してもよろしいですか？" ;;
                confirm_return)       echo "メインメニューに戻りますか？" ;;

                # --- 成功メッセージ ---
                execute_message)      echo "実行します。" ;;
                complete_message)     echo "完了しました。" ;;
                download_success)     echo "ダウンロードに成功しました" ;;
                execute_success)      echo "コマンドが正常に実行されました" ;;
                return_success)       echo "メインメニューに戻りました。" ;;
                delete_success)       echo "正常に削除されました。" ;;

                # --- 失敗メッセージ ---
                download_failed)      echo "ダウンロードに失敗しました" ;;
                execute_failed)       echo "コマンドの実行に失敗しました" ;;
                delete_failed)        echo "削除に失敗しました。" ;;

                # --- キャンセルメッセージ ---
                cancelled_message)    echo "キャンセルされました。" ;;
                exit_cancelled)       echo "終了がキャンセルされました。" ;;
                download_cancelled)   echo "ダウンロードがキャンセルされました。" ;;
                execute_cancelled)    echo "実行がキャンセルされました。" ;;
                return_cancelled)     echo "戻る操作がキャンセルされました。" ;;
                delete_cancelled)     echo "削除がキャンセルされました。" ;;

                *) echo "未定義のメッセージ: $key" ;;
            esac
            ;;
        zh-cn)
            case "$key" in

                *)                    echo "Undefined message: $key" ;;
            esac
            ;;
        zh-tw)
            case "$key" in

                *)                    echo "Undefined message: $key" ;;
            esac
            ;;
        id)
            case "$key" in

                *)                    echo "Undefined message: $key" ;;
            esac
            ;;
        ko)
            case "$key" in

                *)                    echo "Undefined message: $key" ;;
            esac
            ;;
        de)
            case "$key" in

                *)                    echo "Undefined message: $key" ;;
            esac
            ;;
        ru)
            case "$key" in

                *)                    echo "Undefined message: $key" ;;
            esac
            ;;
        en|*)
            case "$key" in
                # --- Main Menu ---
                internet_title)       echo "Internet Settings" ;;
                menu_system)          echo "System Initialization" ;;
                menu_package)         echo "Recommended Package Installation" ;;
                menu_adblock)         echo "Ad Blocker Installation Settings" ;;
                menu_ap)              echo "Access Point Settings" ;;
                menu_other)           echo "Other Script Settings" ;;
                menu_exit)            echo "Exit Script" ;;
                menu_delete)          echo "Delete Script and Exit" ;;
                country_code)         echo "Country Code" ;;
                reset)                echo "Reset" ;;
                select_prompt)        echo "Please make a selection:" ;;
                invalid_option)       echo "Invalid option" ;;
                input_prompt)         echo "Please enter:" ;;

                # --- Confirmation ---
                confirm_default)      echo "Are you sure you want to proceed?" ;;
                confirm_execute)      echo "Do you want to execute this script?" ;;
                confirm_exit)         echo "Are you sure you want to exit?" ;;
                confirm_overwrite)    echo "The file already exists. Do you want to overwrite it?" ;;
                confirm_delete)       echo "Do you really want to delete this?" ;;
                confirm_return)       echo "Do you want to return to the main menu?" ;;

                # --- Success Messages ---
                execute_message)      echo "Executing..." ;;
                complete_message)     echo "Completed." ;;
                download_success)     echo "Download successful" ;;
                execute_success)      echo "Command executed successfully" ;;
                return_success)       echo "Returned to the main menu." ;;
                delete_success)       echo "Deleted successfully." ;;

                # --- Failure Messages ---
                download_failed)      echo "Download failed" ;;
                execute_failed)       echo "Command execution failed" ;;
                delete_failed)        echo "Failed to delete." ;;

                # --- Cancelled Messages ---
                cancelled_message)    echo "Cancelled." ;;
                exit_cancelled)       echo "Exit cancelled." ;;
                download_cancelled)   echo "Download cancelled." ;;
                execute_cancelled)    echo "Execution cancelled." ;;
                return_cancelled)     echo "Return cancelled." ;;
                delete_cancelled)     echo "Deletion cancelled." ;;

                *) echo "Undefined message key: $key" ;;
            esac
            ;;
    esac
}

#########################################################################
# ask_confirmation: 確認プロンプトを表示し、全角/半角の y/n に対応
# 戻り値: y (0) の場合は成功、n (1) の場合はキャンセル
#########################################################################
ask_confirmation() {
    local prompt="${1:-Are you sure you want to proceed?}"
    local choice

    while true; do
        read -p "$(color white "$prompt [Y/n]: ")" choice
        case "$choice" in
            [YyＹｙ]* | "" ) return 0 ;;  # デフォルトは Yes
            [NnＮｎ]* ) return 1 ;;
            * ) echo -e "$(color red "Invalid choice, please enter 'y' or 'n'.")" ;;
        esac
    done
}

#########################################################################
# show_notification: 通知メッセージを表示する関数
#########################################################################
show_notification() {
    local key="$1"
    local message
    message=$(get_message "$key")
    echo -e "$(color white "$message")"
}

#########################################################################
# normalize_language: キャッシュの言語コードがサポート対象か検証し、
#                      サポート外の場合はデフォルト (en) に上書きする
#########################################################################
normalize_language() {
    local CHECK_LANGUAGE READ_LANGUAGE
    CHECK_LANGUAGE="${BASE_DIR}/check_language"
    if [ -f "$CHECK_LANGUAGE" ]; then
        READ_LANGUAGE=$(cat "$CHECK_LANGUAGE")
    fi

    SELECTED_LANGUAGE=""
    for lang in $SUPPORTED_LANGUAGES; do
        if [ "$READ_LANGUAGE" = "$lang" ]; then
            SELECTED_LANGUAGE="$READ_LANGUAGE"
            break
        fi
    done

    if [ -z "$SELECTED_LANGUAGE" ]; then
        SELECTED_LANGUAGE="en"
        echo -e "$(color red "Unsupported language detected. Defaulting to English (en).")"
        echo "$SELECTED_LANGUAGE" > "${BASE_DIR}/check_language"
    fi
}

XXXXX_1_normalize_language() {
    local CHECK_LANGUAGE READ_LANGUAGE
    CHECK_LANGUAGE="${BASE_DIR}/check_language"
    if [ -f "$CHECK_LANGUAGE" ]; then
        READ_LANGUAGE=$(cat "$CHECK_LANGUAGE")
    fi

    SELECTED_LANGUAGE=""
    for lang in $SUPPORTED_LANGUAGES; do
        if [ "$READ_LANGUAGE" = "$lang" ]; then
            SELECTED_LANGUAGE="$READ_LANGUAGE"
            break
        fi
    done

    if [ -z "$SELECTED_LANGUAGE" ]; then
        SELECTED_LANGUAGE="en"
        echo -e "$(color "red" "Unsupported language detected. Defaulting to English (en).")"
        echo "$SELECTED_LANGUAGE" > "${BASE_DIR}/check_language"
    fi
}

#########################################################################
# process_language_selection: ユーザー入力の言語コードから有効な候補を選択する
#########################################################################
#########################################################################
# process_language_selection: ユーザー入力をもとに言語・国を選択
#########################################################################
process_language_selection() {
    local INPUT_LANG="$1" found_entries found_entry

    while true; do
        INPUT_LANG=$(echo "$INPUT_LANG" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        # 完全一致を優先
        found_entries=$(sh "${BASE_DIR}/country-zone.sh" | grep -i -w "${INPUT_LANG}")

        # 部分一致で曖昧検索
        if [ -z "$found_entries" ]; then
            found_entries=$(sh "${BASE_DIR}/country-zone.sh" | grep -i "${INPUT_LANG}")
        fi

        # 一致するデータがない場合
        if [ -z "$found_entries" ]; then
            echo -e "$(color red "No matches found for '$INPUT_LANG'.")"
            if ask_confirmation "Would you like to set English (en) as default?"; then
                found_entries=$(sh "${BASE_DIR}/country-zone.sh" | grep -i "\ben\b")
            else
                read -p "$(color cyan "Please enter more specific input (country, language, or timezone): ")" new_input
                INPUT_LANG="$new_input"
                continue
            fi
        fi

        # 複数候補がある場合
        num_matches=$(echo "$found_entries" | wc -l)
        if [ "$num_matches" -gt 1 ]; then
            echo -e "$(color yellow "Multiple matches found for '$INPUT_LANG'. Please refine your input.")"
            echo "$found_entries" | while IFS= read -r line; do
                echo "$(color cyan "$line")"
            done
            read -p "$(color cyan "Please enter more specific input to narrow down your selection: ")" new_input
            INPUT_LANG="$new_input"
            continue
        else
            found_entry="$found_entries"
        fi

        break
    done

    # フィールド抽出
    SELECTED_LANGUAGE=$(echo "$found_entry" | awk '{print $2}')  # 言語名を取得
    SELECTED_COUNTRY=$(echo "$found_entry" | awk '{print $4}')   # 国コードを取得

    echo "$SELECTED_LANGUAGE" > "${BASE_DIR}/check_language"
    echo "$SELECTED_COUNTRY" > "${BASE_DIR}/check_country"

    # 言語と国を統合して表示
    echo -e "$(color green "Selected Language: ${SELECTED_LANGUAGE} (${SELECTED_COUNTRY})")"

    # タイムゾーン選択を実行
    select_timezone_for_country "$SELECTED_COUNTRY"
}

XXXXX_1_process_language_selection() {
    local INPUT_LANG="$1" found_entries found_entry new_input choice num_matches

    while true; do
        INPUT_LANG=$(echo "$INPUT_LANG" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        # 完全一致を優先（言語コードまたは国コード）
        found_entries=$(sh "${BASE_DIR}/country-zone.sh" | grep -i -w "${INPUT_LANG}")

        # 完全一致で見つからない場合、部分一致（国名や言語名も含む）
        if [ -z "$found_entries" ]; then
            found_entries=$(sh "${BASE_DIR}/country-zone.sh" | grep -i "${INPUT_LANG}")
        fi

        # それでも見つからなければ再入力を促す
        if [ -z "$found_entries" ]; then
            echo "No matching entry found."
            read -p "$(color white "Do you want to re-enter? [y/n]: ")" choice
            case "$choice" in
                [Yy])
                    read -p "$(color white "Please re-enter language: ")" new_input
                    INPUT_LANG="$new_input"
                    continue
                    ;;
                *)
                    echo "Defaulting to English (en)."
                    found_entries=$(sh "${BASE_DIR}/country-zone.sh" | grep -i "\ben\b")
            esac
        fi

        # 複数候補があれば選択肢を表示
        num_matches=$(echo "$found_entries" | wc -l)
        if [ "$num_matches" -gt 1 ]; then
            echo "Multiple matches found. Please select:"
            local i=1
            echo "$found_entries" | while IFS= read -r line; do
                echo "[$i] $line"
                i=$((i+1))
            done
            echo "[0] Re-enter language"

            read -p "$(color white "Enter the number of your choice: ")" choice

            # 無効な入力処理
            if ! [ "$choice" -eq "$choice" ] 2>/dev/null || [ "$choice" -lt 0 ] || [ "$choice" -gt "$num_matches" ]; then
                echo "Invalid selection. Please enter a valid number."
                continue
            fi

            if [ "$choice" -eq 0 ]; then
                read -p "$(color white "Please re-enter language: ")" new_input
                INPUT_LANG="$new_input"
                continue
            fi

            found_entry=$(echo "$found_entries" | sed -n "${choice}p")
        else
            found_entry="$found_entries"
        fi

        break  # 有効な候補が取得できたのでループを抜ける
    done

    # フィールド抽出
    SELECTED_LANGUAGE=$(echo "$found_entry" | awk '{print $3}')
    SELECTED_COUNTRY=$(echo "$found_entry" | awk '{print $4}')

    echo "$SELECTED_LANGUAGE" > "${BASE_DIR}/check_language"
    echo "$SELECTED_COUNTRY" > "${BASE_DIR}/check_country"

    echo "Selected Language: $SELECTED_LANGUAGE"
    echo "Selected Country: $SELECTED_COUNTRY"
}

#########################################################################
# country_zone: 国・ゾーン情報を取得する関数
# country-zonename.sh および country-timezone.sh を利用してゾーン名、タイムゾーン、言語情報を取得する
#########################################################################

country_zone() {
    local country_file="${BASE_DIR}/country-zone.sh"
    local country=$(cat "${BASE_DIR}/check_country")

    ZONENAME=$(sh "$country_file" "$country" "name")
    DISPLAYNAME=$(sh "$country_file" "$country" "display")
    LANGUAGE=$(sh "$country_file" "$country" "lang")
    COUNTRYCODE=$(sh "$country_file" "$country" "code")
    TIMEZONE_CITIES=$(sh "$country_file" "$country" "cities")
    TIMEZONE_OFFSETS=$(sh "$country_file" "$country" "offsets")
}

country_full_info() {
    local country_file="${BASE_DIR}/country-zone.sh"
    local country=$(cat "${BASE_DIR}/check_country")

    # 選択された国の情報を取得し、セミコロンをスペースに置換
    full_info=$(sh "$country_file" "$(cat "${BASE_DIR}/check_country")" | sed 's/;/ /')
    echo "$full_info"
}
