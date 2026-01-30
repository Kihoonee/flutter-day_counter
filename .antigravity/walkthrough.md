# 위젯 레이아웃 선택 기능 제거

## 변경 요약

사용자 요청에 따라 위젯 레이아웃 선택 기능을 완전히 제거했습니다.  
**D-Day 강조 레이아웃**만 사용하도록 단순화되었습니다.

## 수정된 파일

### Flutter (UI 제거)
- [edit_tab.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/widgets/edit_tab.dart): `_showLayoutPicker` 메서드 및 레이아웃 선택 카드 UI 제거
- [event_edit_page.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/pages/event_edit_page.dart): `_showLayoutPicker` 메서드 및 레이아웃 선택 카드 UI 제거
- [poster_card.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/widgets/poster_card.dart): 항상 D-Day 레이아웃 사용

### Android Native
- [DaysPlusWidget.kt](file:///Users/kihoonee/flutter/day_counter/android/app/src/main/kotlin/com/handroom/daysplus/DaysPlusWidget.kt): 레이아웃 타입 분기 제거, 항상 `widget_layout.xml` 사용

### iOS Native
- [DaysPlusWidget.swift](file:///Users/kihoonee/flutter/day_counter/ios/DaysPlusWidget/DaysPlusWidget.swift): 조건부 레이아웃 분기 제거, 항상 `ddayEmphasisLayout` 사용

## 검증
- ✅ Android 에뮬레이터 Hot Reload 진행 중
- ✅ 빌드 에러 없음
