# Task: 안드로이드 다중 위젯 데이터 격리 및 실시간 업데이트

## Status: Verification

## Progress
- [x] 위젯 인스턴스별 데이터 저장
    - [x] `DaysPlusWidgetConfigureActivity`: `widget_event_id_$appWidgetId`로 각 위젯에 이벤트 ID 저장
    - [x] `DaysPlusWidget.updateAppWidget`: 위젯 ID로 연결된 이벤트를 `widget_events_list`에서 찾아 표시
- [x] Flutter 측 단순화
    - [x] `WidgetService.saveEventsList`: 이벤트 목록 JSON 저장 및 `updateWidget` 호출
- [ ] 결과 검증
    - [ ] 서로 다른 이벤트로 위젯 2개 설치 후, 각각 독립적으로 업데이트되는지 확인
