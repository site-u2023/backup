#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

country_code="$1"

# タイムゾーンデータ
# 国名 言語コード 国コード タイムゾーン(複数あり) 母国語または対応バージョン xxはluci-i18n-base非対応
country_timezones_data() {
country_timezones="
Bulgaria bg BG Europe/Sofia Europe/Sofia български  
Canada ca CA America/St_Johns America/Toronto Català  
Czech_Republic cs CZ Europe/Prague Europe/Prague Čeština  
Germany de DE Europe/Berlin Europe/Berlin Deutsch  
Greece el GR Europe/Athens Europe/Athens Ελληνικά  
United_States en US America/New_York America/Chicago Catalan  
Spain es ES Europe/Madrid Europe/Madrid Español  
Catalan ca ES Europe/Madrid Europe/Madrid Català  
France fr FR Europe/Paris Europe/Paris Français  
Israel he IL Asia/Jerusalem Asia/Jerusalem עִבְרִית  
India hi IN Asia/Kolkata Asia/Kolkata हिंदी  
Hungary hu HU Europe/Budapest Europe/Budapest Magyar  
Italy it IT Europe/Rome Europe/Rome Italiano  
Japan ja JP Asia/Tokyo Asia/Tokyo 日本語  
Republic_of_Korea ko KR Asia/Seoul Asia/Seoul 한국어  
Marathi mr IN Asia/Kolkata Asia/Kolkata मराठी  
Malaysia ms MY Asia/Kuala_Lumpur Asia/Kuala_Lumpur Bahasa_Melayu  
Norway no NO Europe/Oslo Europe/Oslo Norsk  
Poland pl PL Europe/Warsaw Europe/Warsaw Polski  
Portugal pt PT Europe/Lisbon Europe/Lisbon Português  
Brazil pt-br BR America/Sao_Paulo America/Sao_Paulo Português_do_Brasil  
Romania ro RO Europe/Bucharest Europe/Bucharest Română  
Russia ru RU Europe/Moscow Europe/Moscow Русский  
Slovak_Republic sk SK Europe/Bratislava Europe/Bratislava Slovenčina  
Sweden sv SE Europe/Stockholm Europe/Stockholm Svenska  
Turkey tr TR Europe/Istanbul Europe/Istanbul Türkçe  
Ukraine uk UA Europe/Kiev Europe/Kiev Українська  
Vietnam vi VN Asia/Ho_Chi_Minh Asia/Ho_Chi_Minh Tiếng_Việt  
China zh-cn CN Asia/Shanghai Asia/Shanghai 简体中文  
Taiwan zh-tw TW Asia/Taipei Asia/Taipei 繁體中文  
Saudi_Arabia ar SA Asia/Riyadh Asia/Riyadh العربية  
Bangladesh bn BD Asia/Dhaka Asia/Dhaka বাংলা  
Denmark da DK Europe/Copenhagen Europe/Copenhagen Dansk  
Finland fi FI Europe/Helsinki Europe/Helsinki Suomi  
Netherlands nl NL Europe/Amsterdam Europe/Amsterdam Nederlands  
Luxembourg xx LU Europe/Luxembourg Europe/Luxembourg  
Switzerland xx CH Europe/Zurich Europe/Zurich  
United_Kingdom xx GB Europe/London Europe/London  
Hong_Kong xx HK Asia/Hong_Kong Asia/Hong_Kong  
Singapore xx SG Asia/Singapore Asia/Singapore  
United_Arab_Emirates xx AE Asia/Dubai Asia/Dubai  
South_Africa xx ZA Africa/Johannesburg Africa/Johannesburg  
Argentina xx AR America/Argentina/Buenos_Aires America/Argentina/Buenos_Aires  
Australia xx AU Australia/Perth Australia/Perth  
Austria xx AT Europe/Vienna Europe/Vienna  
Bolivia xx BO America/La_Paz America/La_Paz  
Chile xx CL America/Santiago America/Santiago  
Iceland xx IS Atlantic/Reykjavik Atlantic/Reykjavik  
Ireland xx IE Europe/Dublin Europe/Dublin  
Kuwait xx KW Asia/Kuwait Asia/Kuwait  
Liechtenstein xx LI Europe/Vaduz Europe/Vaduz  
Lithuania xx LT Europe/Vilnius Europe/Vilnius  
Mexico xx MX America/Mexico_City America/Mexico_City  
Morocco xx MA Africa/Casablanca Africa/Casablanca  
New_Zealand xx NZ Pacific/Auckland Pacific/Auckland  
Puerto_Rico xx PR America/Puerto_Rico America/Puerto_Rico  
Slovenia xx SI Europe/Ljubljana Europe/Ljubljana  
Thailand xx TH Asia/Bangkok Asia/Bangkok  
Uruguay xx UY America/Montevideo America/Montevideo  
Panama xx PA America/Panama America/Panama  
Egypt xx EG Africa/Cairo Africa/Cairo  
Trinidad_and_Tobago xx TT America/Port_of_Spain America/Port_of_Spain  
Costa_Rica xx CR America/Costa_Rica America/Costa_Rica  
Ecuador xx EC America/Guayaquil America/Guayaquil  
Honduras xx HN America/Tegucigalpa America/Tegucigalpa  
Kenya xx KE Africa/Nairobi Africa/Nairobi  
Cyprus xx CY Asia/Nicosia Asia/Nicosia  
Estonia xx EE Europe/Tallinn Europe/Tallinn  
Mauritius xx MU Indian/Mauritius Indian/Mauritius  
Serbia xx RS Europe/Belgrade Europe/Belgrade  
Montenegro xx ME Europe/Belgrade Europe/Belgrade  
Indonesia xx ID Asia/Jakarta Asia/Jakarta  
Peru xx PE America/Lima America/Lima  
Venezuela xx VE America/Caracas America/Caracas  
Jamaica xx JM America/Jamaica America/Jamaica  
Bahrain xx BH Asia/Bahrain Asia/Bahrain  
Oman xx OM Asia/Muscat Asia/Muscat  
Jordan xx JO Asia/Amman Asia/Amman  
Bermuda xx BM Atlantic/Bermuda Atlantic/Bermuda  
Colombia xx CO America/Bogota America/Bogota  
Dominican_Republic xx DO America/Santo_Domingo America/Santo_Domingo  
Guatemala xx GT America/Guatemala America/Guatemala  
Philippines xx PH Asia/Manila Asia/Manila  
Sri_Lanka xx LK Asia/Colombo Asia/Colombo  
El_Salvador xx SV America/El_Salvador America/El_Salvador  
Tunisia xx TN Africa/Tunis Africa/Tunis  
Pakistan xx PK Asia/Karachi Asia/Karachi  
Qatar xx QA Asia/Qatar Asia/Qatar  
Algeria xx DZ Africa/Algiers Africa/Algiers
"
}

check_country_timezone_2() {
if [ -z "$country_code" ]; then
  echo "$country_timezones"
else
  found_entry=$(echo "$country_timezones" | grep -w "$country_code")
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
check_country_timezone

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

