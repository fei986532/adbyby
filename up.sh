#!/bin/sh  
# adbyby update Script
# By viagram
# 

OnTime="30"
DATA_PATH='/usr/share/adbyby/data'
UPDDATE_URL='http://update.adbyby.com/rule3'

gettext()
{
    local url=$1
    echo "�����ַ: "$url
    if [ -f $DATA_PATH/upadtext.tmp ]; then
        rm -f $DATA_PATH/upadtext.tmp
    fi
    wget -c $url -O $DATA_PATH/upadtext.tmp 2>/dev/null
    if [ $? != 0 ] ; then
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
    echo -e "$parstr ���򱾵ذ汾: "$oldver
    echo -e "$parstr �������߰汾: "$newver
    if [ "$newver" == "" ] ; then
        echo -e "$parstr �����ȡ����."
        exit 1
    fi
    if [ "$oldver" != "$newver" ] ; then
        \mv $DATA_PATH/upadtext.tmp $DATA_PATH/$parstr.txt
        if [ $? != 0 ] ; then
            exit $?
        fi
        echo -e "���� $parstr ����ɹ�."
		/etc/init.d/adbyby restart 2>/dev/null
    else
        echo -e "$parstr ����û���°�."
    fi
}

InstallLED(){
    ln -sf /etc/config/ad_up_byby /bin/ad_up_byby
    [ ! -e '/etc/config/ad_up_byby' ] && \mv $0 /etc/config/ad_up_byby && chmod 777 /etc/config/ad_up_byby
    [ -z "`grep \"\*/${OnTime} \* \* \* \* /etc/config/ad_up_byby\" /etc/crontabs/root`" ] && echo "*/${OnTime} * * * * /etc/config/ad_up_byby" >>/etc/crontabs/root && crontab -l
}

aa=$(InstallLED)
echo "���ڸ��¹��˹���,���Ե�..."
bb=$(upadtext lazy)
cc=$(upadtext video)
echo -e "$aa\n$bb\n\n$cc"
