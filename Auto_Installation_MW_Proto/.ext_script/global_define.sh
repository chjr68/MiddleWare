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

LOGFILE='/tmp/.install.log'
TMPFILE='/tmp/.install.tmp'
OUTFILE='/tmp/.install.out'

INSTALL_PATH=/usr/local/src

############################################### 옵션 기본값

OPT_NONE=-9999 #초기값
DIALOG_YESNO_DEFAULT_OK=${OPT_NONE} #0: yes 1: no, ${OPT_NONE}

#설치, 부분설치 옵션
OPT_ENABLE_INSTALL=1 #설치 활성
OPT_NOT_INSTALL=0 #설치 제외

################################################ 설치, 제어 옵션

CHKRPMLIST="net-tools tcpdump dialog ntpdate rdate ntp sshpass gdb wget lsof ipmitool rsyslog rsyslog-openssl ldap radius tacacs make gcc gcc-c++ expat expat-devel java libaio ncurses"

#* Dialog, 기본 OK 로 넘어가는 옵션
GOPT_SKIP_DIALOG_DEFAULT_OK=${OPT_NONE} #0: yes 선택, 1: no 선택, ${OPT_NONE} : 다이얼로그

################################################ DIALOG 관련

#* progressbar, echo로 대체
GOPT_ALTER_PROGRESS_DIALOG_TO_ECHO=${OPT_NONE} #1: 대체, ${OPT_NONE} : progress

#* Dialog, 기본 OK 로 넘어가는 옵션
GOPT_SKIP_DIALOG_DEFAULT_OK=${OPT_NONE} #0: yes 선택, 1: no 선택, ${OPT_NONE} : 다이얼로그

################################################ MENU, 설치관련 (+INPUT BOX)

#* 설치메인 메뉴 선택
MENU_OPT_MAIN_INSTALL=${OPT_NONE} # 1:Install Middleware, 2:Show Version, 3:UnInstall.. ${OPT_NONE} : DIALOG
MENU_OPT_MW_TYPE=${OPT_NONE} # 1:WEB, 2:WAS, 3:DB, ${OPT_NONE} : DIALOG
MENU_OPT_DB_TYPE=${OPT_NONE} # 1:MariaDB, 2:MySQL, 3:PostgreSQL, ${OPT_NONE} : DIALOG

# 미들웨어 버전
MW_WEB_VERSION=${OPT_NONE}
MW_WAS_VERSION=${OPT_NONE}
MW_DB_VERSION=${OPT_NONE}

#모듈 버전 (완전 자동화 할 때 개선필요)
JAVA_VERSION=${OPT_NONE}

#* DISK 파티션 자동 선택
MENU_OPT_SELECT_DISK_PARTITION=${OPT_NONE} #1: 자동 선택, ${OPT_NONE} : DIALOG
AUTO_OPT_DISK_PARTITION="-" #$(fdisk -l 2>&1 |grep Disk|grep sd[a-z] |cut -d ' ' -f2|cut -d ':' -f1 | head -n1) #선택된 디스크 파티션

####* INSTALL_PATH (설치 경로) 선택
#* FactoryInstall Path 선택
MENU_OPT_ENTER_FACTORY_INSTALL_PATH=${OPT_NONE} #1: 자동선택, ${OPT_NONE} : DIALOG
AUTO_OPT_FACTORY_INSTALL_PATH=${INSTALL_PATH} #설치 경로

################################################ DIALOG + Confirm (yes/no)

#* yesno Dialog 기본 옵션, 기본 설정 옵션 일괄 적용
DIALOG_YESNO_DEFAULT_OK=${OPT_NONE} #0: yes 1: no, ${OPT_NONE}

#* 파티션 생성 옵션
DIALOG_YESNO_CREATE_DISK_PARTITION=${OPT_NONE} #1: 디스크에 /home1, /data파티션 생성, 2: / 파티션에 home1,data 디렉토리 생성, ${OPT_NONE} : 다이얼로그 (1번 생성되면 무시)






