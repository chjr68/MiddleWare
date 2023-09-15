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
    #3. 설치된 미들웨어 별 삭제
    #4. 취약점 조치 (추후)
    #5. 미들웨어 연동 지원 (추후)

    dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --menu "Select Menu" 10 50 0 \
    1 "Install Middleware" \
    2 "Show Version" \
    3 "Uninstall" \
    4 "Securitty Setting" \
    5 "Utils" \
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
            Select_Mw_Version

            #설치 경로 다이얼로그, 경로를 선택하고, INSTALL_PATH를 다시 업데이트 한다.
            Input_Middleware_Install_Path

            #기본 시스템 체크, 향후 Install 계열과 Tool 계열 분리
            #CheckAllSystemModule 

            Install_Middleware
            ;;
        2) 
            #Version Info
            PrintVersion
            ;;
        3)
            #UnInstall
            CheckAllSystemModule

            ChkServerRunning
            Uninstall
            ;;
        4)
            #Security Setting
            ;;
        5) 
            #Utils
            ShowMenuTMSUtils
            ;;
        *)
            exit
            ;;
    esac

    #한번 설치를 수행했으면, 초기화를 시켜야 두번 돌지 않음.
    #각 옵션은, 자체적으로 독립적으로 수행이 가능해야 함.
    MENU_OPT_MAIN_INSTALL=${OPT_NONE}

    #TODO: 2023.05.24 여기외에 마땅한 곳이 없다. 과거 rpm 삭제
    #TODO: 모듈 분리 필요 => 모든 rpm 을 한번에 압축해제, 삭제하면서 문제 발생
    #각 사용 모듈별로 rpm, python, syslog등 모듈이 분리되어야 적절하게 수행 가능
    #TODO: 향후 개선
    # delete_tms_dependency_rpms_directory

    #TODO: INSTALL 이 끝나면 종료하는 것도 고민

    Write_Log $FUNCNAME $LINENO "end"
}

function Show_Middleware_Type_Menu
{
    dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --menu "Select Middleware Type" 10 50 0 \
    1 WEB \
    2 WAS \
    3 DB \
    2> $OUTFILE

    item=$(<${OUTFILE})
    case $item in
    1)
        MENU_OPT_MW_TYPE="1"
        ;;
    2)
        MENU_OPT_MW_TYPE="2"
        ;;
    3)
        MENU_OPT_MW_TYPE="3"
        ;;
    *)
        Show_Menu
    esac
}

function Select_Mw_Version()
{
    Write_Log $FUNCNAME $LINENO "start"

    local number=1
    
    case $MENU_OPT_MW_TYPE in
        1) 
            #WEB apache 파일 포맷: httpd-숫자.숫자.숫자
            #정규표현식: '[0-9]{1,3}\-[0-9]{1,3}\-[0-9]{1,3}'
            #mw_pwd: 파일위치 절대경로 확인 필요
            #
            local mw_pwd=`find /working_space/Auto_Installation_MW_Proto/package/1.WEB/ -maxdepth 1 | grep tar.gz | grep -Eo 'httpd-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -k1r`
            ;;
        2) 
            #WAS tomcat 파일 포맷: apache-tomcat-숫자.숫자.숫자
            local mw_pwd=`find /working_space/Auto_Installation_MW_Proto/package/2.WAS/ -maxdepth 1 | grep tar.gz | grep -Eo 'apache-tomcat-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -k1r`

            ;;
        3) 
            #DB db 파일 포맷: mariadb-숫자.숫자.숫자
            local mw_pwd=`find /working_space/Auto_Installation_MW_Proto/package/3.DB/ -maxdepth 1 | grep tar.gz | grep -Eo 'mariadb-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -k1r`
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
        
        dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --menu "Please Select The Middleware Version" 10 50 0 `cat $TMPFILE` 2>$OUTFILE

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

        
    #설치메뉴에 따라 버전명만 변수에 초기화
    case $MENU_OPT_MW_TYPE in
        1) 
            MW_WEB_VERSION=`sed -n -e "${item}"p /tmp/.install.tmp | cut -f 2 -d' '`
            ;;
        2) 
            MW_WAS_VERSION=`sed -n -e "${item}"p /tmp/.install.tmp | cut -f 2 -d' '`
            ;;
        3) 
            MW_DB_VERSION=`sed -n -e "${item}"p /tmp/.install.tmp | cut -f 2 -d' '`
            ;;   
    esac


        # dst="${items[$item]}"

        # #디렉토리 수동 선택
        # [ ${MENU_UTIL_SELECT_RESTORE_DIR} -eq ${OPT_NONE} ] && dst="${items[$item]}" || dst="${AUTO_OPT_TMS_RESTORE_DIR}"
    fi

    #dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --fselect package/  10 50 0 


    Write_Log $FUNCNAME $LINENO "end"
}

function Input_Middleware_Install_Path()
{
    Write_Log $FUNCNAME $LINENO "start"

    #기본 경로는 INSTALL_PATH
    #TMS_INSTALL_PATH, PATCH 설치일경우 해당 값
    #Factory Install 이면 /home1/TMS41 기본값, 다만 선택해서 설정 가능
    #Factory Install 은 처음부터 INSTALL_PATH를 /home1/TMS41 로 제공해준다. (이건 고정 사양)
    
    #2023.03.13 #115619 최초 설치시 인스톨이 진행되지 않는 현상. 자동 설치 옵션의 값이 비어서 발생.
    #자동 설치 옵션이 비었을 경우, 고정 경로 값으로 진행
    if [ -z ${TMS_INSTALL_PATH} ]
    then
        AUTO_OPT_FACTORY_INSTALL_PATH=${INSTALL_PATH} #설치 경로
    fi

    local dialog_message="Please Enter Middleware Install Path \n\
    ex) ${INSTALL_PATH}\n"  

    #TODO: BACKTITLE 중괄호로 안감싸도되나?
    dialog --title "${TITLE}" --backtitle "$BACKTITLE" --inputbox "${dialog_message}" 9 70 "${INSTALL_PATH}" 2> $OUTFILE

    #선택한 경로로 업데이트
    #[ ${MENU_OPT_ENTER_FACTORY_INSTALL_PATH} -eq ${OPT_NONE} ] && INSTALL_PATH=$(<${OUTFILE}) || INSTALL_PATH=${AUTO_OPT_FACTORY_INSTALL_PATH}
    INSTALL_PATH=$(<${OUTFILE})

    Write_Log $FUNCNAME $LINENO "end"
}

# function Show_Warning_Install_Path_Not_Exist()
# {
#     Write_Log $FUNCNAME $LINENO "start"
#
#     if [ -z ${TMS_INSTALL_PATH} ]
#     then
#         WRITE_LOG $FUNCNAME $LINENO "Middleware_Install_Path not exist, source ~/.bash_profile command"
#
#         local MSG="There is no Middleware Installation path.\
#                 \nPlease check environment variable Middleware_Install_Path \
#                 \n(Please run source ~/.bash_profile command)\
#                 \nExit the Installer."
#         tms_dialog ${GOPT_SKIP_DIALOG_DEFAULT_OK} --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
#     
#         #2023.06.08 패치시 TMS_INSTALL_PATH 가 존재하지 않는 경우. 환경 변수 적용
#         ApplyEnvProfile
#
#         exit 1
#     fi
#
#     Write_Log $FUNCNAME $LINENO "end"
#
# }






















