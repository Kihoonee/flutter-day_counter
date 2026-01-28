# UI 및 기능 개선 v2.5 완료 보고서

사용자 경험을 향상시키기 위해 수정 화면의 반응성을 개선하고, 알림 제어권 및 한줄메모의 시각적 피드백 기능을 추가했습니다.

## 주요 **변경 사항**:
- `EventDetailPage`와 `EditTab` 간의 상태 동기화 로직 구현 (Callback 패턴).
- 제목, 날짜(`onDateChanged`), 옵션(`includeToday`, `excludeWeekends`) 변경 시 `PosterCard` 즉시 갱신.
- `EventEditPage`(신규 생성)와 `EditTab`(기존 수정) 동일한 UX 제공.
- **실시간 미리보기 (Live Preview)**: 이벤트 제목, 날짜, 옵션을 변경할 때마다 상단의 `PosterCard` 미리보기가 **즉시 반영**되도록 수정했습니다. 더 이상 저장을 눌러야만 확인 가능한 불편함이 없습니다.
- **알림 토글 추가**: '옵션' 섹션에 **'알림 켜기'** 스위치를 추가했습니다. 이제 특정 이벤트에 대한 알림을 개별적으로 켜고  끌 수 있습니다. (기본값: 켜짐)

### 2. 한줄메모 (Diary) 개선
- **변경 사항**:
- `CustomCalendar` 위젯에 `markerDates` 및 `dDayDate` 파라미터 추가.
- **마커 디자인**: 날짜 하단 점(Dot) 방식에서 **파스텔톤 원(Pastel Filled Circle)** 방식으로 변경.
  - *변경 사유*: 가독성 및 앱 톤 매칭. 선택된 날짜와 유사한 스타일이되, **크기를 축소(약 70%)**하고 **파스텔톤 색상(Primary Container)**을 적용하여 은은하게 표시.
- **D-Day 디자인**: 목표일 날짜에 붉은색 테두리(Border) 표시 유지.
- **레이아웃 복구**: 날짜 셀 크기 표준(32x32) 유지.
- `DiaryTab`에서 데이터 연동 완료.
- **직관적 확인**: 달력을 열자마자 언제 기록을 남겼는지 한눈에 파악할 수 있어, 과거의 추억을 찾아보기 훨씬 쉬워졌습니다.

### 4. 앱 브랜딩 (App Branding)
- **앱 이름 변경**: `Day Counter` -> **`Days+`**
  - Android: `AndroidManifest.xml` label 수정.
  - iOS: `Info.plist` BundleDisplayName 수정.

### 5. 배포 (Deployment)
- **iOS**: iPhone Release Build 설치 완료.
  - *Note*: Release 모드로 설치되어 CLI 디버깅 연결은 실패할 수 있으나, 기기에는 정상 설치되었습니다.
- **Android**: Release APK 빌드 완료 (`app-release.apk`).
- **Simulators**: iOS Simulator & Android Emulator 동시 실행 및 UI 검증 완료.

### 6. UI 미세 조정 (Polish)
- **할 일 입력창 정렬**: 입력 텍스트와 하단 체크박스 아이콘의 시작점을 수직으로 일치시킴 (Left Padding: 24px).
- **등록 버튼 정렬**: 우측 (+) 버튼을 날짜 텍스트 끝선에 맞춤 (Right Padding: 4px).

### 3. 데이터 모델 업데이트
- `Event` 모델에 `isNotificationEnabled` 필드를 추가하여 알림 설정 상태를 기기 내에 안전하게 저장합니다.

## 검증 계획

| 항목 | 플랫폼 | 예상 결과 |
| :--- | :--- | :--- |
| **실시간 미리보기** | Android/iOS | 제목/날짜 입력 시 PosterCard 텍스트/D-Day가 즉시 변경됨 |
| **알림 토글** | Android/iOS | 스위치 상태가 저장되고, 재진입 시 유지됨 |
| **달력 마커** | Android/iOS | 메모가 있는 날짜에만 점이 표시되고, 없는 날짜는 깨끗함 |

모든 기능이 계획대로 구현되었으며, 앱의 완성도가 한층 높아졌습니다. 🚀
