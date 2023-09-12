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

################################################ 메뉴 인터페이스

function Install_Middleware()
{
    Write_Log $FUNCNAME $LINENO "start"

    #이미 설치가 되어 있는지 체크 - Factory Install 시에만 수행한다.
    ChkAlreadyInstalled

    #2019.12.10 FactoryInstall 시에는 firewall 강제 비활성화
    #DisableForceFirewalld

    Write_Log $FUNCNAME $LINENO "end"
}

function ChkAlreadyInstalled()
{
    Write_Log $FUNCNAME $LINENO "start"

    if [ -d ${INSTALL_PATH} ]
    then
        MSG="Already installed. Do you want to go to main menu?"

        dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --yesno "$MSG" 7 80

        answer=$?
        #[ ${DIALOG_YESNO_DEFAULT_OK} -eq ${OPT_NONE} ] && answer=$G_DIALOG_RESULT || answer=${DIALOG_YESNO_DEFAULT_OK}

        case $answer in
            0)
                Show_Menu
                ;;
            1)
                exit
                ;;
        esac
    fi

    Write_Log $FUNCNAME $LINENO "end"
}

#2021.07.26 메뉴와 함수 분리
#standalone 실행
function InstallAtStandAlone()
{
    Write_Log $FUNCNAME $LINENO "start"

    INSTALL_TYPE=${CONST_TYPE_STANDALONE}

    #/etc/hosts 에서 TMS IP주소를 가져온다. #ip_manager_module.sh
    GatherTMSManagerIPInHostFile

    # TMSInstall 호출전에 TMS Running 상태 확인후 종료수행
    ChkServerRunning

    TMSInstall

    Write_Log $FUNCNAME $LINENO "end"
}

#standalone-mongod 실행
function InstallAtStandAloneMongod()
{
    Write_Log $FUNCNAME $LINENO "start"

    INSTALL_TYPE_MONGOD=1

    Write_Log $FUNCNAME $LINENO "select stand alone (mongod), INSTALL_TYPE_MONGOD = ${INSTALL_TYPE_MONGOD}"

    #Patch 시에, 복구할수 있는 정보가 필요 => Patch할때도 물어보면 좋은데.
    #위 옵션으로, .tms 파일만 교체하고, 나머지는 .tms 파일에서 제어.

    #두번 복사이기는 한데, 혹여 있을 사이드 이펙트 조심.
    INSTALL_TYPE=${CONST_TYPE_STANDALONE}

    #/etc/hosts 에서 TMS IP주소를 가져온다. #ip_manager_module.sh
    GatherTMSManagerIPInHostFile

    # TMSInstall 호출전에 TMS Running 상태 확인후 종료수행
    ChkServerRunning

    TMSInstall

    Write_Log $FUNCNAME $LINENO "end"
}

function PatchInstall()
{
    Write_Log $FUNCNAME $LINENO "start"

    #2019.12.10 Patch 시에는 Firewall 활성화 여부 체크
    DisableFirewalld

    if [ ! -d ${INSTALL_PATH} ]
    then
        local MSG="ERROR!! Installation has been aborted. \
            \n   No packages installed."

        tms_dialog ${GOPT_SKIP_DIALOG_DEFAULT_OK} --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
        exit 1
    fi

    #기존 sqlite dump 생성, 나중에 처리하더라도, 로직의 단순화를 위해서 무조건 수행
    #ExportOldSQLDump 빼보자.

    if [ -d ${INSTALL_PATH}.${DATE} ]
    then
        #2021.07.26 메뉴분리, 과거 패치 디렉토리 삭제
        ShowMenuConfirmDeleteOldPatch
    fi

    if [ -d ${INSTALL_PATH}.${DATE} ]
    then

        #2021.07.26 메뉴분리, 설치후 과거 디렉토리 복구
        ShowMenuConfirmInstallAfterRestore
                
    else

        #이 시점에는 명확해야 한다.

        # Patch 시에는 필요 데몬들 및 파일들을 복사하므로 서비스 중지가 필요 없음
        # ChkServerRunning

        #기존 sqlite dump 생성
        #/home1/TMS40/lib 가 이동하면 sqlcipher 동작 안함
        #mkdir -p ${INSTALL_PATH}.${DATE}/www/dbb

        #www만 미리 옮겨 놓음
        #cp -rf ${INSTALL_PATH}/www/dbb/* ${INSTALL_PATH}.${DATE}/www/dbb/

        #ExportOldSQLDump
        GatherTMSLanguageInfo #언어셋 수집, 결함이 있지만, 현재 상태 유지.

        
        #프로세스 종료를 대기, 5초 sleep

        sleep 5

        # 패키지의 기본 경로 '${INSTALL_PATH}'를 이동 (mv) 하지 않는다. (cp 로 수정)
        # Write_Log $FUNCNAME $LINENO "mv ${INSTALL_PATH} to ${INSTALL_PATH}.${DATE}"
        # mv ${INSTALL_PATH} ${INSTALL_PATH}.${DATE}
        backup_tms_install_modules

        sleep 1
    fi

    # ${INSTALL_PATH} 경로를 ${INSTALL_PATH}.${DATE} 복사(cp) 방식으로 변경하여 ${INSTALL_PATH} 경로 존재시 설치 종료 로직 주석처리
    # if [ -d ${INSTALL_PATH} ]
    # then
    #     local MSG="ERROR!! Installation has been aborted. \
    #         \n  ${INSTALL_PATH} Not found. "
    #          tms_dialog ${GOPT_SKIP_DIALOG_DEFAULT_OK} --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
    #     exit 1
    # fi

    #cfg에서 설채유형, DB유형을 가져온다.
    GatherInstallTypeAtCfg

    #slave 개수를 가져온다. => 향후 개선 필요
    TMS_SLAVENUM="`cat /etc/hosts|grep SLAVE |wc -l`"

    # TMSInstall 호출전에 TMS Running 상태 확인후 종료수행
    # 단, 패치시에는 mongodb는 제외하고 정지한다.
    # 기존 ChkServerRunning 함수에서 mongodb를 제외하고 서비스 상태 확인 & 종료 함수를 생성함, 중복 코드로 향후 개선 필요
    ChkServerRunningExceptMongo

    TMSInstall

    Write_Log $FUNCNAME $LINENO "end"
}

function TMSInstall()
{   
    Write_Log $FUNCNAME $LINENO "start"

    #bash_profile이 사라지는 문제로, 설치할때마다 호출
    #TMS plus bash profile 설정
    ApplyEnvProfile #TODO: 두번호출하는 문제, 확인 필요

    Progress=0
    
    #TMS plus 서버 기동 체크
    # TMS plus 서버 기동 체크를 TMSInstall 호출하기 전에 수행한다.
    # 패치 설치시에는 mongodb 중지 필요 없음
    # ChkServerRunning

    #이미 설치가 되어 있는지 체크
    # 패치시에는 ${INSTALL_PATH} 가 유지되므로 해당 기능은 Factory 설치시에만 수행이 되어야 함 - FactoryInstall 함수 안으로 위치 변경
    # ChkAlreadyInstalled

    #설치 ROOT 디렉토리 생성
    mkdir -p ${INSTALL_PATH} # 제일 먼저 만들어야 함
    mkdir -p ${MONGO_PATH} #2023.04.14 MongoDB 분리 진행. 독립 디렉토리 생성
    
    #라이선스 관련.
    ConfigureSerialLicense

    #Mongo, Node 디렉토리 지정
    #UpdateNodeAndMongoPatchInCC
    #UpdateNodeAndMongoPatch
    #InstallNodeAndMongo

    #node 설치
    InstallNode #ext-package-install.sh

    #mongodb 설치
    InstallMongoDB

    #TMS 설치
    InstallTMSServerDaemon

    #elas 설치
    # TMS 설치후 수행 - APP 디렉토리가 필요하므로
    InstallELAS

    #ld.so, ldlibrary 관련 설정
    ConfigureLDSOLibrary

    ########################################################################
    # Master & Slave 
    ########################################################################

    # 메시지 제거
    # MSG="Master & Slave install..."
    # Progress=$(($Progress+$jump))
    # echo $Progress | tms_progress --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0

    #symbolic 링크 설정
    MakeTMSDaemonCfgSymbolicLink

    #node 웹 app 설치 => TODO: InstallNode로 이동
    InstallNodeWebApp

    #MongoDB 디렉토리 생성
    MakeMongoDBDirectory

    # TMS Plus 제품 운영에 필요한 디렉토리 생성 => 향후 TMS 데몬 격리
    # MakeTMSDaemonDirectory

    # Elas 안으로 호출 위치 변경
    # MakeElasDirectory 

    #ELAS, TMS 의 설정 config replace
    UpdateElasAndTMSConfig

    #python 환경변수 추가 (python2, python3 현재 위치 유지)
    #2023.05.03 python3 환경 변수 추가, 과거 날짜의 .py-env.sh 파일 변경으로 해당 함수 호출 주석처리
    #CopyPythonEnvConfig #python-install
    
    #dns 쿼리를 과다하게 요청하는 현상
    AddTMSPlusHostName

    # /etc/rsyslog.d/tms.conf 파일이 항상 복사 (2021.07.21 CC인증도 추가)
    MakeRsyslogConf

    #2019.12.10 위치 이동.
    #Python Install (pymongo 등 설치)
    InstallPython

    #InitializeModules

    #다시 함수 제거, 하나로. 각 모듈은 함수화 하되, 호출+분기 로직은 하나로 (당연히 이 함수내에 실제 구현 로직은 없어야 한다.)
    if [ "${INSTALL_MODE}" == "INSTALL" ]
    then

        Write_Log $FUNCNAME $LINENO "initialize at install, mode=${INSTALL_MODE}"

        initialize_factory_install
        
    else

        ########################################################################
        # PATCH
        ########################################################################

        Write_Log $FUNCNAME $LINENO "initialize at patch, mode=${INSTALL_MODE}"

        patch_at_tms_patch_mode #patch 관련 (이름짓기가 힘들어 마음에는 안들지만 넘어감)

    fi
    
    # DB 관련.RMS 메뉴 활성화, TMS 모드 설정 업데이트
    UpdateTMSSqliteDB

    #시작스크립트, rc, 무결성 스크립트등 업데이트
    UpdateTMSShellScript

    ########################################################################
    # 서비스 종료
    ########################################################################
    MSG="Stop service..."
    Progress=100
    echo $Progress | tms_progress --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0

    #2019.04.22 최초 설치 후 종료
    STOP

    # 2022.08.05 mongodb 무정지 지원
    # Factory Install 시에만 mongodb를 내리고, 패치 시에는 mongodb 정지를 하지 않는다.
    # 향후 해당 로직 개선 
    if [ "${INSTALL_MODE}" == "INSTALL" ]
    then
        # Factory Install 시에만, mongodb도 종료
        # Factory Install 후에 mongodb 중지 필요성 검토
        cd ${MONGO_HOME}/bin/
        StopMongodb
        cd - &> /dev/null
    fi


    #refs #014886 snmp 의 종속성 문제로, 모듈 설치 위치를 main-install로 이동
    InstallSNMP #ext-package-install.sh

    #기존 파일이 존재할때만 상태 출력
    #인증버전에 있었는데.. 다른 곳에서 수행되어 제외.
    #[ -d ${INSTALL_PATH}.${DATE} ] && Status

    EncryptVersionFile

    #RMS => 끝나고 수행해야 함. #73747 Master-Slave 구조에서 Slave 서버 패치 실패 발생 - SLAVE 일 경우 RMS 설치해서는 안됨
    #TODO: 여기는 건드리지 않음.
    if [ "${INSTALL_TYPE}" != ${CONST_TYPE_SLAVE} ] 
    then
        InstallRMS        
    fi

    #어차피 CC만, 그냥 수행.
    #가장 마지막, 난독화 처리 추가 , CC인증 버전일때만
    RunPythonObfuscate #python-install.sh

    #2022.02.22 RMS쪽 python 난독화
    #run_rms_python_obfuscate #rms-install.sh
    #TODO: CC인증이 아닐때, git이 merge가 안되서 오류가 날수 있다. 넘어간다.
    #RunRMSPythonObfuscate

    #기존 파일이 존재할때만 상태 출력
    [ -d ${INSTALL_PATH}.${DATE} ] && Status
    
    #72283 config-gather 추가 (alias + 파일 복사) => DIALOG 제거하고, 기본으로 추가
    CopyConfigGather

    #111000 rsyslog 8.2208.0 버전 패치 툴 추가
    CopyRsyslogPatch

    #rsyslog 설치 자동 추가 
    InstallTMSRsyslog #rsyslog-install.sh

    #마지막 버전 출력, 종료가 되었는지 확인이 애매할때가 많아서 추가
    #DoMenuEventPrintTMSModuleVersion

    #무결성 검사, 가장 마지막에 수행
    #TODO: CC 버전은 버전파일을 암호화 한 후에 무결성 업데이트를 수행해야 한다. 위치 이동
    UpdateIntegrityDB

    #기타 custom 설정, 제품에서 공통으로 사용할수 없지만, 제품내에 포함되는 경우에 사용
    install_custom_modules

    Write_Log $FUNCNAME $LINENO "end"
    
}

function Uninstall()
{

    Write_Log $FUNCNAME $LINENO "start"

    NEW_VERSION=$(cat .version|grep Build|cut -d ":" -f2|sed -e "s/ //g")
    CURRENT_VERSION=$(cat ${INSTALL_PATH}/.version|grep Build|cut -d ":" -f2|sed -e "s/ //g")

    if [ "$CURRENT_VERSION" != "" ]
    then
        STOP
        # Uninstall 시에는 mongodb도 종료
        cd ${MONGO_HOME}/bin/
        StopMongodb
        cd - &> /dev/null

        local MSG="Are you sure you want to delete ${PRODUCT_NAME}($CURRENT_VERSION)?"       
        tms_dialog ${DIALOG_YESNO_DEFAULT_OK} --title "${TITLE}" --backtitle "${BACKTITLE}" --yesno "$MSG" 7 80

        #answer=$?
        [ ${DIALOG_YESNO_DEFAULT_OK} -eq ${OPT_NONE} ] && answer=$G_DIALOG_RESULT || answer=${DIALOG_YESNO_DEFAULT_OK}

        case $answer in
            0)
                # SqliteDB에 immutable 속성이 있을 경우 삭제가 불가능 하기 때문에 chattr -i 명령어 수행 필요
                RemoveSqliteDBImmutableAttr
                rm -rf ${INSTALL_PATH}
                rm -rf ${MONGO_PATH}
                RemoveRMS #RMS 삭제 추가
                ;;
            1)
                exit 1;
                ;;
            255)
                exit 1;
                ;;
        esac

        local MSG="Do you want to initialize the /data area?"

        tms_dialog ${DIALOG_YESNO_DEFAULT_OK} --title "${TITLE}" --backtitle "${BACKTITLE}" --yesno "$MSG" 7 80

        answer=$?
        [ ${DIALOG_YESNO_DEFAULT_OK} -eq ${OPT_NONE} ] && answer=$G_DIALOG_RESULT || answer=${DIALOG_YESNO_DEFAULT_OK}

        case $answer in
            0)              
                
                #mongodb log 경로 삭제
                DeleteMongoDBLogDirectory

                #TMS 부가 경로 삭제
                DeleteTMSEtcDirectory

                #rms 관련
                if [ -d /data/sniper_rms ]; then
				   rm -rf /data/sniper_rms
                fi
                
                #web, 보고서
                RemoveNodeWebEtcDirectory
                
                UninstallProfileFile # TMS Plus bash_profile 삭제

                #rsyslog 관련, 데이터를 삭제해야 같이 삭제하도록 수정.
                #dialog 문구와 안맞기는 하지만, 넘어감
                DeleteRsyslogFiles  # rsyslog 설정 파일들을 삭제한다. 

                ;;
            1)
                Install
                ;;
            255)
                Install
                ;;
        esac

    else
        local MSG="The ${PRODUCT_NAME} is not installed."

        tms_dialog ${GOPT_SKIP_DIALOG_DEFAULT_OK}  --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
        exit 1 #메시지 출력후 종료, 재시도는 콘솔등으로 처리 개선
    fi

    # /etc/hosts 업데이트 => UnInstall
    UpdateTMSIPToEtcHosts

    Install

    Write_Log $FUNCNAME $LINENO "end"
}


#######################################################################################

#기타 custom 설정, 제품에서 공통으로 사용할수 없지만, 제품내에 포함되는 경우에 사용
function install_custom_modules()
{
    #LG U+, custom 기능, csv 저장 관련 설정 추가.
    InstallCustomLGUCsvConfig #tms-daemon-install.sh

    #향후 crontable을 대체, tms에서 자체 관리를 위한 scheudler 목적으로 운영할 Schedule json 파일 추가
    #2022.08.02 로직 변경, 사용안함. 다음 버전에서 소스 삭제.
    # InstallTMSSchedulerConfig #tms-daemon-install.sh

    #TMS NCSC 설치 모드 (설치시 cfg의 일부 설정값이 같이 활성화 되어야 한다.)
    #
    if [ ${GOPT_INSTALL_NCSC_TMS_LIGHT_VERSION} -eq ${OPT_ENABLE_INSTALL} ]
    then
        Write_Log $FUNCNAME $LINENO "install ncsc tms light version"

        cd $g_path/tools/tms_config_customize/

        sh tms-config-customize.sh

        cd - > /dev/null
    fi
}

#factory install 시점의 설치 + 초기화

function initialize_factory_install()
{
    Write_Log $FUNCNAME $LINENO "start"

    ########################################################################
    # 몽고 init Config DB
    ########################################################################
    MSG="Mongo db running & init..."
    Progress=$(($Progress+$jump))        
    echo $Progress | tms_progress --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0       

    if [ "${INSTALL_TYPE}" != ${CONST_TYPE_SLAVE} ]  #MASTER
    then

        #mongodb shard, 초기화
        InitializeMongoAtMaster

        #Sqlite 초기화
        initialize_tms_sqlite_at_master

    else #SLAVE

        InitializeMongoAtSlave
    fi

    Write_Log $FUNCNAME $LINENO "end"
}

#master일때, sqlite 초기화, 메인 체.
function initialize_tms_sqlite_at_master() 
{

    Write_Log $FUNCNAME $LINENO "start"

    ########################################################################
    # DB 생성
    ########################################################################
    MSG="TMS local DB create.."
    Progress=$(($Progress+$jump))
    echo $Progress | tms_progress --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    
    #symbolic 링크 작업은 하되 메시지는 제거
    #이전 버전의 형상과, 실행 순서에 따라 반영이 안될수 있다.
    ldconfig &> /dev/null

    #복구는, 향후 복구, 백업은 계속적으로 백업
    InsertTMSplusSQLDBB

    CheckTMSPlusSqlDBInsertValid
    result=$?

    Write_Log $FUNCNAME $LINENO "sql insert result= ${result} "

    #재시도를 하지 않고, 바로 종료, 재설치 유도 소스코드 아예 지움

    if [ ${result} -eq 1 ]
    then
         local MSG="ERROR!! Installation has been aborted. \
            \n  Fail Insert TMS plus Polic SQL, Please retry Install."

        tms_dialog ${GOPT_SKIP_DIALOG_DEFAULT_OK} --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
        exit 1
    fi

    Write_Log $FUNCNAME $LINENO "end"

}

function patch_at_tms_patch_mode() 
{
    Write_Log $FUNCNAME $LINENO "start"

    echo 10 | tms_progress --backtitle "${BG_TITLE}" --title "${DLG_TITLE}" --gauge "Patch the elas config." 10 70 0

    #Elas 의 cfg Config 의 업데이트
    # Elas 안으로 호출 위치 변경
    # PatchElasCfgConfig

    echo 40 | tms_progress --backtitle "${BG_TITLE}" --title "${DLG_TITLE}" --gauge "Patch the server daemon config." 10 70 0

    #TMS 의 config, json 파일 업데이트
    PatchTMSCfgConfig

    echo 70 | tms_progress --backtitle "${BG_TITLE}" --title "${DLG_TITLE}" --gauge "Patch the node web config." 10 70 0

    #Node 웹서버 config 업데이트 (master만 수행)
    PatchNodeWebConfig

    echo 100 | tms_progress --backtitle "${BG_TITLE}" --title "${DLG_TITLE}" --gauge "The server daemon config patch is complete." 10 70 0
    sleep 1

    #TMS sqlite DB 업데이트
    echo 50 | tms_progress --backtitle "${BG_TITLE}" --title "${DLG_TITLE}" --gauge "Patch TMS plus sqlite DB..." 10 70 0  
    PatchTMSSqliteDB
    sleep 1

    echo 100 | tms_progress --backtitle "${BG_TITLE}" --title "${DLG_TITLE}" --gauge "The sqlite DB patch has been completed." 10 70 0
    sleep 1

    #mongo의 capped DB의 내용 업데이트
    PatchMongoCappedDB

    Write_Log $FUNCNAME $LINENO "end"
}

# ${INSTALL_PATH} 디렉토리를 백업한다.
# copy ${INSTALL_PATH} to ${INSTALL_PATH}.${DATE}
function backup_tms_install_modules()
{
    Write_Log $FUNCNAME $LINENO "start"    

    # 이 함수 호출은, ${INSTALL_PATH}.${DATE} 디렉토리가 미존재하는경우 수행된다.
    # ${INSTALL_PATH}.${DATE} 디렉토리를 생성한다. (디렉토리가 존재할 경우 에러가 발생하지 않기 위하여 -p 옵션 추가)
    # ${INSTALL_PATH}.${DATE} 디렉토리가 존재할 경우 삭제후 재생성 여부 검토
    mkdir -p ${INSTALL_PATH}.${DATE} 

    # 발생가능성은 없지만 디렉토리 생성 실패시 다시 초기 메뉴로 돌아간다.
    # MSG = "TMS 백업 경로가 없습니다. 설치를 다시 시도하십시오."
    if [ ! -d ${INSTALL_PATH}.${DATE} ]
    then
        local MSG="ERROR!! Installation has been aborted. \
        \nTMS Backup path not exist, retry install!"
        Write_Log $FUNCNAME $LINENO "backup path not exist, backup path = ${INSTALL_PATH}.${DATE}, retry install"
        tms_dialog ${GOPT_SKIP_DIALOG_DEFAULT_OK} --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        #경로가 없으면, 설치 종료
        exit 255
    fi

    # ${INSTALL_PATH} 디렉토리 내의 파일들을 ${INSTALL_PATH}.${DATE}로 복사한다.
    # 복사시 권한을 유지한다. (-p : 원본 파일의 소유자, 그룹, 권한등의 정보까지 복사 옵션 )
    Write_Log $FUNCNAME $LINENO "cp ${INSTALL_PATH} to ${INSTALL_PATH}.${DATE}"
    
    # ${INSTALL_PATH} 경로의 필요한 디렉토리만 백업한다.
    
    # TMS APP 모듈 백업 수행
    BackUpAPPModule

    # Mongodb 모듈 백업 수행
    BackUpMongoDBModule

    # Node, Web 모듈 백업 수행
    BackUpNodeWebModule

    # RMS 모듈 백업 수행
    BackUpRMSModule

    # Elas 모듈 백업 수행
    BackUpElasModule

    ########################################################################
    # LOG 디렉토리 백업은 제외 - mongodb의 LOG 는 mongodb 상태 로그로 백업을 하지 않고, 로그를 계속 유지. (원본 경로)
    ########################################################################
    # \cp -rfp  ${INSTALL_PATH}/LOG ${INSTALL_PATH}.${DATE}
    Write_Log $FUNCNAME $LINENO "end"    
}
