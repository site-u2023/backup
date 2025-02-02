#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
#
# country-info.sh
#
# このスクリプトは、統合された国・タイムゾーン情報データを出力します。
# 各レコードは以下の形式で出力されます:
#
#   CountryName DisplayName LanguageCode CountryCode TZ_Cities;TZ_Offsets
#
#  - TZ_Cities: タイムゾーン都市のリスト（カンマ区切り）
#  - TZ_Offsets: タイムゾーンオフセットのリスト（カンマ区切り）
#
# 特定の国を検索する場合:
# sh country-zone.sh Japan
# 全データを出力する場合:
# sh country-zone.sh

cat << 'EOF'
Bulgaria български bg BG Europe/Sofia;EET-2,EEST-3
Canada English ca CA America/Halifax,America/Toronto,America/Winnipeg,America/Edmonton,America/Vancouver;NST3:30NDT2:30,AST4ADT3,EST5EDT4,CST6CDT5,MST7MDT6,PST8PDT7
Czech_Republic Čeština cs CZ Europe/Prague;CET-1,CEST-2
Germany Deutsch de DE Europe/Berlin;CET-1,CEST-2
Greece Ελληνικά el GR Europe/Athens;EET-2,EEST-3
United_States English en US America/New_York,America/Chicago,America/Denver,America/Los_Angeles,America/Anchorage,America/Honolulu;EST5EDT4,CST6CDT5,MST7MDT6,PST8PDT7,AKST9AKDT8,HST10
Spain Español es ES Europe/Madrid;CET-1,CEST-2
Catalan Català ca ES Europe/Madrid;CET-1,CEST-2
France Français fr FR Europe/Paris;CET-1,CEST-2
Israel עִבְרִית he IL Asia/Jerusalem;IST-2,IDT-3
India हिंदी hi IN Asia/Kolkata;IST-5:30
Hungary Magyar hu HU Europe/Budapest;CET-1,CEST-2
Italy Italiano it IT Europe/Rome;CET-1,CEST-2
Japan 日本語 ja JP Asia/Tokyo;JST-9
Republic_of_Korea 한국어 ko KR Asia/Seoul;KST-9
Marathi मराठी mr IN Asia/Kolkata;IST-5:30
Malaysia Bahasa_Melayu ms MY Asia/Kuala_Lumpur;Asia/Kuala_Lumpur
Norway Norsk no NO Europe/Oslo;CET-1,CEST-2
Poland Polski pl PL Europe/Warsaw;CET-1,CEST-2
Portugal Português pt PT Europe/Lisbon;AZOT1,AZOST0,WET0,WEST-1
Brazil Português_do_Brasil pt-br BR America/Sao_Paulo,America/Manaus;BRT3,BRST2,AMT4,ACT4:30
Romania Română ro RO Europe/Bucharest;EET-2,EEST-3
Russia Русский ru RU Europe/Moscow,Asia/Krasnoyarsk,Asia/Yekaterinburg,Asia/Irkutsk,Asia/Vladivostok;MSK-3,SAMT-4,YEKT-5,OMST-6,KRAT-7,IRKT-8,YAKT-9,VLAT-10,MAGT-11
Slovak_Republic Slovenčina sk SK Europe/Bratislava;CET-1,CEST-2
Sweden Svenska sv SE Europe/Stockholm;CET-1,CEST-2
Turkey Türkçe tr TR Europe/Istanbul;TRT-3
Ukraine Українська uk UA Europe/Kiev;EET-2,EEST-3
Vietnam Tiếng_Việt vi VN Asia/Ho_Chi_Minh;ICT-7
China 简体中文 zh-cn CN Asia/Shanghai;CST-8
Taiwan 繁體中文 zh-tw TW Asia/Taipei;CST-8
Saudi_Arabia العربية ar SA Asia/Riyadh;AST-3
Bangladesh বাংলা bn BD Asia/Dhaka;BST-6
Denmark Dansk da DK Europe/Copenhagen;CET-1,CEST-2
Finland Suomi fi FI Europe/Helsinki;EET-2,EEST-3
Netherlands Nederlands nl NL Europe/Amsterdam;CET-1,CEST-2
Luxembourg Luxembourgish xx LU Europe/Luxembourg;CET-1,CEST-2
Switzerland Swiss_German xx CH Europe/Zurich;CET-1,CEST-2
United_Kingdom English xx GB Europe/London;GMT0,BST-1
Hong_Kong Cantonese xx HK Asia/Hong_Kong;HKT-8
Singapore English xx SG Asia/Singapore;SGT-8
United_Arab_Emirates Arabic xx AE Asia/Dubai;GST-4
South_Africa English xx ZA Africa/Johannesburg;SAST-2
Argentina Spanish xx AR America/Argentina/Buenos_Aires;ART3
Australia English xx AU Australia/Perth,Australia/Adelaide,Australia/Sydney,Australia/Lord_Howe,Australia/Hobart;AWST-8,ACST-9:30,AEST-10,LHST-10:30,NFT-11
Austria German xx AT Europe/Vienna;CET-1,CEST-2
Bolivia Spanish xx BO America/La_Paz;BOT4
Chile Spanish xx CL Chile/Continental,Chile/Island;CLT4,CLST3
Iceland Icelandic xx IS Atlantic/Reykjavik;GMT0
Ireland Irish xx IE Europe/Dublin;GMT0,IST-1
Kuwait Arabic xx KW Asia/Kuwait;AST-3
Liechtenstein German xx LI Europe/Vaduz;CET-1,CEST-2
Lithuania Lithuanian xx LT Europe/Vilnius;EET-2,EEST-3
Mexico Spanish xx MX America/Mexico_City,America/Tijuana,America/Monterrey;CST6,CDT5,MST7,MDT6,PST8,PDT7
Morocco Arabic xx MA Africa/Casablanca;WET0,WEST-1
New_Zealand English xx NZ Pacific/Auckland,Pacific/Chatham;NZST-12,NZDT-13
Puerto_Rico Spanish xx PR America/Puerto_Rico;AST4
Slovenia Slovenian xx SI Europe/Ljubljana;CET-1,CEST-2
Thailand Thai xx TH Asia/Bangkok;ICT-7
Uruguay Spanish xx UY America/Montevideo;UYT3
Panama Spanish xx PA America/Panama;EST5
Egypt Arabic xx EG Africa/Cairo;EET-2
Trinidad_and_Tobago English xx TT America/Port_of_Spain;AST4
Costa_Rica Spanish xx CR America/Costa_Rica;CST6
Ecuador Spanish xx EC America/Guayaquil;ECT5
Honduras Spanish xx HN America/Tegucigalpa;CST6
Kenya Swahili xx KE Africa/Nairobi;EAT-3
Cyprus Greek xx CY Asia/Nicosia;EET-2,EEST-3
Estonia Estonian xx EE Europe/Tallinn;EET-2,EEST-3
Mauritius English xx MU Indian/Mauritius;MUT+4
Serbia Serbian xx RS Europe/Belgrade;CET-1,CEST-2
Montenegro Montenegrin xx ME Europe/Podgorica;CET-1,CEST-2
Indonesia Indonesian xx ID Asia/Jakarta,Asia/Bali,Asia/Makassar;WIB-7,WITA-8,WIT-9
Peru Spanish xx PE America/Lima;PET5
Venezuela Spanish xx VE America/Caracas;VET-4:30
Jamaica English xx JM America/Jamaica;EST5
Bahrain Arabic xx BH Asia/Bahrain;AST-3
Oman Arabic xx OM Asia/Muscat;GST-4
Jordan Arabic xx JO Asia/Amman;EET-2
Bermuda English xx BM Atlantic/Bermuda;AST4
Colombia Spanish xx CO America/Bogota;COT5
Dominican_Republic Spanish xx DO America/Santo_Domingo;AST4
Guatemala Spanish xx GT America/Guatemala;CST6
Philippines Filipino xx PH Asia/Manila;PHT-8
Sri_Lanka Sinhala xx LK Asia/Colombo;IST-5:30
El_Salvador Spanish xx SV America/El_Salvador;CST6
Tunisia Arabic xx TN Africa/Tunis;CET-1
Pakistan Urdu xx PK Asia/Karachi;PKT-5
Qatar Arabic xx QA Asia/Qatar;AST-3
Algeria Arabic xx DZ Africa/Algiers;CET-1
EOF

get_country_info() {
    local query="$1"
    local country_info

    country_info=$(country_data | grep -iw "$query")

    if [ -n "$country_info" ]; then
        echo "$country_info"
    else
        echo "Country code or country name not found."
        exit 1
    fi
}

# コマンドライン引数が指定されている場合、その国の情報を取得
if [ -n "$1" ]; then
    get_country_info "$1"
else
    country_data
fi

get_country_info
