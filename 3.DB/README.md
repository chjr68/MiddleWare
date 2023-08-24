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
- 설치 경로 : /usr/local/src
- selinux 해제 <br>
\# sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config <br>
\# reboot <br>
\# getenforce (Disabled 출력 확인)
- root 권한사용 <br>
\# sudo -i
## 2. 모듈 설치
* 모듈 설치 리스트, 환경변수 설정 등
## 3. 패키지 다운로드
## 4. 설치
* config 설정, configure/make/make install
## 5. 서비스 등록
## 6. 서비스 시작
## 7. 별첨
* apache <> tomcat / tomcat <> DB 연동방법



# BUGS
Please report bugs to me

# AUTHOR

Kim JiHwan, <chjr68@naver.com>

