# Task: 이벤트 상세 화면 구현

- [ ] 데이터 레이어 업데이트
    - [ ] `TodoItem` 엔티티/모델 생성 <!-- id: 1 -->
    - [ ] `DiaryEntry` 엔티티/모델 생성 <!-- id: 2 -->
    - [ ] `Event` 엔티티에 `todos` 및 `diaryEntries` 필드 추가 <!-- id: 3 -->
    - [ ] `build_runner` 실행하여 코드 재생성 <!-- id: 4 -->

- [ ] UI 구현
    - [ ] `EventDetailPage` 생성 (AppBar, PosterCard, TabBar 포함된 Scaffold) <!-- id: 5 -->
    - [ ] `TodoTab` 위젯 구현 (목록, 추가, 체크, 삭제) <!-- id: 6 -->
    - [ ] `DiaryTab` 위젯 구현 (목록, 추가, 편집, 삭제) <!-- id: 7 -->
    - [ ] `EventListPage` 내비게이션 업데이트 (수정 페이지 대신 상세 페이지로 이동) <!-- id: 8 -->
    - [ ] `EventDetailPage`에서 `EventEditPage`로 이동하는 내비게이션 추가 <!-- id: 9 -->

- [ ] 상태 관리 로직
    - [ ] `EventController`에 투두 관련 기능 추가 (추가, 토글, 제거) <!-- id: 10 -->
    - [ ] `EventController`에 다이어리 관련 기능 추가 (추가, 편집, 제거) <!-- id: 11 -->

- [ ] 검증
    - [ ] 수동 테스트: 이벤트 생성, 투두 추가, 투두 토글, 다이어리 작성 <!-- id: 12 -->
    - [ ] 수동 테스트: 화면 이동 흐름 (목록 -> 상세 -> 수정 -> 상세 -> 목록) <!-- id: 13 -->
    - [ ] 수동 테스트: 데이터 유지 확인 (앱 재시작) <!-- id: 14 -->
