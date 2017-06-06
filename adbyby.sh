#!/bin/bash
# Adbyby
# By viagram
# viagram@qq.com

opkg update

wget -c https://raw.githubusercontent.com/viagram/adbyby/master/adbyby_2.7.ipk -O /tmp/adbyby_2.7.ipk  --no-check-certificate
opkg install /tmp/adbyby_2.7.ipk #--force-depends --force-Overwrite --force-maintainer
rm -f /tmp/adbyby_2.7.ipk

wget -c https://raw.githubusercontent.com/viagram/adbyby/master/luci-app-adbyby.ipk -O /tmp/luci-app-adbyby.ipk  --no-check-certificate
opkg install /tmp/luci-app-adbyby.ipk #--force-depends --force-Overwrite --force-maintainer
rm -f /tmp/luci-app-adbyby.ipk

wget -c https://raw.githubusercontent.com/viagram/adbyby/master/up.sh -O /tmp/up.sh --no-check-certificate
bash /tmp/up.sh
rm -f /tmp/up.sh
