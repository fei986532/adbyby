#!/bin/bash
# Adbyby
# By viagram
# viagram@qq.com

opkg update

curl -sk https://raw.githubusercontent.com/viagram/adbyby/master/adbyby_2.7.ipk -o /tmp/adbyby_2.7.ipk
opkg install /tmp/adbyby_2.7.ipk #--force-depends --force-overwrite --force-maintainer
rm -f /tmp/adbyby_2.7.ipk

curl -sk https://raw.githubusercontent.com/viagram/adbyby/master/luci-app-adbyby.ipk -o /tmp/luci-app-adbyby.ipk
opkg install /tmp/luci-app-adbyby.ipk #--force-depends --force-overwrite --force-maintainer
rm -f /tmp/luci-app-adbyby.ipk

curl -sk https://raw.githubusercontent.com/viagram/adbyby/master/up.sh -o /tmp/up.sh
bash /tmp/up.sh
rm -f /tmp/up.sh