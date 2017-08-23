#!/bin/bash  
# adbyby update Script
# By viagram
# 

i=1
OnTime="30"
DATA_PATH='/usr/share/adbyby/data'
UPDDATE_URL='http://update.adbyby.com/rule3'

function gettext(){
	local url=$1
	if [[ -f $DATA_PATH/adbyby-rule.tmp ]]; then
		rm -f $DATA_PATH/adbyby-rule.tmp
	fi
	command -v wget >/dev/null 2>&1
	if [ $? == 0 ]; then
		wget --no-check-certificate -t3 -T5 -c $url -O $DATA_PATH/adbyby-rule.tmp  >/dev/null 2>&1
	else
		command -v curl >/dev/null 2>&1
		if [ $? == 0 ]; then
		   curl -sk $url -o $DATA_PATH/adbyby-rule.tmp --retry 3 >/dev/null 2>&1
		fi
	fi
	if [[ $? != 0 ]]; then
		echo -e "\033[41;37m	下载 $url 失败 $? \033[0m"
		exit $?
	fi
	return 0
}

function upadtext(){
	local parstr=$1
	if [ "$parstr" == "lazy" -o "$parstr" == "video" ];then
		echo
		echo -e "\033[32m	正在更新: ${parstr}规则,请稍等...\033[0m"
		local url=$UPDDATE_URL/$parstr".jpg"
		gettext $url
	else
		echo -e "\033[41;37m	未知规则:${parstr}\033[0m"
		exit 1
	fi
	OLD_STR=$(head -1 $DATA_PATH/$parstr.txt | awk -F' ' '{print $3,$4}')
	OLD_INT=$(date -d "${OLD_STR}" +%s)
	NEW_STR=$(head -1 $DATA_PATH/adbyby-rule.tmp | awk -F' ' '{print $3,$4}')
	NEW_INT=$(date -d "${NEW_STR}" +%s)
	echo -e "\033[32m	规则地址: $url \033[0m"
	echo -e "\033[32m	本地版本: $OLD_STR \033[0m"
	echo -e "\033[32m	在线版本: $NEW_STR \033[0m"
	if [[ -z $NEW_STR ]]; then
		echo -e "\033[41;37m	更新结果: 获取错误.\033[0m"
		exit 1
	fi
	if [[ $OLD_INT -lt $NEW_INT  ]]; then
		\cp -f $DATA_PATH/adbyby-rule.tmp $DATA_PATH/$parstr.txt
		if [[ $? != 0  ]]; then
			rm -f $DATA_PATH/adbyby-rule.tmp
			echo -e "\033[32m	Error: $? \033[0m"
			exit $?
		fi
		rm -f $DATA_PATH/adbyby-rule.tmp
		echo -e "\033[32m	更新结果: 更新成功.\033[0m"
		((i++))
		if [[ $i -gt 2 ]]; then
			/etc/init.d/adbyby restart 2>/dev/null
		fi
	else
		echo -e "\033[32m	更新结果: 规则已是最新版本.\033[0m"
	fi
}

function Install_UP(){
	MYSLEF="$(dirname $(readlink -f $0))/$(basename $0)"
	if [[ "${MYSLEF}" != "/etc/config/upadbyby" ]] && [[ "${MYSLEF}" != "/bin/upadbyby" ]]; then
		echo -e "\033[32m	正在安装自动更新脚本,请稍等...\033[0m"
		rm -f /bin/upadbyby
		rm -f /etc/config/upadbyby
		\mv ${MYSLEF} /etc/config/upadbyby
		if [[ $? -eq 0 ]]; then
			echo -e "	\033[32m自动更新脚本安装成功.\033[0m"
		else
			echo -e "	\033[41;37m自动更新脚本安装失败.\033[0m"
		fi
		chmod 777 /etc/config/upadbyby
		ln -sf /etc/config/upadbyby /bin/upadbyby
	fi
	CRON_FILE="/etc/crontabs/root"
	if [[ ! $(cat ${CRON_FILE}) =~ "*/480 * * * * /etc/config/upadbyby" ]]; then
		echo -e "	\033[32m正在添加计划任务..."
		echo "*/480 * * * * /etc/config/upadbyby" >> ${CRON_FILE}
		if [[ $? -eq 0 ]]; then
			echo -e "	\033[32m计划任务安装成功.\033[0m"
		else
			echo -e "	\033[41;37m计划任务安装失败.\033[0m"
		fi
	fi
}

Install_UP
upadtext lazy
upadtext video
