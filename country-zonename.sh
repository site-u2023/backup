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
Canada ca CA America/Halifax America/Toronto America/Winnipeg America/Edmonton America/Vancouver English  
Czech_Republic cs CZ Europe/Prague Čeština  
Germany de DE Europe/Berlin Deutsch  
Greece el GR Europe/Athens Ελληνικά  
United_States en US America/New_York America/Chicago America/Denver America/Los_Angeles America/Anchorage America/Honolulu English
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
Luxembourg xx LU Europe/Luxembourg Luxembourgish  
Switzerland xx CH Europe/Zurich Swiss_German  
United_Kingdom xx GB Europe/London English  
Hong_Kong xx HK Asia/Hong_Kong Cantonese  
Singapore xx SG Asia/Singapore English  
United_Arab_Emirates xx AE Asia/Dubai Arabic  
South_Africa xx ZA Africa/Johannesburg English  
Argentina xx AR America/Argentina/Buenos_Aires Spanish  
Australia xx AU Australia/Perth Australia/Adelaide Australia/Sydney Australia/Lord_Howe Island Australia/Hobart English  
Austria xx AT Europe/Vienna German  
Bolivia xx BO America/La_Paz Spanish  
Chile xx CL Chile/Continental Chile/Island Spanish  
Iceland xx IS Atlantic/Reykjavik Icelandic  
Ireland xx IE Europe/Dublin Irish  
Kuwait xx KW Asia/Kuwait Arabic  
Liechtenstein xx LI Europe/Vaduz German  
Lithuania xx LT Europe/Vilnius Lithuanian  
Mexico xx MX America/Mexico_City America/Tijuana America/Monterrey Spanish  
Morocco xx MA Africa/Casablanca Arabic  
New_Zealand xx NZ Pacific/Auckland Pacific/Chatham English  
Puerto_Rico xx PR America/Puerto_Rico Spanish  
Slovenia xx SI Europe/Ljubljana Slovenian  
Thailand xx TH Asia/Bangkok Thai  
Uruguay xx UY America/Montevideo Spanish  
Panama xx PA America/Panama Spanish  
Egypt xx EG Africa/Cairo Arabic  
Trinidad_and_Tobago xx TT America/Port_of_Spain English  
Costa_Rica xx CR America/Costa_Rica Spanish  
Ecuador xx EC America/Guayaquil Spanish  
Honduras xx HN America/Tegucigalpa Spanish  
Kenya xx KE Africa/Nairobi Swahili  
Cyprus xx CY Asia/Nicosia Greek  
Estonia xx EE Europe/Tallinn Estonian  
Mauritius xx MU Indian/Mauritius English  
Serbia xx RS Europe/Belgrade Serbian  
Montenegro xx ME Europe/Podgorica Montenegrin  
Indonesia xx ID Asia/Jakarta Asia/Bali Asia/Makassar Indonesian  
Peru xx PE America/Lima Spanish  
Venezuela xx VE America/Caracas Spanish  
Jamaica xx JM America/Jamaica English  
Bahrain xx BH Asia/Bahrain Arabic  
Oman xx OM Asia/Muscat Arabic  
Jordan xx JO Asia/Amman Arabic  
Bermuda xx BM Atlantic/Bermuda English  
Colombia xx CO America/Bogota Spanish  
Dominican_Republic xx DO America/Santo_Domingo Spanish  
Guatemala xx GT America/Guatemala Spanish  
Philippines xx PH Asia/Manila Filipino  
Sri_Lanka xx LK Asia/Colombo Sinhala  
El_Salvador xx SV America/El_Salvador Spanish  
Tunisia xx TN Africa/Tunis Arabic  
Pakistan xx PK Asia/Karachi Urdu  
Qatar xx QA Asia/Qatar Arabic  
Algeria xx DZ Africa/Algiers Arabic  
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
