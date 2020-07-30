#!/bin/bash  
# adbyby update Script
# By viagram
# 

i=1
DATA_PATH='/usr/share/adbyby/data'

function uprule(){
	local parstr=${1}
	if [[ "${parstr}" == "lazy" || "${parstr}" == "video" ]]; then
		echo
		echo -e "\033[32m	正在更新: ${parstr}规则,请稍等...\033[0m"
		[[ -f ${DATA_PATH}/adbyby-rule.tmp ]] && rm -f ${DATA_PATH}/adbyby-rule.tmp
		#url="https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/${parstr}.txt"
		url="https://adbyby.coding.net/p/xwhyc-rules/d/xwhyc-rules/git/raw/master/${parstr}.txt"
		if ! curl -skL ${url} -o ${DATA_PATH}/adbyby-rule.tmp --retry 3 --speed-time 10 --speed-limit 1 --connect-timeout 10 >/dev/null 2>&1; then
			rm -f ${DATA_PATH}/adbyby-rule.tmp
			if ! curl -skL ${url} -o ${DATA_PATH}/adbyby-rule.tmp --retry 3 --speed-time 10 --speed-limit 1 --connect-timeout 10 >/dev/null 2>&1; then
				echo -e "\033[41;37m	下载 ${parstr} 规则失败 $? \033[0m"
				rm -f ${DATA_PATH}/adbyby-rule.tmp
				exit 1
			fi
		fi
		if ! head -1 ${DATA_PATH}/adbyby-rule.tmp | egrep -io '[0-9]{2,4}-[0-9]{1,2}-[0-9]{1,2}[[:space:]*][0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}' >/dev/null 2>&1; then
			echo -e "\033[41;37m	下载 $url 失败 $? \033[0m"
			rm -f ${DATA_PATH}/adbyby-rule.tmp
			exit 1
		fi
	else
		echo -e "\033[41;37m	未知规则: ${parstr}\033[0m"
		rm -f ${DATA_PATH}/adbyby-rule.tmp
		exit 1
	fi
	OLD_STR=$(head -1 ${DATA_PATH}/$parstr.txt | egrep -io '[0-9]{2,4}-[0-9]{1,2}-[0-9]{1,2}[[:space:]*][0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}')
	OLD_INT=$(date -d "${OLD_STR}" +%s)
	NEW_STR=$(head -1 ${DATA_PATH}/adbyby-rule.tmp | egrep -io '[0-9]{2,4}-[0-9]{1,2}-[0-9]{1,2}[[:space:]*][0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}')
	NEW_INT=$(date -d "${NEW_STR}" +%s)
	echo -e "\033[32m	规则地址: $url \033[0m"
	echo -e "\033[32m	本地版本: $OLD_STR \033[0m"
	echo -e "\033[32m	在线版本: $NEW_STR \033[0m"
	if [[ $OLD_INT -lt $NEW_INT  ]]; then
		if cp -rf ${DATA_PATH}/adbyby-rule.tmp ${DATA_PATH}/$parstr.txt; then
			echo -e "\033[32m	更新结果: 更新成功.\033[0m"
			rm -f ${DATA_PATH}/adbyby-rule.tmp
		else
			echo -e "\033[32m	更新结果: 错误[$?] \033[0m"
			rm -f ${DATA_PATH}/adbyby-rule.tmp
			exit 1
		fi
		((i++))
		[[ ${i} -gt 2 ]] && sleep 1
	else
		echo -e "\033[32m	更新结果: 规则已是最新版本.\033[0m"
		rm -f ${DATA_PATH}/adbyby-rule.tmp
	fi
}

function up_user(){
	[[ -f /tmp/user-rule.tmp ]] && rm -f /tmp/user-rule.tmp
	echo -e "\n\033[32m	顺便更新一下用户自定义规则.\033[0m"
	url="https://dnsdian.com/OpenWRT/user.txt"
	if ! curl -skL ${url} -o /tmp/user-rule.tmp --retry 3 --speed-time 10 --speed-limit 1 --connect-timeout 10 >/dev/null 2>&1; then
		rm -f /tmp/user-rule.tmp
		exit 1
	else
		if [[ -d /usr/adbyby ]]; then
			rm -f /usr/adbyby/user.txt
			\cp -rf /tmp/user-rule.tmp /usr/adbyby/user.txt
		fi
		rm -f /usr/share/adbyby/rules.txt
		\cp -rf /tmp/user-rule.tmp /usr/share/adbyby/rules.txt
		rm -f /tmp/user-rule.tmp
	fi
}

function Install_UP(){
	VERSION=14
	MYSLEF="$(dirname $(readlink -f $0))/$(basename $0)"
	curl -skL "https://raw.githubusercontent.com/viagram/adbyby/master/upadbyby.sh" -o /tmp/upadbyby.tmp --retry 3 --speed-time 10 --speed-limit 1 --connect-timeout 10
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
if [[ -n $(ps | grep -v grep | grep -i '/adbyby') ]]; then
	uprule lazy
	uprule video
	up_user
	rm -rf /tmp/adbyby
	/etc/init.d/adbyby restart >/dev/null 2>&1
fi
