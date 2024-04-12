# 1. MiddleWare Installation GuideBook.
미들웨어 설치 가이드를 기술합니다.

## M/W list
|name |description |
|---|---|
|[WEB](https://github.com/chjr68/MiddleWare/tree/main/1.WEB) |Apache |
|[WAS](https://github.com/chjr68/MiddleWare/tree/master/2.WAS) |Tomcat |
|[DB](https://github.com/chjr68/MiddleWare/tree/master/3.DB) |MariaDB / MySQL / PostgreSQL |

# 2. Auto Installation Script
미들웨어 자동설치 스크립트 개발 후 업로드 예정 <br>
[작업공간](https://github.com/chjr68/MiddleWare/tree/main/Auto_Installation_MW)

## <strong>2.1. 사용법</strong> 
<details>
<summary><strong>스크립트 사용방법</strong></summary>

1. <strong>Auto_Installation_MW_V1.X.tar.gz 파일 서버에 업로드</strong> <br>
    WinSCP / FileZilla 등 프로그램 사용
2. <strong>파일 압축 해제</strong> <br>
    <img src="https://github.com/chjr68/MiddleWare/tree/main/ETC/images/2.file_list.png"> <br>
    \# tar xvf Auto_Installation_MW_V1.X.tar.gz
3. <strong>InstallMW 스크립트 실행</strong> <br>
    \# ./InstallMW
4. <strong>(최초 1회) 필수 라이브러리/자주 사용되는 명령어 설치</strong> <br>
    <img src="https://github.com/chjr68/MiddleWare/tree/main/ETC/images/4.first_execute"> <br>
    자주 사용되는 명령어 설치 (tcpdump, sshpass, net-tools, wget) <br>
    미들웨어 필수 라이브러리 설치 (gcc, make, expat, java, python 등)

5. <strong>메뉴 선택</strong> <br>
    <img src="https://github.com/chjr68/MiddleWare/tree/main/ETC/images/5.menu_list"> <br>
    1) Install Middleware: 미들웨어 설치 <br>
    2) Show Version: 설치된 미들웨어 버전 정보 확인 <br>
    3) Utils (추후): mod.jk 연동 등 <br>
    4) Security Setting (추후): 미들웨어 취약점 조치 <br>
    5) Uninstall: 설치된 미들웨어 삭제 <br>

6. <strong>설치 타입 선택</strong> <br>
    <img src="https://github.com/chjr68/MiddleWare/tree/main/ETC/images/6.install_type"> <br>
    1) Package: 지정된 경로에 업로드된 패키지를 사용해 설치(폐쇄망)
        <details>
        <summary><strong>※ Package 업로드 시, 지원형식에 유의</strong></summary>
        <img src="https://github.com/chjr68/MiddleWare/tree/main/ETC/images/6.file_format">
        </details>
    2) Wget: 사용자에게 버전입력을 받아 wget으로 파일 다운로드 후 자동 설치(온라인)
7. <strong>설치</strong> <br>
    <img src="https://github.com/chjr68/MiddleWare/tree/main/ETC/images/7.menu_install_procedure"> <br>
8. <strong>확인</strong> <br>
    <img src="https://github.com/chjr68/MiddleWare/tree/main/ETC/images/8.install_check">
</details>

## <strong>2.2. 가이드</strong> 
### 지원OS
1. CentOS 7 <br>
2. Ubuntu 22.04 <br>
3. RockyOS 8

### 지원 미들웨어 버전 (메이저 버전 기준) <br>
- Httpd V2.0 이상 <br>
(V2.3은 Beta 패키지로 설치 불가)
- Tomcat V7.0 이상
- MariaDB V10 이상
- MySQL V5.7 이상
- PostgreSQL V10 이상

### 서비스 명 / 계정 명
- WEB <br>
Apache: httpd
- WAS <br>
Tomcat: tomcat
- DB <br>
MariaDB: mariadb / maria <br>
MySQL: mysql / mysql (패스워드 경로: /data/mysql/.passwd) <br>
PostgreSQL: postgres / postgres

### 제약사항
- AWS 환경에서 생성된 VM한정 (타 CSP 검증 안됨)
- 설치 후 <strong>`source /etc/profile`</strong> 실행 (PATH 적용 필요)
- 지원 OS버전 확인
- 지원 미들웨어버전 확인
- 지정된 파일 형식 / 업로드 디렉토리 준수
- 설치 서버의 쉘 여러 개로 동시 작업 X

## <strong>2.3. 예상 구현 기능</strong>
- 다이얼로그 기반 자동 설치 스크립트(GUI)
- 사용자가 패키지 다운로드 및 저장위치에 업로드하여 기본 패키지 버전 선택 <br>
※ 버전 별 호환성까지 검증하진 않음.
- Install / Uninstall / Config / Log Level / 설치 경로 입력 / 취약점(추후) 고려
## <strong>2.4. 패키지  (23년 12월 기준)</strong>
    ※유의사항※

    > 파일은 tar.gz 확장자로 다운로드
    > 파일 포맷 준수
    > 업로드 경로 준수

|Type |URL |Format |Path |
|---|---|---|---|
|apache |http://archive.apache.org/dist/httpd/ |httpd-2.4.46.tar.gz |package\1.WEB |
|apr/apr-util |https://dlcdn.apache.org/apr/ |apr-1.7.4.tar.gz <br>apr-util-1.6.3.tar.gz |package\module |
|pcre |https://sourceforge.net/projects/pcre/files/pcre/ |pcre-8.45.tar.gz |package\module |
|tomcat |http://archive.apache.org/dist/tomcat/ |apache-tomcat-8.5.92.tar.gz |package\2.WAS |
|mariadb |https://downloads.mariadb.com/MariaDB/ |mariadb-2.13.4-linux-systemd-x86_64.tar.gz |package\3.DB\MariaDB |
|mysql |https://downloads.mysql.com/archives/community/ |mysql-1.2.3-el7-x86_64.tar.gz |package\3.DB\MySQL |
|postgresql |https://www.postgresql.org/ftp/source/ |postgresql-12.5.tar.gz |package\3.DB\PostgreSQL |

# <strong>3. TODO List (24년 계획)</strong>
    ※ 우선순위에 따라 계획 수립
       공수에 비해 효율이 낮다고 판단되는 기능은 검토 or 추후 개발
1. <del>OS 확장 (완료)</del> <br>
\- Ubuntu 22.04<br>
\- RockyOS 8

2. Progress Bar <br>
\- 좀 더 가시성 있게 진행률 체크할 수 있는 방법 검토 <br>
\- 빌드 > 컴파일 > 설치 과정을 볼 수 있게 <br>
\- 단순히 설치만 하는 DB는 임시로 50%로 넘어가게 하드코딩 <br>
(db설치 스크립트 파일마다 함수를 만들어서 진행률에 반영할 수 있지만 비효율적으로 보임)

3. 파일 다운로드 자동화 <br>
\- wget 활용하여 파일 다운로드 자동화 <br>
\- (기존) 패키지 다운로드 후 지정된 경로에 업로드하여 설치 <br>
\- (추가) Install Type을 추가하여 기존 업로드 설치 기능 외 wget 옵션 제공 <br>

4. 취약점 조치 (추후) <br>
\- MiddleWare 기본 취약점 조치

5. Utils (추후) <br>
\- WEB <> WAS 자동 연동 (mod_jk) <br>
\- WAS <> DB 자동 연동 <br>
\- Session Clustering

# BUGS
Please report bugs to me

# AUTHOR

Kim JiHwan, <chjr68@naver.com>

