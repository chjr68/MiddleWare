# 1. MiddleWare Installation GuideBook. (Manually)
미들웨어 수동 설치 가이드를 기술합니다.

## M/W list
|name |description |
|---|---|
|[WEB](https://github.com/chjr68/MiddleWare/tree/main/1.WEB) |Apache |
|[WAS](https://github.com/chjr68/MiddleWare/tree/master/2.WAS) |Tomcat |
|[DB](https://github.com/chjr68/MiddleWare/tree/master/3.DB) |MariaDB |

# 2. Auto Installation Script
미들웨어 자동설치 스크립트 개발 후 업로드 예정 <br>
[작업공간](https://github.com/chjr68/MiddleWare/tree/main/Auto_Installation_MW_Proto)

1. <strong>OS</strong> 
- CentOS <br>
RockyOS(추후)
2. <strong>3-tier</strong>
- Apache / Tomcat / MariaDB / MySQL / PostgreSQL
3. <strong>예상 구현 기능</strong>
- 다이얼로그 기반 자동 설치 스크립트(GUI)
- 사용자가 패키지 다운로드 및 저장위치에 업로드하여 기본 패키지 버전 선택 <br>
※ 버전 별 호환성까지 검증하진 않음.
- Install / Uninstall / Config / Log Level / 설치 경로 입력 / 취약점(추후) 고려
4. <strong>패키지 다운로드 경로 (23년 12월 기준)</strong>
    * ※ 파일은 tar.gz 확장자로 다운로드
    * 4.1 Apache <br>
    httpd: http://archive.apache.org/dist/httpd/ <br>
    apr / apr-util: https://dlcdn.apache.org/apr/ <br>
    pcre: https://sourceforge.net/projects/pcre/files/pcre/
    httpd v2.4 / v2.2 지원, v2.3 불가
    * 4.2 Tomcat <br>
    tomcat: http://archive.apache.org/dist/tomcat/tomcat-8/
    * 4.3 MariaDB <br>
    mariadb: https://downloads.mariadb.com/MariaDB/ <br>
    <strong>systemd</strong> 파일 형식만 호환 가능 <br>
    ex) mariadb-10.2.41-linux-<strong>systemd</strong>-x86_64.tar.gz
    * 4.4 MySQL <br>
    mysql: https://downloads.mysql.com/archives/community/ <br>
    <strong>엔터프라이즈 리눅스(el)</strong> 형식만 호환 가능 <br>
    mysql v8.0 / v5.7.21 이상만 지원
    ex) mysql-8.0.33-<strong>el7</strong>-x86_64.tar.gz
    * 4.5 PostgreSQL <br>
    postgresql: https://www.postgresql.org/ftp/source/
5. <strong>패키지 파일 형식 및 저장 위치 (정확한 명칭의 패키지 파일 다운로드)</strong> <br><br>
<strong><예시></strong>
    * 5.1 apache
      * <strong>httpd-2.4.46.tar.gz</strong><br>
      저장위치: package\1.WEB
      * <strong>apr-1.7.4.tar</strong><br>
      저장위치: package\module
      * <strong>apr-util-1.6.3.tar</strong><br>
      저장위치: package\module
      * <strong>pcre-8.45.tar</strong><br>
      저장위치: package\module
    * 5.2 tomcat<br>
      * <strong>apache-tomcat-8.5.92.tar.gz</strong><br>
      저장위치: package\2.WAS      
    * 5.3 mariadb<br>
      * <strong>mariadb-2.13.4-linux-systemd-x86_64.tar.gz</strong><br>
      저장위치: package\3.DB\MariaDB
    * 5.4 mysql<br>
      * <strong>mysql-1.2.3-el7-x86_64.tar.gz</strong><br>
      저장위치: package\3.DB\MySQL
    * 5.5 postgresql<br>
      * <strong>postgresql-12.5.tar.gz</strong><br>
      저장위치: package\3.DB\PostgreSQL
6. <strong>TODO List (24년 계획)</strong> <br><br>
    * 6.1 Utils
      * WEB <> WAS 자동 연동 (mod_jk)
      * WAS <> DB 자동 연동
    * 6.2 취약점 조치
      * MiddleWare 기본 취약점 조치
    * 6.3 OS 확장
      * Ubuntu
      * RockyOS  
    * 6.4 Progress Bar
      * 좀 더 가시성 있게 진행률 체크할 수 있는 방법 검토
# BUGS
Please report bugs to me

# AUTHOR

Kim JiHwan, <chjr68@naver.com>

