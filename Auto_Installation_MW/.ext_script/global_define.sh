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
VERSION='/tmp/.version.out'

INSTALL_PATH=/usr/local/src

PATH=/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

############################################### 옵션 기본값

OPT_NONE=-9999 #초기값

#설치, 부분설치 옵션
OPT_ENABLE_INSTALL=1 #설치 활성
OPT_NOT_INSTALL=0 #설치 제외

################################################ 설치, 제어 옵션

CHKRPMLIST="dialog net-tools tcpdump sshpass wget lsof make gcc expat java libaio ncurses python3 readline-devel zlib-devel"

################################################ DIALOG 관련

#* progressbar, echo로 대체
#jump=0

################################################ MENU, 설치관련 (+INPUT BOX)

#* 설치메인 메뉴 선택
MENU_OPT_MAIN_INSTALL=${OPT_NONE} # 1:Install Middleware, 2:Show Version, 3:UnInstall.. ${OPT_NONE} : DIALOG
MENU_OPT_MW_TYPE=${OPT_NONE} # 1:WEB, 2:WAS, 3:DB, ${OPT_NONE} : DIALOG
MENU_OPT_WEB_TYPE=${OPT_NONE} # 1:Apache, ${OPT_NONE} : DIALOG
MENU_OPT_WAS_TYPE=${OPT_NONE} # 1:Tomcat, ${OPT_NONE} : DIALOG
MENU_OPT_DB_TYPE=${OPT_NONE} # 1:MariaDB, 2:MySQL, 3:PostgreSQL, ${OPT_NONE} : DIALOG

# OS 타입 #1: CentOS / 2: Ubuntu / 3: RockyOS / 4:Amazon Linux
# TODO: rpm 설치 확인해보고 RHEL / Debian 계열 2개로 나누기 1/2
OS_TYPE=${OPT_NONE}

# 미들웨어 버전 (TYPE 선택 후 버전출력 인자값만 받으면되니까 크게 MW TYPE으로 나눠도 될듯?)
MW_WEB_VERSION=${OPT_NONE}
MW_WAS_VERSION=${OPT_NONE}
MW_DB_VERSION=${OPT_NONE}

#모듈 버전 (완전 자동화 할 때 개선필요)
JAVA_VERSION=${OPT_NONE}

#APR / PCRE 버전
APR_VERSION=${OPT_NONE}
APR_UTIL_VERSION=${OPT_NONE}
PCRE_VERSION=${OPT_NONE}