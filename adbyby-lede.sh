#!/bin/bash
# Adbyby
# By viagram
# viagram@qq.com

curl -sk https://raw.githubusercontent.com/viagram/adbyby/master/adbyby_2.7-20160110_mips_24kc.ipk -o /tmp/adbyby_2.7-20160110_mips_24kc.ipk
opkg install adbyby_2.7-20160110_mips_24kc.ipk
rm -f /tmp/adbyby_2.7-20160110_mips_24kc.ipk

curl -sk https://raw.githubusercontent.com/viagram/adbyby/master/luci-app-adbyby_git-16.324.51057-1c27f6b-1_all.ipk -o /tmp/luci-app-adbyby_git-16.324.51057-1c27f6b-1_all.ipk
opkg install luci-app-adbyby_git-16.324.51057-1c27f6b-1_all.ipk
rm -f /tmp/luci-app-adbyby_git-16.324.51057-1c27f6b-1_all.ipk

curl -sk https://raw.githubusercontent.com/viagram/adbyby/master/up.sh -o /tmp/up.sh
sh /tmp/up.sh
