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

function Show_Menu()
{
    Write_Log $FUNCNAME $LINENO "start"

    #1. 메뉴 진입 시, WEB/WAS/DB 3가지 항목 출력 > 패키지 디렉토리에서 설치가능 버전 출력 > 경로 입력(디폴트 제공)
    #2. installed version / not installed
    #3. 미들웨어 연동 지원 (추후)
    #4. 취약점 조치 (추후)
    #5. 설치된 미들웨어 별 삭제

    dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --menu "Select Menu" 10 50 0 \
    1 "Install Middleware" \
    2 "Show Version" \
    3 "Utils" \
    4 "Security Setting" \
    5 "Uninstall" \
    2> $OUTFILE

    item=$(<${OUTFILE})

    case $item in
        1)
            #Middleware Install
            INSTALL_MODE="INSTALL"

            #미들웨어 타입 선택
            Show_Middleware_Type_Menu
            
            #타입 별 버전 선택 
            #Proto: package 디렉토리에 tar.gz파일 업로드 후 동작확인
            #TODO: 버전값을 불러와서 파일을 받아온 뒤 해당 버전 설치
            Select_Middleware_Version

            #설치 경로 다이얼로그, 경로를 선택하고, INSTALL_PATH를 다시 업데이트 한다.
            Input_Middleware_Install_Path

            Install_Middleware
            ;;
        2) 
            #Version Info
            Show_Middleware_Version
            ;;
        3)
            #Utils
            Not_Supported_function
            ;;
        4)
            #Security Setting
            Not_Supported_function
            ;;
        5) 
            #UnInstall MiddleWare
            Uninstall
            ;;
        *)
            exit
            ;;
    esac

    MENU_OPT_MAIN_INSTALL=${OPT_NONE}

    Write_Log $FUNCNAME $LINENO "end"
}

function Show_Middleware_Type_Menu
{
    Write_Log $FUNCNAME $LINENO "start"

    dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --menu "Select Middleware Type" 10 50 0 \
    1 WEB \
    2 WAS \
    3 DB \
    2> $OUTFILE

    item=$(<${OUTFILE})
    case $item in
    1)
        MENU_OPT_MW_TYPE="1"
        Show_Web_Type_Menu
        ;;
    2)
        MENU_OPT_MW_TYPE="2"
        Show_Was_Type_Menu
        ;;
    3)
        MENU_OPT_MW_TYPE="3"
        Show_Db_Type_Menu
        ;;
    *)
        exit
        ;;
    esac    
    
    Write_Log $FUNCNAME $LINENO "end"
}

function Show_Web_Type_Menu
{
    Write_Log $FUNCNAME $LINENO "start"

    dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --menu "Select Middleware Type" 10 50 0 \
    1 Apache \
    2> $OUTFILE

    item=$(<${OUTFILE})
    case $item in
    1)
        MENU_OPT_WEB_TYPE="1"
        ;;
    *)
        exit
        ;;
    esac    
    
    Write_Log $FUNCNAME $LINENO "end"
}

function Show_Was_Type_Menu
{
    Write_Log $FUNCNAME $LINENO "start"

    dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --menu "Select Middleware Type" 10 50 0 \
    1 Tomcat \
    2> $OUTFILE

    item=$(<${OUTFILE})
    case $item in
    1)
        MENU_OPT_WAS_TYPE="1"
        ;;
    *)
        exit
        ;;
    esac    
    
    Write_Log $FUNCNAME $LINENO "end"
}

function Show_Db_Type_Menu
{
    Write_Log $FUNCNAME $LINENO "start"

    dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --menu "Select DB Type" 10 50 0 \
    1 MariaDB \
    2 MySQL \
    3 PostgreSQL \
    2> $OUTFILE

    item=$(<${OUTFILE})
    case $item in
    1)
        MENU_OPT_DB_TYPE="1"
        ;;
    2)
        MENU_OPT_DB_TYPE="2"
        ;;
    3)
        MENU_OPT_DB_TYPE="3"
        ;;
    *)
        exit
        ;;
    esac

    Write_Log $FUNCNAME $LINENO "end"
}

function Select_Middleware_Version()
{
    Write_Log $FUNCNAME $LINENO "start"
    
    case $MENU_OPT_MW_TYPE in
        1) 
            Select_Web_Version
            ;;
        2) 
            Select_Was_Version 
            ;;
        3) 
            Select_Db_Version
            ;;   
    esac

    Write_Log $FUNCNAME $LINENO "end"
}

function Select_Web_Version()
{
    Write_Log $FUNCNAME $LINENO "start"

    case $MENU_OPT_WEB_TYPE in
        1) 
            Select_Apache_Version
            Select_Apr_Version
            Select_AprUtil_Version
            Select_Pcre_Version
            ;;
    esac

    Write_Log $FUNCNAME $LINENO "end"
}

function Select_Apache_Version()
{
    Write_Log $FUNCNAME $LINENO "start"

    local number=1
    #WEB apache 파일 포맷: httpd-숫자.숫자.숫자
    #정규표현식: '[0-9]{1,3}\-[0-9]{1,3}\-[0-9]{1,3}'
    #mw_pwd: 파일위치 절대경로 확인 필요
    
    local mw_pwd=`find $g_path/package/1.WEB/ -maxdepth 1 | grep tar.gz | grep -Eo 'httpd-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -k1r`

    \cp -f /dev/null $TMPFILE

    if [ `echo $mw_pwd | wc -w` -eq 0 ]
    then
        local MSG="Apache file does not exist."
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu
    else
        for list in $mw_pwd
        do
            echo "$number $list"  >> $TMPFILE
            items[$number]=$list
            ((number++))
        done
        
        dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --menu "Please Select The WEB Version" 10 50 0 `cat $TMPFILE` 2>$OUTFILE

        case $? in
            1)
                exit 1
                ;;
            255)
                exit 1
                ;;
        esac

        #TODO: item에 선택한 번호의 버전을 가져오고 싶음 (완료)
        #TMPFILE에 선택가능한 버전 모두 입력되어 있으니까, 번호랑 매핑해서 버전포맷 가져오면 되지않나? 
        item=$(<${OUTFILE})

        MW_WEB_VERSION=`sed -n -e "${item}"p /tmp/.install.tmp | cut -f 2 -d' '`
    fi

    Write_Log $FUNCNAME $LINENO "end"
}

function Select_Apr_Version()
{
    Write_Log $FUNCNAME $LINENO "start"

    local number=1
    local module_pwd=`find $g_path/package/module/ -maxdepth 1 | grep tar.gz | grep -Eo 'apr-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -k1r`

    \cp -f /dev/null $TMPFILE

    if [ `echo $module_pwd | wc -w` -eq 0 ]
    then
        local MSG="Apr file does not exist."
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu
    else
        for list in $module_pwd
        do
            echo "$number $list"  >> $TMPFILE
            items[$number]=$list
            ((number++))
        done
        
        dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --menu "Please Select The Apr Version" 10 50 0 `cat $TMPFILE` 2>$OUTFILE

        case $? in
            1)
                exit 1
                ;;
            255)
                exit 1
                ;;
        esac

        item=$(<${OUTFILE})

        APR_VERSION=`sed -n -e "${item}"p /tmp/.install.tmp | cut -f 2 -d' '`
    fi

    Write_Log $FUNCNAME $LINENO "end"
}

function Select_AprUtil_Version()
{
    Write_Log $FUNCNAME $LINENO "start"

    local number=1
    local module_pwd=`find $g_path/package/module/ -maxdepth 1 | grep tar.gz | grep -Eo 'apr-util-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -k1r`

    \cp -f /dev/null $TMPFILE

    if [ `echo $module_pwd | wc -w` -eq 0 ]
    then
        local MSG="Apr-Util file does not exist."
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu
    else
        for list in $module_pwd
        do
            echo "$number $list"  >> $TMPFILE
            items[$number]=$list
            ((number++))
        done
        
        dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --menu "Please Select The Apr-Util Version" 10 50 0 `cat $TMPFILE` 2>$OUTFILE

        case $? in
            1)
                exit 1
                ;;
            255)
                exit 1
                ;;
        esac

        item=$(<${OUTFILE})

        APR_UTIL_VERSION=`sed -n -e "${item}"p /tmp/.install.tmp | cut -f 2 -d' '`
    fi

    Write_Log $FUNCNAME $LINENO "end"
}

function Select_Pcre_Version()
{
    Write_Log $FUNCNAME $LINENO "start"

    local number=1
    local module_pwd=`find $g_path/package/module/ -maxdepth 1 | grep tar.gz | grep -Eo 'pcre-[0-9]{1,3}\.[0-9]{1,3}' | sort -k1r`

    \cp -f /dev/null $TMPFILE

    if [ `echo $module_pwd | wc -w` -eq 0 ]
    then
        local MSG="Pcre file does not exist."
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu
    else
        for list in $module_pwd
        do
            echo "$number $list"  >> $TMPFILE
            items[$number]=$list
            ((number++))
        done
        
        dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --menu "Please Select The Pcre Version" 10 50 0 `cat $TMPFILE` 2>$OUTFILE

        case $? in
            1)
                exit 1
                ;;
            255)
                exit 1
                ;;
        esac

        item=$(<${OUTFILE})

        PCRE_VERSION=`sed -n -e "${item}"p /tmp/.install.tmp | cut -f 2 -d' '`
    fi

    Write_Log $FUNCNAME $LINENO "end"
}

function Select_Was_Version()
{
    Write_Log $FUNCNAME $LINENO "start"

    local number=1
    
    case $MENU_OPT_WAS_TYPE in
        1) 
            #WAS tomcat 파일 포맷: apache-tomcat-숫자.숫자.숫자
            local mw_pwd=`find $g_path/package/2.WAS/ -maxdepth 1 | grep tar.gz | grep -Eo 'apache-tomcat-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -k1r`
            ;;
    esac

    \cp -f /dev/null $TMPFILE

    if [ `echo $mw_pwd | wc -w` -gt 0 ]
    then
        for list in $mw_pwd
        do
            echo "$number $list"  >> $TMPFILE
            items[$number]=$list
            ((number++))
        done
        
        dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --menu "Please Select The WAS Version" 10 50 0 `cat $TMPFILE` 2>$OUTFILE

        case $? in
            1)
                exit 1
                ;;
            255)
                exit 1
                ;;
        esac

        item=$(<${OUTFILE})

        MW_WAS_VERSION=`sed -n -e "${item}"p /tmp/.install.tmp | cut -f 2 -d' '`
    fi

    Write_Log $FUNCNAME $LINENO "end"
}

function Select_Db_Version()
{
    Write_Log $FUNCNAME $LINENO "start"

    local number=1
    
    case $MENU_OPT_DB_TYPE in
        1) 
            #mw_pwd: 파일위치 절대경로 확인 필요
            #DB db 파일 포맷: mariadb-숫자.숫자.숫자
            #DB type 별 파일 포맷 확인 및 조치 필요
            local mw_pwd=`find $g_path/package/3.DB/MariaDB -maxdepth 1 | grep tar.gz | grep -Eo 'mariadb-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -k1r`            ;;
        2) 
            #MySQL 파일 포맷:
            local mw_pwd=`find $g_path/package/3.DB/MySQL -maxdepth 1 | grep tar.gz | grep -Eo 'mysql-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -k1r`
            ;;
        3) 
            #PostgreSQL 파일 포맷:
            local mw_pwd=`find $g_path/package/3.DB/PostgreSQL -maxdepth 1 | grep tar.gz | grep -Eo 'postgresql-[0-9]{1,3}\.[0-9]{1,3}' | sort -k1r`
            ;;   
    esac

    \cp -f /dev/null $TMPFILE

    if [ `echo $mw_pwd | wc -w` -gt 0 ]
    then
        for list in $mw_pwd
        do
            echo "$number $list"  >> $TMPFILE
            items[$number]=$list
            ((number++))
        done
        
        dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --menu "Please Select The DB Version" 10 50 0 `cat $TMPFILE` 2>$OUTFILE

        case $? in
            1)
                exit 1
                ;;
            255)
                exit 1
                ;;
        esac

        item=$(<${OUTFILE})

        MW_DB_VERSION=`sed -n -e "${item}"p /tmp/.install.tmp | cut -f 2 -d' '`
    fi

    Write_Log $FUNCNAME $LINENO "end"
}

function Input_Middleware_Install_Path()
{
    Write_Log $FUNCNAME $LINENO "start"

    local dialog_message="Please Enter Middleware Install Path \n\
    ex) ${INSTALL_PATH}\n"  

    #TODO: BACKTITLE 중괄호로 안감싸도되나?
    dialog --title "${TITLE}" --backtitle "$BACKTITLE" --inputbox "${dialog_message}" 9 70 "${INSTALL_PATH}" 2> $OUTFILE

    answer=$?
    case $answer in
        0)
            #선택한 경로로 업데이트
            INSTALL_PATH=$(<${OUTFILE})
            ;;
        1)
            exit
            ;;
    esac

    Write_Log $FUNCNAME $LINENO "end"
}

# Uninstall
function Uninstall()
{
    Write_Log $FUNCNAME $LINENO "start"

    Show_Middleware_Type_Menu

    case $MENU_OPT_MW_TYPE in
        1) 
            Uninstall_Web
            ;;
        2) 
            Uninstall_Was
            ;;
        3) 
            Uninstall_Db
            ;;   
    esac

    source /etc/profile

    local MSG="Uninstallation finished.
    \nTerminate menu"

    dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

    Write_Log $FUNCNAME $LINENO "end"
}

function Uninstall_Web()
{
    Write_Log $FUNCNAME $LINENO "start"

    case $MENU_OPT_WEB_TYPE in
        1) 
            Uninstall_Web_Apache
            ;;

    esac

    Write_Log $FUNCNAME $LINENO "end"
}

function Uninstall_Was()
{
    Write_Log $FUNCNAME $LINENO "start"

    case $MENU_OPT_WAS_TYPE in
        1) 
            Uninstall_Was_Tomcat
            ;;

    esac

    Write_Log $FUNCNAME $LINENO "end"
}

function Uninstall_Db()
{
    Write_Log $FUNCNAME $LINENO "start"

    case $MENU_OPT_DB_TYPE in
        1) 
            Uninstall_Db_Mariadb
            ;;
        2)
            Uninstall_Db_Mysql
            ;;
        3)
            Uninstall_Db_Postgresql
            ;;
    esac

    Write_Log $FUNCNAME $LINENO "end"
}
