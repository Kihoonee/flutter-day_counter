# UI 및 기능 개선 v2.5 구현 계획

사용자가 요청한 **수정 화면의 실시간 반응형 수정**, **알림 토글 추가**, 그리고 **한줄메모 달력 마커 표시** 기능을 구현합니다.

## User Review Required
> [!IMPORTANT]
> `Event` 모델에 `isNotificationEnabled` 필드가 추가됩니다. 이 변경으로 인해 `build_runner` 실행이 필요하며, 기존 앱 데이터와의 호환성을 위해 `default: true`로 설정됩니다.

## Proposed Changes

### [Domain Layer]

#### [MODIFY] [event.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/domain/event.dart)
- `Event` 클래스에 `bool isNotificationEnabled` 필드 추가 (Default: true).
- `freezed` 및 `json_serializable` 재생성을 위한 `build_runner` 실행.

### [Presentation Layer - Edit Page]

#### [MODIFY] [event_edit_page.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/pages/event_edit_page.dart)
- **실시간 미리보기 수정**: `TextField`의 `onChanged` 및 기타 입력 위젯의 상태 변경이 `setState`를 통해 확실하게 UI 리빌드를 트리거하도록 재점검.
    - *분석 결과*: 코드는 정상이지만, 복잡한 위젯 트리에서 상태 갱신이 시각적으로 지연되거나 묻히는 경우가 있을 수 있음. 명시적으로 `PosterCard`에 키를 주거나 상태 관리를 단순화하여 해결 시도.
- **알림 토글 추가**: '옵션' 카드 내에 '알림 켜기' `SwitchListTile` 추가.

### [Presentation Layer - Diary & Calendar]

#### [MODIFY] [custom_calendar.dart](file:///Users/kihoonee/flutter/day_counter/lib/core/widgets/custom_calendar.dart)
- `CustomCalendar` 및 `showCustomCalendar`에 `List<DateTime>? markerDates` 파라미터 추가.
- `_buildDaysGrid` 메서드에서 해당 날짜 아래에 작은 원형 점(Dot) 렌더링 로직 추가.

### App Configuration
#### [MODIFY] [AndroidManifest.xml](file:///Users/kihoonee/flutter/day_counter/android/app/src/main/AndroidManifest.xml)
- Change `android:label` to "Days+".

#### [MODIFY] [Info.plist](file:///Users/kihoonee/flutter/day_counter/ios/Runner/Info.plist)
- Change `CFBundleDisplayName` to "Days+".
- Change `CFBundleName` to "Days+".

#### [MODIFY] [date_field.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/widgets/date_field.dart)
- `pickDate` 함수에 `markerDates` 파라미터를 전달할 수 있도록 시그니처 수정.

#### [MODIFY] [diary_tab.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/widgets/diary_tab.dart)
- `_showDiaryDialog` 내부의 날짜 선택 로직에서 현재 이벤트의 `diaryEntries` 날짜 목록을 추출하여 `pickDate`에 전달.

## Verification Plan

### Automated Tests
- `flutter test`를 실행하여 모델 변경 후 JSON 직렬화/역직렬화가 정상 작동하는지 확인.

### Manual Verification
1. **수정 화면**:
   - 제목 입력 시 상단 카드에 즉시 반영되는지 확인.
   - 날짜 및 옵션 변경 시 D-Day 계산이 즉시 반영되는지 확인.
   - 알림 토글 스위치가 정상 작동하고 저장되는지 확인.
2. **한줄메모**:
   - 작성/수정 다이얼로그에서 달력 아이콘 클릭.
   - 달력에 메모가 있는 날짜 밑에 점이 표시되는지 확인.
