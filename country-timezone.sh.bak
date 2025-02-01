#!/bin/sh
# License: CC0
# OpenWrt >= 19.07
# As of February 1, 2025

SELECTED_LANGUAG="$1"

# タイムゾーンデータ
# 国名 言語コード 国コード タイムゾーン(複数あり) 母国語または対応バージョン xxはluci-i18n-base非対応
country_timezones_data() {
country_timezones="
Bulgaria bg BG EET-2 EEST-3 български  
Canada ca CA NST3:30NDT2:30 AST4ADT3 EST5EDT4 CST6CDT5 MST7MDT6 PST8PDT7 Català  
Czech_Republic cs CZ CET-1 CEST-2 Čeština  
Germany de DE CET-1 CEST-2 Deutsch  
Greece el GR EET-2 EEST-3 Ελληνικά  
United_States en US EST5EDT4 CST6CDT5 MST7MDT6 PST8PDT7 AKST9AKDT8 HST10 English 
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

check_country_timezone() {
  if [ -z "$SELECTED_LANGUAG" ]; then
    echo "$country_timezones"
  else
    found_entry=$(echo "$country_timezones" | grep -iw "$SELECTED_LANGUAG")
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
