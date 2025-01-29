#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

# タイムゾーンデータ
country_timezones="
en US United States UTC-5 UTC-6 UTC-7 UTC-8 UTC-9 UTC-10 UTC-11
ca CA Canada UTC-3 UTC-4 UTC-5 UTC-6 UTC-7 UTC-8 UTC-9
ja JP Japan UTC+9
de DE Germany UTC+1 UTC+2
nl NL Netherlands UTC+1 UTC+2
it IT Italy UTC+1 UTC+2
pt PT Portugal UTC-1 UTC+0 UTC+1
lu LU Luxembourg UTC+1 UTC+2
no NO Norway UTC+1 UTC+2
fi FI Finland UTC+2 UTC+3
dk DK Denmark UTC+1 UTC+2
ch CH Switzerland UTC+1 UTC+2
cz CZ Czech Republic UTC+1 UTC+2
es ES Spain UTC+1 UTC+2
gb GB United Kingdom UTC+0 UTC+1
kr KR Republic of Korea UTC+9
cn CN China UTC+8
fr FR France UTC+1 UTC+2
hk HK Hong Kong UTC+8
sg SG Singapore UTC+8
tw TW Taiwan UTC+8
br BR Brazil UTC-3 UTC-4 UTC-5
il IL Israel UTC+2 UTC+3
sa SA Saudi Arabia UTC+3
lb LB Lebanon UTC+2
ae AE United Arab Emirates UTC+4
za ZA South Africa UTC+2
ar AR Argentina UTC-3
au AU Australia UTC+8 UTC+9 UTC+10 UTC+11 UTC+12
at AT Austria UTC+1 UTC+2
bo BO Bolivia UTC-4
cl CL Chile UTC-3 UTC-4 UTC-5
gr GR Greece UTC+2 UTC+3
is IS Iceland UTC+0
in IN India UTC+5:30
ie IE Ireland UTC+0 UTC+1
kw KW Kuwait UTC+3
li LI Liechtenstein UTC+1 UTC+2
lt LT Lithuania UTC+2 UTC+3
mx MX Mexico UTC-6 UTC-7 UTC-8
ma MA Morocco UTC+0 UTC+1
nz NZ New Zealand UTC+12 UTC+13
pl PL Poland UTC+1 UTC+2
pr PR Puerto Rico UTC-4
sk SK Slovak Republic UTC+1 UTC+2
si SI Slovenia UTC+1 UTC+2
th TH Thailand UTC+7
uy UY Uruguay UTC-3
pa PA Panama UTC-5
ru RU Russia UTC+3 UTC+4 UTC+5 UTC+6 UTC+7 UTC+8 UTC+9 UTC+10 UTC+11
eg EG Egypt UTC+2
tt TT Trinidad and Tobago UTC-4
tr TR Turkey UTC+3
cr CR Costa Rica UTC-6
ec EC Ecuador UTC-5
hn HN Honduras UTC-6
ke KE Kenya UTC+3
ua UA Ukraine UTC+2 UTC+3
vn VN Vietnam UTC+7
bg BG Bulgaria UTC+2 UTC+3
cy CY Cyprus UTC+2 UTC+3
ee EE Estonia UTC+2 UTC+3
mu MU Mauritius UTC+4
ro RO Romania UTC+2 UTC+3
cs CS Serbia and Montenegro UTC+1 UTC+2
id ID Indonesia UTC+7 UTC+8 UTC+9
pe PE Peru UTC-5
ve VE Venezuela UTC-4
jm JM Jamaica UTC-5
bh BH Bahrain UTC+3
om OM Oman UTC+4
jo JO Jordan UTC+2
bm BM Bermuda UTC-4
co CO Colombia UTC-5
do DO Dominican Republic UTC-4
gt GT Guatemala UTC-6
ph PH Philippines UTC+8
lk LK Sri Lanka UTC+5:30
sv SV El Salvador UTC-6
tn TN Tunisia UTC+1
pk PK Pakistan UTC+5
qa QA Qatar UTC+3
dz DZ Algeria UTC+1

"

# 引数チェック
if [ -z "$1" ]; then
  echo "Usage: $0 <country_code>"
  exit 1
fi

# 国コードを検索
country_code="$1"
found_entry=$(echo "$country_timezones" | grep -E "^$country_code " )

if [ -n "$found_entry" ]; then
  echo "$found_entry"
else
  echo "Country code not found."
  exit 1
fi

