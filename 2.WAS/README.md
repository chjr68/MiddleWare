# Tomcat Installation GuideBook. (Manually)
Tomcat 수동 설치 가이드를 기술합니다.


## 목차
1. 사전준비
2. 모듈 설치
3. 패키지 다운로드
4. 미들웨어 설치
5. 서비스 등록
6. 서비스 시작
7. 별첨

## 1. 사전준비
- 작업 환경 : CentOS
- 설치 버전 : Tomcat 8.5 / 8.0
- 설치 경로 : /usr/local/src
- 인터넷 통신 : O <br>
(불가한 환경일 경우, 아래 모듈과 패키지 파일을 따로 받아서 업로드 후 진행)
- selinux 해제 <br>
\# sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config <br>
\# reboot <br>
\# getenforce (Disabled 출력 확인)
- root 권한사용 <br>
\# sudo -i
## 2. 모듈 설치
- 모듈 설치 리스트, 환경변수 설정 등

- 패키지, 소스 코드 컴파일 명령어 설치<br>
\# yum -y install wget make
- 자바 설치 <br>
\# yum -y install java-1.8.0-openjdk-devel.x86_64

## 3. 패키지 다운로드
※ 버전 다를 경우, 아래 경로 수정 후 입력

- Apache 다운로드 <br>
\# wget `https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.92/bin/apache-tomcat-8.5.92.tar.gz`

## 4. 설치
- config 설정, configure/make/make install

- 환경변수 설정 <br>
\# vi /etc/profile 경로 추가 <br>
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-devel.x86_64

- 패키지 압축 해제 (경로 확인) <br>
\# tar zxvf "패키지 명"

- tomcat 설치 <br>
별도 설치 필요없음.

## 5. 서비스 등록
- 서비스 등록 <br>
\# vi /etc/systemd/system/tomcat.service <br>

- 아래내용 추가 (주석 포함)
&nbsp; <br><br>
\# Systemd unit file for tomcat <br>
[Unit] <br>
Description=Apache Tomcat Web Application Container <br>
After=syslog.target network.target
 <br> <br>
[Service] <br>
Type=forking
 <br> <br>
Environment="JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-devel.x86_64"
Environment="CATALINA_HOME=/usr/local/src/apache-tomcat-8.5.92"
Environment="CATALINA_BASE=/usr/local/src/apache-tomcat-8.5.92"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
 <br> <br>
ExecStart=/usr/local/src/apache-tomcat-8.5.92/bin/startup.sh <br>
ExecStop=/usr/local/src/apache-tomcat-8.5.92/bin/shutdown.sh
 <br> <br>
User=root <br>
Group=root <br>
UMask=0007 <br>
RestartSec=10 <br>
Restart=always
 <br> <br>
[Install] <br>
WantedBy=multi-user.target <br>
 <br>
:wq
&nbsp; <br><br>


## 6. 서비스 로드 / 시작
- 서비스 시작 <br>
\# systemctl daemon-reload <br>
\# systemctl enable tomcat

## 7. 별첨

- configure 옵션 잘못 줬을 때 초기화 방법 <br>
\# make distclean
- [WEB <> WAS / WAS <> DB 연동방법](https://github.com/chjr68/MiddleWare/tree/master/ETC)


# BUGS
Please report bugs to me

# AUTHOR

Kim JiHwan, <chjr68@naver.com>


