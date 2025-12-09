#!/bin/bash

# 기본 출력 경로 설정
OUTPUT_DIR="."
INPUT_MODE="logshow"
TARGET_FILE=""

# 옵션 처리: o: (출력 디렉토리), i: (입력 아카이브 파일)
while getopts "o:i:" opt; do
    case ${opt} in
        o )
            OUTPUT_DIR="$OPTARG"
            mkdir -p "$OUTPUT_DIR"
            ;;
        i )
            TARGET_FILE="$OPTARG"
            INPUT_MODE="archive"
            ;;
        \? )
            echo "사용법: $0 [-o 출력_경로] [-i 아카이브_파일]"
            exit 1
            ;;
    esac
done
shift $((OPTIND -1)) # 처리된 옵션을 제거

# log show 명령어에 사용할 타겟 설정
if [ "$INPUT_MODE" = "archive" ]; then
    LOG_TARGET="--archive $TARGET_FILE"
else
    LOG_TARGET=""
fi

echo "=============================================="
echo "        AUL 검사 실행: $TARGET_FILE"
echo "=============================================="

echo ""
DEVICE_OUTPUT="$OUTPUT_DIR/device_access.log"
echo "=========== Device Access ===========" > "$DEVICE_OUTPUT"
echo "=========== 기기 접속(Device Access) ==========="

echo ""
echo "[1] 외부 접속 (Remote Access: SSH)"

echo "[1] 외부 접속 (Remote Access: SSH)" >> "$DEVICE_OUTPUT"
log show --info --debug \
--predicate 'process contains "sshd-session" AND eventMessage contains "keyboard-interactive"' \
$LOG_TARGET >> "$DEVICE_OUTPUT"
echo "" >> "$DEVICE_OUTPUT"
echo ""
echo "[2] 내부 접속 (Local Login: Password Unlock)"

echo "[2] 내부 접속 (Local Login: Password Unlock)" >> "$DEVICE_OUTPUT"
log show --info --debug \
--predicate 'process contains "loginwindow" AND eventMessage contains "enter. password is CORRECT"' \
$LOG_TARGET >> "$DEVICE_OUTPUT"
echo "" >> "$DEVICE_OUTPUT"
echo ""
echo "[3] 내부 접속 (Local Login: TouchID)"

echo "[3] 내부 접속 (Local Login: TouchID)" >> "$DEVICE_OUTPUT"
log show --info --debug \
--predicate 'process contains "loginwindow" AND eventMessage contains "APEventTouchIDMatch"' \
$LOG_TARGET >> "$DEVICE_OUTPUT"
echo "" >> "$DEVICE_OUTPUT"

echo ""
COLLECTION_OUTPUT="$OUTPUT_DIR/leakage_collection.log"
echo "=========== Leakage Collection ===========" > "$COLLECTION_OUTPUT"
echo "=========== 유출 정보 수집(Leakage Collection) ==========="

echo ""
echo "[4] 파일 탐색 - ls 명령어 사용 여부"

echo "[4] 파일 탐색 - ls 명령어 사용 여부" >> "$COLLECTION_OUTPUT"
log show --info --debug \
--predicate 'process == "ls" AND eventMessage contains "Retrieve User by ID"' \
$LOG_TARGET >> "$COLLECTION_OUTPUT"
echo "" >> "$COLLECTION_OUTPUT"
echo ""
echo "[5] 파일 탐색 - find 명령어로 접근한 디렉토리 및 파일 확인"

echo "[5] 파일 탐색 - find 명령어로 접근한 디렉토리 및 파일 확인" >> "$COLLECTION_OUTPUT"
log show --info --debug \
--predicate 'process contains "kernel" AND eventMessage contains "System Policy: find("' \
$LOG_TARGET >> "$COLLECTION_OUTPUT"
echo "" >> "$COLLECTION_OUTPUT"
echo ""
echo "[6] 파일 탐색 - mdfind 명령어 사용 여부"

echo "[6] 파일 탐색 - mdfind 명령어 사용 여부" >> "$COLLECTION_OUTPUT"
log show --info --debug \
--predicate 'process contains "mdfind" AND eventMessage contains "Retrieve User by ID"' \
$LOG_TARGET >> "$COLLECTION_OUTPUT"
echo "" >> "$COLLECTION_OUTPUT"
echo ""
echo "[7] 파일 이동 - Drag & Drop fileID 확인"

echo "[7] 파일 이동 - Drag & Drop fileID 확인" >> "$COLLECTION_OUTPUT"
log show --info --debug \
--predicate 'process contains "filecoordinationd" AND eventMessage contains "com.apple.desktopservices.copyengine"' \
$LOG_TARGET >> "$COLLECTION_OUTPUT"
echo "" >> "$COLLECTION_OUTPUT"

echo ""
PREPROC_OUTPUT="$OUTPUT_DIR/preprocessing.log"
echo "=========== Pre-Processing ===========" > "$PREPROC_OUTPUT"
echo "=========== 수집 정보 전처리(Pre-Processing) ==========="

echo ""
echo "[8] 데이터 압축 - 메타데이터 변경 사실 확인"

echo "[8] 데이터 압축 - 메타데이터 변경 사실 확인" >> "$PREPROC_OUTPUT"
log show --info --debug \
--predicate 'process contains "mds_stores" AND eventMessage contains "compressing"' \
$LOG_TARGET >> "$PREPROC_OUTPUT"
echo "" >> "$PREPROC_OUTPUT"
echo ""
echo "[9] 데이터 압축 - zip 압축 발생 여부(GUI)"

echo "[9] 데이터 압축 - zip 압축 발생 여부(GUI)" >> "$PREPROC_OUTPUT"
log show --info --debug \
--predicate 'process contains "ArchiveService" AND eventMessage contains "Read options: 20000 -- URL:"' \
$LOG_TARGET >> "$PREPROC_OUTPUT"
echo "" >> "$PREPROC_OUTPUT"
echo ""
echo "[10] 데이터 압축 - zip 민감 파일 압축 여부"

echo "[10] 데이터 압축 - zip 민감 파일 압축 여부" >> "$PREPROC_OUTPUT"
log show --info --debug \
--predicate 'process contains "tccd" AND eventMessage contains "TCCDProcess: identifier=com.apple.zip"' \
$LOG_TARGET >> "$PREPROC_OUTPUT"
echo "" >> "$PREPROC_OUTPUT"
echo ""
echo "[11] 데이터 압축 - ditto 명령어 사용 여부"

echo "[11] 데이터 압축 - ditto 명령어 사용 여부" >> "$PREPROC_OUTPUT"
log show --info --debug \
--predicate 'process contains "ditto" AND eventMessage contains "Retrieve User by ID"' \
$LOG_TARGET >> "$PREPROC_OUTPUT"
echo "" >> "$PREPROC_OUTPUT"
echo ""
echo "[12] 데이터 암호화 - openssl 사용 여부"

echo "[12] 데이터 암호화 - openssl 사용 여부" >> "$PREPROC_OUTPUT"
log show --info --debug \
--predicate 'process contains "kernel" AND eventMessage contains "openssl"' \
$LOG_TARGET >> "$PREPROC_OUTPUT"
echo "" >> "$PREPROC_OUTPUT"

echo ""
EXFIL_OUTPUT="$OUTPUT_DIR/exfiltration.log"
echo "=========== Exfiltration ===========" > "$EXFIL_OUTPUT"
echo "=========== 수집 정보 유출(Exfiltration) ==========="

echo ""
echo "[13] iCloud - 파일 업로드 사실 확인"

echo "[13] iCloud - 파일 업로드 사실 확인" >> "$EXFIL_OUTPUT"
log show --info --debug \
--predicate 'process contains "fileproviderd" AND eventMessage contains "FP snapshot mutation: insert"' \
$LOG_TARGET >> "$EXFIL_OUTPUT"
echo "" >> "$EXFIL_OUTPUT"
echo ""
echo "[14] 외부 서버 - curl 통신 확인"

echo "[14] 외부 서버 - curl 통신 확인" >> "$EXFIL_OUTPUT"
log show --info --debug \
--predicate 'process contains "kernel" AND eventMessage contains "tcp" AND eventMessage contains "curl"' \
$LOG_TARGET >> "$EXFIL_OUTPUT"
echo "" >> "$EXFIL_OUTPUT"
echo ""
echo "[15] 외부 서버 - curl 통신 IP 확인"

echo "[15] 외부 서버 - curl 통신 IP 확인" >> "$EXFIL_OUTPUT"
log show --info --debug \
--predicate 'process contains "curl" AND eventMessage contains "nat"' \
$LOG_TARGET >> "$EXFIL_OUTPUT"
echo "" >> "$EXFIL_OUTPUT"
echo ""
echo "[16] 외부 서버 - rsync 통신 확인"

echo "[16] 외부 서버 - rsync 통신 확인" >> "$EXFIL_OUTPUT"
log show --info --debug \
--predicate 'process contains "opendirectoryd" AND eventMessage contains "PROC: scp"' \
$LOG_TARGET >> "$EXFIL_OUTPUT"
echo "" >> "$EXFIL_OUTPUT"
echo ""
echo "[17] 외부 서버 - scp 통신 확인"

echo "[17] 외부 서버 - scp 통신 확인" >> "$EXFIL_OUTPUT"
log show --info --debug \
--predicate 'process contains "opendirectoryd" AND eventMessage contains "scp"' \
$LOG_TARGET >> "$EXFIL_OUTPUT"
echo "" >> "$EXFIL_OUTPUT"

echo ""
echo "[18] 저장장치 - USB/SSD 제품명 및 연결 확인"

echo "[18] 저장장치 - USB/SSD 제품명 및 연결 확인" >> "$EXFIL_OUTPUT"
log show --info --debug \
--predicate 'process contains "icdd" AND eventMessage contains "Added"' \
$LOG_TARGET >> "$EXFIL_OUTPUT"
echo "" >> "$EXFIL_OUTPUT"
echo ""
echo "[19] 저장장치 - PID/VID 확인"

echo "[19] 저장장치 - PID/VID 확인" >> "$EXFIL_OUTPUT"
log show --info --debug \
--predicate 'process contains "com.apple.ifdreader" AND eventMessage contains "new device skipped"' \
$LOG_TARGET >> "$EXFIL_OUTPUT"
echo "" >> "$EXFIL_OUTPUT"
echo ""
echo "[20] Bluetooth - AirDrop 여부 확인"

echo "[20] Bluetooth - AirDrop 여부 확인" >> "$EXFIL_OUTPUT"
log show --info --debug \
--predicate 'process contains "sharingd" AND eventMessage contains "AirDrop send performance"' \
$LOG_TARGET >> "$EXFIL_OUTPUT"
echo "" >> "$EXFIL_OUTPUT"
echo ""
echo "[21] 메신저 - 카카오톡 파일 Drag&Drop 여부 확인"

echo "[21] 메신저 - 카카오톡 파일 Drag&Drop 여부 확인" >> "$EXFIL_OUTPUT"
log show --info --debug \
--predicate 'process contains "KakaoTalk" AND eventMessage contains "Apple CFPasteboard drag"' \
$LOG_TARGET >> "$EXFIL_OUTPUT"
echo "" >> "$EXFIL_OUTPUT"

echo ""
TRACE_OUTPUT="$OUTPUT_DIR/trace_deletion.log"
echo "=========== Trace Deletion ===========" > "$TRACE_OUTPUT"
echo "=========== 유출 흔적 삭제(Trace Deletion) ==========="

echo ""
echo "[22] 파일 삭제 - 휴지통 이동(Command + Del)"

echo "[22] 파일 삭제 - 휴지통 이동(Command + Del)" >> "$TRACE_OUTPUT"
log show --info --debug \
--predicate 'process contains "Finder" AND eventMessage contains "cmdMoveToTrash"' \
$LOG_TARGET >> "$TRACE_OUTPUT"
echo "" >> "$TRACE_OUTPUT"
echo ""
echo "[23] 파일 삭제 - 휴지통 비우기"

echo "[23] 파일 삭제 - 휴지통 비우기" >> "$TRACE_OUTPUT"
log show --info --debug \
--predicate 'process contains "Finder" AND eventMessage contains "Setting trashFull=0"' \
$LOG_TARGET >> "$TRACE_OUTPUT"
echo "" >> "$TRACE_OUTPUT"
echo ""
echo "[24] 파일 삭제 - 즉시 삭제(Command + Option + Del)"

echo "[24] 파일 삭제 - 즉시 삭제(Command + Option + Del)" >> "$TRACE_OUTPUT"
log show --info --debug \
--predicate 'process contains "Finder" AND eventMessage contains "cmdDeleteImmediately"' \
$LOG_TARGET >> "$TRACE_OUTPUT"
echo "" >> "$TRACE_OUTPUT"
