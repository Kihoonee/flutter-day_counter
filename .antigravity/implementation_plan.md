# 설정 페이지 전역 알림 세분화 및 "당일 포함" 제거

사용자 요청에 따라 설정 페이지에서 "새 이벤트 당일 포함" 설정 항목을 제거하고, 전역 알림 설정을 세분화(D-Day, D-1, 100일 단위 기념일)하여 개별적으로 제어할 수 있도록 개선합니다.

## 변경 사항

### [설정 페이지]
#### [MODIFY] [settings_page.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/pages/settings_page.dart)
- `kIncludeTodayDefault` 상수 제거.
- `_includeToday` 상태 제거.
- `kGlobalNotificationsDDay`, `kGlobalNotificationsDMinus1`, `kGlobalNotificationsAnniv` 상수 추가.
- UI에서 단일 "전역 알림 설정"을 세분화된 스위치 그룹으로 교체.
- "새 이벤트 당일 포함" 스위치 제거.

### [알림 서비스]
#### [MODIFY] [notification_service.dart](file:///Users/kihoonee/flutter/day_counter/lib/core/services/notification_service.dart)
- `scheduleEvent`에서 세분화된 전역 설정을 확인하여 각 타입별 알림 예약 여부 결정.

### [이벤트 수정/생성 페이지]
#### [MODIFY] [event_edit_page.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/pages/event_edit_page.dart)
- `default_includeToday` 설정을 읽어오는 로직 제거.
- 새 이벤트의 `_includeToday` 기본값을 항상 `true`로 설정.

## 검증 계획

### 자동/수동 검증
- **설정 페이지 UI 확인**: 전역 알림이 세분화되어 표시되는지, "당일 포함"이 사라졌는지 확인.
- **알림 스케줄링 확인**: 특정 타입(예: D-1)만 껐을 때 해당 알림이 예약되지 않는지 로그 확인.
- **새 이벤트 생성**: "당일 포함" 스위치가 기본적으로 켜져 있는지 확인.
