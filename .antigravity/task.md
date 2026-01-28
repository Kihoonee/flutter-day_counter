# 기능 및 UI 개선 v2.5

## 수정화면 (EventEditPage) 개선
- [x] **실시간 미리보기 수정**: 타이틀, 날짜, 옵션 변경 시 상단 PosterCard가 즉시 업데이트되지 않는 문제 수정.
- [x] **알림 설정 토글 추가**: 당일포함/주말제외 옵션 하단에 '알림 켜기/끄기' 토글 추가.
  - [x] `Event` 모델에 `isNotificationEnabled` 필드 추가.
  - [x] DB 마이그레이션 (기존 데이터 default true).

## 한줄메모 (Diary) 개선
- [x] **달력 마커 표시**: 날짜 선택 달력(CustomCalendar)에 메모가 존재하는 날짜를 점(Mark)으로 표시.
  - [x] `CustomCalendar` 위젯에 `markerDates` 파라미터 추가.
  - [x] 날짜 그리드에 마커 렌더링 로직 구현.
  - [x] `DiaryTab`에서 다이어리 엔트리 날짜 리스트 전달.
  - [x] **UI 개선**: 마커 스타일 변경 (점 -> 색상 원) 및 기본 셀 크기(32x32) 복구.
  - [x] **D-Day 표시**: 목표일(Target Date)에 붉은 테두리(Border) 표시로 구분.

## (보류) 앱 이름 변경
- [x] 앱 이름을 'Days+ (데이즈플러스)'로 변경.
  - [x] iOS (`Info.plist` -> "Days+")

## 배포 및 빌드 (Deployment)
- [/] **iOS**: Simulator 실행 & iPhone Release 설치.
  - [/] iOS Simulator 실행 (`flutter run`) - *Skipped (Device Not Found)*
  - [x] iPhone Release 설치 (`flutter run --release`) - *Installed (Launch failed via CLI)*
- [x] **Android**: Release APK 빌드 (`flutter build apk --release`)
  - Path: `build/app/outputs/flutter-apk/app-release.apk`
