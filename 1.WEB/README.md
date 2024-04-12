# Apache Installation GuideBook. (Manually)
Apache 수동 설치 가이드를 기술합니다.


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
- 설치 버전 : Apache 2.4.46
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
- 컴파일러 설치 <br>
\# yum -y install gcc gcc-c++
- xml parser 설치 (expat) <br>
\# yum -y install expat expat-devel expat-static

## 3. 패키지 다운로드
※ 버전 다를 경우, 아래 경로 수정 후 입력

- pcre 다운로드 <br> 
정규식 패턴 일치를 구현하는 함수<br>
\# wget `https://sourceforge.net/projects/pcre/files/pcre/8.45/pcre-8.45.tar.gz/download`

- apr/apr-util 다운로드 <br>
Apache Portable Runtime, 고급 IO 기능/기본 프로세스 처리 기능 등 제공 <br>
\# wget `https://dlcdn.apache.org//apr/apr-1.7.4.tar.gz` <br>
\# wget `https://dlcdn.apache.org//apr/apr-util-1.6.3.tar.gz`

- Apache 다운로드 <br>
\# wget `http://archive.apache.org/dist/httpd/httpd-2.4.46.tar.gz`


## 4. 설치
- config 설정, configure/make/make install

- 패키지 압축 해제 (경로 확인) <br>
\# tar zxvf "패키지 명"

- pcre 설치 <br>
\# cd /usr/local/src/pcre-8.45/ <br>
\# ./configure --prefix=/usr/local/src/pcre-8.45/ <br>
\# make && make install

- apr/apr-util 설치 <br>
\# cd /usr/local/src/apr-1.7.4 <br>
\# ./configure --prefix=/usr/local/src/apr <br>
\# make && make install 
&nbsp; <br><br>
\# cd /usr/local/src/apr-util-1.6.3 <br>
\# ./configure --prefix=/usr/local/src/apr-util --with-apr=/usr/local/src/apr <br>
\# make && make install <br>

- apache 설치 <br>
\# ./configure --prefix=/usr/local/src/apache2.4 \\ <br>
--enable-module=so --enable-rewrite --enable-so \\ <br>
--with-apr=/usr/local/src/apr \\ <br>
--with-apr-util=/usr/local/src/apr-util \\ <br>
--with-pcre=/usr/local/src/pcre-8.45/bin/pcre-config \\ <br>
--enable-mods-shared=all <br>
\# make && make install

## 5. 서비스 등록
- 서비스 등록 <br>
\# cp /usr/local/src/apache2.4/bin/apachectl /etc/init.d/httpd <br>
\# vi /etc/init.d/httpd<br>
아래내용 추가 (주석 포함)
&nbsp; <br><br>
\# chkconfig: 2345 90 90 <br>
\# description: init file for Apache server daemon <br>
\# processname: /usr/local/src/apache2.4/bin/apachectl <br>
\# config: /usr/local/src/apache2.4/conf/httpd.conf <br>
\# pidfile: /usr/local/src/apache2.4/logs/httpd.pid <br>
:wq
&nbsp; <br><br>
\# chkconfig --add httpd

## 6. 서비스 시작
- 서비스 시작 <br>
\# systemctl start httpd

## 7. 별첨

- configure 옵션 잘못 줬을 때 초기화 방법 <br>
\# make distclean
- [WEB <> WAS / WAS <> DB 연동방법](https://github.com/chjr68/MiddleWare/tree/master/ETC)


# BUGS
Please report bugs to me

# AUTHOR

Kim JiHwan, <chjr68@naver.com>

