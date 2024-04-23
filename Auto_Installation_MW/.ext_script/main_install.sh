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

    #디렉토리 생성 전, 파일 유무/생성 여부 확인 후 만들어야 됨
    Make_Dir

    case $MENU_OPT_MW_TYPE in
        1)
            Install_Web
            ;;
        2)
            Install_Was
            ;;
        3)
            Install_Db
            ;;   
    esac

    source /etc/profile

    Write_Log $FUNCNAME $LINENO "end"
}

function Check_Dir_Exist()
{
    Write_Log $FUNCNAME $LINENO "start"

    if [ -d ${INSTALL_PATH} ]
    then
        MSG="Already exist. Do you want to go to main menu?"

        dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --yesno "$MSG" 7 80

        answer=$?

        case $answer in
            0)
                Show_Menu
                ;;
            1)
                exit
                ;;
        esac
    fi

    source /etc/profile

    Write_Log $FUNCNAME $LINENO "end"
}

function Make_Dir()
{
    Write_Log $FUNCNAME $LINENO "start"

    #if 구문으로 디렉토리 존재유무 확인 후 생성

    #설치 디렉토리 생성
    mkdir -p ${INSTALL_PATH} # 제일 먼저 만들어야 함
    echo "PATH=${INSTALL_PATH}" >> $TMPFILE

    Write_Log $FUNCNAME $LINENO "end"
}

#TODO: 파일 버전 선택해서 설치 (완료)
#      config파일 수정 시, 특정 라인찾아서 아래 넣기
#      추가 파일 생성
#      미들웨어 버전 별 모듈 버전(apr, pcre 등)까지 맞출 수 없으니, 사용자가 다운로드 후 디렉토리에 업로드 하는 형식으로 우선진행
#      apr, pcre는 하드코딩해서 버전 픽스 -> 이 부분도 설치 자유도를 위해 업로드 파일 선택하게끔 개선(완료)

#TODO: 설치되는 파일리스트, 컴파일 메세지 출력되지 않도록 처리.(완료)
#      Dialog Progress bar만 보이도록

#TODO: Progress bar 모듈마다 작동하도록 (모듈1설치 1~100% -> 모듈2설치 1~100% ...)
#      config 및 환경변수 설정해주는 코드 작성

function Set_Configure()
{
    Write_Log $FUNCNAME $LINENO "start"

    local STEP="Configure"
    Progress=$(($Progress+$jump))

    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG\n $STEP" 10 70 0
    ./configure $1 > /dev/null 2>&1

    Write_Log $FUNCNAME $LINENO "end"
}

function Set_Make()
{
    Write_Log $FUNCNAME $LINENO "start"

    local STEP="Make"
    Progress=$(($Progress+$jump))

    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG\n $STEP" 10 70 0
    make >> $1 2>&1

    Write_Log $FUNCNAME $LINENO "end"
}

function Set_Make_Install()
{
    Write_Log $FUNCNAME $LINENO "start"

    local STEP="Make Install"
    Progress=$(($Progress+$jump))

    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG\n $STEP" 10 70 0
    make install >> $1 2>&1

    Write_Log $FUNCNAME $LINENO "end"
}

function Install_Web()
{
    Write_Log $FUNCNAME $LINENO "start"

    case $MENU_OPT_WEB_TYPE in
        1) 
            count=16
            jump=$((100/$count))

            #apache는 모듈별 함수로 나뉘어 있어서 Progressbar 개선완료.
            #타 MW는 검토필요
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

    MSG="Apr Install ( $APR_VERSION )"
    Progress=$(($Progress+$jump))
    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    tar zxf ${g_path}/package/module/${APR_VERSION}.tar.gz -C ${g_path}/package/module

    cd ${g_path}/package/module/${APR_VERSION}
    Set_Configure --prefix=$INSTALL_PATH/apr
    Set_Make ${g_path}/trace_log/apr.log 
    Set_Make_Install ${g_path}/trace_log/apr.log

    #TODO: 모듈버전을 넣어야 됨.
    echo $APR_VERSION >> $VERSION

    Write_Log $FUNCNAME $LINENO "end"
}

function Install_Apache_Apr_Util()
{
    Write_Log $FUNCNAME $LINENO "start"

    MSG="Apr-Util Install ( $APR_UTIL_VERSION )"
    Progress=$(($Progress+$jump))
    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    tar zxf ${g_path}/package/module/${APR_UTIL_VERSION}.tar.gz -C ${g_path}/package/module

    cd ${g_path}/package/module/${APR_UTIL_VERSION}
    Set_Configure "--prefix=$INSTALL_PATH/apr-util --with-apr=$INSTALL_PATH/apr"
    Set_Make ${g_path}/trace_log/apr-util.log
    Set_Make_Install ${g_path}/trace_log/apr-util.log

    echo $APR_UTIL_VERSION >> $VERSION

    Write_Log $FUNCNAME $LINENO "end"
}

function Install_Apache_Pcre()
{
    Write_Log $FUNCNAME $LINENO "start"

    MSG="Pcre Install ( $PCRE_VERSION )"
    Progress=$(($Progress+$jump))
    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    tar zxf ${g_path}/package/module/${PCRE_VERSION}.tar.gz -C ${g_path}/package/module

    cd ${g_path}/package/module/${PCRE_VERSION}
    Set_Configure "--prefix=$INSTALL_PATH/pcre"
    Set_Make ${g_path}/trace_log/pcre.log
    Set_Make_Install ${g_path}/trace_log/pcre.log

    echo $PCRE_VERSION >> $VERSION

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

    # 버전에 따라 configure 하는 명령어가 다름
    major=$(echo ${MW_WEB_VERSION} | cut -d'-' -f2  | cut -d'.' -f1)
    minor=$(echo ${MW_WEB_VERSION} | cut -d'-' -f2  | cut -d'.' -f2)
    patch=$(echo ${MW_WEB_VERSION} | cut -d'-' -f2  | cut -d'.' -f3)

    if [ $major == 2 ] && [ $minor -ge 4 ] 
    then
        Set_Configure "--prefix=$INSTALL_PATH/${MW_WEB_VERSION} \
        --enable-module=so --enable-rewrite --enable-so \
        --with-apr=$INSTALL_PATH/apr \
        --with-apr-util=$INSTALL_PATH/apr-util \
        --with-pcre=$INSTALL_PATH/pcre/bin/pcre-config \
        --enable-mods-shared=all"
    else
        Set_Configure "--prefix=$INSTALL_PATH/${MW_WEB_VERSION} \
        --enable-module=so --enable-rewrite --enable-so \
        --enable-mods-shared=all"
    fi

    #Rocky expat 에러처리
    if [ $OS_TYPE == 3 ]
    then
        if [ `cat ${g_path}/package/1.WEB/${MW_WEB_VERSION}/build/config_vars.mk | grep "AP_LIBS" | grep expat | wc -l` -eq 0 ]
        then
            sed -i '/^AP_LIBS = /s@$@ -lexpat@' ${g_path}/package/1.WEB/${MW_WEB_VERSION}/build/config_vars.mk
        fi
    fi

    Set_Make ${g_path}/trace_log/apache.log
    Set_Make_Install ${g_path}/trace_log/apache.log

    Write_Log $FUNCNAME $LINENO "end"
}

function Set_Apache_Config()
{
    Write_Log $FUNCNAME $LINENO "start"

    cp $INSTALL_PATH/${MW_WEB_VERSION}/bin/apachectl /etc/init.d/httpd
    echo -e "\n#
# chkconfig: 2345 90 90
# description: init file for Apache server daemon
# processname: $INSTALL_PATH/${MW_WEB_VERSION}/bin/apachectl
# config: $INSTALL_PATH/${MW_WEB_VERSION}/conf/httpd.conf
# pidfile: $INSTALL_PATH/${MW_WEB_VERSION}/logs/httpd.pid
#" >> /etc/init.d/httpd
    
    if [ $OS_TYPE == 1 ]
    then
        chkconfig --add httpd
    elif [ $OS_TYPE == 2 ]
    then
        sed -i '/^#ServerName www.example.com:80$/s@#@@' $INSTALL_PATH/${MW_WEB_VERSION}/conf/httpd.conf
        sed -i '/^ServerName www.example.com:80$/s@www.example.com:80@localhost@' $INSTALL_PATH/${MW_WEB_VERSION}/conf/httpd.conf
        update-rc.d httpd defaults
    fi

    #서비스 등록
    echo -e "[Unit]
Description=apache
After=network.target syslog.target

[Service]
Type=forking
User=root
Group=root

ExecStart=$INSTALL_PATH/${MW_WEB_VERSION}/bin/apachectl start
ExecStop=$INSTALL_PATH/${MW_WEB_VERSION}/bin/apachectl stop

Umask=007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/httpd.service

    #서비스 종료
    #TODO: 서비스없을떄 예외처리
    #grep 필터링 했을 때 grep 프로세스를 제거하고 출력하는 구문 grep -v grep
    if [ `ps -ef | grep httpd | grep -v grep | wc -l` -eq 0 ]
    then
        ps -ef | grep httpd | awk '{print $2}' | xargs kill -9 > /dev/null 2>&1
    fi

    # httpd v2.0.x 추가 수행
    if [ $major == 2 ] && [ $minor == 0 ] 
    then
        if [ $OS_TYPE == 1 ] || [ $OS_TYPE == 3 ]
        then
            sed -i '/^Group #-1/s@#-1@nobody@' $INSTALL_PATH/$MW_WEB_VERSION/conf/httpd.conf
        elif [ $OS_TYPE == 2 ]
        then
            sed -i '/^Group #-1/s@#-1@nogroup@' $INSTALL_PATH/$MW_WEB_VERSION/conf/httpd.conf
        fi
    fi

    #경로이동
    cd ${INSTALL_PATH}

    #서비스 시작
    systemctl daemon-reload
    systemctl enable httpd >> ${g_path}/trace_log/apache.log 2>&1
    systemctl restart httpd

    if [ `systemctl is-active httpd` == "active" ]
    then
        echo $MW_WEB_VERSION $INSTALL_PATH >> $VERSION

        local MSG="Installation Finished\
        \nTerminate menu"
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Write_Log $FUNCNAME $LINENO "end"
    else
        local MSG="Installation is Failed\
        \nTerminate menu"
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
    fi
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
    local jump=50
    Progress=$(($Progress+$jump))
    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    tar zxf ${g_path}/package/2.WAS/${MW_WAS_VERSION}.tar.gz -C ${INSTALL_PATH}

    if [ $OS_TYPE == 1 ] || [ $OS_TYPE == 3 ]
    then
        JAVA_VERSION=`rpm -qa | grep -E 'java-[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}-openjdk-[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}'`
    elif [ $OS_TYPE == 2 ]
    then
        JAVA_VERSION=java-8-openjdk-amd64
    fi

    # 버전별 의존성 문제 발생 시, 예외처리
    # major=$(echo ${MW_WAS_VERSION} | cut -d'-' -f2  | cut -d'.' -f1)
    # minor=$(echo ${MW_WAS_VERSION} | cut -d'-' -f2  | cut -d'.' -f2)
    # patch=$(echo ${MW_WAS_VERSION} | cut -d'-' -f2  | cut -d'.' -f3)

    # if [ $major == 8 ] && [ $minor -ge 5 ] 
    # then
    #     echo "version diff"
    # else
    #     echo "version diff"
    # fi


    #TODO: java 버전바뀌는거 체크해야 됨, 이미 환경변수 있을경우 패스하는 로직, 자바경로 자동으로 찾아서 넣어주는 로직
    if [ `cat /etc/profile | grep "export JAVA_HOME=" | wc -l` -eq 0 ]
    then
        echo -e "export JAVA_HOME=/usr/lib/jvm/$JAVA_VERSION" >> /etc/profile
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

    if [ `cat /etc/profile | grep "export PATH=" | wc -l` -eq 1 ]
    then
        sed -i '/^export PATH=/s@$@:'$INSTALL_PATH/$MW_WAS_VERSION'/bin@' /etc/profile
        source /etc/profile
    elif [ `cat /etc/profile | grep "export PATH=" | grep ${INSTALL_PATH}/${MW_WAS_VERSION}/bin | wc -l` -eq 0 ]
    then
        echo -e "export PATH=${PATH}:${INSTALL_PATH}/${MW_WAS_VERSION}/bin" >> /etc/profile
        source /etc/profile
    fi

    systemctl daemon-reload
    systemctl enable tomcat > /dev/null 2>&1
    systemctl restart tomcat
    
    if [ `systemctl is-active tomcat` == "active" ]
    then
        echo $MW_WAS_VERSION $INSTALL_PATH >> $VERSION
        echo $JAVA_VERSION >> $VERSION

        local MSG="Installation Finished\
        \nTerminate menu"
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Write_Log $FUNCNAME $LINENO "end"
    else
        local MSG="Installation Failed\
        \nTerminate menu"
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
    fi
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
    tar zxf ${g_path}/package/3.DB/MariaDB/${MW_DB_VERSION}-linux-systemd*.tar.gz -C ${INSTALL_PATH}

    mv ${INSTALL_PATH}/${MW_DB_VERSION}-linux-systemd* ${INSTALL_PATH}/${MW_DB_VERSION}
    
    #사용자 생성
    if [ `cat /etc/group | grep maria | wc -l` -eq 0 ]
    then
        groupadd maria
        useradd -g maria maria > /dev/null 2>&1
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

    # major=$(echo ${MW_DB_VERSION} | cut -d'-' -f2  | cut -d'.' -f1)
    # minor=$(echo ${MW_DB_VERSION} | cut -d'-' -f2  | cut -d'.' -f2)
    # patch=$(echo ${MW_DB_VERSION} | cut -d'-' -f2  | cut -d'.' -f3)

    # if [ $major == 10 ] && [ $minor == 2 ] 
    # then
    #     \cp -f $INSTALL_PATH/$MW_DB_VERSION/support-files/mysql.server /etc/init.d/mariadb.service
    # elif [ $major == 10 ] && [ $minor == 0 ]
    #     \cp -f $INSTALL_PATH/$MW_DB_VERSION/support-files/mysql.server /etc/init.d/mariadb.service

    # else
    #     echo "else start"
    # fi

    \cp -f $INSTALL_PATH/$MW_DB_VERSION/support-files/mysql.server /etc/init.d/mariadb.service
    sed -i '/^basedir=$/s@=@='$INSTALL_PATH/$MW_DB_VERSION'@' /etc/init.d/mariadb.service
    sed -i '/^datadir=$/s@=@=/data/mariadb/master@' /etc/init.d/mariadb.service

    #TODO: sed명령어 쓸때 변수못집어넣나? ex) $INSTALL_PATH (큰따옴표 쓰면 됨)
    # vi /etc/systemd/system/mariadb.service
    # sed -i '/^basedir=$/s/=/=\'$INSTALL'/' mariadb.service 변수 사용할 땐, ''(작은 따옴표) 한번 더 묶어주면 됨
    
    \cp -f $INSTALL_PATH/$MW_DB_VERSION/support-files/systemd/mariadb.service /etc/systemd/system/mariadb.service
    sed -i '/^User=/s@mysql@maria@' /etc/systemd/system/mariadb.service
    sed -i '/^Group=/s@mysql@maria@' /etc/systemd/system/mariadb.service

    if [ `cat /etc/profile | grep "export PATH=" | wc -l` -eq 1 ]
    then
        sed -i '/^export PATH=/s@$@:'$INSTALL_PATH/$MW_DB_VERSION'/bin@' /etc/profile
        source /etc/profile
    elif [ `cat /etc/profile | grep "export PATH=" | grep ${INSTALL_PATH}/${MW_DB_VERSION}/bin | wc -l` -eq 0 ]
    then
        echo -e "export PATH=${PATH}:${INSTALL_PATH}/${MW_DB_VERSION}/bin" >> /etc/profile
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
    
    #심볼릭링크 (mariadb 실행파일에 /usr/local/mysql 경로가 하드코딩 되어있어서 추가 필요)
    ln -s ${INSTALL_PATH}/${MW_DB_VERSION} /usr/local/mysql
    
    if [ $OS_TYPE == 2 ]
    then
        #libncurses
        if [ -z "`find /usr/lib -name libncurses.so.5`" ]
        then
            cp ${g_path}/rpms/common-lib/libncurses/libncurses.so.5 /lib/.
        fi
        #libtinfo
        if [ -z "`find /usr/lib -name libtinfo.so.5`" ]
        then
            cp ${g_path}/rpms/common-lib/libtinfo/libtinfo.so.5 /lib/.
        fi
        #libsystemd-daemon
        if [ -z "`find /usr/lib -name libsystemd-daemon.so.0`" ]
        then
            dpkg -i ${g_path}/rpms/deb/apt/db/libsystemd-daemon/systemd-libs_219-79_amd64.deb >> $RPM_LOG 2>&1
            ln -s /usr/lib64/libsystemd-daemon.so.0 /usr/lib/x86_64-linux-gnu/libsystemd-daemon.so.0    
        fi
    fi
    if [ $OS_TYPE == 3 ]
    then
        #libncurses
        if [ -z "`find /usr/lib64 -name libncurses.so.5`" ]
        then
            cp ${g_path}/rpms/common-lib/libncurses/libncurses.so.5 /lib64/.
        fi
        #libtinfo
        if [ -z "`find /usr/lib64 -name libtinfo.so.5`" ]
        then
            cp ${g_path}/rpms/common-lib/libtinfo/libtinfo.so.5 /lib64/.
        fi
        #libsystemd-daemon
        if [ -z "`find /usr/lib64 -name libsystemd-daemon.so.0`" ]
        then
            cp ${g_path}/rpms/rocky/dnf/db/libsystemd-daemon/libsystemd-daemon.so.0 /usr/lib64/.
        fi
    fi

    #TODO: 서비스 systemctl start mysql로 됨 (서비스명 변경 완료)
    systemctl daemon-reload
    systemctl enable mariadb > /dev/null 2>&1
    systemctl start mariadb

    if [ `systemctl is-active mariadb` == "active" ]
    then
        echo $MW_DB_VERSION $INSTALL_PATH >> $VERSION

        local MSG="Installation Finished\
        \nTerminate menu"
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Write_Log $FUNCNAME $LINENO "end"
    else
        local MSG="Installation Failed\
        \nTerminate menu"
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
    fi
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
        useradd -M -s /sbin/nologin -g mysql mysql > /dev/null 2>&1
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
    
    if [ `cat /etc/profile | grep "export PATH=" | wc -l` -eq 1 ]
    then
        sed -i '/^export PATH=/s@$@:'$INSTALL_PATH/$MW_DB_VERSION'/bin@' /etc/profile
        source /etc/profile
    elif [ `cat /etc/profile | grep "export PATH=" | grep ${INSTALL_PATH}/${MW_DB_VERSION}/bin | wc -l` -eq 0 ]
    then
        echo -e "export DB_HOME=${INSTALL_PATH}/${MW_DB_VERSION}
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

    if [ $OS_TYPE == 2 ]
    then
        #libssl
        if [ -z "`find /usr/lib -name libssl.so.10`" ]
        then            
            cp ${g_path}/rpms/common-lib/libssl/libssl.so.10 /lib/.
        fi
        #libcrypto
        if [ -z "`find /usr/lib -name libcrypto.so.10`" ]
        then
            cp ${g_path}/rpms/common-lib/libcrypto/libcrypto.so.10 /lib/.
        fi
        #libncurses
        if [ -z "`find /usr/lib -name libncurses.so.5`" ]
        then
            cp ${g_path}/rpms/common-lib/libncurses/libncurses.so.5 /lib/.
        fi
        #libtinfo
        if [ -z "`find /usr/lib -name libtinfo.so.5`" ]
        then
            cp ${g_path}/rpms/common-lib/libtinfo/libtinfo.so.5 /lib/.
        fi
    elif [ $OS_TYPE == 3 ]
    then
        #libssl
        if [ -z "`find /usr/lib64 -name libssl.so.10`" ]
        then            
            cp ${g_path}/rpms/common-lib/libssl/libssl.so.10 /lib64/.
        fi
        #libcrypto
        if [ -z "`find /usr/lib64 -name libcrypto.so.10`" ]
        then
            cp ${g_path}/rpms/common-lib/libcrypto/libcrypto.so.10 /lib64/.
        fi
        #libncurses
        if [ -z "`find /usr/lib64 -name libncurses.so.5`" ]
        then
            cp ${g_path}/rpms/common-lib/libncurses/libncurses.so.5 /lib64/.
        fi
        #libtinfo
        if [ -z "`find /usr/lib64 -name libtinfo.so.5`" ]
        then
            cp ${g_path}/rpms/common-lib/libtinfo/libtinfo.so.5 /lib64/.
        fi
    fi

    #db 설치
    cd ${INSTALL_PATH}/${MW_DB_VERSION}/bin
    ./mysqld --initialize --user=mysql > /data/mysql/.passwd 2>&1
    ./mysql_ssl_rsa_setup --defaults-file=/etc/my.cnf > /dev/null 2>&1

    #심볼릭링크 (mysql 실행파일에 /usr/local/mysql 경로가 하드코딩 되어 있어서 추가 필요)
    ln -s /data/mysql/mysql.sock /tmp/mysql.sock

    #서비스등록 및 시작
    \cp -f $INSTALL_PATH/$MW_DB_VERSION/support-files/mysql.server /etc/init.d/mysql
    sed -i '/^basedir=$/s@=@='$INSTALL_PATH/$MW_DB_VERSION'@' /etc/init.d/mysql
    sed -i '/^datadir=$/s@=@=/data/mysql@' /etc/init.d/mysql

    if [ $OS_TYPE == 1 ]
    then
        chkconfig --add mysql
    elif [ $OS_TYPE == 2 ]
    then
        #./mysqld_safe --user=mysql 이거하면 왜 행걸림?
        update-rc.d mysql defaults
    fi

    systemctl daemon-reload
    systemctl enable mysql > /dev/null 2>&1
    systemctl start mysql

    if [ `systemctl is-active mysql` == "active" ]
    then
        echo $MW_DB_VERSION $INSTALL_PATH >> $VERSION

        local MSG="Installation Finished\
        \nTerminate menu"
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        local MSG="Please Remember Initial Password Path\
        \n/data/mysql/.passwd"
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Write_Log $FUNCNAME $LINENO "end"
    else
        local MSG="Installation Failed\
        \nTerminate menu"
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
    fi
}

#TODO: Postgresql 설치방법 가이드북 작성 및 코드 작성
function Install_Postgresql()
{
    Write_Log $FUNCNAME $LINENO "start"

    #TODO: Progressbar 하드코딩 말고 로직 변경
    jump=0

    MSG="PostgreSQL Install ( $MW_DB_VERSION )"
    Progress=$(($Progress+$jump))
    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    tar zxf ${g_path}/package/3.DB/PostgreSQL/${MW_DB_VERSION}.tar.gz -C ${g_path}/package/3.DB/PostgreSQL
    
    if [ `cat /etc/profile | grep "export PATH=" | wc -l` -eq 1 ]
    then
        sed -i '/^export PATH=/s@$@:'$INSTALL_PATH/$MW_DB_VERSION'/bin@' /etc/profile
        source /etc/profile
    elif [ `cat /etc/profile | grep "export PATH=" | grep ${INSTALL_PATH}/bin | wc -l` -eq 0 ]
    then
        echo -e "export PATH=${PATH}:${INSTALL_PATH}/${MW_DB_VERSION}/bin" >> /etc/profile
        source /etc/profile
    fi

    #사용자 생성
    if [ `cat /etc/group | grep postgres | wc -l` -eq 0 ]
    then
        useradd -d ${INSTALL_PATH} postgres > /dev/null 2>&1
    fi

    cd ${g_path}/package/3.DB/PostgreSQL/${MW_DB_VERSION}

    # 버전에 따라 configure 하는 명령어가 다름
    major=$(echo ${MW_DB_VERSION} | cut -d'-' -f2  | cut -d'.' -f1)
    minor=$(echo ${MW_DB_VERSION} | cut -d'-' -f2  | cut -d'.' -f2)
    #patch=$(echo ${MW_DB_VERSION} | cut -d'-' -f2  | cut -d'.' -f3)

    count=4
    jump=$((100/$count))

    if [ $major == 16 ] && [ $minor -ge 0 ] 
    then
        #./configure --prefix=${INSTALL_PATH}/${MW_DB_VERSION} --enable-depend --enable-nls=utf-8 --with-python3 > /dev/null 2>&1
        Set_Configure "--prefix=${INSTALL_PATH}/${MW_DB_VERSION} --enable-depend --enable-nls=utf-8 --without-icu"
    else
        Set_Configure "--prefix=${INSTALL_PATH}/${MW_DB_VERSION} --enable-depend --enable-nls=utf-8"
    fi

    Set_Make ${g_path}/trace_log/postgresql.log
    Set_Make_Install ${g_path}/trace_log/postgresql.log

    mkdir -p /data/postgresql
    PGDATA="/data/postgresql"
    chown -R postgres:postgres /data/

    chown -R postgres:postgres ${INSTALL_PATH}/$MW_DB_VERSION

    su - postgres -c "${INSTALL_PATH}/$MW_DB_VERSION/bin/initdb -E utf-8 -D /data/postgresql" > /dev/null 2>&1

    #서비스등록 및 시작
    echo -e "[Unit]
Description=PostgreSQL
After=syslog.target
After=network.target \n
[Service]
Type=forking \n
User=postgres
Group=postgres \n
# Note: avoid inserting whitespace in these Environment= lines, or you may
# break postgresql-setup. \n
# Location of database directory
Environment=PGDATA=/data/postgresql
Environment=POSTGRES_HOME=$INSTALL_PATH/$MW_DB_VERSION \n
# Where to send early-startup messages from the server (before the logging
# options of postgresql.conf take effect)
# This is normally controlled by the global default set by systemd
# StandardOutput=syslog \n
# Disable OOM kill on the postmaster
OOMScoreAdjust=-1000 \n
ExecStart=$INSTALL_PATH/$MW_DB_VERSION/bin/pg_ctl start -D "${PGDATA}" -s -w -t 300
ExecStop=$INSTALL_PATH/$MW_DB_VERSION/bin/pg_ctl stop -D "${PGDATA}" -s -m fast
ExecReload=$INSTALL_PATH/$MW_DB_VERSION/bin/pg_ctl reload -D "${PGDATA}" -s
 \n
# Give a reasonable amount of time for the server to start up/shut down
TimeoutSec=300 \n
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/postgres.service

    #경로이동
    cd ${INSTALL_PATH}

    systemctl daemon-reload
    systemctl enable postgres > /dev/null 2>&1
    systemctl restart postgres

    # #postgre 구동 및 접속
    # cd ${INSTALL_PATH}/$MW_DB_VERSION/bin/
    # su - postgres -c "postgres -D /data/postgresql/ &" > /dev/null 2>&1 | echo -ne '\n'
    #
    # psql -U postgres 

    if [ `systemctl is-active postgres` == "active" ]
    then
        echo $MW_DB_VERSION $INSTALL_PATH >> $VERSION

        local MSG="Installation Finished\
        \nTerminate menu"
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Write_Log $FUNCNAME $LINENO "end"
    else
        local MSG="Installation Failed\
        \nTerminate menu"
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
    fi
}

function Uninstall_Web_Apache()
{
    Write_Log $FUNCNAME $LINENO "start"

    if [ ! -f $VERSION ] || [ `cat $VERSION | grep "httpd" | wc -l` -eq 0 ]
    then
        local MSG="Apache is not installed."
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu
    else
        local jump=50
        MW_WEB_VERSION=`cat $VERSION | grep "httpd" | cut -f 1 -d' '`

        #첫번째 줄은 항상 경로로 입력하고 첫줄만 가져오는 코드?
        INSTALL_PATH=`cat $VERSION | grep $MW_WEB_VERSION | cut -f 2 -d ' '`
        APR_VERSION=`cat $VERSION | grep "apr" | head -1`
        APR_UTIL_VERSION=`cat $VERSION | grep "apr-util"`
        PCRE_VERSION=`cat $VERSION | grep "pcre"`
        MSG="Apache Uninstall ( $MW_WEB_VERSION )"
        Progress=$(($Progress+$jump))
        echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0

        if [ `ps -ef | grep httpd | wc -l` -gt 1 ]
        then
            systemctl stop httpd
        fi

        #TODO: apr, apr-util, pcre 각각 다 지워줘야 됨
        # cd ${g_path}/package/module/${APR_VERSION}
        # make distclean > /dev/null 2>&1
        
        # cd ${g_path}/package/module/${APR_UTIL_VERSION}
        # make distclean > /dev/null 2>&1

        # cd ${g_path}/package/module/${PCRE_VERSION}
        # make distclean > /dev/null 2>&1

        cd ${g_path}

        rm -rf /etc/systemd/system/httpd.service
        rm -rf /etc/init.d/httpd
        [ -d ${g_path}/package/1.WEB/${MW_WEB_VERSION} ] && rm -rf ${g_path}/package/1.WEB/${MW_WEB_VERSION}
        [ -d ${g_path}/package/module/${APR_VERSION} ] && rm -rf ${g_path}/package/module/${APR_VERSION}
        [ -d ${g_path}/package/module/${APR_UTIL_VERSION} ] && rm -rf ${g_path}/package/module/${APR_UTIL_VERSION}
        [ -d ${g_path}/package/module/${PCRE_VERSION} ] && rm -rf ${g_path}/package/module/${PCRE_VERSION}
        rm -rf ${INSTALL_PATH}

        sed -i "/$MW_WEB_VERSION/d" $VERSION
        sed -i "/$APR_VERSION/d" $VERSION
        sed -i "/$APR_UTIL_VERSION/d" $VERSION
        sed -i "/$PCRE_VERSION/d" $VERSION
    fi

    Write_Log $FUNCNAME $LINENO "end"
}

function Uninstall_Was_Tomcat()
{
    Write_Log $FUNCNAME $LINENO "start"

    if [ ! -f $VERSION ] || [ `cat $VERSION | grep "tomcat" | wc -l` -eq 0 ]
    then
        local MSG="Tomcat is not installed."
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu
    else
        local jump=50
        MW_WAS_VERSION=`cat $VERSION | grep "tomcat" | cut -f 1 -d ' '`
        JAVA_VERSION=`cat $VERSION | grep "java" | cut -f 1 -d ' '`

        INSTALL_PATH=`cat $VERSION | grep $MW_WAS_VERSION | cut -f 2 -d ' '`
        #TODO: JAVA_VERSION 정의해줘야 됨. .version.out 파일 걸 가져오기

        MSG="Tomcat Uninstall ( $MW_WAS_VERSION )"
        Progress=$(($Progress+$jump))
        echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
        
        if [ `ps -ef | grep tomcat | wc -l` -gt 1 ]
        then
            systemctl stop tomcat
        fi
        
        rm -rf /etc/systemd/system/tomcat.service
        [ -d ${g_path}/package/2.WAS/${MW_WAS_VERSION} ] && rm -rf ${g_path}/package/2.WAS/${MW_WAS_VERSION}
        rm -rf ${INSTALL_PATH}

        #확인필요, tomcat path라인 삭제 구문
        sed -i '/^export PATH=/s@:'$INSTALL_PATH/$MW_WAS_VERSION/bin'@''@' /etc/profile
        sed -i "/$JAVA_VERSION/d" /etc/profile

        sed -i "/$MW_WAS_VERSION/d" $VERSION
        sed -i "/$JAVA_VERSION/d" $VERSION

        source /etc/profile
    fi
    
    Write_Log $FUNCNAME $LINENO "end"
}

function Uninstall_Db_Mariadb()
{
    Write_Log $FUNCNAME $LINENO "start"

    if [ ! -f $VERSION ] || [ `cat $VERSION | grep "mariadb" | wc -l` -eq 0 ]
    then
        local MSG="MariaDB is not installed."
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu
    else
        local jump=50
        MW_DB_VERSION=`cat $VERSION | grep "mariadb" | cut -f 1 -d ' '`
        INSTALL_PATH=`cat $VERSION | grep $MW_DB_VERSION | cut -f 2 -d ' '`
        #TODO: .version.out 파일 걸 가져오기

        MSG="MariaDB Uninstall ( $MW_DB_VERSION )"
        Progress=$(($Progress+$jump))
        echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0

        if [ `systemctl is-active mariadb` == "active" ]
        then
            systemctl stop mariadb
        fi

        if [ `cat /etc/group | grep maria | wc -l` -eq 1 ]
        then
            userdel maria
            rm -rf /home/maria
        fi

        rm -rf /usr/local/mysql
        rm -rf /var/log/mariadb.log
        rm -rf /etc/init.d/mariadb.service
        rm -rf /etc/systemd/system/mariadb.service
        rm -rf /etc/my.cnf
        rm -rf /tmp/mysql.sock

        rm -rf ${INSTALL_PATH}
        rm -rf /data

        #TODO: 경로에 '/' 포함되어 있어서 처리 필요
        sed -i '/^export PATH=/s@:'$INSTALL_PATH/$MW_DB_VERSION/bin'@''@' /etc/profile

        sed -i "/$MW_DB_VERSION/d" $VERSION
        source /etc/profile
    fi

    Write_Log $FUNCNAME $LINENO "end"
}

function Uninstall_Db_Mysql()
{
    Write_Log $FUNCNAME $LINENO "start"

    if [ ! -f $VERSION ] || [ `cat $VERSION | grep "mysql" | wc -l` -eq 0 ]
    then
        local MSG="MySQL is not installed."
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu
    else
        local jump=50
        MW_DB_VERSION=`cat $VERSION | grep "mysql" | cut -f 1 -d ' '`
        INSTALL_PATH=`cat $VERSION | grep $MW_DB_VERSION | cut -f 2 -d ' '`
        #TODO: .version.out 파일 걸 가져오기

        MSG="MySQL Uninstall ( $MW_DB_VERSION )"
        Progress=$(($Progress+$jump))
        echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0

        if [ `systemctl is-active mysql` == "active" ]
        then
            systemctl stop mysql
        fi

        if [ `cat /etc/group | grep mysql | wc -l` -eq 1 ]
        then
            userdel mysql
            rm -rf /home/mysql
        fi

        if [ `cat /etc/profile | grep "export PATH=" | grep ${INSTALL_PATH}/${MW_DB_VERSION}/bin | wc -l` -eq 1 ]
        then
            sed -i "/$MW_DB_VERSION/d" /etc/profile
            source /etc/profile
        fi

        rm -rf /tmp/mysql.sock
        rm -rf /etc/init.d/mysql
        rm -rf /etc/my.cnf
        rm -rf /etc/systemd/system/mysql.service
        rm -rf /etc/systemd/system/mysqld.service

        rm -rf ${INSTALL_PATH}
        rm -rf /data

        #TODO: 경로에 '/' 포함되어 있어서 처리 필요 (완료)
        sed -i '/^export PATH=/s@:'$INSTALL_PATH/$MW_DB_VERSION/bin'@''@' /etc/profile

        sed -i "/$MW_DB_VERSION/d" $VERSION
        source /etc/profile
    fi

    Write_Log $FUNCNAME $LINENO "end"
}

function Uninstall_Db_Postgresql()
{
    Write_Log $FUNCNAME $LINENO "start"

    if [ ! -f $VERSION ] || [ `cat $VERSION | grep "postgresql" | wc -l` -eq 0 ]
    then
        local MSG="PostgreSQL is not installed."
        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

        Show_Menu
    else
        local jump=50
        MW_DB_VERSION=`cat $VERSION | grep "postgresql" | cut -f 1 -d ' '`
        INSTALL_PATH=`cat $VERSION | grep $MW_DB_VERSION | cut -f 2 -d ' '`
        #TODO: .version.out 파일 걸 가져오기

        MSG="PostgreSQL Uninstall ( $MW_DB_VERSION )"
        Progress=$(($Progress+$jump))
        echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0

        if [ `ps -ef | grep "postgresql" | wc -l` -gt 1 ]
        then
            kill `cat /data/postgresql/postmaster.pid | head -1` | echo -ne '\n' > /dev/null 2>&1
        fi

        if [ `systemctl is-active postgres` == "active" ]
        then
            systemctl stop postgres
        fi

        if [ `cat /etc/group | grep postgres | wc -l` -eq 1 ]
        then
            userdel postgres
        fi

        # cd ${g_path}/package/3.DB/PostgreSQL/${MW_DB_VERSION}
        # make distclean > /dev/null 2>&1

        [ -d ${g_path}/package/3.DB/PostgreSQL/${MW_DB_VERSION} ] && rm -rf ${g_path}/package/3.DB/PostgreSQL/${MW_DB_VERSION}
        rm -rf ${INSTALL_PATH}
        rm -rf /data
        rm -rf /etc/systemd/system/postgres

        #TODO: 경로에 '/' 포함되어 있어서 처리 필요
        sed -i '/^export PATH=/s@:'$INSTALL_PATH/$MW_DB_VERSION/bin'@''@' /etc/profile

        sed -i "/$MW_DB_VERSION/d" $VERSION
        source /etc/profile
    fi

    Write_Log $FUNCNAME $LINENO "end"
}

function Check_Wget_Install_Version
{
    Write_Log $FUNCNAME $LINENO "start"

    # 버전 분류
    major=$(echo ${INSTALL_VERSION} | cut -d'.' -f1)
    minor=$(echo ${INSTALL_VERSION} | cut -d'.' -f2)
    patch=$(echo ${INSTALL_VERSION} | cut -d'.' -f3)

    # WEB
    case $MENU_OPT_MW_TYPE in
    1)
        if [ $MENU_OPT_WEB_TYPE == 1 ]
        then 
            MW_WEB_VERSION=httpd-${INSTALL_VERSION}
            URL=http://archive.apache.org/dist/httpd/${MW_WEB_VERSION}.tar.gz
            Check_Wget_Version_Exist $URL

            if [ $WGET_STATUS == 1 ]
            then
                wget -NP ${g_path}/package/1.WEB/ ${URL} > /dev/null 2>&1
            elif [ $WGET_STATUS == 0 ]
            then
                local MSG="${MW_WEB_VERSION} file does not exist."
                dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
            fi

            #모듈 3개를 for문으로 반복하여 수행
            for module in $MODULELIST
            do
                if [ "$module" == "apr" ]
                then
                    URL=https://dlcdn.apache.org/apr/${APR_VERSION}.tar.gz
                    Check_Wget_Version_Exist $URL
                elif [ "$module" == "apr-util" ]
                then
                    URL=https://dlcdn.apache.org/apr/${APR_UTIL_VERSION}.tar.gz
                    Check_Wget_Version_Exist $URL
                elif [ "$module" == "pcre" ]
                then
                    URL=https://sourceforge.net/projects/pcre/files/pcre/${MODULE_VERSION}/${PCRE_VERSION}.tar.gz/download
                    Check_Wget_Version_Exist $URL
                fi
                
                if [ $WGET_STATUS == 1 ]
                then
                    wget -NP ${g_path}/package/module/ ${URL} > /dev/null 2>&1
                elif [ $WGET_STATUS == 0 ]
                then
                    if [ "$moudle" == "apr" ]
                    then
                        local MSG="${APR_VERSION} file does not exist."
                        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
                    elif [ "$moudle" == "apr-util" ]
                    then
                        local MSG="${APR_UTIL_VERSION} file does not exist."
                        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
                    elif [ "$moudle" == "pcre" ]
                    then
                        local MSG="${PCRE_VERSION} file does not exist."
                        dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
                    fi
                fi
            done
        fi
        ;;
    # WAS
    2)
        if [ $MENU_OPT_WAS_TYPE == 1 ]
        then
            MW_WAS_VERSION=apache-tomcat-${INSTALL_VERSION}
            URL=https://archive.apache.org/dist/tomcat/tomcat-${major}/v${INSTALL_VERSION}/bin/${MW_WAS_VERSION}.tar.gz
            Check_Wget_Version_Exist $URL

            if [ $WGET_STATUS == 1 ]
            then
                wget -NP ${g_path}/package/2.WAS/ ${URL} > /dev/null 2>&1
            elif [ $WGET_STATUS == 0 ]
            then
                local MSG="${MW_WAS_VERSION} file does not exist.\
                \nPlease Check Available Version"
                dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
            fi
        fi
        ;;
    # DB
    3)
        if [ $MENU_OPT_DB_TYPE == 1 ]
        then
            MW_DB_VERSION=mariadb-${INSTALL_VERSION}
            URL=https://downloads.mariadb.com/MariaDB/${MW_DB_VERSION}/bintar-linux-systemd-x86_64/${MW_DB_VERSION}-linux-systemd-x86_64.tar.gz
            Check_Wget_Version_Exist $URL

            if [ $WGET_STATUS == 1 ]
            then
                wget -NP ${g_path}/package/3.DB/MariaDB/ ${URL} > /dev/null 2>&1
            elif [ $WGET_STATUS == 0 ]
            then
                local MSG="${MW_DB_VERSION} file does not exist.\
                \nPlease Check Available Version"
                dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
            fi
        elif [ $MENU_OPT_DB_TYPE == 2 ]
        then
            MW_DB_VERSION=mysql-${INSTALL_VERSION}
            URL=https://downloads.mysql.com/archives/get/p/23/file/${MW_DB_VERSION}-el7-x86_64.tar.gz
            Check_Wget_Version_Exist $URL

            if [ $WGET_STATUS == 1 ]
            then
                wget -NP ${g_path}/package/3.DB/MySQL/ ${URL} > /dev/null 2>&1
            elif [ $WGET_STATUS == 0 ]
            then
                local MSG="${MW_DB_VERSION} file does not exist.\
                \nPlease Check Available Version"
                dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
            fi
        elif [ $MENU_OPT_DB_TYPE == 3 ]
        then
            MW_DB_VERSION=postgresql-${INSTALL_VERSION}
            URL=https://ftp.postgresql.org/pub/source/v${INSTALL_VERSION}/${MW_DB_VERSION}.tar.gz
            Check_Wget_Version_Exist $URL

            if [ $WGET_STATUS == 1 ]
            then
                wget -NP ${g_path}/package/3.DB/PostgreSQL/ ${URL} > /dev/null 2>&1
            elif [ $WGET_STATUS == 0 ]
            then
                local MSG="${MW_DB_VERSION} file does not exist.\
                \nPlease Check Available Version"
                dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70
            fi
        fi
        ;;
    esac

    #wget 버전 미 지원 시, 버전 재 입력
    if [ $WGET_STATUS == 0 ]
    then
        Input_Middleware_Version
        Check_Wget_Install_Version
    fi

    Write_Log $FUNCNAME $LINENO "end"
}

function Check_Internet_Status
{
    Write_Log $FUNCNAME $LINENO "start"

    ping -c 1 -w 1 "8.8.8.8" &> /dev/null
    if [ "$?" == "0" ] ; 
    then
        INTERNET_STATUS=1
    else
        INTERNET_STATUS=0
    fi

    Write_Log $FUNCNAME $LINENO "end"
}

function Check_Wget_Version_Exist
{
    Write_Log $FUNCNAME $LINENO "start"

    wget --spider $1 &> /dev/null
    if [ "$?" == "0" ] ; 
    then
        WGET_STATUS=1
    else
        WGET_STATUS=0
    fi

    Write_Log $FUNCNAME $LINENO "end"
}
