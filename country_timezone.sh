#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

country_code="$1"

# タイムゾーンデータ
# 国名 言語コード 国コード タイムゾーン(複数あり) 母国語または対応バージョン xxはluci-i18n-base非対応
country_timezones_data() {
country_timezones="
Bulgaria bg BG EET-2 EEST-3 български  
Canada ca CA NST3:30NDT2:30 AST4ADT3 EST5EDT4 CST6CDT5 MST7MDT6 PST8PDT7 Català  
Czech_Republic cs CZ CET-1 CEST-2 Čeština  
Germany de DE CET-1 CEST-2 Deutsch  
Greece el GR EET-2 EEST-3 Ελληνικά  
United_States en US EST5EDT4 CST6CDT5 MST7MDT6 PST8PDT7 AKST9AKDT8 HST10  
Spain es ES CET-1 CEST-2 Español  
Catalan ca ES CET-1 CEST-2 Català  
France fr FR CET-1 CEST-2 Français  
Israel he IL IST-2 IDT-3 עִבְרִית  
India hi IN IST-5:30 हिंदी  
Hungary hu HU CET-1 CEST-2 Magyar  
Italy it IT CET-1 CEST-2 Italiano  
Japan ja JP JST-9 日本語  
Republic_of_Korea ko KR KST-9 한국어  
Marathi mr IN IST-5:30 मराठी  
Malaysia ms MY MYT-8 Bahasa_Melayu  
Norway no NO CET-1 CEST-2 Norsk  
Poland pl PL CET-1 CEST-2 Polski  
Portugal pt PT AZOT1 AZOST0 WET0 WEST-1 Português  
Brazil pt-br BR BRT3 BRST2 AMT4 ACT4:30 Português_do_Brasil  
Romania ro RO EET-2 EEST-3 Română  
Russia ru RU MSK-3 SAMT-4 YEKT-5 OMST-6 KRAT-7 IRKT-8 YAKT-9 VLAT-10 MAGT-11 Русский  
Slovak_Republic sk SK CET-1 CEST-2 Slovenčina  
Sweden sv SE CET-1 CEST-2 Svenska  
Turkey tr TR TRT-3 Türkçe  
Ukraine uk UA EET-2 EEST-3 Українська  
Vietnam vi VN ICT-7 Tiếng_Việt  
China zh-cn CN CST-8 简体中文  
Taiwan zh-tw TW CST-8 繁體中文  
Saudi_Arabia ar SA AST-3 العربية  
Bangladesh bn BD BST-6 বাংলা  
Denmark da DK CET-1 CEST-2 Dansk  
Finland fi FI EET-2 EEST-3 Suomi  
Netherlands nl NL CET-1 CEST-2 Nederlands  
Luxembourg xx LU CET-1 CEST-2  
Switzerland xx CH CET-1 CEST-2  
United_Kingdom xx GB GMT0 BST-1  
Hong_Kong xx HK HKT-8  
Singapore xx SG SGT-8  
United_Arab_Emirates xx AE GST-4  
South_Africa xx ZA SAST-2  
Argentina xx AR ART3  
Australia xx AU AWST-8 ACST-9:30 AEST-10 LHST-10:30 NFT-11  
Austria xx AT CET-1 CEST-2  
Bolivia xx BO BOT4  
Chile xx CL CLT4 CLST3  
Iceland xx IS GMT0  
Ireland xx IE GMT0 IST-1  
Kuwait xx KW AST-3  
Liechtenstein xx LI CET-1 CEST-2  
Lithuania xx LT EET-2 EEST-3  
Mexico xx MX CST6 CDT5 MST7 MDT6 PST8 PDT7  
Morocco xx MA WET0 WEST-1  
New_Zealand xx NZ NZST-12 NZDT-13  
Puerto_Rico xx PR AST4  
Slovenia xx SI CET-1 CEST-2  
Thailand xx TH ICT-7  
Uruguay xx UY UYT3  
Panama xx PA EST5  
Egypt xx EG EET-2  
Trinidad_and_Tobago xx TT AST4  
Costa_Rica xx CR CST6  
Ecuador xx EC ECT5  
Honduras xx HN CST6  
Kenya xx KE EAT-3  
Cyprus xx CY EET-2 EEST-3  
Estonia xx EE EET-2 EEST-3  
Mauritius xx MU MUT+4
Serbia xx RS CET-1 CEST-2  
Montenegro xx ME CET-1 CEST-2  
Indonesia xx ID WIB-7 WITA-8 WIT-9  
Peru xx PE PET5
Venezuela xx VE VET-4:30
Jamaica xx JM EST5  
Bahrain xx BH AST-3  
Oman xx OM GST-4  
Jordan xx JO EET-2  
Bermuda xx BM AST4  
Colombia xx CO COT5  
Dominican_Republic xx DO AST4  
Guatemala xx GT CST6  
Philippines xx PH PHT-8  
Sri_Lanka xx LK IST-5:30  
El_Salvador xx SV CST6  
Tunisia xx TN CET-1  
Pakistan xx PK PKT-5  
Qatar xx QA AST-3  
Algeria xx DZ CET-1  
"
}

country_timezones_data_2() {
country_timezones_2="
Bulgaria bg BG Europe/Sofia български  
Canada ca CA America/Halifax America/Toronto America/Winnipeg America/Edmonton America/Vancouver Català  
Czech_Republic cs CZ Europe/Prague Čeština  
Germany de DE Europe/Berlin Deutsch  
Greece el GR Europe/Athens Ελληνικά  
United_States en US America/New_York America/Chicago America/Denver America/Los_Angeles America/Anchorage America/Honolulu  
Spain es ES Europe/Madrid Español  
Catalan ca ES Europe/Madrid Català  
France fr FR Europe/Paris Français  
Israel he IL Asia/Jerusalem עִבְרִית  
India hi IN Asia/Kolkata हिंदी  
Hungary hu HU Europe/Budapest Magyar  
Italy it IT Europe/Rome Italiano  
Japan ja JP Asia/Tokyo 日本語  
Republic_of_Korea ko KR Asia/Seoul 한국어  
Marathi mr IN Asia/Kolkata मराठी  
Malaysia ms MY Asia/Kuala_Lumpur Bahasa_Melayu  
Norway no NO Europe/Oslo Norsk  
Poland pl PL Europe/Warsaw Polski  
Portugal pt PT Europe/Lisbon Português  
Brazil pt-br BR America/Sao_Paulo America/Manaus Português_do_Brasil  
Romania ro RO Europe/Bucharest Română  
Russia ru RU Europe/Moscow Asia/Krasnoyarsk Asia/Yekaterinburg Asia/Irkutsk Asia/Vladivostok Русский  
Slovak_Republic sk SK Europe/Bratislava Slovenčina  
Sweden sv SE Europe/Stockholm Svenska  
Turkey tr TR Europe/Istanbul Türkçe  
Ukraine uk UA Europe/Kiev Українська  
Vietnam vi VN Asia/Ho_Chi_Minh Tiếng_Việt  
China zh-cn CN Asia/Shanghai 简体中文  
Taiwan zh-tw TW Asia/Taipei 繁體中文  
Saudi_Arabia ar SA Asia/Riyadh العربية  
Bangladesh bn BD Asia/Dhaka বাংলা  
Denmark da DK Europe/Copenhagen Dansk  
Finland fi FI Europe/Helsinki Suomi  
Netherlands nl NL Europe/Amsterdam Nederlands  
Luxembourg xx LU Europe/Luxembourg  
Switzerland xx CH Europe/Zurich  
United_Kingdom xx GB Europe/London  
Hong_Kong xx HK Asia/Hong_Kong  
Singapore xx SG Asia/Singapore  
United_Arab_Emirates xx AE Asia/Dubai  
South_Africa xx ZA Africa/Johannesburg  
Argentina xx AR America/Argentina/Buenos_Aires  
Australia xx AU Australia/Perth Australia/Adelaide Australia/Sydney Australia/Lord_Howe Island Australia/Hobart  
Austria xx AT Europe/Vienna  
Bolivia xx BO America/La_Paz  
Chile xx CL Chile/Continental Chile/Island  
Iceland xx IS Atlantic/Reykjavik  
Ireland xx IE Europe/Dublin  
Kuwait xx KW Asia/Kuwait  
Liechtenstein xx LI Europe/Vaduz  
Lithuania xx LT Europe/Vilnius  
Mexico xx MX America/Mexico_City America/Tijuana America/Monterrey  
Morocco xx MA Africa/Casablanca  
New_Zealand xx NZ Pacific/Auckland Pacific/Chatham  
Puerto_Rico xx PR America/Puerto_Rico  
Slovenia xx SI Europe/Ljubljana  
Thailand xx TH Asia/Bangkok  
Uruguay xx UY America/Montevideo  
Panama xx PA America/Panama  
Egypt xx EG Africa/Cairo  
Trinidad_and_Tobago xx TT America/Port_of_Spain  
Costa_Rica xx CR America/Costa_Rica  
Ecuador xx EC America/Guayaquil  
Honduras xx HN America/Tegucigalpa  
Kenya xx KE Africa/Nairobi  
Cyprus xx CY Asia/Nicosia  
Estonia xx EE Europe/Tallinn  
Mauritius xx MU Indian/Mauritius  
Serbia xx RS Europe/Belgrade  
Montenegro xx ME Europe/Podgorica  
Indonesia xx ID Asia/Jakarta Asia/Bali Asia/Makassar  
Peru xx PE America/Lima  
Venezuela xx VE America/Caracas  
Jamaica xx JM America/Jamaica  
Bahrain xx BH Asia/Bahrain  
Oman xx OM Asia/Muscat  
Jordan xx JO Asia/Amman  
Bermuda xx BM Atlantic/Bermuda  
Colombia xx CO America/Bogota  
Dominican_Republic xx DO America/Santo_Domingo  
Guatemala xx GT America/Guatemala  
Philippines xx PH Asia/Manila  
Sri_Lanka xx LK Asia/Colombo  
El_Salvador xx SV America/El_Salvador  
Tunisia xx TN Africa/Tunis  
Pakistan xx PK Asia/Karachi  
Qatar xx QA Asia/Qatar  
Algeria xx DZ Africa/Algiers  
"
}

check_country_timezone_2() {
  if [ -z "$country_code" ]; then
    echo "$country_timezones_2"
  else
    found_entry=$(echo "$country_timezones_2" | grep -iw "$country_code")
    if [ -n "$found_entry" ]; then
      echo "$found_entry"
    else
      echo "Country code or country name not found."
      exit 1
    fi
  fi
}

check_country_timezone() {
  if [ -z "$country_code" ]; then
    echo "$country_timezones"
  else
    found_entry=$(echo "$country_timezones" | grep -iw "$country_code")
    if [ -n "$found_entry" ]; then
      echo "$found_entry"
    else
      echo "Country code or country name not found."
      exit 1
    fi
  fi
}

country_timezones_data
country_timezones_data_2
check_country_timezone
check_country_timezone_2

#check_country_code_data() {
#country_code="$1"

#found_entry=$(echo "$country_timezones" | grep -w "$country_code")

#found_entry=$(echo "$country_timezones" | grep -E "\b$country_code\b")
#found_entry=$(echo "$country_timezones" | grep -E "\b$country_code\b" | sed 's/-/\\-/g')
#found_entry=$(echo "$country_timezones" | grep -w "$country_code\b" | sed 's/-/\\-/g')
#found_entry=$(echo "$country_timezones" | grep -E "(^|\s)$country_code(\s|$)")

#if [ -n "$found_entry" ]; then
#  echo "$found_entry"
#else
#  echo "Country code or country name not found."
#  exit 1
#fi
#}

#check_country_code() {
#if [ -z "$1" ]; then
#  echo "Usage: $0 <country_code>"
#  exit 1
#fi
#check_country_code_data "$1"
#}

