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
    
    case $MENU_OPT_WEB_TYPE in
        1) 
            Show_Apache_Version
            ;;

    esac

    Write_Log $FUNCNAME $LINENO "end"
}

function Show_Apache_Version()
{
    Write_Log $FUNCNAME $LINENO "start"

    if [ ! -f $VERSION ] || [ `cat $VERSION | grep "httpd" | wc -l` -eq 0 ]
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
    
    case $MENU_OPT_WAS_TYPE in
        1) 
            Show_Tomcat_Version
            ;;

    esac

    Write_Log $FUNCNAME $LINENO "end"
}

function Show_Tomcat_Version()
{
    Write_Log $FUNCNAME $LINENO "start"
    
    if [ ! -f $VERSION ] || [ `cat $VERSION | grep "tomcat" | wc -l` -eq 0 ]
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
    
    case $MENU_OPT_DB_TYPE in
        1) 
            Show_Mariadb_Version
            ;;
        2) 
            Show_Mysql_Version
            ;;
        3) 
            Show_Postgresql_Version
            ;;
    esac

    Write_Log $FUNCNAME $LINENO "end"
}

function Show_Mariadb_Version()
{
    Write_Log $FUNCNAME $LINENO "start"
    
    if [ ! -f $VERSION ] || [ `cat $VERSION | grep -E "maria" | wc -l` -eq 0 ]
    then
        local MSG="MariaDB is not installed."
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu 
    else
        MW_DB_VERSION=`cat $VERSION | grep -E "maria" | cut -f 1 -d' '`

        local MSG="Middleware Type / Version\
        \n'$MW_DB_VERSION'"

        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu
    fi   

    Write_Log $FUNCNAME $LINENO "end"
}

function Show_Mysql_Version()
{
    Write_Log $FUNCNAME $LINENO "start"
    
    if [ ! -f $VERSION ] || [ `cat $VERSION | grep -E "mysql" | wc -l` -eq 0 ]
    then
        local MSG="MySQL is not installed."
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu 
    else
        MW_DB_VERSION=`cat $VERSION | grep -E "mysql" | cut -f 1 -d' '`

        local MSG="Middleware Type / Version\
        \n'$MW_DB_VERSION'"

        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu
    fi   

    Write_Log $FUNCNAME $LINENO "end"
}

function Show_Postgresql_Version()
{
    Write_Log $FUNCNAME $LINENO "start"
    
    if [ ! -f $VERSION ] || [ `cat $VERSION | grep -E "postgresql" | wc -l` -eq 0 ]
    then
        local MSG="PostgreSQL is not installed."
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu 
    else
        MW_DB_VERSION=`cat $VERSION | grep -E "postgresql" | cut -f 1 -d' '`

        local MSG="Middleware Type / Version\
        \n'$MW_DB_VERSION'"

        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu
    fi   

    Write_Log $FUNCNAME $LINENO "end"
}
