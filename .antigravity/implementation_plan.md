# 알림 설정 개별화 (Per-Event Granularity)

사용자 요청에 따라 전역 설정에 있던 세분화된 알림 옵션(D-Day, D-1, 기념일)을 개별 이벤트 설정으로 이동합니다.
설정 페이지는 전체 알림의 On/Off를 제어하는 마스터 스위치만 유지하여 UX를 간소화하고 유연성을 높입니다.

## 변경 사항

### [도메인 모델]
#### [MODIFY] [event.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/domain/event.dart)
- `notifyDDay`, `notifyDMinus1`, `notifyAnniv` 필드 추가 (기본값: `true`).

### [이벤트 수정/생성 페이지]
#### [MODIFY] [event_edit_page.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/pages/event_edit_page.dart)
- 개별 알림 스위치 하단에 세분화된 옵션(D-Day, D-1, 기념일) UI 추가.
- 새로 추가된 필드들에 대한 상태 관리 및 저장 로직 구현.

### [설정 페이지]
#### [MODIFY] [settings_page.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/pages/settings_page.dart)
- 세분화된 전역 알림 토글들 제거.
- 마스터 "전역 알림 설정"만 유지.

### [알림 서비스]
#### [MODIFY] [notification_service.dart](file:///Users/kihoonee/flutter/day_counter/lib/core/services/notification_service.dart)
- `scheduleEvent`에서 마스터 전역 설정을 먼저 확인한 후, **해당 이벤트의 개별 알림 옵션**을 확인하여 스케줄링.

## 검증 계획

### 자동/수동 검증
- **설정 페이지 UI 확인**: 심플하게 마스터 스위치만 남았는지 확인.
- **이벤트 편집 UI 확인**: 각 이벤트마다 알림 타이밍을 다르게 설정할 수 있는지 확인.
- **알림 예약 로그 확인**: 특정 이벤트에서 D-1만 껐을 때 해당 알림이 제외되는지 확인.
