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

function Decompress_Rpms()
{
    Write_Log $FUNCNAME $LINENO "start"

    # rpms.tar.gz 압축파일 해제
    tar zxf ${g_path}/rpms.tar.gz -C ${g_path}/

    Write_Log $FUNCNAME $LINENO "end"
}

#용량 확보
function Delete_Rpms_Directory()
{
    Write_Log $FUNCNAME $LINENO "start"
    
    # rpms.tar.gz 해제 파일 삭제
    rm -rf ${g_path}/rpms

    #WEB module 압축 해제 디렉토리 삭제
    ls -l ${g_path}/package/module | grep ^d | awk '{print $NF}' | xargs rm -rf

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

    # 해당 시스템의 공개키가 누락되었을 경우 발생되는 경고 메시지가 출력 되지 않도록 key 파일 import 수행
    rpm --import /etc/pki/rpm-gpg/RPM* >> $RPM_LOG 2>&1

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
                if [ -z "`rpm -qa net-tools`" ]
                then
                    rpm -Uvh ${g_path}/rpms/core-rpms/net-tools-2.0-0.22.20131004git.el7.x86_64.rpm   >> $RPM_LOG 2>&1
                fi
                ;;
            tcpdump)
                if [ -z "`rpm -qa tcpdump`" ]
                then
                    rpm -Uvh ${g_path}/rpms/tcpdump/libpcap-1.5.3-11.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/tcpdump/tcpdump-4.9.2-3.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            dialog)
                if [ -z "`rpm -qa dialog`"  ]
                then
                    rpm -Uvh ${g_path}/rpms/core-rpms/dialog-1.2-4.20130523.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            ntpdate)
                if [ -z "`rpm -qa ntpdate`" ]
                then
                    rpm -Uvh ${g_path}/rpms/ntp/ntpdate-4.2.6p5-28.el7.centos.x86_64.rpm --nodeps  >> $RPM_LOG 2>&1
                fi
                ;;
            rdate)
                if [ -z "`rpm -qa rdate`"   ]
                then
                    rpm -Uvh ${g_path}/rpms/ntp/rdate-1.4-25.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            ntp)
                if [ -z "`rpm -qa ntp`" ]
                then
                    rpm -Uvh ${g_path}/rpms/ntp/ntpdate-4.2.6p5-28.el7.centos.x86_64.rpm --nodeps  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/ntp/autogen-libopts-5.18-5.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/ntp/ntp-4.2.6p5-28.el7.centos.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            sshpass)
                if [ -z "`rpm -qa sshpass`" ]
                then
                    rpm -Uvh ${g_path}/rpms/core-rpms/sshpass-1.06-2.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            gdb)
                if [ -z "`rpm -qa gdb`" ]
                then
                    rpm -Uvh ${g_path}/rpms/core-rpms/gdb-7.6.1-110.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            wget)
                if [ -z "`rpm -qa wget`" ]
                then
                    rpm -Uvh ${g_path}/rpms/core-rpms/wget-1.14-15.el7_4.1.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            lsof)
                if [ -z "`rpm -qa lsof`" ]
                then
                    rpm -Uvh ${g_path}/rpms/core-rpms/lsof-4.87-4.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            ipmitool)
                if [ -z "`rpm -qa ipmitool`" ]
                then
                    rpm -Uvh ${g_path}/rpms/ipmitool/net-snmp-libs-5.7.2-49.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                         
                    rpm -Uvh ${g_path}/rpms/ipmitool/OpenIPMI-2.0.27-1.el7.x86_64.rpm --nodeps  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/ipmitool/OpenIPMI-libs-2.0.27-1.el7.x86_64.rpm --nodeps  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/ipmitool/OpenIPMI-modalias-2.0.27-1.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/ipmitool/ipmitool-1.8.18-9.el7_7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;             
            ldap)
                if [ -z "`rpm -qa openldap-servers-sql`" ]
                then            
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/ldap/openldap-2.4.44-23.el7_9.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/ldap/compat-openldap-2.3.43-5.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/ldap/openldap-clients-2.4.44-23.el7_9.x86_64.rpm  >> $RPM_LOG 2>&1

                    rpm -Uvh ${g_path}/rpms/mf_authenticate/ldap/libtool-ltdl-2.4.2-22.el7_3.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/ldap/openldap-servers-2.4.44-23.el7_9.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/ldap/unixODBC-2.3.1-14.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/ldap/cyrus-sasl-lib-2.1.26-23.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/ldap/cyrus-sasl-2.1.26-23.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/ldap/cyrus-sasl-devel-2.1.26-23.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/ldap/openldap-devel-2.4.44-23.el7_9.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/ldap/openldap-servers-sql-2.4.44-23.el7_9.x86_64.rpm  >> $RPM_LOG 2>&1                 
                fi					
                ;;   
            radius)
                if [ -z "`rpm -qa freeradius-utils`" ]
                then            
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/radius/libtalloc-2.1.16-1.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/radius/apr-1.4.8-7.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/radius/boost-system-1.53.0-28.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/radius/apr-util-1.5.2-6.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/radius/xerces-c-3.1.1-10.el7_7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/radius/log4cxx-0.10.0-16.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/radius/boost-thread-1.53.0-28.el7.x86_64.rpm  >> $RPM_LOG 2>&1  
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/radius/tncfhh-utils-0.8.3-16.el7.x86_64.rpm  >> $RPM_LOG 2>&1 
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/radius/tncfhh-0.8.3-16.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/radius/tncfhh-libs-0.8.3-16.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/radius/freeradius-3.0.13-15.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/radius/freeradius-utils-3.0.13-15.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;   
            tacacs)
                if [ -z "`rpm -qa tac_plus`" ]
                then            
                    rpm -Uvh ${g_path}/rpms/mf_authenticate/tacacs/tac_plus-4.0.4.26-1.el6.nux.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            make)
                #TODO: yum으로 기 설치된 패키지 확인하는 구문 작성필요
                #make gcc gcc-c++ expat expat-devel java libaio ncurses
                if [ -z "`rpm -qa make`" ]
                then            
                    #TODO: 폐쇄망에서 설치가능하도록, 의존성파일을 수동으로 받아놓기(추후)
                    yum -y install make >> $RPM_LOG 2>&1
                fi
                ;;    
            gcc) 
                if [ -z "`rpm -qa gcc`" ]
                then            
                    yum -y install gcc gcc-c++ >> $RPM_LOG 2>&1
                fi
                ;;  
            gcc-c++) 
            if [ -z "`rpm -qa gcc-c++`" ]
            then            
                yum -y install gcc-c++ >> $RPM_LOG 2>&1
            fi
            ;;  
            expat) 
                if [ -z "`rpm -qa expat`" ]
                then            
                    yum -y install expat >> $RPM_LOG 2>&1
                fi
                ;;      
            expat-devel) 
                if [ -z "`rpm -qa expat-devel`" ]
                then            
                    yum -y install expat-devel >> $RPM_LOG 2>&1
                fi
                ;;      
            java) 
                if [ -z "`rpm -qa java-11-openjdk`" ]
                then            
                    yum -y install java-1.8.0-openjdk-devel.x86_64
                fi
                ;;      
            libaio) 
                if [ -z "`rpm -qa libaio`" ]
                then            
                    yum -y install libaio >> $RPM_LOG 2>&1
                fi
                ;;      
            ncurses) 
                if [ -z "`rpm -qa ncurses`" ]
                then            
                    yum -y install ncurses* >> $RPM_LOG 2>&1
                fi
                ;;    
            python3) 
                if [ -z "`rpm -qa python3`" ]
                then            
                    yum -y install python3 >> $RPM_LOG 2>&1
                fi
                ;;  
            python3-devel) 
                if [ -z "`rpm -qa python3-devel`" ]
                then            
                    yum -y install python3-devel >> $RPM_LOG 2>&1
                fi
                ;;  
            readline-devel) 
                if [ -z "`rpm -qa readline-devel`" ]
                then            
                    yum -y install readline-devel >> $RPM_LOG 2>&1
                fi
                ;;  
            zlib-devel) 
                if [ -z "`rpm -qa zlib-devel`" ]
                then            
                    yum -y install zlib-devel >> $RPM_LOG 2>&1
                fi
                ;;  
        esac
    done

    if [ $Progress -ne 100 ]
    then
        Progress=100        
        echo $Progress | tms_progress --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    fi

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

        if [ -z "`rpm -qa ${rpm_string}`" ]
        then
            retval=1
            echo "NOT INSTALL ( ${rpm_string} )" >> $OUTFILE
            Write_Log $FUNCNAME $LINENO "NOT INSTALL ( ${rpm_string} )"

            #설치한 파일이 없으면, 표준버전은 설치
        fi
    done

    if [ $Progress -ne 100 ]
    then
        Progress=100        
        echo $Progress | tms_progress --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0
    fi

    if [ ${retval} -eq 1 ]
    then
        #rpm 설치
        Install_Rpms
    fi

    touch .chkrpms #상태 변수 개념.

    Write_Log $FUNCNAME $LINENO "end"
}

