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

    case $MENU_OPT_MW_TYPE in
        1)
            Make_Dir

            #module install
            Install_Apache_Apr
            Install_Apache_Apr_Util
            Install_Apache_Pcre

            #httpd install
            Install_Apache

            #config setting
            Set_Apache_Config
            ;;
        2)
            Make_Dir

            Install_Tomcat
            ;;
        3)
            Make_Dir

            Install_Db
            ;;   
    esac

    local MSG="Installation finished.\
    \nGo back to the main menu"

    dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

    Write_Log $FUNCNAME $LINENO "end"
}

function ChkAlreadyInstalled()
{
    Write_Log $FUNCNAME $LINENO "start"

    if [ -d ${INSTALL_PATH} ]
    then
        MSG="Already exist. Do you want to go to main menu?"

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

function Make_Dir()
{
    Write_Log $FUNCNAME $LINENO "start"

    #설치 디렉토리 생성
    mkdir -p ${INSTALL_PATH} # 제일 먼저 만들어야 함

    Write_Log $FUNCNAME $LINENO "end"

}

#TODO: 파일 버전 선택해서 설치 (완료)
#      config파일 수정 시, 특정 라인찾아서 아래 넣기
#      추가 파일 생성
#      미들웨어 버전 별 모듈 버전(apr, pcre 등)까지 맞출 수 없으니, 사용자가 다운로드 후 디렉토리에 업로드 하는 형식으로 우선진행
#      apr, pcre는 하드코딩해서 버전 픽스

#TODO: 설치되는 파일리스트, 컴파일 메세지 출력되지 않도록 처리.(완료)
#      Dialog Progress bar만 보이도록

#TODO: Progress bar 모듈마다 작동하도록 (모듈1설치 1~100% -> 모듈2설치 1~100% ...)
#      config 및 환경변수 설정해주는 코드 작성
function Install_Apache_Apr()
{
    Write_Log $FUNCNAME $LINENO "start"

    MSG="Apr Install ( apr-1.7.4 )"
    Progress=$(($Progress+$jump))
    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    tar zxf ${g_path}/package/1.WEB/module/apr-1.7.4.tar.gz -C ${g_path}/package/1.WEB/module

    cd ${g_path}/package/1.WEB/module/apr-1.7.4
    ./configure --prefix=$INSTALL_PATH/apr > /dev/null 2>&1
    make > /dev/null 2>&1
    make install > /dev/null 2>&1

    Write_Log $FUNCNAME $LINENO "end"
}

function Install_Apache_Apr_Util()
{
    Write_Log $FUNCNAME $LINENO "start"

    MSG="Apr-Util Install ( apr-util-1.6.3 )"
    Progress=$(($Progress+$jump))
    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    tar zxf ${g_path}/package/1.WEB/module/apr-util-1.6.3.tar.gz -C ${g_path}/package/1.WEB/module

    cd ${g_path}/package/1.WEB/module/apr-util-1.6.3
    ./configure --prefix=$INSTALL_PATH/apr-util --with-apr=$INSTALL_PATH/apr > /dev/null 2>&1
    make > /dev/null 2>&1
    make install > /dev/null 2>&1

    Write_Log $FUNCNAME $LINENO "end"
}

function Install_Apache_Pcre()
{
    Write_Log $FUNCNAME $LINENO "start"

    MSG="Pcre Install ( pcre-8.45 )"
    Progress=$(($Progress+$jump))
    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    tar zxf ${g_path}/package/1.WEB/module/pcre-8.45.tar.gz -C ${g_path}/package/1.WEB/module

    cd ${g_path}/package/1.WEB/module/pcre-8.45
    ./configure --prefix=$INSTALL_PATH/pcre > /dev/null 2>&1
    make > /dev/null 2>&1
    make install > /dev/null 2>&1

    Write_Log $FUNCNAME $LINENO "end"
}

function Install_Apache()
{
    Write_Log $FUNCNAME $LINENO "start"

    MSG="Apache Install ( $MW_WEB_VERSION )"
    Progress=$(($Progress+$jump))
    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    tar zxf ${g_path}/package/1.WEB/${MW_WEB_VERSION}.tar.gz -C ${g_path}/package/1.WEB

    cd ${g_path}/package/1.WEB/${MW_WEB_VERSION}
    ./configure --prefix=$INSTALL_PATH/apache2.4 \
    --enable-module=so --enable-rewrite --enable-so \
    --with-apr=$INSTALL_PATH/apr \
    --with-apr-util=$INSTALL_PATH/apr-util \
    --with-pcre=$INSTALL_PATH/pcre/pcre-config \
    --enable-mods-shared=all > /dev/null 2>&1
    make > /dev/null 2>&1
    make install > /dev/null 2>&1

    Write_Log $FUNCNAME $LINENO "end"
}

function Set_Apache_Config()
{
    Write_Log $FUNCNAME $LINENO "start"

    #서비스 등록
    #TODO: 이부분 잘 안되는듯, 서비스 재시작 에러나서 ps로 UID확인 및 4개프로세스 킬하면 재시작 잘됨
    cp $INSTALL_PATH/apache2.4/bin/apachectl /etc/init.d/httpd
    echo -e "\n# \n
    # chkconfig: 2345 90 90\n
    # description: init file for Apache server daemon \n
    # processname: $INSTALL_PATH/apache2.4/bin/apachectl \n
    # config: $INSTALL_PATH/apache2.4/conf/httpd.conf \n
    # pidfile: $INSTALL_PATH/apache2.4/logs/httpd.pid \n
    #" >> /etc/init.d/httpd

    chkconfig --add httpd

    #서비스 종료
    #TODO: 서비스없을떄 예외처리
    #ps -ef | grep httpd | awk '{print $2}' | xargs kill -9

    #서비스 시작
    systemctl restart httpd

    Write_Log $FUNCNAME $LINENO "end"
}

function Install_Tomcat()
{
    Write_Log $FUNCNAME $LINENO "start"

    MSG="Tomcat Install ( $MW_WAS_VERSION )"
    Progress=$(($Progress+$jump))
    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    tar zxf ${g_path}/package/2.WAS/${MW_WAS_VERSION}.tar.gz -C ${INSTALL_PATH}

    JAVA_VERSION=`rpm -qa | grep -E 'java-[0-9]{1,2}\-openjdk\-[0-9]{1,2}\.'`

    #TODO: java 버전바뀌는거 체크해야 됨, 이미 환경변수 있을경우 패스하는 로직, 자바경로 자동으로 찾아서 넣어주는 로직
    echo -e "\nexport JAVA_HOME=/usr/lib/jvm/$JAVA_VERSION" >> /etc/profile
    source /etc/profile

    touch /etc/systemd/system/tomcat.service

    #중간 java버전 확인 필요
    echo -e "# Systemd unit file for tomcat \n
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target \n
[Service] 
Type=forking \n
Environment="JAVA_HOME=/usr/lib/jvm/$JAVA_VERSION"
Environment="CATALINA_HOME=$INSTALL_PATH/$MW_WAS_VERSION"
Environment="CATALINA_BASE=$INSTALL_PATH/$MW_WAS_VERSION"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom" \n
ExecStart=$INSTALL_PATH/$MW_WAS_VERSION/bin/startup.sh
ExecStop=$INSTALL_PATH/$MW_WAS_VERSION/bin/shutdown.sh \n
User=root
Group=root
UMask=0007
RestartSec=10
Restart=always \n
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/tomcat.service

    systemctl daemon-reload
    systemctl enable tomcat
    systemctl restart tomcat
    
    Write_Log $FUNCNAME $LINENO "end"
}

function Install_Db()
{
    Write_Log $FUNCNAME $LINENO "start"

    Write_Log $FUNCNAME $LINENO "end"
}