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

    Write_Log $FUNCNAME $LINENO "end"
}

function Install_Rpms()
{
    Write_Log $FUNCNAME $LINENO "start"

    local Progress=0

    #진행과정 로딩바 출력
    local jump=$((100/`echo ${CHKRPMLIST} |wc -w`))

    if [ $jump -eq 0 ]
    then
        local jump=$((1000/`echo ${CHKRPMLIST} |wc -w`))
    fi

    # 해당 시스템의 공개키가 누락되었을 경우 발생되는 경고 메시지가 출력 되지 않도록 key 파일 import 수행
    rpm --import /etc/pki/rpm-gpg/RPM* >> $RPM_LOG 2>&1

    for rpm_string in $CHKRPMLIST
    do
        MSG="Install RPM : ${rpm_string}"

        Write_Log $FUNCNAME $LINENO "${MSG}"

        Progress=$(($Progress+$jump))
        
        echo $Progress | tms_progress --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0

        #TODO: 불필요 rpm 구문 삭제, 전역변수 파일 CHKRPMLIST 내용도 수정
        case ${rpm_string} in
            perl)
                # perl-lib 설치 확인 후 perl 설치 수행
                if [ -z "`rpm -qa perl-libs`" ]
                then
                    # perl 은 경로에 존재하는 모든 rpm 파일을 설치하는 방법 수행
                    rpm -Uvh --replacefiles --replacepkgs ${g_path}/RPMS/perl/*.rpm  >> $RPM_LOG 2>&1 
                fi
                ;;
            net-tools)
                if [ -z "`rpm -qa net-tools`" ]
                then
                    rpm -Uvh ${g_path}/RPMS/core-rpms/net-tools-2.0-0.22.20131004git.el7.x86_64.rpm   >> $RPM_LOG 2>&1
                fi
                ;;
            ntsysv)
                if [ -z "`rpm -qa ntsysv`"    ]
                then
                    rpm -Uvh ${g_path}/RPMS/core-rpms/ntsysv-1.7.4-1.el7.x86_64.rpm  >> $RPM_LOG 2>&1 
                fi
                ;;
            tcpdump)
                if [ -z "`rpm -qa tcpdump`" ]
                then
                    rpm -Uvh ${g_path}/RPMS/tcpdump/libpcap-1.5.3-11.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/tcpdump/tcpdump-4.9.2-3.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            policycoreutils)
                if [ -z "`rpm -qa policycoreutils`" ]
                then
                    rpm -Uvh ${g_path}/RPMS/policy-core-utils/libselinux-2.5-12.el7.x86_64.rpm   >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/policy-core-utils/libselinux-python-2.5-12.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/policy-core-utils/libselinux-utils-2.5-12.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/policy-core-utils/libsepol-2.5-8.1.el7.x86_64.rpm   >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/policy-core-utils/policycoreutils-2.5-22.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            dialog)
                if [ -z "`rpm -qa dialog`"  ]
                then
                    rpm -Uvh ${g_path}/RPMS/core-rpms/dialog-1.2-4.20130523.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            ntpdate)
                if [ -z "`rpm -qa ntpdate`" ]
                then
                    rpm -Uvh ${g_path}/RPMS/ntp/ntpdate-4.2.6p5-28.el7.centos.x86_64.rpm --nodeps  >> $RPM_LOG 2>&1
                fi
                ;;
            rdate)
                if [ -z "`rpm -qa rdate`"   ]
                then
                    rpm -Uvh ${g_path}/RPMS/ntp/rdate-1.4-25.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            pcituils)
                if [ -z "`rpm -qa pciutils`" ]
                then
                    rpm -Uvh ${g_path}/RPMS/core-rpms/pciutils-libs-3.5.1-3.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/core-rpms/pciutils-3.5.1-3.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            smartmontools)
                if [ -z "`rpm -qa smartmontools`" ]
                then
                    rpm -Uvh ${g_path}/RPMS/core-rpms/mailx-12.5-19.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/core-rpms/smartmontools-6.5-1.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            fontconfig)
                if [ -z "`rpm -qa fontconfig`" ]
                then
                    rpm -Uvh ${g_path}/RPMS/fontconfig/fontpackages-filesystem-1.44-8.el7.noarch.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/fontconfig/stix-fonts-1.1.0-5.el7.noarch.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/fontconfig/fontconfig-2.10.95-11.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            ntp)
                if [ -z "`rpm -qa ntp`" ]
                then
                    rpm -Uvh ${g_path}/RPMS/ntp/ntpdate-4.2.6p5-28.el7.centos.x86_64.rpm --nodeps  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/ntp/autogen-libopts-5.18-5.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/ntp/ntp-4.2.6p5-28.el7.centos.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            sshpass)
                if [ -z "`rpm -qa sshpass`" ]
                then
                    rpm -Uvh ${g_path}/RPMS/core-rpms/sshpass-1.06-2.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            gdb)
                if [ -z "`rpm -qa gdb`" ]
                then
                    rpm -Uvh ${g_path}/RPMS/core-rpms/gdb-7.6.1-110.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            wget)
                if [ -z "`rpm -qa wget`" ]
                then
                    rpm -Uvh ${g_path}/RPMS/core-rpms/wget-1.14-15.el7_4.1.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            iptables-services) #2021.08.20 iptable 없음.
                if [ -z "`rpm -qa iptables-services`" ]
                then
                    # iptables 설치 후 iptables-services 설치 필요
                    rpm -Uvh ${g_path}/RPMS/core-rpms/iptables-1.4.21-28.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/core-rpms/iptables-services-1.4.21-28.el7.x86_64.rpm --nodeps  >> $RPM_LOG 2>&1
                fi
                ;;
            lsof)
                if [ -z "`rpm -qa lsof`" ]
                then
                    rpm -Uvh ${g_path}/RPMS/core-rpms/lsof-4.87-4.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            ipmitool)
                if [ -z "`rpm -qa ipmitool`" ]
                then
                    rpm -Uvh ${g_path}/RPMS/ipmitool/net-snmp-libs-5.7.2-49.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                         
                    rpm -Uvh ${g_path}/RPMS/ipmitool/OpenIPMI-2.0.27-1.el7.x86_64.rpm --nodeps  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/ipmitool/OpenIPMI-libs-2.0.27-1.el7.x86_64.rpm --nodeps  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/ipmitool/OpenIPMI-modalias-2.0.27-1.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/ipmitool/ipmitool-1.8.18-9.el7_7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;             
            ldap)
                if [ -z "`rpm -qa openldap-servers-sql`" ]
                then            
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/ldap/openldap-2.4.44-23.el7_9.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/ldap/compat-openldap-2.3.43-5.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/ldap/openldap-clients-2.4.44-23.el7_9.x86_64.rpm  >> $RPM_LOG 2>&1

                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/ldap/libtool-ltdl-2.4.2-22.el7_3.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/ldap/openldap-servers-2.4.44-23.el7_9.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/ldap/unixODBC-2.3.1-14.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/ldap/cyrus-sasl-lib-2.1.26-23.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/ldap/cyrus-sasl-2.1.26-23.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/ldap/cyrus-sasl-devel-2.1.26-23.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/ldap/openldap-devel-2.4.44-23.el7_9.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/ldap/openldap-servers-sql-2.4.44-23.el7_9.x86_64.rpm  >> $RPM_LOG 2>&1                 
                fi					
                ;;   
            radius)
                if [ -z "`rpm -qa freeradius-utils`" ]
                then            
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/radius/libtalloc-2.1.16-1.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/radius/apr-1.4.8-7.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/radius/boost-system-1.53.0-28.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/radius/apr-util-1.5.2-6.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/radius/xerces-c-3.1.1-10.el7_7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/radius/log4cxx-0.10.0-16.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/radius/boost-thread-1.53.0-28.el7.x86_64.rpm  >> $RPM_LOG 2>&1  
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/radius/tncfhh-utils-0.8.3-16.el7.x86_64.rpm  >> $RPM_LOG 2>&1 
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/radius/tncfhh-0.8.3-16.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/radius/tncfhh-libs-0.8.3-16.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/radius/freeradius-3.0.13-15.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/radius/freeradius-utils-3.0.13-15.el7.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;   
            tacacs)
                if [ -z "`rpm -qa tac_plus`" ]
                then            
                    rpm -Uvh ${g_path}/RPMS/mf_authenticate/tacacs/tac_plus-4.0.4.26-1.el6.nux.x86_64.rpm  >> $RPM_LOG 2>&1
                fi
                ;;
            MegaCli)
                # 서버 HDD 상태 정보 수집을 위한 MegaCli rpm 설치
                if [ -z "`rpm -qa MegaCli`" ]
                then
                    rpm -Uvh ${g_path}/RPMS/MegaCli/MegaCli-8.07.14-1.noarch.rpm  >> $RPM_LOG 2>&1
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

    local jump=$((100/`echo ${CHKRPMLIST} |wc -w`))

    if [ $jump -eq 0 ]
    then
        local jump=$((1000/`echo ${CHKRPMLIST} |wc -w`))
    fi

    for rpm_string in $CHKRPMLIST
    do
        MSG="Check installation : ${rpm_string}"

        Progress=$(($Progress+$jump))

        echo $Progress | tms_progress --backtitle "${BACKTITLE}" --title "${TITLE}" --gauge "Please wait...\n $MSG" 10 70 0

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


