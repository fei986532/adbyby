#!/bin/bash  
# adbyby update Script
# By viagram
# 

i=1
DATA_PATH='/usr/share/adbyby/data'

function uprule(){
    local parstr=${1}
    if [[ "${parstr}" == "lazy" || "${parstr}" == "video" ]];then
        echo
        echo -e "\033[32m    正在更新: ${parstr}规则,请稍等...\033[0m"
        if [[ -f $DATA_PATH/adbyby-rule.tmp ]]; then
            rm -f $DATA_PATH/adbyby-rule.tmp
        fi
        if command -v wget >/dev/null 2>&1; then
            url="http://update.adbyby.com/rule3/${parstr}.jpg"
            if ! wget --no-check-certificate -t3 -T5 -c ${url} -O $DATA_PATH/adbyby-rule.tmp >/dev/null 2>&1; then
                rm -f $DATA_PATH/adbyby-rule.tmp
                url="https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/${parstr}.txt"
                if ! wget --no-check-certificate -t3 -T5 -c ${url} -O $DATA_PATH/adbyby-rule.tmp >/dev/null 2>&1; then
                    echo -e "\033[41;37m    下载 ${parstr} 规则失败 $? \033[0m"
                fi
            fi
        elif command -v curl >/dev/null 2>&1; then
            url="http://update.adbyby.com/rule3/${parstr}.jpg"
            if ! curl -skL ${url} -o $DATA_PATH/adbyby-rule.tmp --retry 3 >/dev/null 2>&1; then
                rm -f $DATA_PATH/adbyby-rule.tmp
                url="https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/${parstr}.txt"
                if ! curl -skL ${url} -o $DATA_PATH/adbyby-rule.tmp --retry 3 >/dev/null 2>&1; then
                    echo -e "\033[41;37m    下载 ${parstr} 规则失败 $? \033[0m"
                fi
            fi
        fi
        if ! head -1 $DATA_PATH/adbyby-rule.tmp | egrep -io '[0-9]{2,4}-[0-9]{1,2}-[0-9]{1,2}[[:space:]*][0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}' >/dev/null 2>&1; then
            echo -e "\033[41;37m    下载 $url 失败 $? \033[0m"
            rm -f $DATA_PATH/adbyby-rule.tmp
            exit $?
        fi
    else
        echo -e "\033[41;37m    未知规则: ${parstr}\033[0m"
        exit 1
    fi
    OLD_STR=$(head -1 $DATA_PATH/$parstr.txt | egrep -io '[0-9]{2,4}-[0-9]{1,2}-[0-9]{1,2}[[:space:]*][0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}')
    OLD_INT=$(date -d "${OLD_STR}" +%s)
    NEW_STR=$(head -1 $DATA_PATH/adbyby-rule.tmp | egrep -io '[0-9]{2,4}-[0-9]{1,2}-[0-9]{1,2}[[:space:]*][0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}')
    NEW_INT=$(date -d "${NEW_STR}" +%s)
    echo -e "\033[32m    规则地址: $url \033[0m"
    echo -e "\033[32m    本地版本: $OLD_STR \033[0m"
    echo -e "\033[32m    在线版本: $NEW_STR \033[0m"
    if [[ $OLD_INT -lt $NEW_INT  ]]; then
        if cp -f $DATA_PATH/adbyby-rule.tmp $DATA_PATH/$parstr.txt; then
            echo -e "\033[32m    更新结果: 更新成功.\033[0m"
        else
            echo -e "\033[32m    更新结果: 错误[$?] \033[0m"
            rm -f $DATA_PATH/adbyby-rule.tmp
            exit $?
        fi
        ((i++))
        if [[ ${i} -gt 2 ]]; then
            /etc/init.d/adbyby restart 2>/dev/null
        fi
    else
        echo -e "\033[32m    更新结果: 规则已是最新版本.\033[0m"
    fi
    rm -f $DATA_PATH/adbyby-rule.tmp
}

function Install_UP(){
    MYSLEF="$(dirname $(readlink -f $0))/$(basename $0)"
    if [[ "${MYSLEF}" != "/bin/upadbyby" ]]; then
        echo -e "\033[32m    正在安装自动更新脚本,请稍等...\033[0m"
        if [[ -e /bin/upadbyby ]]; then
            rm -f /bin/upadbyby
        fi
        if cp -f ${MYSLEF} /bin/upadbyby; then
            echo -e "    \033[32m自动更新脚本安装成功.\033[0m"
        else
            echo -e "    \033[41;37m自动更新脚本安装失败.\033[0m"
        fi
        chmod +x /bin/upadbyby
        rm -f $(readlink -f $0)
    fi
    CRON_FILE="/etc/crontabs/root"
    if [[ ! $(cat ${CRON_FILE}) =~ "*/480 * * * * /bin/upadbyby" ]]; then
        echo -e "    \033[32m正在添加计划任务..."
        if echo "*/480 * * * * /bin/upadbyby" >> ${CRON_FILE}; then
            echo -e "    \033[32m计划任务安装成功.\033[0m"
        else
            echo -e "    \033[41;37m计划任务安装失败.\033[0m"
        fi
    fi
}

Install_UP
if [[ -n $(ps | grep -v grep | grep -i '/adbyby') ]]; then
    uprule lazy
    uprule video
fi
