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
Canada ca CA NST3:30NDT2:30 AST4ADT3 EST5EDT4 CST6CDT5 MST7MDT6 PST8PDT7 English  
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
Luxembourg xx LU CET-1 CEST-2 Luxembourgish  
Switzerland xx CH CET-1 CEST-2 Swiss_German  
United_Kingdom xx GB GMT0 BST-1 English  
Hong_Kong xx HK HKT-8 Cantonese  
Singapore xx SG SGT-8 English  
United_Arab_Emirates xx AE GST-4 Arabic  
South_Africa xx ZA SAST-2 English  
Argentina xx AR ART3 Spanish  
Australia xx AU AWST-8 ACST-9:30 AEST-10 LHST-10:30 NFT-11 English  
Austria xx AT CET-1 CEST-2 German  
Bolivia xx BO BOT4 Spanish  
Chile xx CL CLT4 CLST3 Spanish  
Iceland xx IS GMT0 Icelandic  
Ireland xx IE GMT0 IST-1 Irish  
Kuwait xx KW AST-3 Arabic  
Liechtenstein xx LI CET-1 CEST-2 German  
Lithuania xx LT EET-2 EEST-3 Lithuanian  
Mexico xx MX CST6 CDT5 MST7 MDT6 PST8 PDT7 Spanish  
Morocco xx MA WET0 WEST-1 Arabic  
New_Zealand xx NZ NZST-12 NZDT-13 English  
Puerto_Rico xx PR AST4 Spanish  
Slovenia xx SI CET-1 CEST-2 Slovenian  
Thailand xx TH ICT-7 Thai  
Uruguay xx UY UYT3 Spanish  
Panama xx PA EST5 Spanish  
Egypt xx EG EET-2 Arabic  
Trinidad_and_Tobago xx TT AST4 English  
Costa_Rica xx CR CST6 Spanish  
Ecuador xx EC ECT5 Spanish  
Honduras xx HN CST6 Spanish  
Kenya xx KE EAT-3 Swahili  
Cyprus xx CY EET-2 EEST-3 Greek  
Estonia xx EE EET-2 EEST-3 Estonian  
Mauritius xx MU MUT+4 English  
Serbia xx RS CET-1 CEST-2 Serbian  
Montenegro xx ME CET-1 CEST-2 Montenegrin  
Indonesia xx ID WIB-7 WITA-8 WIT-9 Indonesian  
Peru xx PE PET5 Spanish  
Venezuela xx VE VET-4:30 Spanish  
Jamaica xx JM EST5 English  
Bahrain xx BH AST-3 Arabic  
Oman xx OM GST-4 Arabic  
Jordan xx JO EET-2 Arabic  
Bermuda xx BM AST4 English  
Colombia xx CO COT5 Spanish  
Dominican_Republic xx DO AST4 Spanish  
Guatemala xx GT CST6 Spanish  
Philippines xx PH PHT-8 Filipino  
Sri_Lanka xx LK IST-5:30 Sinhala  
El_Salvador xx SV CST6 Spanish  
Tunisia xx TN CET-1 Arabic  
Pakistan xx PK PKT-5 Urdu  
Qatar xx QA AST-3 Arabic  
Algeria xx DZ CET-1 Arabic  
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
