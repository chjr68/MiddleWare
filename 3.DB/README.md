# DB Installation GuideBook. (Manually)
DB 수동 설치 가이드를 기술합니다.

## 카테고리
1. MariaDB
2. MySQL
3. PostgreSQL

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
- 설치 버전 : MariaDB 10.x.x
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
\# yum -y install wget libaio ncurses*

## 3. 패키지 다운로드
※ 버전 다를 경우, 아래 경로 수정 후 입력

- MariaDB 다운로드 <br>
\# wget `https://downloads.mariadb.com/MariaDB/mariadb-10.2.41/bintar-linux-systemd-x86_64/`

## 4. 설치
- config 설정, install

- 환경변수 설정 <br>
\# vi /etc/profile 경로 추가 <br>
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-devel.x86_64

- 패키지 압축 해제 (경로 확인) <br>
\# tar zxvf "패키지 명"

- 디렉토리 명 변경 <br>
\# mv mariadb-10.2.41-linux-systemd-x86_64 mariadb <br>
\# cd mariadb

- 사용자 / 디렉토리 생성 <br>
\# groupadd maria
\# useradd -g maria maria
 <br>
\# mkdir -p /data/mariadb/master <br>
\# mkdir -p /data/mariadb/ibdata <br>
\# mkdir -p /data/mariadb/iblog <br>
\# mkdir -p /data/mariadb/log-bin <br>
\# chown -R mariadb.mariadb /data/mariadb <br>
 <br>
\# touch /var/log/mariadb.log <br>
\# chmod 644 /var/log/mariadb.log <br>
\# chown mysql:mysql /var/log/mariadb.log <br>

- 심볼릭 링크 <br>
\# ln -s mariadb /usr/local/mysql

- MariaDB 설정 <br>
\# vi /etc/my.cnf <br>
 <br>
아래내용 추가 <br>
 <br>
\# Mariadb <br>
[server] <br>
 <br>
\# mysqld standalone daemon <br>
[mysqld] <br>
port                            = 3306 <br>
datadir                         = /data/mariadb/master <br>
socket                          = /tmp/mysql.sock <br>
 <br>
\# Character set (utf8mb4) <br>
character_set-client-handshake  = FALSE <br>
character-set-server            = utf8mb4 <br>
collation_server                = utf8mb4_general_ci <br>
init_connect                    = set collation_connection=utf8mb4_general_ci <br>
init_connect                    = set names utf8mb4 <br>
 <br>
\# Common <br>
table_open_cache                = 2048 <br>
max_allowed_packet              = 32M <br>
binlog_cache_size               = 1M <br>
max_heap_table_size             = 64M <br>
read_buffer_size                = 64M <br>
read_rnd_buffer_size            = 16M <br>
sort_buffer_size                = 8M <br>
join_buffer_size                = 8M <br>
ft_min_word_len                 = 4 <br>
lower_case_table_names          = 1 <br>
default-storage-engine          = innodb <br>
thread_stack                    = 240K <br>
transaction_isolation           = READ-COMMITTED <br>
tmp_table_size                  = 32M <br>
 <br>
\# Connection <br>
max_connections                 = 200 <br>
max_connect_errors              = 50 <br>
back_log                        = 100 <br>
thread_cache_size               = 100 <br>
 <br>
\# Query Cache <br>
query_cache_size                = 32M <br>
query_cache_limit               = 2M <br>
 <br>
log-bin                         = /data/mariadb/log-bin/mysql-bin <br>
 <br>
:wq

- 초기화 <br>
\# cd /usr/local/src/mariadb/scripts <br>
\# ./mysql_install_db --user=mysql --basedir=/usr/local/src/mariadb --datadir=/data/mariadb/master --defaults-file=/etc/my.cnf

## 5. 서비스 등록
- 서비스 등록 <br>
\# cd support-files/ <br>
\# cp mysql.server /etc/init.d/mariadb.service <br>
\# vi /etc/init.d/mariadb.service <br>
 <br>
경로설정 <br>
basedir=/usr/local/src/mariadb <br>
datadir=/data/mariadb/master <br>
 <br>
\# vi /etc/profile <br>
\# export PATH=${PATH}:/usr/local/src/mariadb/bin <br>
 <br>
\# source /etc/profile <br>
 <br>
\# \cp -f /usr/local/src/mariadb/support-files/systemd/mariadb.service /etc/systemd/system/mariadb.service
 <br>
\# vi /etc/systemd/system/mariadb.service <br>
 <br>
내용변경 <br>
User=maria <br>
Group=maria

## 6. 서비스 로드 / 시작
- 서비스 시작 <br>
\# systemctl start mariadb

## 7. 별첨

# BUGS
Please report bugs to me

# AUTHOR

Kim JiHwan, <chjr68@naver.com>