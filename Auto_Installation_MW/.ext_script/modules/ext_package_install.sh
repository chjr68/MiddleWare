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

function Check_Os_Type
{
    Write_Log $FUNCNAME $LINENO "start"

    if [ -f /etc/redhat-release ]
    then
        if [ -n "`cat /etc/redhat-release | grep CentOS`" ]   
        then        
            #CentOS
            OS_TYPE=1
        elif [ -n "`cat /etc/redhat-release | grep "Rocky Linux release 8"`" ]
        then        
            #RockyOS
            OS_TYPE=3
        fi
    elif [ -n "`cat /etc/issue | grep "Ubuntu 22.04"`" ]
    then
        #Ubuntu
        OS_TYPE=2
    # elif [ -f /etc/ ]
    # then
    #     #Amazon Linux
    #     OS_TYPE=4    
    fi 
    
    Write_Log $FUNCNAME $LINENO "end"
}

function Decompress_Rpms()
{
    Write_Log $FUNCNAME $LINENO "start"

    # rpms.tar.gz 압축파일 해제
    #tar zxf ${g_path}/rpms.tar.gz -C ${g_path}/

    Write_Log $FUNCNAME $LINENO "end"
}

#용량 확보
function Delete_Directory()
{
    Write_Log $FUNCNAME $LINENO "start"
    
    # rpms.tar.gz 해제 파일 삭제

    # 테스트 완료 전 까지 주석처리
    #rm -rf ${g_path}/rpms

    # module 압축 해제 디렉토리 삭제
    find ${g_path}/package/1.WEB/. -type d | xargs rm -rf > /dev/null 2>&1
    find ${g_path}/package/module/. -type d | xargs rm -rf > /dev/null 2>&1
    find ${g_path}/package/2.WAS/. -type d | xargs rm -rf > /dev/null 2>&1
    find ${g_path}/package/3.DB/MariaDB/. -type d | xargs rm -rf > /dev/null 2>&1
    find ${g_path}/package/3.DB/MySQL/. -type d | xargs rm -rf > /dev/null 2>&1
    find ${g_path}/package/3.DB/PostgreSQL/. -type d | xargs rm -rf > /dev/null 2>&1

    Write_Log $FUNCNAME $LINENO "end"
}

function Install_Rpms()
{
    Write_Log $FUNCNAME $LINENO "start"

    local Progress=0

    #진행과정 로딩바 출력
    local jump=$((100/`echo ${CHKRPMLIST} | wc -w`))

    if [ $jump -eq 0 ]
    then
        local jump=$((1000/`echo ${CHKRPMLIST} | wc -w`))
    fi

    for rpm_string in $CHKRPMLIST
    do
        MSG="Install RPM : ${rpm_string}"

        Write_Log $FUNCNAME $LINENO "${MSG}"

        Progress=$(($Progress+$jump))
        
        echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0

        #TODO: 불필요 rpm 구문 삭제, 전역변수 파일 CHKRPMLIST 내용도 수정
        #      추후 폐쇄망에서 사용가능하도록 의존성파일 rpm 화
        case ${rpm_string} in      
            net-tools)
                #CentOS / RockyOS
                if [ $OS_TYPE == 1 ] || [ $OS_TYPE == 3 ]
                then
                    if [ -z "`rpm -qa net-tools`" ]
                    then
                        rpm -Uvh ${g_path}/rpms/centos/core-rpms/net-tools-2.0-0.22.20131004git.el7.x86_64.rpm >> $RPM_LOG 2>&1
                    fi
                #Ubuntu
                elif [ $OS_TYPE == 2 ]
                then
                    if [ -z "`dpkg -l | cut -d" " -f3 | grep net-tools`" ]
                    then
                        dpkg -i ${g_path}/rpms/ubuntu/core-debs/net-tools_2.0-1.22_amd64.deb >> $RPM_LOG 2>&1
                    fi
                #Amazon Linux
                elif [ $OS_TYPE == 4 ]
                then
                    :
                fi  
                ;;
            dialog)
                if [ $OS_TYPE == 1 ]
                then
                    if [ -z "`rpm -qa dialog`"  ]
                    then
                        rpm -Uvh ${g_path}/rpms/centos/core-rpms/dialog-1.2-4.20130523.el7.x86_64.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 2 ]
                then
                    if [ -z "`dpkg -l | cut -d" " -f3 | grep dialog`" ]
                    then
                        dpkg -i ${g_path}/rpms/ubuntu/core-debs/dialog_1.3-20211214-1_amd64.deb >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 3 ]
                then
                    if [ -z "`rpm -qa dialog`" ]
                    then
                        rpm -Uvh ${g_path}/rpms/rocky/core-rpms/dialog-1.3-13.20171209.el8.x86_64.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 4 ]
                then
                    :
                fi
                ;;
            sshpass)
                if [ $OS_TYPE == 1 ] || [ $OS_TYPE == 3 ]
                then
                    if [ -z "`rpm -qa sshpass`" ]
                    then
                        rpm -Uvh ${g_path}/rpms/centos/core-rpms/sshpass-1.06-2.el7.x86_64.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 2 ]
                then
                    if [ -z "`dpkg -l | cut -d" " -f3 | grep sshpass`" ]
                    then
                        :
                    fi
                elif [ $OS_TYPE == 4 ]
                then
                    :
                fi
                ;;
            wget)
                if [ $OS_TYPE == 1 ]
                then
                    if [ -z "`rpm -qa wget`" ]
                    then
                        rpm -Uvh ${g_path}/rpms/centos/core-rpms/wget-1.14-15.el7_4.1.x86_64.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 2 ]
                then
                    if [ -z "`dpkg -l | cut -d" " -f3 | grep wget`" ]
                    then
                        dpkg -i ${g_path}/rpms/ubuntu/core-debs/wget_1.14-16_amd64.deb >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 3 ]
                then
                    if [ -z "`rpm -qa wget`" ]
                    then
                        rpm -Uvh ${g_path}/rpms/rocky/core-rpms/libmetalink-0.1.3-7.el8.x86_64.rpm >> $RPM_LOG 2>&1
                        rpm -Uvh ${g_path}/rpms/rocky/core-rpms/wget-1.19.5-11.el8.x86_64.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 4 ]
                then
                    :
                fi
                ;;
            lsof)
                if [ $OS_TYPE == 1 ] || [ $OS_TYPE == 3 ]
                then
                    if [ -z "`rpm -qa lsof`" ]
                    then
                        rpm -Uvh ${g_path}/rpms/centos/core-rpms/lsof-4.87-4.el7.x86_64.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 2 ]
                then
                    if [ -z "`dpkg -l | cut -d" " -f3 | grep lsof`" ]
                    then
                        dpkg -i ${g_path}/rpms/ubuntu/core-debs/lsof_4.87-5_amd64.deb >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 4 ]
                then
                    :
                fi
                ;;
            tcpdump)
                if [ $OS_TYPE == 1 ]
                then
                    if [ -z "`rpm -qa tcpdump`" ]
                    then
                        rpm -Uvh ${g_path}/rpms/centos/tcpdump/libpcap-1.5.3-11.el7.x86_64.rpm >> $RPM_LOG 2>&1
                        rpm -Uvh ${g_path}/rpms/centos/tcpdump/tcpdump-4.9.2-3.el7.x86_64.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 2 ]
                then
                    if [ -z "`dpkg -l | cut -d" " -f3 | grep tcpdump`" ]
                    then
                        dpkg -i ${g_path}/rpms/ubuntu/tcpdump/libpcap_1.5.3-12_amd64.deb >> $RPM_LOG 2>&1
                        dpkg -i ${g_path}/rpms/ubuntu/tcpdump/tcpdump_4.9.2-4_amd64.deb >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 3 ]
                then
                    if [ -z "`rpm -qa tcpdump`" ]
                    then
                        rpm -Uvh ${g_path}/rpms/centos/tcpdump/libibverbs-46.0-1.el8.1.x86_64.rpm >> $RPM_LOG 2>&1
                        rpm -Uvh ${g_path}/rpms/centos/tcpdump/libpcap-1.9.1-5.el8.x86_64.rpm >> $RPM_LOG 2>&1
                        rpm -Uvh ${g_path}/rpms/centos/tcpdump/tcpdump-4.9.3-3.el8_9.1.x86_64.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 4 ]
                then
                    :
                fi
                ;;    
            make)
                if [ $OS_TYPE == 1 ] || [ $OS_TYPE == 3 ]
                then
                    #TODO: yum으로 기 설치된 패키지 확인하는 구문 작성필요
                    #make gcc gcc-c++ expat expat-devel java libaio ncurses
                    if [ -z "`rpm -qa make`" ]
                    then            
                        #TODO: 폐쇄망에서 설치가능하도록, 의존성파일을 수동으로 받아놓기(추후)
                        rpm -Uvh ${g_path}/rpms/centos/yum/apache/make/make-3.82-24.el7.x86_64.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 2 ]
                then
                    if [ -z "`dpkg -l | cut -d" " -f3 | grep make`" ]
                    then
                        dpkg -i ${g_path}/rpms/ubuntu/apt/apache/make/make_3.82-25_amd64.deb >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 4 ]
                then
                    :
                fi
                ;;    
            gcc) 
                if [ $OS_TYPE == 1 ]
                then
                    if [ -z "`rpm -qa gcc`" ] || [ -z "`rpm -qa gcc-c++`" ]
                    then            
                        rpm -Uvh ${g_path}/rpms/centos/yum/apache/gcc/*.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 2 ]
                then
                    if [ -z "`dpkg -l | cut -d" " -f3 | grep gcc`" ] || [ -z "`dpkg -l | cut -d" " -f3 | grep g++`" ]
                    then
                        dpkg -i ${g_path}/rpms/ubuntu/apt/apache/gcc/*.deb >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 3 ]
                then
                    if [ -z "`rpm -qa gcc`" ] || [ -z "`rpm -qa gcc-c++`" ]
                    then
                        rpm -Uvh ${g_path}/rpms/rocky/dnf/apache/gcc/*.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 4 ]
                then
                    :
                fi
                ;;  
            expat) 
                if [ $OS_TYPE == 1 ]
                then
                    if [ -z "`rpm -qa expat-devel`" ]
                    then            
                        rpm -Uvh ${g_path}/rpms/centos/yum/apache/expat/*.rpm >> $RPM_LOG 2>&1
                        rpm -Uvh ${g_path}/rpms/centos/yum/apache/expat/expat-devel-2.1.0-15.el7_9.x86_64.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 2 ]
                then
                    if [ -z "`dpkg -l | cut -d" " -f3 | grep libpcre32`" ]
                    then
                        dpkg -i ${g_path}/rpms/ubuntu/apt/apache/expat/*.deb >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 3 ]
                then
                    if [ -z "`rpm -qa expat-devel`" ]
                    then
                        rpm -Uvh ${g_path}/rpms/rocky/dnf/apache/expat/expat-devel-2.2.5-11.el8.x86_64.rpm >> $RPM_LOG 2>&1
                        rpm -Uvh ${g_path}/rpms/rocky/dnf/apache/expat/expat-2.2.5-11.el8.x86_64.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 4 ]
                then
                    :
                fi
                ;;        
            java) 
                if [ $OS_TYPE == 1 ]
                then
                    if [ -z "`rpm -qa java-1.8.0-openjdk`" ]
                    then            
                        rpm -Uvh ${g_path}/rpms/centos/yum/tomcat/java/*.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 2 ]
                then
                    if [ -z "`dpkg -l | cut -d" " -f3 | grep java-1.8.0-openjdk`" ]
                    then
                        dpkg -i ${g_path}/rpms/ubuntu/apt/tomcat/java/*.deb >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 3 ]
                then
                    if [ -z "`rpm -qa java-1.8.0-openjdk`" ]
                    then
                        rpm -Uvh ${g_path}/rpms/rocky/dnf/tomcat/java/*.rpm >> $RPM_LOG 2>&1
                    fi

                elif [ $OS_TYPE == 4 ]
                then
                    :
                fi
                ;;      
            libaio) 
                if [ $OS_TYPE == 1 ] || [ $OS_TYPE == 3 ]
                then
                    if [ -z "`rpm -qa libaio`" ]
                    then            
                        rpm -Uvh ${g_path}/rpms/centos/yum/db/libaio/libaio-0.3.109-13.el7.x86_64.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 2 ]
                then
                    if [ -z "`dpkg -l | cut -d" " -f3 | grep libaio`" ]
                    then
                        dpkg -i ${g_path}/rpms/ubuntu/apt/db/libaio_0.3.109-14_amd64.deb >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 4 ]
                then
                    :
                fi
                ;;      
            ncurses) 
                if [ $OS_TYPE == 1 ]
                then
                    if [ -z "`rpm -qa ncurses`" ]
                    then            
                        rpm -Uvh ${g_path}/rpms/centos/yum/db/ncurses/*.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 2 ]
                then
                    if [ -z "`dpkg -l | cut -d" " -f3 | grep libncurses5`" ]
                    then
                        dpkg -i ${g_path}/rpms/ubuntu/apt/db/ncurses/*.deb >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 4 ]
                then
                    :
                fi
                ;;    
            python3) 
                if [ $OS_TYPE == 1 ]
                then
                    if [ -z "`rpm -qa python3`" ]
                    then            
                        rpm -Uvh ${g_path}/rpms/centos/yum/db/python/*.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 2 ]
                then
                    if [ -z "`dpkg -l | cut -d" " -f3 | grep python3.10-dev`" ]
                    then
                        dpkg -i ${g_path}/rpms/ubuntu/apt/db/python/*.deb >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 3 ]
                then
                    if [ -z "`rpm -qa python3`" ]
                    then            
                        rpm -Uvh ${g_path}/rpms/rocky/dnf/db/python/*.rpm >> $RPM_LOG 2>&1
                    fi

                elif [ $OS_TYPE == 4 ]
                then
                    :
                fi
                ;;  
            readline-devel) 
                if [ $OS_TYPE == 1 ]
                then
                    if [ -z "`rpm -qa readline-devel`" ]
                    then            
                        rpm -Uvh ${g_path}/rpms/centos/yum/db/readline/*.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 2 ]
                then
                    if [ -z "`dpkg -l | cut -d" " -f3 | grep libreadline-dev`" ]
                    then
                        dpkg -i ${g_path}/rpms/ubuntu/apt/db/libreadline/*.deb >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 3 ]
                then
                    if [ -z "`rpm -qa readline-devel`" ]
                    then            
                        rpm -Uvh ${g_path}/rpms/rocky/dnf/db/readline/*.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 4 ]
                then
                    :
                fi
                ;;  
            zlib-devel) 
                if [ $OS_TYPE == 1 ]
                then
                    if [ -z "`rpm -qa zlib-devel`" ]
                    then            
                        rpm -Uvh ${g_path}/rpms/centos/yum/db/zlib/zlib-1.2.7-21.el7_9.i686.rpm >> $RPM_LOG 2>&1
                        rpm -Uvh ${g_path}/rpms/centos/yum/db/zlib/zlib-devel-1.2.7-21.el7_9.x86_64.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 2 ]
                then
                    if [ -z "`dpkg -l | cut -d" " -f3 | grep zlib1g-dev`" ]
                    then
                        dpkg -i ${g_path}/rpms/ubuntu/apt/db/zlib/zlib1g-dev_1%3a1.2.11.dfsg-2ubuntu9.2_amd64.deb >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 3 ]
                then
                    if [ -z "`rpm -qa zlib-devel`" ]
                    then            
                        rpm -Uvh ${g_path}/rpms/rocky/dnf/db/zlib/*.rpm >> $RPM_LOG 2>&1
                    fi
                elif [ $OS_TYPE == 4 ]
                then
                    :
                fi
                ;;
            msgfmt)
                #UbuntuS 일 경우 별도 설치
                if [ $OS_TYPE == 2 ]
                then    
                    if [ -z "`dpkg -l | cut -d" " -f3 | grep ^gettext$`" ]
                    then
                        dpkg -i ${g_path}/rpms/ubuntu/apt/db/msgfmt/libgomp1_12.3.0-1ubuntu1~22.04_amd64.deb >> $RPM_LOG 2>&1
                        dpkg -i ${g_path}/rpms/ubuntu/apt/db/msgfmt/gettext_0.21-4ubuntu4_amd64.deb >> $RPM_LOG 2>&1
                    fi
                fi
                ;; 
            compat-openssl10)
                #RockyOS일 경우 별도 설치 -> 재 확인 필요
                if [ $OS_TYPE == 3 ]
                then    
                    if [ -z "`rpm -qa compat-openssl10`" ]
                    then
                        rpm -Uvh ${g_path}/rpms/rocky/compat-openssl/*.rpm >> $RPM_LOG 2>&1
                    fi
                fi
                ;;      
        esac
    done

    Write_Log $FUNCNAME $LINENO "end"
}

function Check_Rpms_Dependency() 
{
    Write_Log $FUNCNAME $LINENO "start"

    #혹여 실패할 경우에 .chkrpms 를 삭제한다.
    if [ -f .chkrpms ] 
    then
        Write_Log $FUNCNAME $LINENO "skip check dependency rpms (.chkrpms exists)"
        return
    fi

    #OS별 추가 필수모듈이 있을경우
    if [ $OS_TYPE == 1 ]
    #CentOS
    then
        # 해당 시스템의 공개키가 누락되었을 경우 발생되는 경고 메시지가 출력 되지 않도록 key 파일 import 수행
        rpm --import /etc/pki/rpm-gpg/RPM* >> $RPM_LOG 2>&1
    elif [ $OS_TYPE == 2 ]
    #Ubuntu
    then
        CHKRPMLIST+=" msgfmt"
    elif [ $OS_TYPE == 3 ]
    #RockyOS
    then
        CHKRPMLIST+=" compat-openssl10"
    elif [ $OS_TYPE == 4 ]
    #Amazon Linux
    then
        :
    fi

    retval=0

    local Progress=0

    \cp -f /dev/null $OUTFILE

    local jump=$((100/`echo ${CHKRPMLIST} | wc -w`))

    if [ $jump -eq 0 ]
    then
        local jump=$((1000/`echo ${CHKRPMLIST} | wc -w`))
    fi

    for rpm_string in $CHKRPMLIST
    do
        MSG="Check installation : ${rpm_string}"

        Progress=$(($Progress+$jump))

        echo $Progress | dialog --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0

        #설치한 파일이 없으면 설치
        if [ $OS_TYPE == 1 ] || [ $OS_TYPE == 3 ]
        then
            if [ -z "`rpm -qa ${rpm_string}`" ]
            then
                retval=1
                echo "NOT INSTALL ( ${rpm_string} )" >> $OUTFILE
                Write_Log $FUNCNAME $LINENO "NOT INSTALL ( ${rpm_string} )"
            fi
        elif [ $OS_TYPE == 2 ]
        then        
            if [ -z "`dpkg -l | cut -d" " -f3 | grep ${rpm_string}`" ]
            then
                retval=1
                echo "NOT INSTALL ( ${rpm_string} )" >> $OUTFILE
                Write_Log $FUNCNAME $LINENO "NOT INSTALL ( ${rpm_string} )"
            fi
        fi    
    done

    if [ ${retval} -eq 1 ]
    then
        #rpm 설치
        Install_Rpms
    fi

    touch .chkrpms #상태 변수 개념.

    Write_Log $FUNCNAME $LINENO "end"
}