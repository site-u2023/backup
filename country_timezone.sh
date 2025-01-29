#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

# タイムゾーンデータ
# 国名 言語コード 国コード タイムゾーン(複数あり) xxはluci-i18n-base非対応
country_timezones_data() {
country_timezones="
Saudi_Arabia ar SA UTC+3
Bulgaria bg BG UTC+2 UTC+3
Bangladesh bn BD UTC+6
Canada ca CA UTC-3 UTC-4 UTC-5 UTC-6 UTC-7 UTC-8 UTC-9
Czech_Republic cs CZ UTC+1 UTC+2
Denmark da DK UTC+1 UTC+2
Germany de DE UTC+1 UTC+2
Greece el GR UTC+2 UTC+3
United_States en US UTC-5 UTC-6 UTC-7 UTC-8 UTC-9 UTC-10 UTC-11
Spain es ES UTC+1 UTC+2
Finland fi FI UTC+2 UTC+3
France fr FR UTC+1 UTC+2
Israel he IL UTC+2 UTC+3
India hi IN UTC+5:30
Hungary hu HU UTC+1 UTC+2
Italy it IT UTC+1 UTC+2
Japan ja JP UTC+9
Republic_of_Korea ko KR UTC+9
India mr IN UTC+5:30
Malaysia ms MY UTC+8
Netherlands nl NL UTC+1 UTC+2
Norway no NO UTC+1 UTC+2
Poland pl PL UTC+1 UTC+2
Portugal pt PT UTC-1 UTC+0 UTC+1
Brazil pt-br BR UTC-3 UTC-4 UTC-5
Romania ro RO UTC+2 UTC+3
Russia ru RU UTC+3 UTC+4 UTC+5 UTC+6 UTC+7 UTC+8 UTC+9 UTC+10 UTC+11
Slovak_Republic sk SK UTC+1 UTC+2
Sweden sv SE UTC+1 UTC+2
Turkey tr TR UTC+3
Ukraine uk UA UTC+2 UTC+3
Vietnam vi VN UTC+7
China zh-cn CN UTC+8
Taiwan zh-tw TW UTC+8
Luxembourg xx LU UTC+1 UTC+2
Switzerland xx CH UTC+1 UTC+2
United_Kingdom xx GB UTC+0 UTC+1
Hong_Kong xx HK UTC+8
Singapore xx SG UTC+8
United_Arab_Emirates xx AE UTC+4
South_Africa xx ZA UTC+2
Argentina xx AR UTC-3
Australia xx AU UTC+8 UTC+9 UTC+10 UTC+11 UTC+12
Austria xx AT UTC+1 UTC+2
Bolivia xx BO UTC-4
Chile xx CL UTC-3 UTC-4 UTC-5
Iceland xx IS UTC+0
Ireland xx IE UTC+0 UTC+1
Kuwait xx KW UTC+3
Liechtenstein xx LI UTC+1 UTC+2
Lithuania xx LT UTC+2 UTC+3
Mexico xx MX UTC-6 UTC-7 UTC-8
Morocco xx MA UTC+0 UTC+1
New_Zealand xx NZ UTC+12 UTC+13
Puerto_Rico xx PR UTC-4
Slovenia xx SI UTC+1 UTC+2
Thailand xx TH UTC+7
Uruguay xx UY UTC-3
Panama xx PA UTC-5
Egypt xx EG UTC+2
Trinidad_and_Tobago xx TT UTC-4
Costa_Rica xx CR UTC-6
Ecuador xx EC UTC-5
Honduras xx HN UTC-6
Kenya xx KE UTC+3
Cyprus xx CY UTC+2 UTC+3
Estonia xx EE UTC+2 UTC+3
Mauritius xx MU UTC+4
Serbia_and_Montenegro xx CS UTC+1 UTC+2
Indonesia xx ID UTC+7 UTC+8 UTC+9
Peru xx PE UTC-5
Venezuela xx VE UTC-4
Jamaica xx JM UTC-5
Bahrain xx BH UTC+3
Oman xx OM UTC+4
Jordan xx JO UTC+2
Bermuda xx BM UTC-4
Colombia xx CO UTC-5
Dominican_Republic xx DO UTC-4
Guatemala xx GT UTC-6
Philippines xx PH UTC+8
Sri_Lanka xx LK UTC+5:30
El_Salvador xx SV UTC-6
Tunisia xx TN UTC+1
Pakistan xx PK UTC+5
Qatar xx QA UTC+3
Algeria xx DZ UTC+1
"
}

check_country_code2() {
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <country_code> <timezone>"
  exit 1
fi
}

check_country_code_data2() {
country_code="$1"
timezone="$2"

found_entry=$(echo "$country_timezones" | grep -E "^$country_code " | grep -w "$timezone")

if [ -n "$found_entry" ]; then
  echo "$found_entry"
else
  echo "Country code or timezone not found."
  exit 1
fi
}

check_country_code() {
if [ -z "$1" ]; then
  echo "Usage: $0 <country_code>"
  exit 1
fi
}

check_country_code_data() {
country_code="$1"

found_entry=$(echo "$country_timezones" | grep -E "^$country_code ")

if [ -n "$found_entry" ]; then
  echo "$found_entry"
else
  echo "Country code not found."
  exit 1
fi
}

check_country_code "$1"
country_timezones_data
check_country_code_data "$1"
# check_country_code2 "$1"  "$2"
# check_country_code_data2 "$1" "$2"
