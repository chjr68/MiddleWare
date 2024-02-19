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

function print_color_echo()
{
    #Green        0;32     Light Green   1;32

    YELLOW='\033[1;33m'
    LBLUE='\033[1;34m'
    #Light Blue    1;34
    NC='\033[0m' # No Color

    #bold=$(tput bold)
    normal=$(tput sgr0)

    msg=$1 #메시지, 개행 제거
    #msg=$(echo $1 | sed -e 's/\n/,/g')

    #msg="|$1//[$'\t\r\n ']}|"

    #msg=$(echo $1|tr -d '\n')
    
    #화면출력
    echo -e "${YELLOW}[$(date '+%Y/%m/%d %H:%M:%S')] ${LBLUE}${msg}${NC} ${normal}"
    #echo "[$(date '+%Y/%m/%d %H:%M:%S')] ${msg}"

}

function tms_progress()
{
    #WRITE_LOG $FUNCNAME $LINENO "start" 너무 많이 출력
    #WRITE_LOG $FUNCNAME $LINENO "progress $@" #근데 출력이 안될듯

    #opt_alt_echo=$1 #GOPT_ALT_PROGRESS_TO_ECHO
    #TODO: 이건 인자로 받으면 안되고, 전역 값으로 분기 처리 필요

    #dialog 를 echo로 대체 하는 옵션
    if [ ${GOPT_ALTER_PROGRESS_DIALOG_TO_ECHO} -eq 1 ]
    then
        shift 5 #옵션, --backtitle, --title 까지 + --gauge 까지.
        msg="$1"
        
        print_color_echo "$(python -c "print ('${msg}'.replace('\n', ''))")" #한개만 출력

    else
        dialog "$@"
    fi
}

function Middleware_Menu_Input()
{
    Write_Log $FUNCNAME $LINENO "start"

    #처음값은 skip 옵션
    opt_skip=$1

    #두번째 값은 자동 선택 옵션 값
    opt_default_value=$2

    shift 2 #두개를 떼어낸다.

    #여기 계속 중복 이기는 함.. 미세하게 틀려서..
    #입력값이 없을때만 dialog 실행, 아니면 기본값
    if [ ${opt_skip} -eq ${OPT_NONE} ]
    then

        Write_Log $FUNCNAME $LINENO "dialog option = $@"
        #이후는 동일
        dialog "$@"

        result=$?

        #TODO: 이부분의 처리가 필요한듯, cancel 이면 exit.
        case $result in
        1)
            # #116657, 압축 해제된 rpm 디렉토리를 삭제한다.
            Delete_Rpms_Directory
            exit 1
            ;;
        255)
            #exit 1 ;; #여기까지는 안될듯.
            Show_Menu
            ;;
        esac

    else 
        #5개 제거후 메시지 출력
        #echo $opt_default

        shift 5  #--title "${TITLE}" --backtitle "${BACKTITLE}" --yesno / --msgbox
        msg="$1"
        
        print_color_echo "$(python -c "print ('${msg}'.replace('\n', ''))")"
        echo "${opt_default_value}" #다음라인에 옵션 출력 => 출력은 동일.
    fi

    Write_Log $FUNCNAME $LINENO "end"
}

