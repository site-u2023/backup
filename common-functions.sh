#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# 
# common-functions.sh
#
# 各種共通処理（ヘルプ表示、カラー出力、システム情報確認、言語選択、確認・通知メッセージの多言語対応など）を提供する。
#
echo common-functions.sh Last update 202502031310-26

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
        lang_field=$(echo "$line" | awk '{print $3}')  # 言語コード
        if [ "$lang_field" != "xx" ]; then
            output=$(echo "$line" | awk '{print $1, $2, $3, $4, $5}')  # 国名、母国語、言語コード、国コード、タイムゾーンを表示
            echo -e "$(color white "$output")"
        fi
    done

    echo -e "$(color white "------------------------------------------------------")"
    echo -e "$(color white "Select a country for language and timezone configuration.")"

    while true; do
        read -p "$(color cyan "Please enter country, language, or timezone: ")" INPUT_LANG
        process_language_selection "$INPUT_LANG"
        normalize_language

        # 最終確認
        read -p "$(color yellow "Apply these settings? [Y/n]: ")" confirm
        case "$confirm" in
            [Yy]* | "" ) 
                echo -e "$(color green "Settings applied successfully.")"
                break
                ;;
            [Nn]* )
                echo -e "$(color white "Let's try again.")"
                ;;
            * )
                echo -e "$(color red "Invalid input. Please enter Y or N.")"
                ;;
        esac
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
    local menu_key="$2"  # ここでメニューのキーを受け取る
    local script_name="$3"
    local input_lang="$4"

    # メニュー説明を多言語で表示
    local description=$(get_message "$menu_key")
    echo -e "$(color white "$description")"

    case "$action" in
        "return")
            if ask_confirmation "return"; then
                show_notification "return"
                return 0
            else
                show_notification "return_cancelled"
            fi
            ;;
        "exit")
            if ask_confirmation "menu_exit"; then
                show_notification "exit"
                exit 0
            else
                show_notification "exit_cancelled"
            fi
            ;;
        "delete")
            if ask_confirmation "delete"; then
                rm -rf "${BASE_DIR}" /usr/bin/aios /tmp/aios.sh || handle_error "$(get_message delete_failed)"
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
                    . "${BASE_DIR}/${script_name}" "$input_lang" || handle_error "$(get_message script_execution_failed)"
                else
                    show_notification "download_failure"
                fi
            else
                show_notification "download_cancelled"
            fi
            ;;
        "command")
            if ask_confirmation "execute_command"; then
                eval "$script_name" || handle_error "$(get_message script_execution_failed)"
            else
                show_notification "execution_cancelled"
            fi
            ;;
        *)
            echo -e "$(color red "$(get_message unknown_action)")"
            ;;
    esac
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
                confirm_default)      echo "本当に実行しますか？" ;;
                execute_message)      echo "実行します。" ;;
                complete_message)     echo "完了しました。" ;;
                cancelled_message)    echo "キャンセルされました。" ;;
                download_success)     echo "ダウンロードが成功しました。" ;;
                return)               echo "戻ります。" ;;
                return_cancelled)     echo "戻る操作がキャンセルされました。" ;;
                *)                    echo "未定義のメッセージ: $key" ;;
            esac
            ;;
        zh-cn)
            case "$key" in
                internet_title)       echo "互联网设置" ;;
                menu_system)          echo "系统初始设置" ;;
                menu_package)         echo "推荐安装包" ;;
                menu_adblock)         echo "广告拦截器设置" ;;
                menu_ap)              echo "访问点设置" ;;
                menu_other)           echo "其他脚本设置" ;;
                menu_exit)            echo "退出脚本" ;;
                menu_delete)          echo "删除脚本并退出" ;;
                country_code)         echo "国码" ;;
                reset)                echo "重置" ;;
                select_prompt)        echo "请选择:" ;;
                invalid_option)       echo "无效的选项" ;;
                input_prompt)         echo "请输入:" ;;
                confirm_default)      echo "您确定吗？" ;;
                execute_message)      echo "执行中。" ;;  # または "执行します。" とするかはお好みで
                complete_message)     echo "完成了。" ;;
                cancelled_message)    echo "已取消。" ;;
                download_success)     echo "ダウンロードが成功しました。" ;;
                return)               echo "戻ります。" ;;
                return_cancelled)     echo "戻る操作がキャンセルされました。" ;;
                *)                    echo "Undefined message: $key" ;;
            esac
            ;;
        zh-tw)
            case "$key" in
                internet_title)       echo "網路設定" ;;
                menu_system)          echo "系統初始設定" ;;
                menu_package)         echo "推薦安裝包" ;;
                menu_adblock)         echo "廣告攔截器設定" ;;
                menu_ap)              echo "連接點設定" ;;
                menu_other)           echo "其他腳本設定" ;;
                menu_exit)            echo "退出腳本" ;;
                menu_delete)          echo "移除腳本並退出" ;;
                country_code)         echo "國碼" ;;
                reset)                echo "重設" ;;
                select_prompt)        echo "請選擇:" ;;
                invalid_option)       echo "無效的選項" ;;
                input_prompt)         echo "請輸入:" ;;
                confirm_default)      echo "您確定嗎？" ;;
                execute_message)      echo "執行中。" ;;  # ※「実行します。」相当
                complete_message)     echo "完成了。" ;;
                cancelled_message)    echo "已取消。" ;;
                download_success)     echo "ダウンロードが成功しました。" ;;
                return)               echo "戻ります。" ;;
                return_cancelled)     echo "戻る操作がキャンセルされました。" ;;
                *)                    echo "Undefined message: $key" ;;
            esac
            ;;
        id)
            case "$key" in
                internet_title)       echo "Pengaturan Internet" ;;
                menu_system)          echo "Pengaturan Sistem Awal" ;;
                menu_package)         echo "Instalasi Paket yang Direkomendasikan" ;;
                menu_adblock)         echo "Pengaturan Pemblokir Iklan" ;;
                menu_ap)              echo "Pengaturan Titik Akses" ;;
                menu_other)           echo "Pengaturan Skrip Lainnya" ;;
                menu_exit)            echo "Keluar dari Skrip" ;;
                menu_delete)          echo "Hapus skrip dan keluar" ;;
                country_code)         echo "Kode Negara" ;;
                reset)                echo "Reset" ;;
                select_prompt)        echo "Silakan pilih:" ;;
                invalid_option)       echo "Opsi tidak valid" ;;
                input_prompt)         echo "Silakan masukkan:" ;;
                confirm_default)      echo "Apakah Anda yakin?" ;;
                execute_message)      echo "Eksekusi." ;;  # または "Sedang dijalankan." とする
                complete_message)     echo "Selesai." ;;
                cancelled_message)    echo "Dibatalkan." ;;
                download_success)     echo "ダウンロードが成功しました。" ;;
                return)               echo "戻ります。" ;;
                return_cancelled)     echo "戻る操作がキャンセルされました。" ;;
                *)                    echo "Undefined message: $key" ;;
            esac
            ;;
        ko)
            case "$key" in
                internet_title)       echo "인터넷 설정" ;;
                menu_system)          echo "시스템 초기 설정" ;;
                menu_package)         echo "추천 패키지 설치" ;;
                menu_adblock)         echo "광고 차단기 설치 설정" ;;
                menu_ap)              echo "액세스 포인트 설정" ;;
                menu_other)           echo "기타 스크립트 설정" ;;
                menu_exit)            echo "스크립트 종료" ;;
                menu_delete)          echo "스크립트 삭제 및 종료" ;;
                country_code)         echo "국가 코드" ;;
                reset)                echo "리셋" ;;
                select_prompt)        echo "옵션을 선택하세요:" ;;
                invalid_option)       echo "잘못된 옵션입니다" ;;
                input_prompt)         echo "입력해 주세요:" ;;
                confirm_default)      echo "정말로 실행하시겠습니까?" ;;
                execute_message)      echo "실행합니다." ;;
                complete_message)     echo "완료되었습니다." ;;
                cancelled_message)    echo "취소되었습니다." ;;
                download_success)     echo "ダウンロードが成功しました。" ;;
                return)               echo "戻ります。" ;;
                return_cancelled)     echo "戻る操作がキャンセルされました。" ;;
                *)                    echo "Undefined message: $key" ;;
            esac
            ;;
        de)
            case "$key" in
                internet_title)       echo "Interneteinstellungen" ;;
                menu_system)          echo "Erste Systemeinstellungen" ;;
                menu_package)         echo "Empfohlene Paketinstallation" ;;
                menu_adblock)         echo "Werbeblocker-Einstellungen" ;;
                menu_ap)              echo "Zugangspunkt-Einstellungen" ;;
                menu_other)           echo "Andere Skripteinstellungen" ;;
                menu_exit)            echo "Skript beenden" ;;
                menu_delete)          echo "Skript löschen und beenden" ;;
                country_code)         echo "Ländercode" ;;
                reset)                echo "Zurücksetzen" ;;
                select_prompt)        echo "Bitte wählen Sie eine Option:" ;;
                invalid_option)       echo "Ungültige Option" ;;
                input_prompt)         echo "Bitte eingeben:" ;;
                confirm_default)      echo "Sind Sie sicher?" ;;
                execute_message)      echo "Ausführen." ;;
                complete_message)     echo "Abgeschlossen." ;;
                cancelled_message)    echo "Abgebrochen." ;;
                download_success)     echo "ダウンロードが成功しました。" ;;
                return)               echo "戻ります。" ;;
                return_cancelled)     echo "戻る操作がキャンセルされました。" ;;
                *)                    echo "Undefined message: $key" ;;
            esac
            ;;
        ru)
            case "$key" in
                internet_title)       echo "Настройки интернета" ;;
                menu_system)          echo "Начальные настройки системы" ;;
                menu_package)         echo "Рекомендуемая установка пакетов" ;;
                menu_adblock)         echo "Настройки блокировки рекламы" ;;
                menu_ap)              echo "Настройки точки доступа" ;;
                menu_other)           echo "Другие настройки скриптов" ;;
                menu_exit)            echo "Выход из скрипта" ;;
                menu_delete)          echo "Удалить скрипт и выйти" ;;
                country_code)         echo "Код страны" ;;
                reset)                echo "Сброс" ;;
                select_prompt)        echo "Пожалуйста, выберите опцию:" ;;
                invalid_option)       echo "Неверный вариант" ;;
                input_prompt)         echo "Пожалуйста, введите:" ;;
                confirm_default)      echo "Вы уверены?" ;;
                execute_message)      echo "Выполняется." ;;
                complete_message)     echo "Завершено." ;;
                cancelled_message)    echo "Отменено." ;;
                download_success)     echo "ダウンロードが成功しました。" ;;
                return)               echo "戻ります。" ;;
                return_cancelled)     echo "戻る操作がキャンセルされました。" ;;
                *)                    echo "Undefined message: $key" ;;
            esac
            ;;
        en|*)
            case "$key" in
                internet_title)       echo "Internet Configuration" ;;
                menu_system)          echo "Initial System Settings" ;;
                menu_package)         echo "Recommended Package Installation" ;;
                menu_adblock)         echo "Ad blocker installation settings" ;;
                menu_ap)              echo "Access Point Settings" ;;
                menu_other)           echo "Other Script Settings" ;;
                menu_exit)            echo "Exit Script" ;;
                menu_delete)          echo "Remove script and exit" ;;
                country_code)         echo "Country Code" ;;
                reset)                echo "Reset" ;;
                select_prompt)        echo "Please select:" ;;
                invalid_option)       echo "Invalid option" ;;
                input_prompt)         echo "Please enter:" ;;
                confirm_default)      echo "Are you sure?" ;;
                execute_message)      echo "Executing." ;;
                complete_message)     echo "Completed." ;;
                cancelled_message)    echo "Cancelled." ;;
                download_success)     echo "Download successful." ;;
                return)               echo "Returning." ;;            # ← 追加
                return_cancelled)     echo "Return operation cancelled." ;;  # ← 追加
                *)                    echo "Undefined message: $key" ;;
            esac
            ;;
    esac
}

XXXXX_get_message() {
    local lang="$SELECTED_LANGUAGE"
    local key="$1"
    case "$lang" in
        ja)
            case "$key" in
                internet_title)    echo "インターネット設定" ;;
                exit_message)      echo "終了" ;;
                select_prompt)     echo "選択してください:" ;;
                invalid_option)    echo "無効なオプションです" ;;
                input_prompt)      echo "入力してください:" ;;
                confirm_default)   echo "本当に実行しますか？" ;;
                complete_message)  echo "完了しました。" ;;
                cancelled_message) echo "キャンセルされました。" ;;
                menu_system)       echo "システム初期設定" ;;
                menu_package)      echo "推奨パッケージインストール" ;;
                menu_adblock)      echo "広告ブロッカーインストール設定" ;;
                menu_ap)           echo "アクセスポイント設定" ;;
                menu_other)        echo "その他のスクリプト設定" ;;
                menu_delete)       echo "スクリプト削除終了" ;;
                *)                 echo "未定義のメッセージ: $key" ;;
            esac
            ;;
        zh-cn)
            case "$key" in
                internet_title)    echo "互联网设置" ;;
                exit_message)      echo "退出" ;;
                select_prompt)     echo "请选择:" ;;
                invalid_option)    echo "无效的选项" ;;
                input_prompt)      echo "请输入:" ;;
                confirm_default)   echo "您确定吗？" ;;
                complete_message)  echo "完成了。" ;;
                cancelled_message) echo "已取消。" ;;
                menu_system)       echo "系统初始设置" ;;
                menu_package)      echo "推荐安装包" ;;
                menu_adblock)      echo "广告拦截器设置" ;;
                menu_ap)           echo "访问点设置" ;;
                menu_other)        echo "其他脚本设置" ;;
                menu_delete)       echo "删除脚本并退出" ;;
                *)                 echo "Undefined message: $key" ;;
            esac
            ;;
        zh-tw)
            case "$key" in
                internet_title)    echo "網路設定" ;;
                exit_message)      echo "退出" ;;
                select_prompt)     echo "請選擇:" ;;
                invalid_option)    echo "無效的選項" ;;
                input_prompt)      echo "請輸入:" ;;
                confirm_default)   echo "您確定嗎？" ;;
                complete_message)  echo "完成了。" ;;
                cancelled_message) echo "已取消。" ;;
                menu_system)       echo "系統初始設定" ;;
                menu_package)      echo "推薦安裝包" ;;
                menu_adblock)      echo "廣告攔截器設定" ;;
                menu_ap)           echo "連接點設定" ;;
                menu_other)        echo "其他腳本設定" ;;
                menu_delete)       echo "移除腳本並退出" ;;
                *)                 echo "Undefined message: $key" ;;
            esac
            ;;
        id)
            case "$key" in
                internet_title)    echo "Pengaturan Internet" ;;
                exit_message)      echo "Keluar" ;;
                select_prompt)     echo "Silakan pilih:" ;;
                invalid_option)    echo "Opsi tidak valid" ;;
                input_prompt)      echo "Silakan masukkan:" ;;
                confirm_default)   echo "Apakah Anda yakin?" ;;
                complete_message)  echo "Selesai." ;;
                cancelled_message) echo "Dibatalkan." ;;
                menu_system)       echo "Pengaturan Sistem Awal" ;;
                menu_package)      echo "Instalasi Paket yang Direkomendasikan" ;;
                menu_adblock)      echo "Pengaturan Pemasangan Pemblokir Iklan" ;;
                menu_ap)           echo "Pengaturan Titik Akses" ;;
                menu_other)        echo "Pengaturan Skrip Lainnya" ;;
                menu_delete)       echo "Hapus skrip dan keluar" ;;
                *)                 echo "Undefined message: $key" ;;
            esac
            ;;
        ko)
            case "$key" in
                internet_title)    echo "인터넷 설정" ;;
                exit_message)      echo "종료" ;;
                select_prompt)     echo "선택하세요:" ;;
                invalid_option)    echo "잘못된 옵션입니다" ;;
                input_prompt)      echo "입력해 주세요:" ;;
                confirm_default)   echo "정말로 실행하시겠습니까?" ;;
                complete_message)  echo "완료되었습니다." ;;
                cancelled_message) echo "취소되었습니다." ;;
                menu_system)       echo "시스템 초기 설정" ;;
                menu_package)      echo "추천 패키지 설치" ;;
                menu_adblock)      echo "광고 차단기 설치 설정" ;;
                menu_ap)           echo "액세스 포인트 설정" ;;
                menu_other)        echo "기타 스크립트 설정" ;;
                menu_delete)       echo "스크립트 삭제 및 종료" ;;
                *)                 echo "Undefined message: $key" ;;
            esac
            ;;
        de)
            case "$key" in
                internet_title)    echo "Interneteinstellungen" ;;
                exit_message)      echo "Beenden" ;;
                select_prompt)     echo "Bitte wählen:" ;;
                invalid_option)    echo "Ungültige Option" ;;
                input_prompt)      echo "Bitte eingeben:" ;;
                confirm_default)   echo "Sind Sie sicher?" ;;
                complete_message)  echo "Abgeschlossen." ;;
                cancelled_message) echo "Abgebrochen." ;;
                menu_system)       echo "Erste Systemeinstellungen" ;;
                menu_package)      echo "Empfohlene Paketinstallation" ;;
                menu_adblock)      echo "Werbeblocker-Einstellungen" ;;
                menu_ap)           echo "Zugangspunkt-Einstellungen" ;;
                menu_other)        echo "Andere Skripteinstellungen" ;;
                menu_delete)       echo "Skript löschen und beenden" ;;
                *)                 echo "Undefined message: $key" ;;
            esac
            ;;
        ru)
            case "$key" in
                internet_title)    echo "Настройки интернета" ;;
                exit_message)      echo "Выход" ;;
                select_prompt)     echo "Пожалуйста, выберите:" ;;
                invalid_option)    echo "Неверный вариант" ;;
                input_prompt)      echo "Пожалуйста, введите:" ;;
                confirm_default)   echo "Вы уверены?" ;;
                complete_message)  echo "Завершено." ;;
                cancelled_message) echo "Отменено." ;;
                menu_system)       echo "Начальные настройки системы" ;;
                menu_package)      echo "Рекомендуемая установка пакетов" ;;
                menu_adblock)      echo "Настройки блокировки рекламы" ;;
                menu_ap)           echo "Настройки точки доступа" ;;
                menu_other)        echo "Другие настройки скриптов" ;;
                menu_delete)       echo "Удалить скрипт и выйти" ;;
                *)                 echo "Undefined message: $key" ;;
            esac
            ;;
        en|*)
            case "$key" in
                internet_title)    echo "Internet Configuration" ;;
                exit_message)      echo "Exit" ;;
                select_prompt)     echo "Please select:" ;;
                invalid_option)    echo "Invalid option" ;;
                input_prompt)      echo "Please enter:" ;;
                confirm_default)   echo "Are you sure?" ;;
                complete_message)  echo "Completed." ;;
                cancelled_message) echo "Cancelled." ;;
                menu_system)       echo "Initial System Settings" ;;
                menu_package)      echo "Recommended Package Installation" ;;
                menu_adblock)      echo "Ad blocker installation settings" ;;
                menu_ap)           echo "Access Point Settings" ;;
                menu_other)        echo "Other Script Settings" ;;
                menu_delete)       echo "Remove script and exit" ;;
                *)                 echo "Undefined message: $key" ;;
            esac
            ;;
    esac
}


XXXXX_get_message() {
    local key="$1"
    local lang="$SELECTED_LANGUAGE"

    case "$lang" in
        ja)
            case "$key" in
                confirm_default) echo "本当に実行しますか？" ;;
                download_success) echo "ダウンロードが成功しました。" ;;
                exit_cancelled) echo "終了操作がキャンセルされました。" ;;
                delete_cancelled) echo "削除操作がキャンセルされました。" ;;
                delete_success) echo "スクリプトと設定が削除されました。" ;;
                download_cancelled) echo "ダウンロード操作がキャンセルされました。" ;;
                exit_complete) echo "終了操作が完了しました。" ;;
                delete_complete) echo "削除操作が完了しました。" ;;
                menu_internet) echo "インターネット設定" ;;
                menu_system) echo "システム初期設定" ;;
                menu_package) echo "推奨パッケージインストール" ;;
                menu_adblock) echo "広告ブロッカーインストール設定" ;;
                menu_ap) echo "アクセスポイント設定" ;;
                menu_other) echo "その他のスクリプト設定" ;;
                menu_exit) echo "スクリプト終了" ;;
                menu_delete) echo "スクリプト削除終了" ;;
                *) echo "操作が完了しました。" ;;
            esac
            ;;
        zh-cn)
            case "$key" in
                confirm_default) echo "您确定吗？" ;;
                download_success) echo "下载成功。" ;;
                exit_cancelled) echo "退出操作已取消。" ;;
                delete_cancelled) echo "删除操作已取消。" ;;
                delete_success) echo "脚本和配置已删除。" ;;
                download_cancelled) echo "下载操作已取消。" ;;
                exit_complete) echo "退出操作已完成。" ;;
                delete_complete) echo "删除操作已完成。" ;;
                menu_internet) echo "互联网设置" ;;
                menu_system) echo "系统初始设置" ;;
                menu_package) echo "推荐安装包" ;;
                menu_adblock) echo "广告拦截器设置" ;;
                menu_ap) echo "访问点设置" ;;
                menu_other) echo "其他脚本设置" ;;
                menu_exit) echo "退出脚本" ;;
                menu_delete) echo "删除脚本并退出" ;;
                *) echo "操作已完成。" ;;
            esac
            ;;
        zh-tw)
            case "$key" in
                confirm_default) echo "您確定嗎？" ;;
                download_success) echo "下載成功。" ;;
                exit_cancelled) echo "退出操作已取消。" ;;
                delete_cancelled) echo "刪除操作已取消。" ;;
                delete_success) echo "腳本和配置已刪除。" ;;
                download_cancelled) echo "下載操作已取消。" ;;
                exit_complete) echo "退出操作已完成。" ;;
                delete_complete) echo "刪除操作已完成。" ;;
                menu_internet) echo "網路設定" ;;
                menu_system) echo "系統初始設定" ;;
                menu_package) echo "推薦安裝包" ;;
                menu_adblock) echo "廣告攔截器設定" ;;
                menu_ap) echo "連接點設定" ;;
                menu_other) echo "其他腳本設定" ;;
                menu_exit) echo "退出腳本" ;;
                menu_delete) echo "移除腳本並退出" ;;
                *) echo "操作已完成。" ;;
            esac
            ;;
        id)
            case "$key" in
                confirm_default) echo "Apakah Anda yakin?" ;;
                download_success) echo "Unduhan berhasil." ;;
                exit_cancelled) echo "Operasi keluar dibatalkan." ;;
                delete_cancelled) echo "Operasi penghapusan dibatalkan." ;;
                delete_success) echo "Skrip dan konfigurasi telah dihapus." ;;
                download_cancelled) echo "Operasi unduhan dibatalkan." ;;
                exit_complete) echo "Operasi keluar selesai." ;;
                delete_complete) echo "Operasi penghapusan selesai." ;;
                menu_internet) echo "Pengaturan Internet" ;;
                menu_system) echo "Pengaturan Sistem Awal" ;;
                menu_package) echo "Instalasi Paket yang Direkomendasikan" ;;
                menu_adblock) echo "Pengaturan Pemasangan Pemblokir Iklan" ;;
                menu_ap) echo "Pengaturan Titik Akses" ;;
                menu_other) echo "Pengaturan Skrip Lainnya" ;;
                menu_exit) echo "Keluar dari Skrip" ;;
                menu_delete) echo "Hapus skrip dan keluar" ;;
                *) echo "Operasi selesai." ;;
            esac
            ;;
        ko)
            case "$key" in
                confirm_default) echo "정말로 실행하시겠습니까?" ;;
                download_success) echo "다운로드 성공." ;;
                exit_cancelled) echo "종료 작업이 취소되었습니다." ;;
                delete_cancelled) echo "삭제 작업이 취소되었습니다." ;;
                delete_success) echo "스크립트와 설정이 삭제되었습니다." ;;
                download_cancelled) echo "다운로드 작업이 취소되었습니다." ;;
                exit_complete) echo "종료 작업이 완료되었습니다." ;;
                delete_complete) echo "삭제 작업이 완료되었습니다." ;;
                menu_internet) echo "인터넷 설정" ;;
                menu_system) echo "시스템 초기 설정" ;;
                menu_package) echo "추천 패키지 설치" ;;
                menu_adblock) echo "광고 차단기 설치 설정" ;;
                menu_ap) echo "액세스 포인트 설정" ;;
                menu_other) echo "기타 스크립트 설정" ;;
                menu_exit) echo "스크립트 종료" ;;
                menu_delete) echo "스크립트 삭제 및 종료" ;;
                *) echo "작업이 완료되었습니다." ;;
            esac
            ;;
        de)
            case "$key" in
                confirm_default) echo "Sind Sie sicher?" ;;
                download_success) echo "Download erfolgreich." ;;
                exit_cancelled) echo "Beenden-Vorgang abgebrochen." ;;
                delete_cancelled) echo "Löschvorgang abgebrochen." ;;
                delete_success) echo "Skript und Konfiguration wurden gelöscht." ;;
                download_cancelled) echo "Download-Vorgang abgebrochen." ;;
                exit_complete) echo "Beenden-Vorgang abgeschlossen." ;;
                delete_complete) echo "Löschvorgang abgeschlossen." ;;
                menu_internet) echo "Interneteinstellungen" ;;
                menu_system) echo "Erste Systemeinstellungen" ;;
                menu_package) echo "Empfohlene Paketinstallation" ;;
                menu_adblock) echo "Werbeblocker-Einstellungen" ;;
                menu_ap) echo "Zugangspunkt-Einstellungen" ;;
                menu_other) echo "Andere Skripteinstellungen" ;;
                menu_exit) echo "Skript beenden" ;;
                menu_delete) echo "Skript löschen und beenden" ;;
                *) echo "Vorgang abgeschlossen." ;;
            esac
            ;;
        ru)
            case "$key" in
                confirm_default) echo "Вы уверены?" ;;
                download_success) echo "Загрузка успешна." ;;
                exit_cancelled) echo "Выход отменён." ;;
                delete_cancelled) echo "Удаление отменено." ;;
                delete_success) echo "Скрипт и настройки удалены." ;;
                download_cancelled) echo "Загрузка отменена." ;;
                exit_complete) echo "Выход завершён." ;;
                delete_complete) echo "Удаление завершено." ;;
                menu_internet) echo "Настройки интернета" ;;
                menu_system) echo "Начальные настройки системы" ;;
                menu_package) echo "Рекомендуемая установка пакетов" ;;
                menu_adblock) echo "Настройки установки блокировщика рекламы" ;;
                menu_ap) echo "Настройки точки доступа" ;;
                menu_other) echo "Другие настройки скриптов" ;;
                menu_exit) echo "Выход из скрипта" ;;
                menu_delete) echo "Удалить скрипт и выйти" ;;
                *) echo "Операция завершена." ;;
            esac
            ;;
        en|*)
            case "$key" in
                confirm_default) echo "Are you sure?" ;;
                download_success) echo "Download successful." ;;
                exit_cancelled) echo "Exit operation cancelled." ;;
                delete_cancelled) echo "Delete operation cancelled." ;;
                delete_success) echo "Script and configuration deleted." ;;
                download_cancelled) echo "Download operation cancelled." ;;
                exit_complete) echo "Exit operation completed." ;;
                delete_complete) echo "Delete operation completed." ;;
                menu_internet) echo "Internet settings" ;;
                menu_system) echo "Initial System Settings" ;;
                menu_package) echo "Recommended Package Installation" ;;
                menu_adblock) echo "Ad blocker installation settings" ;;
                menu_ap) echo "Access Point Settings" ;;
                menu_other) echo "Other Script Settings" ;;
                menu_exit) echo "Exit Script" ;;
                menu_delete) echo "Remove script and exit" ;;
                *) echo "Operation completed." ;;
            esac
            ;;
    esac
}

#########################################################################
# ask_confirmation: 確認プロンプトを表示し、ユーザーの入力 (y/n) を待つ
#########################################################################
ask_confirmation() {
    local prompt
    prompt=$(get_message confirm_default)
    local choice
    while true; do
        read -p "$(color white "$prompt [y/n]: ")" choice
        case "$choice" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo -e "$(color white "Invalid choice, please enter 'y' or 'n'.")" ;;
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
    local INPUT_LANG="$1" found_entries found_entry new_input confirm

    while true; do
        INPUT_LANG=$(echo "$INPUT_LANG" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        # 完全一致を優先（言語コード、国コード、国名）
        found_entries=$(sh "${BASE_DIR}/country-zone.sh" | grep -i -w "${INPUT_LANG}")

        # 完全一致がない場合、部分一致で曖昧検索
        if [ -z "$found_entries" ]; then
            found_entries=$(sh "${BASE_DIR}/country-zone.sh" | grep -i "${INPUT_LANG}")
        fi

        # 一致するデータがない場合
        if [ -z "$found_entries" ]; then
            echo -e "$(color red "No matches found for '$INPUT_LANG'.")"
            read -p "$(color yellow "Would you like to set English (en) as default? [Y/n]: ")" confirm
            case "$confirm" in
                [Yy]* | "" )
                    found_entries=$(sh "${BASE_DIR}/country-zone.sh" | grep -i "\ben\b")
                    ;;
                * )
                    read -p "$(color cyan "Please enter more specific input (country, language, or timezone): ")" new_input
                    INPUT_LANG="$new_input"
                    continue
                    ;;
            esac
        fi

        # 部分一致で複数の候補が見つかった場合
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

        # 完全一致が得られた場合
        if [ -n "$found_entry" ]; then
            break
        fi
    done

    # フィールド抽出
    SELECTED_LANGUAGE=$(echo "$found_entry" | awk '{print $3}')
    SELECTED_COUNTRY=$(echo "$found_entry" | awk '{print $4}')

    echo "$SELECTED_LANGUAGE" > "${BASE_DIR}/check_language"
    echo "$SELECTED_COUNTRY" > "${BASE_DIR}/check_country"

    echo -e "$(color green "Selected Country: $SELECTED_COUNTRY")"
    echo -e "$(color green "Selected Language: $SELECTED_LANGUAGE")"
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
