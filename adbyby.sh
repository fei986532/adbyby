#!/bin/bash
# Adbyby
# By viagram
# viagram@qq.com

curl -sk https://raw.githubusercontent.com/viagram/adbyby/master/adbyby_2.7_ar71xx.ipk -o /root/adbyby_2.7_ar71xx.ipk
opkg install adbyby_2.7_ar71xx.ipk --force-depends --force-overwrite --force-maintainer
rm -f /root/adbyby_2.7_ar71xx.ipk 

curl -sk https://raw.githubusercontent.com/viagram/adbyby/master/luci-app-adbyby_2016-01-27_all.ipk -o /root/luci-app-adbyby_2016-01-27_all.ipk
opkg install luci-app-adbyby_2016-01-27_all.ipk --force-depends --force-overwrite --force-maintainer
rm -f /root/luci-app-adbyby_2016-01-27_all.ipk

curl -sk https://raw.githubusercontent.com/viagram/adbyby/master/up.sh -o /root/up.sh
sh /root/up.sh
