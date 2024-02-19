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
    Chk_Dir_Exist

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

    source /etc/profile

    local MSG="Installation finished.\
    \nTerminate menu"

    dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

    Write_Log $FUNCNAME $LINENO "end"
}

function Chk_Dir_Exist()
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

    #설치 디렉토리 생성
    mkdir -p ${INSTALL_PATH} # 제일 먼저 만들어야 함
    echo "PATH=${INSTALL_PATH}" >> $TMPFILE

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
            #TODO: 현재 2.4.X 버전만 호환 됨. apr, apr-util 사용자 커스텀생성으로 바꿔야 될듯
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

    MSG="Apr Install ( $APR_VERSION )"
    Progress=$(($Progress+$jump))
    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    tar zxf ${g_path}/package/module/${APR_VERSION}.tar.gz -C ${g_path}/package/module

    cd ${g_path}/package/module/${APR_VERSION}
    ./configure --prefix=$INSTALL_PATH/apr > /dev/null 2>&1
    make > ${g_path}/trace_log/apr.log 2>&1
    make install >> ${g_path}/trace_log/apr.log 2>&1

    #TODO: 모듈버전을 넣어야 됨.
    echo $APR_VERSION >> $VERSION

    Write_Log $FUNCNAME $LINENO "end"
}

function Install_Apache_Apr_Util()
{
    Write_Log $FUNCNAME $LINENO "start"
    local jump=25

    MSG="Apr-Util Install ( $APR_UTIL_VERSION )"
    Progress=$(($Progress+$jump))
    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    tar zxf ${g_path}/package/module/${APR_UTIL_VERSION}.tar.gz -C ${g_path}/package/module

    cd ${g_path}/package/module/${APR_UTIL_VERSION}
    ./configure --prefix=$INSTALL_PATH/apr-util --with-apr=$INSTALL_PATH/apr > /dev/null 2>&1
    make > ${g_path}/trace_log/apr-util.log 2>&1
    make install > ${g_path}/trace_log/apr-util.log 2>&1

    echo $APR_UTIL_VERSION >> $VERSION

    Write_Log $FUNCNAME $LINENO "end"
}

function Install_Apache_Pcre()
{
    Write_Log $FUNCNAME $LINENO "start"
    local jump=25

    MSG="Pcre Install ( $PCRE_VERSION )"
    Progress=$(($Progress+$jump))
    echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    tar zxf ${g_path}/package/module/${PCRE_VERSION}.tar.gz -C ${g_path}/package/module

    cd ${g_path}/package/module/${PCRE_VERSION}
    ./configure --prefix=$INSTALL_PATH/pcre > ${g_path}/trace_log/pcre.log 2>&1
    make >> ${g_path}/trace_log/pcre.log 2>&1
    make install >> ${g_path}/trace_log/pcre.log 2>&1

    echo $PCRE_VERSION >> $VERSION

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

    # 버전에 따라 configure 하는 명령어가 다름
    major=$(echo ${MW_WEB_VERSION} | cut -d'-' -f2  | cut -d'.' -f1)
    minor=$(echo ${MW_WEB_VERSION} | cut -d'-' -f2  | cut -d'.' -f2)
    patch=$(echo ${MW_WEB_VERSION} | cut -d'-' -f2  | cut -d'.' -f3)

    if [ $major == 2 ] && [ $minor -ge 4 ] 
    then
        ./configure --prefix=$INSTALL_PATH/${MW_WEB_VERSION} \
        --enable-module=so --enable-rewrite --enable-so \
        --with-apr=$INSTALL_PATH/apr \
        --with-apr-util=$INSTALL_PATH/apr-util \
        --with-pcre=$INSTALL_PATH/pcre/bin/pcre-config \
        --enable-mods-shared=all > ${g_path}/trace_log/apache.log 2>&1
    else
        ./configure --prefix=$INSTALL_PATH/${MW_WEB_VERSION} \
        --enable-module=so --enable-rewrite --enable-so \
        --enable-mods-shared=all > ${g_path}/trace_log/apache.log 2>&1
    fi

    make >> ${g_path}/trace_log/apache.log 2>&1
    make install >> ${g_path}/trace_log/apache.log 2>&1

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
    chkconfig --add httpd

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
    if [ `ps -ef | grep httpd | wc -l` -gt 1 ]
    then
        ps -ef | grep httpd | awk '{print $2}' | xargs kill -9 > /dev/null 2>&1
    fi

    # httpd v2.0.x 추가 수행
    if [ $major == 2 ] && [ $minor == 0 ] 
    then
        sed -i '/^Group #-1/s@#-1@nobody@' $INSTALL_PATH/$MW_WEB_VERSION/conf/httpd.conf
    fi

    #서비스 시작
    systemctl daemon-reload
    systemctl enable httpd >> ${g_path}/trace_log/apache.log 2>&1
    systemctl restart httpd

    echo $MW_WEB_VERSION $INSTALL_PATH >> $VERSION

    Write_Log $FUNCNAME $LINENO "end"
}

function Install_Was()
{
    Write_Log $FUNCNAME $LINENO "start"

    case $MENU_OPT_WAS_TYPE in
        1) 
            Install_Tomcat_Java

            Install_Tomcat
            ;;
    esac

    Write_Log $FUNCNAME $LINENO "end"
}

function Install_Tomcat_Java()
{
    Write_Log $FUNCNAME $LINENO "start"



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

    JAVA_VERSION=`rpm -qa | grep -E 'java-[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}-openjdk-[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}'`

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
    
    echo $JAVA_VERSION >> $VERSION
    echo $MW_WAS_VERSION $INSTALL_PATH >> $VERSION

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


    #TODO: 서비스 systemctl start mysql로 됨 (서비스명 변경 완료)
    systemctl enable mariadb > /dev/null 2>&1
    systemctl start mariadb

    echo $MW_DB_VERSION $INSTALL_PATH >> $VERSION

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
    systemctl enable mysql.service > /dev/null 2>&1
    systemctl start mysql.service

    echo $MW_DB_VERSION $INSTALL_PATH >> $VERSION

    # #mysql root password 변경, /data/mysql/.passwd 파일 읽어서 초기 패스워드 사용해야 됨
    # mysql -uroot -p'초기패스워드' -e "alter user 'root'@'localhost' identified by 'Sniper13@$';"

    local MSG="Please Remember Initial Password Route\
    \n/data/mysql/.passwd"

    dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "$MSG" 10 70

    Write_Log $FUNCNAME $LINENO "end"
}

#TODO: Postgresql 설치방법 가이드북 작성 및 코드 작성
function Install_Postgresql()
{
    Write_Log $FUNCNAME $LINENO "start"

    #TODO: Progressbar 하드코딩 말고 로직 변경
    local jump=50

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
    ./configure --prefix=${INSTALL_PATH}/${MW_DB_VERSION} --enable-depend --enable-nls=utf-8 --with-python > /dev/null 2>&1

    make > /dev/null 2>&1
    make install > /dev/null 2>&1

    mkdir -p /data/postgresql
    chown -R postgres:postgres /data/

    chown -R postgres:postgres ${INSTALL_PATH}/$MW_DB_VERSION

    su - postgres -c "${INSTALL_PATH}/$MW_DB_VERSION/bin/initdb -E utf-8 -D /data/postgresql" > /dev/null 2>&1

    #서비스등록 및 시작
    echo -e "[Unit]
Description=PostgreSQL 9.6.19
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
Environment=POSTGRES_HOME=$INSTALL_PATH/$MW_WAS_VERSION \n
# Where to send early-startup messages from the server (before the logging
# options of postgresql.conf take effect)
# This is normally controlled by the global default set by systemd
# StandardOutput=syslog \n
# Disable OOM kill on the postmaster
OOMScoreAdjust=-1000 \n
ExecStart=$INSTALL_PATH/$MW_WAS_VERSION/bin/pg_ctl start -D "${PGDATA}" -s -w -t 300
ExecStop=$INSTALL_PATH/$MW_WAS_VERSION/bin/pg_ctl stop -D "${PGDATA}" -s -m fast
ExecReload=$INSTALL_PATH/$MW_WAS_VERSION/bin/pg_ctl reload -D "${PGDATA}" -s
 \n
# Give a reasonable amount of time for the server to start up/shut down
TimeoutSec=300 \n
[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/postgres.service

    systemctl daemon-reload
    systemctl enable postgres > /dev/null 2>&1
    systemctl restart postgres

    # #postgre 구동
    # cd ${INSTALL_PATH}/$MW_DB_VERSION/bin/
    # su - postgres -c "postgres -D /data/postgresql/ &" > /dev/null 2>&1 | echo -ne '\n'

    echo $MW_DB_VERSION $INSTALL_PATH >> $VERSION

    Write_Log $FUNCNAME $LINENO "end"
}

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
        cd ${g_path}/package/module/${APR_VERSION}
        make distclean > /dev/null 2>&1
        
        cd ${g_path}/package/module/${APR_UTIL_VERSION}
        make distclean > /dev/null 2>&1

        cd ${g_path}/package/module/${PCRE_VERSION}
        make distclean > /dev/null 2>&1

        cd ${g_path}

        rm -rf /etc/systemd/system/httpd.service
        rm -rf /etc/init.d/httpd
        rm -rf ${g_path}/package/1.WEB/${MW_WEB_VERSION}
        rm -rf ${g_path}/package/module/${APR_VERSION}
        rm -rf ${g_path}/package/module/${APR_UTIL_VERSION}
        rm -rf ${g_path}/package/module/${PCRE_VERSION}
        rm -rf ${INSTALL_PATH}

        sed -i "/$MW_WEB_VERSION/d" $VERSION
        sed -i "/$APR_VERSION/d" $VERSION
        sed -i "/$APR_UTIL_VERSION/d" $VERSION
        sed -i "/$PCRE_VERSION/d" $VERSION

    fi

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
        MW_WAS_VERSION=`cat $VERSION | grep "tomcat" | cut -f 1 -d' '`
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
        rm -rf ${g_path}/package/2.WAS/${MW_WAS_VERSION}
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
        fi

        rm -rf /usr/local/mysql
        rm -rf /var/log/mariadb.log
        rm -rf /etc/init.d/mariadb.service
        rm -rf /etc/systemd/system/mariadb.service
        rm -rf /etc/my.cnf

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
        rm -rf /etc/init.d/mysql.service
        rm -rf /etc/my.cnf

        rm -rf ${INSTALL_PATH}
        rm -rf /data

        #TODO: 경로에 '/' 포함되어 있어서 처리 필요
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

        cd ${g_path}/package/3.DB/PostgreSQL/${MW_DB_VERSION}
        make distclean > /dev/null 2>&1
        cd ${g_path}

        rm -rf ${g_path}/package/3.DB/PostgreSQL/${MW_DB_VERSION}
        rm -rf ${INSTALL_PATH}
        rm -rf /data

        #TODO: 경로에 '/' 포함되어 있어서 처리 필요
        sed -i '/^export PATH=/s@:'$INSTALL_PATH/$MW_DB_VERSION/bin'@''@' /etc/profile

        sed -i "/$MW_DB_VERSION/d" $VERSION
        source /etc/profile
        
        userdel postgres
    fi

    Write_Log $FUNCNAME $LINENO "end"
}