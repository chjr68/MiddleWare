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

#절대경로
g_path=$( cd "$(dirname "$0")" ; pwd )


function Show_Middleware_Version()
{
    Write_Log $FUNCNAME $LINENO "start"

    Show_Middleware_Type_Menu

    case $MENU_OPT_MW_TYPE in
        1) 
            Show_Web_Version
            ;;
        2) 
            Show_Was_Version 
            ;;
        3) 
            Show_Db_Version
            ;;   
    esac

    Write_Log $FUNCNAME $LINENO "end"
}

function Show_Web_Version()
{
    Write_Log $FUNCNAME $LINENO "start"
    
    if [ `cat $VERSION | grep "httpd" | wc -l` -eq 0 ]
    then
        local MSG="Apache is not installed."
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu
    else
        MW_WEB_VERSION=`cat $VERSION | grep -E "httpd" | cut -f 1 -d' '`

        local MSG="Middleware Type / Version\
        \n'$MW_WEB_VERSION'"

        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu
    fi   

    Write_Log $FUNCNAME $LINENO "end"
}

function Show_Was_Version()
{
    Write_Log $FUNCNAME $LINENO "start"
    
    if [ `cat $VERSION | grep "tomcat" | wc -l` -eq 0 ]
    then
        local MSG="Tomcat is not installed."
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu 
    else
        MW_WAS_VERSION=`cat $VERSION | grep -E "tomcat" | cut -f 1 -d' '`

        local MSG="Middleware Type / Version\
        \n'$MW_WAS_VERSION'"

        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
        
        Show_Menu
    fi   
    
    Write_Log $FUNCNAME $LINENO "end"
}

function Show_Db_Version()
{
    Write_Log $FUNCNAME $LINENO "start"
    
    if [ `cat $VERSION | grep -E "maria|mysql|postgre" | wc -l` -eq 0 ]
    then
        local MSG="DB is not installed."
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu 
    else
        MW_DB_VERSION=`cat $VERSION | grep -E "maria|mysql|postgre" | cut -f 1 -d' '`

        local MSG="Middleware Type / Version\
        \n'$MW_DB_VERSION'"

        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu
    fi   
    

    Write_Log $FUNCNAME $LINENO "end"
}