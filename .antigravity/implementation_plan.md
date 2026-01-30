# 위젯 개선 Phase 2 구현 계획

## 요구사항 정리

| # | 요구사항 | 플랫폼 |
|---|----------|--------|
| 1 | 위젯 텍스트 반투명 해제 | Android/iOS |
| 2 | 위젯 배경 alpha 0.8으로 변경 | Android/iOS |
| 3 | D-day 폰트 크기 = 타이틀의 110% | Android/iOS |
| 4 | 타이틀 위치 상단으로 | Android |
| 5 | D-day 위치 하단으로 | Android |
| 6 | 이벤트 선택화면 잘림 수정 | Android |
| 7 | 이벤트 선택화면 세로모드 고정 | Flutter |
| 8 | 자동 첫번째 이벤트 위젯 로직 제거 | Flutter |
| 9 | image-3.png 이슈 분석 | Flutter |

---

## 제안된 변경사항

### Android 위젯 레이아웃

#### [MODIFY] [widget_layout.xml](file:///Users/kihoonee/flutter/day_counter/android/app/src/main/res/layout/widget_layout.xml)
- 배경 alpha: `0.7` → `0.8`
- 타이틀 텍스트 색상 100% 불투명 유지 (현재 OK)
- D-day 폰트 크기: `34sp` → `18sp` (타이틀 16sp의 110%)
- 타이틀 상단 패딩 축소, D-day 하단 마진 추가

#### [MODIFY] [widget_layout_title.xml](file:///Users/kihoonee/flutter/day_counter/android/app/src/main/res/layout/widget_layout_title.xml)
- 배경 alpha: `0.7` → `0.8`
- 폰트 비율 조정

---

### iOS 위젯 SwiftUI

#### [MODIFY] [DaysPlusWidget.swift](file:///Users/kihoonee/flutter/day_counter/ios/DaysPlusWidget/DaysPlusWidget.swift)
- 배경색에 `.opacity(0.8)` 적용
- D-day 폰트 크기를 타이틀의 110%로 조정 (16 → 18)
- 날짜 텍스트 opacity 0.8 → 1.0 (불투명)

---

### DaysPlusWidget.kt (Android)

#### [MODIFY] [DaysPlusWidget.kt](file:///Users/kihoonee/flutter/day_counter/android/app/src/main/kotlin/com/handroom/daysplus/DaysPlusWidget.kt)
- `dateColor` alpha 204 → 255 (날짜도 불투명)

---

### Flutter 위젯 서비스

#### [MODIFY] [event_controller.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/application/event_controller.dart)
- `_updateWidget()` 메서드에서 `WidgetService().updateWidget(top)` 호출 제거
- `saveEventsList(sorted)`만 유지하여 위젯 선택 목록만 동기화

---

### 이벤트 선택 화면 (image-2.png 이슈)

> **분석결과**: Android 위젯 이벤트 선택은 시스템 UI가 처리하므로 Flutter에서 제어 불가. 잘림 현상은 이벤트 제목이 길 때 발생하는 것으로 보임.

#### [MODIFY] DisplayRepresentation 조정 필요 (iOS)
`SelectEventIntent.swift`에서 subtitle 포맷 조정:
```swift
DisplayRepresentation(title: "\(title)", subtitle: "\(date) | \(dDay)")
```

---

### image-3.png 이슈 분석

> **분석결과**: 스크린샷은 이벤트 상세 페이지 헤더의 카드를 보여줍니다. 이 카드는 **Layout Type 1 (TitleEmphasis)**를 사용 중이며:
> - 제목이 중앙에 크게 표시
> - D-Day와 날짜가 하단에 나란히 표시
>
> 이것은 `_buildTitleEmphasis` 메서드의 의도된 디자인입니다. **레이아웃 이상 없음**.
>
> 단, 변경 희망 시 수정 가능합니다.

---

## 검증 계획

1. Android 에뮬레이터에서 위젯 추가 후 배경 투명도 및 텍스트 가독성 확인
2. iOS 시뮬레이터에서 위젯 추가 후 동일 확인
3. 이벤트 목록에 여러 개 추가 후 위젯이 자동으로 첫번째 이벤트를 표시하지 않는지 확인
4. 위젯 이벤트 선택 시 목록이 잘리지 않는지 확인
