#/!bin/bash
#
# Author by Kim JiHwan (chjr68@naver.com)
#
#########################################################################################
###                                                                                   ###
###         _____  _                    _  ___  ___ _____ ______                      ###
###        /  __ \| |                  | | |  \/  |/  ___|| ___ \                     ###
###        | /  \/| |  ___   _   _   __| | | .  . |\ `--. | |_/ /                     ###
###        | |    | | / _ \ | | | | / _` | | |\/| | `--. \|  __/                      ###
###        | \__/\| || (_) || |_| || (_| | | |  | |/\__/ /| |                         ###
###         \____/|_| \___/  \__,_| \__,_| \_|  |_/\____/ \_|                         ###
###                                                                                   ###
#########################################################################################

echo "sample file"

#최초, 가장 기본 rpm (dialog, net-tools) 설치
function Install_Default_Rpms()
{
    Write_Log $FUNCNAME $LINENO "start"

    #가장 베이스, rpm 설치
    [ -z "`rpm -qa dialog`" ] && rpm -Uvh ${g_path}/rpms/core-rpms/dialog-1.2-4.20130523.el7.x86_64.rpm  >> $LOGFILE 2>&1
    [ -z "`rpm -qa net-tools`" ] && rpm -Uvh ${g_path}/rpms/core-rpms/net-tools-2.0-0.22.20131004git.el7.x86_64.rpm   >> $LOGFILE 2>&1

    Write_Log $FUNCNAME $LINENO "end"
}























