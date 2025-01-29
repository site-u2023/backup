#!/bin/sh
# License: CC0
# OpenWrt >= 19.07

# タイムゾーンデータ
country_timezones="
en United States UTC-5 UTC-6 UTC-7 UTC-8 UTC-9 UTC-10 UTC-11
ca Canada UTC-3 UTC-4 UTC-5 UTC-6 UTC-7 UTC-8 UTC-9
ja Japan UTC+9
de Germany UTC+1 UTC+2
nl Netherlands UTC+1 UTC+2
it Italy UTC+1 UTC+2
pt Portugal UTC-1 UTC+0 UTC+1
lu Luxembourg UTC+1 UTC+2
no Norway UTC+1 UTC+2
fi Finland UTC+2 UTC+3
dk Denmark UTC+1 UTC+2
ch Switzerland UTC+1 UTC+2
cz Czech Republic UTC+1 UTC+2
es Spain UTC+1 UTC+2
gb United Kingdom UTC+0 UTC+1
kr Republic of Korea UTC+9
cn China UTC+8
fr France UTC+1 UTC+2
hk Hong Kong UTC+8
sg Singapore UTC+8
tw Taiwan UTC+8
br Brazil UTC-3 UTC-4 UTC-5
il Israel UTC+2 UTC+3
sa Saudi Arabia UTC+3
lb Lebanon UTC+2
ae United Arab Emirates UTC+4
za South Africa UTC+2
ar Argentina UTC-3
au Australia UTC+8 UTC+9 UTC+10 UTC+11 UTC+12
at Austria UTC+1 UTC+2
bo Bolivia UTC-4
cl Chile UTC-3 UTC-4 UTC-5
gr Greece UTC+2 UTC+3
is Iceland UTC+0
in India UTC+5:30
ie Ireland UTC+0 UTC+1
kw Kuwait UTC+3
li Liechtenstein UTC+1 UTC+2
lt Lithuania UTC+2 UTC+3
mx Mexico UTC-6 UTC-7 UTC-8
ma Morocco UTC+0 UTC+1
nz New Zealand UTC+12 UTC+13
pl Poland UTC+1 UTC+2
pr Puerto Rico UTC-4
sk Slovak Republic UTC+1 UTC+2
si Slovenia UTC+1 UTC+2
th Thailand UTC+7
uy Uruguay UTC-3
pa Panama UTC-5
ru Russia UTC+3 UTC+4 UTC+5 UTC+6 UTC+7 UTC+8 UTC+9 UTC+10 UTC+11
eg Egypt UTC+2
tt Trinidad and Tobago UTC-4
tr Turkey UTC+3
cr Costa Rica UTC-6
ec Ecuador UTC-5
hn Honduras UTC-6
ke Kenya UTC+3
ua Ukraine UTC+2 UTC+3
vn Vietnam UTC+7
bg Bulgaria UTC+2 UTC+3
cy Cyprus UTC+2 UTC+3
ee Estonia UTC+2 UTC+3
mu Mauritius UTC+4
ro Romania UTC+2 UTC+3
cs Serbia and Montenegro UTC+1 UTC+2
id Indonesia UTC+7 UTC+8 UTC+9
pe Peru UTC-5
ve Venezuela UTC-4
jm Jamaica UTC-5
bh Bahrain UTC+3
om Oman UTC+4
jo Jordan UTC+2
bm Bermuda UTC-4
co Colombia UTC-5
do Dominican Republic UTC-4
gt Guatemala UTC-6
ph Philippines UTC+8
lk Sri Lanka UTC+5:30
sv El Salvador UTC-6
tn Tunisia UTC+1
pk Pakistan UTC+5
qa Qatar UTC+3
dz Algeria UTC+1
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

