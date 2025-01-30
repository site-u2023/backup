#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# As of February 1, 2025

SELECTED_LANGUAG="$1"

# タイムゾーンデータ
# 国名 言語コード 国コード タイムゾーン(複数あり) 母国語または対応バージョン xxはluci-i18n-base非対応
country_zonename_data() {
country_zonename="
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

check_country_zonename() {
  if [ -z "$SELECTED_LANGUAG" ]; then
    echo "$country_zonename"
  else
    found_entry=$(echo "$country_zonename" | grep -iw "$SELECTED_LANGUAG")
    if [ -n "$found_entry" ]; then
      echo "$found_entry"
    else
      echo "Country code or country name not found."
      exit 1
    fi
  fi
}

country_zonename_data
check_country_zonename
