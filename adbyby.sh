#!/bin/bash
# Adbyby
# By viagram
# viagram@qq.com

opkg update

wget -c https://raw.githubusercontent.com/viagram/adbyby/master/adbyby_2.7-8.0.1_all.ipk -O /tmp/adbyby_2.7-8.0.1_all.ipk  --no-check-certificate
opkg install /tmp/adbyby_2.7-8.0.1_all.ipk --force-depends #--force-Overwrite --force-maintainer
rm -f /tmp/adbyby_2.7-8.0.1_all.ipk

wget -c https://raw.githubusercontent.com/viagram/adbyby/master/upadbyby.sh -O /tmp/upadbyby.sh  --no-check-certificate
bash /tmp/upadbyby.sh
rm -f /tmp/upadbyby.sh
