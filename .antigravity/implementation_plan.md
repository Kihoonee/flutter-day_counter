# 알림 설정 개별화 및 부모-자식 관계 로직 개선

사용자의 피드백에 따라 이벤트 수정/생성 페이지의 알림 설정을 개선합니다. 세분화된 알림 옵션은 항상 노출되며, 마스터 스위치와 유기적으로 연동됩니다.

## 변경 사항

### [이벤트 수정/생성 페이지]
#### [MODIFY] [event_edit_page.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/pages/event_edit_page.dart)
- **UI 개선**: `if (_isNotificationEnabled)` 조건을 제거하여 세부 알림 옵션이 항상 보이도록 수정합니다.
- **부모-자식 로직 구현**:
    - **알림 켜기(부모)**를 끄면 모든 세부 알림(자식: D-Day, D-1, 기념일)이 자동으로 **Off**가 됩니다.
    - **세부 알림(자식)** 중 하나라도 켜면 **알림 켜기(부모)**가 자동으로 **On**이 됩니다.
- **UI 상시 노출**: `if (_isNotificationEnabled)` 조건을 제거하여 부모 스위치가 꺼져 있어도 자식 스위치들을 볼 수 있게 수정합니다.
- **수정 페이지 확인**: 기존 이벤트를 불러올 때(`_initFrom`) 모든 필드가 올바르게 로드되는지 확인합니다.

### [설정 페이지 & 알림 서비스]
#### [MODIFY] [settings_page.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/pages/settings_page.dart)
- 전역 알림을 다시 **On**으로 바꿀 때, 각 이벤트의 개별 세부 설정값을 참조하여 알림이 다시 스케줄링되도록 보장합니다. (이미 `rescheduleAllNotifications`를 호출하고 있으므로 해당 로직을 재점검합니다.)

## 검증 계획

### 자동/수동 검증
- **로직 확인**: 마스터 스위치를 껐을 때 하위 스위치들이 같이 꺼지는지 확인.
- **로직 확인**: 마스터가 꺼진 상태에서 하위 스위치를 하나라도 켰을 때 마스터가 같이 켜지는지 확인.
- **UI 유지**: 마스터를 꺼도 하위 메뉴가 사라지지 않고 그대로 남아있는지 확인.
- **수정 모드 확인**: 기존 이벤트를 수정할 때도 세부 알림 설정이 잘 보이는지 확인.
