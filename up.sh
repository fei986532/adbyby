#!/bin/sh  
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
    if [ -f $DATA_PATH/upadtext.tmp ]; then
        rm -f $DATA_PATH/upadtext.tmp
    fi
    wget -c $url -O $DATA_PATH/upadtext.tmp 2>/dev/null
    if [ $? != 0 ] ; then
        echo "Error: "$?
        exit $?
    fi
}

upadtext()
{
    local parstr=$1
    if [ "$parstr" == "lazy" ];then
        local url=$UPDDATE_URL/$parstr".jpg"
        gettext $url
    fi
    if [ "$parstr" == "video" ];then
        local url=$UPDDATE_URL/$parstr".jpg"
        gettext $url
    fi
    
    oldver=`head -1 $DATA_PATH/$parstr.txt | awk -F' ' '{print $3,$4}'`
    newver=`head -1 $DATA_PATH/upadtext.tmp | awk -F' ' '{print $3,$4}'`
    echo -e "规则名称: "$parstr
    echo -e "规则地址: "$url
    echo -e "本地版本: "$oldver
    echo -e "在线版本: "$newver
    if [ "$newver" == "" ] ; then
        echo -e "更新结果: 获取错误."
        exit 1
    fi
    if [ "$oldver" != "$newver" ] ; then
        \mv $DATA_PATH/upadtext.tmp $DATA_PATH/$parstr.txt
        if [ $? != 0 ] ; then
            echo "Error: "$?
            exit $?
        fi
        echo -e "更新结果: 更新成功."
        ((i++))
        if [ $i -gt 2 ]; then
            /etc/init.d/adbyby restart 2>/dev/null
        fi
    else
        echo -e "更新结果: 规则已是最新版本."
    fi
}

Install_UP(){
    if [ "$0" != "/etc/config/ad_up_byby" ] && [ "$0" != "/bin/ad_up_byby" ]; then
        rm -f /bin/ad_up_byby
        rm -f /etc/config/ad_up_byby
        \mv $0 /etc/config/ad_up_byby
        chmod 777 /etc/config/ad_up_byby
        ln -sf /etc/config/ad_up_byby /bin/ad_up_byby
    fi
    #[ ! -e '/etc/config/ad_up_byby' ] && \mv $0 /etc/config/ad_up_byby && chmod 777 /etc/config/ad_up_byby
    [ -z "`grep \"\*/${OnTime} \* \* \* \* /etc/config/ad_up_byby\" /etc/crontabs/root`" ] && echo "*/${OnTime} * * * * /etc/config/ad_up_byby" >>/etc/crontabs/root && crontab -l
}

echo "正在更新过滤规则,请稍等..."
Install_UP
upadtext lazy
upadtext video
