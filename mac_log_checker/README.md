# auto.sh README

[Read in English](#english-version)

## 개요
해당 쉘 스크립트는 macOS AUL(Apple Unified Log) 로그를 기반으로 시스템의 보안 이벤트 및 유출 행위를 분석하고, 영역별 로그 파일로 정리하는 자동화 쉘 스크립트입니다.

## 기능
- **기기 접속(Device Access)**
  - 외부 SSH 접속 기록
  - 내부 로그인 기록(비밀번호, TouchID)
- **유출 정보 수집(Leakage Collection)**
  - 파일 탐색: `ls`, `find`, `mdfind`
  - 파일 이동: Drag & Drop
- **수집 정보 전처리(Pre-Processing)**
  - 데이터 압축 및 zip/ditto 사용 여부
  - 데이터 암호화: openssl
- **수집 정보 유출(Exfiltration)**
  - iCloud 파일 업로드
  - 외부 서버 전송: curl, rsync, scp
  - 저장장치 연결 확인
  - Bluetooth(AirDrop), 메신저(KakaoTalk) Drag & Drop
- **유출 흔적 삭제(Trace Deletion)**
  - 파일 휴지통 이동, 휴지통 비우기, 즉시 삭제

## 사용법
```bash
# 기본 사용법
./mac_log_checker.sh

# -i 옵션: archive 파일 지정
./mac_log_checker.sh -i system_logs.logarchive

# -o 옵션: 출력 디렉토리 지정
./mac_log_checker.sh -i system_logs.logarchive -o ./result
```

## 출력
각 영역별로 로그 파일이 생성됩니다.
- `device_access.log`
- `leakage_collection.log`
- `preprocessing.log`
- `exfiltration.log`
- `trace_deletion.log`

## 요구 사항
- macOS 환경
- `log show` 명령어 사용 가능

## 참고
- 스크립트는 AUL 로그에서 특정 프로세스 및 이벤트 메시지를 기준으로 필터링하여 분석합니다.
- 로그 파일이 없거나 이벤트가 없으면 해당 섹션은 비어 있을 수 있습니다.

---

# auto.sh README <a name="english-version"></a>

## Overview
This shell script automates the analysis of system security events and data exfiltration activities based on macOS AUL (Apple Unified Log) and organizes the findings into log files by category.

## Features
- **Device Access**
  - External SSH access records
  - Internal login records (Password, TouchID)
- **Leakage Collection**
  - File search: `ls`, `find`, `mdfind`
  - File movement: Drag & Drop
- **Pre-Processing**
  - Data compression and usage of zip/ditto
  - Data encryption: openssl
- **Exfiltration**
  - iCloud file upload
  - External server transmission: curl, rsync, scp
  - Storage device connection check
  - Bluetooth (AirDrop), Messenger (KakaoTalk) Drag & Drop
- **Trace Deletion**
  - Moving files to Trash, Emptying Trash, Immediate deletion

## Usage
```bash
# Basic Usage
./mac_log_checker.sh

# -i option: Specify archive file
./mac_log_checker.sh -i system_logs.logarchive

# -o option: Specify output directory
./mac_log_checker.sh -i system_logs.logarchive -o ./result
```

## Output
Log files are generated for each category:
- `device_access.log`
- `leakage_collection.log`
- `preprocessing.log`
- `exfiltration.log`
- `trace_deletion.log`

## Requirements
- macOS environment
- Availability of the `log show` command

## Note
- The script analyzes logs by filtering specific processes and event messages from the AUL.
- If there are no log files or matching events, the corresponding section may be empty.
