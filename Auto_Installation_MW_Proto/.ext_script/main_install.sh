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
            #디렉토리 생성 전, 파일 유무/생성 여부 확인 후 만들어야 됨
            Make_Dir

            Install_Web
            ;;
        2)
            Make_Dir

            Install_Was
            ;;
        3)
            Make_Dir

            Install_Db
            ;;   
    esac

    local MSG="Installation finished.\
    \nTerminate menu"

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
function Install_Web()
{
    Write_Log $FUNCNAME $LINENO "start"

    case $MENU_OPT_WEB_TYPE in
        1) 
            #module install
            Install_Apache_Apr
            Install_Apache_Apr_Util
            Install_Apache_Pcre

            #httpd install
            Install_Apache

            #config setting
            Set_Apache_Config
            ;;
    esac

    Write_Log $FUNCNAME $LINENO "end"
}


function Install_Apache_Apr()
{
    Write_Log $FUNCNAME $LINENO "start"
    local jump=0

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
    local jump=25

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
    local jump=25

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
    local jump=25

    MSG="Apache Install ( $MW_WEB_VERSION )"
    Progress=$(($Progress+$jump))
    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    tar zxf ${g_path}/package/1.WEB/${MW_WEB_VERSION}.tar.gz -C ${g_path}/package/1.WEB

    cd ${g_path}/package/1.WEB/${MW_WEB_VERSION}
    ./configure --prefix=$INSTALL_PATH/apache \
    --enable-module=so --enable-rewrite --enable-so \
    --with-apr=$INSTALL_PATH/apr \
    --with-apr-util=$INSTALL_PATH/apr-util \
    --with-pcre=$INSTALL_PATH/pcre/bin/pcre-config \
    --enable-mods-shared=all > /dev/null 2>&1
    make > /dev/null 2>&1
    make install > /dev/null 2>&1

    Write_Log $FUNCNAME $LINENO "end"
}

function Set_Apache_Config()
{
    Write_Log $FUNCNAME $LINENO "start"

    #TODO: 이부분 잘 안되는듯, 서비스 재시작 에러나서 ps로 UID확인 및 4개프로세스 킬하면 재시작 잘됨
    cp $INSTALL_PATH/apache/bin/apachectl /etc/init.d/httpd
    echo -e "\n#
# chkconfig: 2345 90 90
# description: init file for Apache server daemon
# processname: $INSTALL_PATH/apache/bin/apachectl
# config: $INSTALL_PATH/apache/conf/httpd.conf
# pidfile: $INSTALL_PATH/apache/logs/httpd.pid
#" >> /etc/init.d/httpd
    chkconfig --add httpd

    #서비스 등록
    echo -e "[Unit]
Description=apache
After=network.target syslog.target

[Service]
Type=forking
User=root
Group=root

ExecStart=$INSTALL_PATH/apache/bin/apachectl start
ExecStop=$INSTALL_PATH/apache/bin/apachectl stop

Umask=007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/httpd.service

    #서비스 종료
    #TODO: 서비스없을떄 예외처리
    if [ `ps -ef | grep httpd | wc -l` -gt 1 ]
    then
        ps -ef | grep httpd | awk '{print $2}' | xargs kill -9
    fi

    #서비스 시작
    systemctl daemon-reload
    systemctl restart httpd

    Write_Log $FUNCNAME $LINENO "end"
}

function Install_Was()
{
    Write_Log $FUNCNAME $LINENO "start"

    case $MENU_OPT_WAS_TYPE in
        1) 
            Install_Tomcat
            ;;
    esac

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
    if [ `cat /etc/profile | grep "export JAVA_HOME=" | wc -l` -eq 0 ]
    then
        echo -e "\nexport JAVA_HOME=/usr/lib/jvm/$JAVA_VERSION" >> /etc/profile
        source /etc/profile
    fi

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

    case $MENU_OPT_DB_TYPE in
        1) 
            Install_Mariadb
            ;;
        2)
            Install_Mysql
            ;;
        3)
            Install_Postgresql
            ;;

    esac


    Write_Log $FUNCNAME $LINENO "end"
}

function Install_Mariadb()
{
    Write_Log $FUNCNAME $LINENO "start"

    #TODO: Progressbar 하드코딩 말고 로직 변경
    local jump=50

    MSG="MariaDB Install ( $MW_DB_VERSION )"
    Progress=$(($Progress+$jump))
    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    tar zxf ${g_path}/package/3.DB/MariaDB/${MW_DB_VERSION}-linux-systemd-x86_64.tar.gz -C ${INSTALL_PATH}

    mv ${INSTALL_PATH}/${MW_DB_VERSION}-linux-systemd-x86_64 ${INSTALL_PATH}/${MW_DB_VERSION}
    
    #사용자 생성
    if [ `cat /etc/group | grep maria | wc -l` -eq 0 ]
    then
        groupadd maria
        useradd -g maria maria
    fi

    #메인 디렉토리 권한변경
    chown -R maria.maria ${INSTALL_PATH}/${MW_DB_VERSION}

    #디렉토리 생성 및 권한 변경
    mkdir -p /data/mariadb/master
    mkdir -p /data/mariadb/ibdata
    mkdir -p /data/mariadb/iblog
    mkdir -p /data/mariadb/log-bin
    chown -R maria.maria /data/mariadb          
    
    touch /var/log/mariadb.log
    chmod 644 /var/log/mariadb.log
    chown maria:maria /var/log/mariadb.log

    \cp -f $INSTALL_PATH/$MW_DB_VERSION/support-files/mysql.server /etc/init.d/mariadb.service
    sed -i '/^basedir=$/s@=@='$INSTALL_PATH/$MW_DB_VERSION'@' /etc/init.d/mariadb.service
    sed -i '/^datadir=$/s@=@=/data/mariadb/master@' /etc/init.d/mariadb.service

    #TODO: sed명령어 쓸때 변수못집어넣나? ex) $INSTALL_PATH (큰따옴표 쓰면 됨)
    # vi /etc/systemd/system/mariadb.service
    # sed -i '/^basedir=$/s/=/=\'$INSTALL'/' mariadb.service 변수 사용할 땐, ''(작은 따옴표) 한번 더 묶어주면 됨
    
    \cp -f $INSTALL_PATH/$MW_DB_VERSION/support-files/systemd/mariadb.service /etc/systemd/system/mariadb.service
    sed -i '/^User=/s@mysql@maria@' /etc/systemd/system/mariadb.service
    sed -i '/^Group=/s@mysql@maria@' /etc/systemd/system/mariadb.service

    if [ `cat /etc/profile | grep "export PATH=" | wc -l` -eq 0 ]
    then
        echo -e "\nexport PATH=${PATH}:${INSTALL_PATH}/${MW_DB_VERSION}/bin" >> /etc/profile
        source /etc/profile
    fi

    echo -e "# Mariadb
[server]

# mysqld standalone daemon
[mysqld]
port                            = 3306
datadir                         = /data/mariadb/master
socket                          = /tmp/mysql.sock

# Character set (utf8mb4)
character_set-client-handshake  = FALSE
character-set-server            = utf8mb4
collation_server                = utf8mb4_general_ci
init_connect                    = set collation_connection=utf8mb4_general_ci
init_connect                    = set names utf8mb4

# Common
table_open_cache                = 2048
max_allowed_packet              = 32M
binlog_cache_size               = 1M
max_heap_table_size             = 64M
read_buffer_size                = 64M
read_rnd_buffer_size            = 16M
sort_buffer_size                = 8M
join_buffer_size                = 8M
ft_min_word_len                 = 4
lower_case_table_names          = 1
default-storage-engine          = innodb
thread_stack                    = 240K
transaction_isolation           = READ-COMMITTED
tmp_table_size                  = 32M

# Connection
max_connections                 = 200
max_connect_errors              = 50
back_log                        = 100
thread_cache_size               = 100

# Query Cache
query_cache_size                = 32M
query_cache_limit               = 2M

log-bin                         = /data/mariadb/log-bin/mysql-bin" > /etc/my.cnf

    #db 설치
    cd ${INSTALL_PATH}/${MW_DB_VERSION}/scripts 
    ./mysql_install_db --user=maria --basedir="${INSTALL_PATH}/${MW_DB_VERSION}" --datadir=/data/mariadb/master --defaults-file=/etc/my.cnf > /dev/null 2>&1
    
    #심볼릭링크 (mariadb 실행파일에 /usr/local/mysql 경로가 하드코딩되어있어서 추가 필요)
    ln -s ${INSTALL_PATH}/${MW_DB_VERSION} /usr/local/mysql


    #TODO: 서비스 systemctl start mysql로 됨 (서비스명 변경 완료)
    systemctl start mariadb

    Write_Log $FUNCNAME $LINENO "end"
}

function Install_Mysql()
{
    Write_Log $FUNCNAME $LINENO "start"

    #TODO: Progressbar 하드코딩 말고 로직 변경
    local jump=50

    MSG="MySQL Install ( $MW_DB_VERSION )"
    Progress=$(($Progress+$jump))
    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    tar zxf ${g_path}/package/3.DB/MySQL/${MW_DB_VERSION}-el7-x86_64.tar.gz -C ${INSTALL_PATH}

    mv ${INSTALL_PATH}/${MW_DB_VERSION}-el7-x86_64 ${INSTALL_PATH}/${MW_DB_VERSION}
    
    #사용자 생성
    if [ `cat /etc/group | grep mysql | wc -l` -eq 0 ]
    then
        groupadd mysql
        useradd -M -s /sbin/nologin -g mysql mysql
    fi



    #메인 디렉토리 생성 및 권한변경
    mkdir -p ${INSTALL_PATH}/${MW_DB_VERSION}/log
    touch ${INSTALL_PATH}/${MW_DB_VERSION}/log/mysql.log

    chown -R mysql.mysql ${INSTALL_PATH}/${MW_DB_VERSION}

    #디렉토리 생성 및 권한 변경
    mkdir -p /data/mysql
    touch /data/mysql/.passwd

    chown -R mysql:mysql /data/mysql    
    
    # #환경변수 추가
    # if [ `cat ~/.bash_profile | grep "PATH=" | grep $INSTALL_PATH/$MW_DB_VERSION | wc -l` -eq 0 ]
    # then
    #     sed -i '/^PATH=/s@$@'$INSTALL_PATH/$MW_DB_VERSION'@' ~/.bash_profile
    #     source ~/.bash_profile
    # fi
    
    if [ `cat /etc/profile | grep "export PATH=" | grep ${INSTALL_PATH}/${MW_DB_VERSION}/bin | wc -l` -eq 0 ]
    then
        echo -e "\nexport DB_HOME=${INSTALL_PATH}/${MW_DB_VERSION}
export PATH="$PATH:${INSTALL_PATH}/${MW_DB_VERSION}/bin"" >> /etc/profile
        source /etc/profile
    fi

    echo -e "[mysqld]
#datadir=/var/lib/mysql
#socket=/var/lib/mysql/mysql.sock
datadir=/data/mysql
socket=/data/mysql/mysql.sock

[mysqld_safe]
#log-error=/var/log/mariadb/mariadb.log
#pid-file=/var/run/mariadb/mariadb.pid

log-error=$INSTALL_PATH/$MW_DB_VERSION/log/mysql.log
pid-file=$INSTALL_PATH/$MW_DB_VERSION/mysql.pid
" > /etc/my.cnf

    #db 설치
    cd ${INSTALL_PATH}/${MW_DB_VERSION}/bin
    ./mysqld --initialize --user=mysql > /data/mysql/.passwd 2>&1
    ./mysql_ssl_rsa_setup --defaults-file=/etc/my.cnf > /dev/null 2>&1
    #./mysqld_safe --user=mysql 이거 치면 왜 쉘 멈추냐?

    #심볼릭링크 (mariadb 실행파일에 /usr/local/mysql 경로가 하드코딩되어있어서 추가 필요)
    ln -s /data/mysql/mysql.sock /tmp/mysql.sock

    #서비스등록 및 시작
    \cp -f $INSTALL_PATH/$MW_DB_VERSION/support-files/mysql.server /etc/init.d/mysql.service
    sed -i '/^basedir=$/s@=@='$INSTALL_PATH/$MW_DB_VERSION'@' /etc/init.d/mysql.service
    sed -i '/^datadir=$/s@=@=/data/mysql@' /etc/init.d/mysql.service

    chkconfig --add mysql.service
    systemctl start mysql.service

    Write_Log $FUNCNAME $LINENO "end"
}

function Uninstall()
{
    Write_Log $FUNCNAME $LINENO "start"

    #각 모듈설치(configure했던)경로에서 make clean

    Write_Log $FUNCNAME $LINENO "end"
}