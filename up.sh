#!/bin/sh  
# adbyby update Script
# By viagram
# 

OnTime="30 6"
DATA_PATH='/usr/share/adbyby/data'
UPDDATE_URL='http://update.adbyby.com/rule3'

gettext()
{
    local url=$1
	echo "update the "$url
	if [ -f $DATA_PATH/upadtext.tmp ]; then
        rm -f $DATA_PATH/upadtext.tmp
	fi
	wget -c $url -O $DATA_PATH/upadtext.tmp
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
    echo "old: "$oldver
    echo "new: "$newver
    if [ "$oldver" != "$newver" ];then
        \mv $DATA_PATH/upadtext.tmp $DATA_PATH/$parstr.txt
        echo "update $parstr OK."
    else
        echo "$parstr no update."
    fi
}

InstallLED(){
    ln -sf /etc/config/adbyby_up /bin/adbyby_up
    [ ! -e '/etc/config/adbyby_up' ] && \mv $0 /etc/config/adbyby_up && chmod 777 /etc/config/adbyby_up
    [ -z "`grep \"${OnTime} \* \* \* /etc/config/adbyby_up\" /etc/crontabs/root`" ] && echo "${OnTime} * * * /etc/config/adbyby_up" >>/etc/crontabs/root && crontab -l
}

InstallLED
upadtext lazy
upadtext video
