#!/bin/bash  
# adbyby update Script
# By viagram
# 

i=1
OnTime="30"
DATA_PATH='/usr/share/adbyby/data'
UPDDATE_URL='http://update.adbyby.com/rule3'

gettext()
{
	local url=$1
	if [[ -f $DATA_PATH/adbyby-rule.tmp ]]; then
		rm -f $DATA_PATH/adbyby-rule.tmp
	fi
	wget --no-check-certificate -c $url -O $DATA_PATH/adbyby-rule.tmp 2>/dev/null
	if [[ $? != 0 ]]; then
		echo -e "\033[41;37m	���� $url ʧ�� $? \033[0m"
		exit $?
	fi
}

upadtext()
{
	local parstr=$1
	if [[ "$parstr" == "lazy" ]];then
		local url=$UPDDATE_URL/$parstr".jpg"
		gettext $url
	fi
	if [[ "$parstr" == "video" ]];then
		local url=$UPDDATE_URL/$parstr".jpg"
		gettext $url
	fi
	
	OLD_STR=$(head -1 $DATA_PATH/$parstr.txt | awk -F' ' '{print $3,$4}')
	OLD_INT=$(date -d "${OLD_STR}" +%s)
	NEW_STR=$(head -1 $DATA_PATH/adbyby-rule.tmp | awk -F' ' '{print $3,$4}')
	NEW_INT=$(date -d "${NEW_STR}" +%s)
	echo -e "\033[32m	��������: $parstr \033[0m"
	echo -e "\033[32m	�����ַ: $url \033[0m"
	echo -e "\033[32m	���ذ汾: $OLD_STR \033[0m"
	echo -e "\033[32m	���߰汾: $NEW_STR \033[0m"
	if [[ -z $NEW_STR ]]; then
		echo -e "\033[41;37m	���½��: ��ȡ����.\033[0m"
		exit 1
	fi
	if [[ $OLD_INT -lt $NEW_INT  ]]; then
		\mv $DATA_PATH/adbyby-rule.tmp $DATA_PATH/$parstr.txt
		if [[ $? != 0  ]]; then
			echo -e "\033[32m	Error: $? \033[0m"
			exit $?
		fi
		echo -e "\033[32m	���½��: ���³ɹ�.\033[0m"
		((i++))
		if [[ $i -gt 2 ]]; then
			/etc/init.d/adbyby restart 2>/dev/null
		fi
	else
		echo -e "\033[32m	���½��: �����������°汾.\033[0m"
	fi
}

Install_UP(){
	MYSLEF="$(dirname $(readlink -f $0))/$(basename $0)"
	if [[ "${MYSLEF}" != "/etc/config/ad_up_byby" ]] && [[ "${MYSLEF}" != "/bin/ad_up_byby" ]]; then
		echo -e "\033[32m	���ڰ�װ�Զ����½ű�,���Ե�...\033[0m"
		rm -f /bin/ad_up_byby
		rm -f /etc/config/ad_up_byby
		\mv $0 /etc/config/ad_up_byby
		chmod 777 /etc/config/ad_up_byby
		ln -sf /etc/config/ad_up_byby /bin/ad_up_byby
	fi
	CRON_FILE="/etc/crontabs/root"
	if [[ ! $(cat ${CRON_FILE}) =~ "*/480 * * * * /etc/config/ad_up_byby" ]]; then
		echo -e "	\033[32m������Ӽƻ�����..."
		echo "*/480 * * * * /etc/config/ad_up_byby" >> ${CRON_FILE}
		if [[ $? -eq 0 ]]; then
			echo -e "	\033[32m�ƻ�����װ�ɹ�\033[0m."
		else
			echo -e "	\033[41;37m�ƻ�����װʧ��\033[0m."
		fi
	fi
}

Install_UP
echo -e "\033[32m	���ڸ��¹��˹���,���Ե�...\033[0m"
upadtext lazy
upadtext video
