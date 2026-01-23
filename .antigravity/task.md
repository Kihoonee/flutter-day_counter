# Task: 이벤트 상세 화면 구현 및 UI/UX 개선

## 데이터 레이어 업데이트
- [x] `TodoItem` 엔티티 생성 (`domain/todo_item.dart`)
- [x] `DiaryEntry` 엔티티 생성 (`domain/diary_entry.dart`)
- [x] `Event` 엔티티에 `todos`, `diaryEntries`, `iconIndex` 필드 추가
- [x] `build_runner` 실행하여 코드 재생성
- [x] Sembast 직렬화 문제 해결 (build.yaml 설정)

## UI 구현 (기본)
- [x] `EventDetailPage` 생성 (3탭: 투두/다이어리/수정)
- [x] Locale 초기화 문제 해결 (bootstrap.dart)

## UI/UX 개선 (Refinement)
- [x] **PosterCard**: 아이콘 리스트 20개 정의 및 테마 분리, 컬러 5개 추가.
- [x] **EditTab (수정) & EventEditPage**:
    - 기준일 제거 (항상 오늘).
    - [x] **스타일 개선 2차**: 배경색 통일, 테두리 제거, 간격 확보, 날짜 볼드 제거, 삭제 버튼 강조.
- [x] **DiaryTab (다이어리)**:
    - [x] **데이터 동기화 버그 수정**: `eventId` 기반 구독으로 변경하여 작성 시 즉시 반영 보장.
    - [x] **스타일 개선**:
        - 카드 테두리 및 달력 아이콘 제거.
        - 작성 다이얼로그 UX 개선 (달력 숨김, 날짜 선택 팝업).
        - FAB 그림자 감소.
    - 카드 삭제: 스와이프(Dismissible) 적용.
    - 카드 수정: 디자인 개선된 카드 클릭 또는 수정 버튼.
- [x] **TodoTab (할일)**:
    - 입력 필드 및 Empty State 스타일 개선.

## 라우팅 및 내비게이션
- [x] `router.dart`에 `/detail` 경로 추가
- [x] `EventListPage`의 `onTap`을 `/detail`로 변경

## 버그 수정 & 마무리
- [x] PosterCard 오버플로우 수정
- [x] Sembast `_DiaryEntry not supported` 에러 수정
- [x] Intl `Locale data has not been initialized` 에러 수정
- [x] 최종 스타일 점검 및 Git Commit 완료.
