#!/bin/bash  
# adbyby update Script
# By viagram
# 

function Install_UP(){
	VERSION=16
	MYSLEF="$(dirname $(readlink -f $0))/$(basename $0)"
	curl -skL "https://raw.githubusercontent.com/viagram/adbyby/master/upadbyby.sh" -o /tmp/upadbyby.tmp
	LOC_VER=$(cat /usr/bin/upadbyby | egrep -io 'VERSION=[0-9]{1,3}' | egrep -io '[0-9]{1,3}')
	NET_VER=$(cat /tmp/upadbyby.tmp | egrep -io 'VERSION=[0-9]{1,3}' | egrep -io '[0-9]{1,3}')
	if [[ ${NET_VER} -gt ${LOC_VER} ]]; then
		rm -f /usr/bin/upadbyby
		cp -rf /tmp/upadbyby.tmp /usr/bin/upadbyby
		chmod +x /usr/bin/upadbyby
		echo -e "\033[32m	自动更新脚本更新成功.\033[0m"
		rm -f /tmp/upadbyby.tmp
	fi
	rm -f /tmp/upadbyby.tmp
	if [[ "${MYSLEF}" != "/usr/bin/upadbyby" ]]; then
		echo -e "\033[32m	正在安装自动更新脚本,请稍等...\033[0m"
		[[ -e /usr/bin/upadbyby ]] && rm -f /usr/bin/upadbyby
		if cp -rf ${MYSLEF} /usr/bin/upadbyby; then
			echo -e "	\033[32m自动更新脚本安装成功.\033[0m"
		else
			echo -e "	\033[41;37m自动更新脚本安装失败.\033[0m"
		fi
		chmod +x /usr/bin/upadbyby
		rm -f $(readlink -f $0)
	fi
	CRON_FILE="/etc/crontabs/root"
	if [[ ! $(cat ${CRON_FILE}) =~ "*/480 * * * * /usr/bin/upadbyby" ]]; then
		echo -e "	\033[32m正在添加计划任务..."
		if echo "*/480 * * * * /usr/bin/upadbyby" >> ${CRON_FILE}; then
			echo -e "	\033[32m计划任务安装成功.\033[0m"
		else
			echo -e "	\033[41;37m计划任务安装失败.\033[0m"
			exit 1
		fi
	fi
}

################################################################################################
echo -e "\033[32m	正在初始化脚本.\033[0m"
if ! command -v curl >/dev/null 2>&1; then
	opkg update
	opkg install curl
fi
Install_UP
if ps | egrep -v grep | egrep -iq '/adbyby'; then
	echo -e "\033[32m	正在更新规则.\033[0m"
	update_url="$(uci get network.lan.ipaddr 2> /dev/null):$(uci get uhttpd.main.listen_https 2> /dev/null | cut -d: -f2 | cut -d' ' -f1)"
	curl -skLc /tmp/.login.txt "https://${update_url}/cgi-bin/luci" -d "luci_username=root&luci_password=vgadmin" -o /dev/null
	curl -skLb /tmp/.login.txt "https://${update_url}/cgi-bin/luci/admin/services/adbyby/refresh?set=rule_data" -o /dev/null
	rm -f /tmp/.login.txt
	rm -f /tmp/adbyby.updated
	bash /usr/share/adbyby/adbybyupdate.sh >/dev/null 2>&1
	#rm -rf /tmp/adbyby
	#/etc/init.d/adbyby restart >/dev/null 2>&1
	echo -e "\033[32m	更新完成.\033[0m"
fi
