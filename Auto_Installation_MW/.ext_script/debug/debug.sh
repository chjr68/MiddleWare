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

#로그 초기화 및 로깅

#절대경로
g_path=$( cd "$(dirname "$0")" ; pwd )

#rpm 설치 이력을 저장하는 파일경로, 경로는 init 경로에서 생성
RPM_LOG=""

function Init_Log()
{
  #디렉토리를 만들어서 로그 관리
  mkdir -p ${g_path}/trace_log

  touch ${g_path}/trace_log/package_$$.log
  #chmod 755 ${g_path}/.debuglog

  date >> ${g_path}/trace_log/package_$$.log

  #2022.01 패키지 스크립트 - 주요 알람 로그 추가
  touch ${g_path}/trace_log/trace.log # 1개의 파일에 모두 추가

  date >> ${g_path}/trace_log/package.log

  RPM_LOG=${g_path}/trace_log/rpm_install_$$.log

  #최초 기록시간 추가
  echo "[$(date '+%Y/%m/%d %H:%M:%S')]" > ${RPM_LOG}
}

#ex) WRITE_LOG $FUNCNAME $LINENO "INSTALL, TMS Serial = " $TMS_SERIAL
function Write_Log()
{
  #$$ = pid
  local string="[$(date '+%Y/%m/%d %H:%M:%S')][$$][$1:($2)] $3 $4"

  # if [ $DEBUG_STATE -eq "TRUE" ]
  # then
  #   echo $string  #화면에도 출력    
  # fi
  
  echo $string &>> ${g_path}/trace_log/package_$$.log
}
