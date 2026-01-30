# 위젯 개선사항 구현 완료

## 구현 내역

### Phase 1: 안드로이드 폰트 자동 크기 조절 ✅
- [widget_layout.xml](file:///Users/kihoonee/flutter/day_counter/android/app/src/main/res/layout/widget_layout.xml) → `ConstraintLayout` + `autoSizeTextType="uniform"` 적용
- 위젯 크기 변경 시 텍스트 겹침 현상 해결

---

### Phase 2: 레이아웃 선택 기능 ✅

| 레이아웃 | 설명 |
|---|---|
| **D-Day 강조** (기본) | D-Day 크게, 타이틀+목표일 상단 |
| **타이틀 강조** | 타이틀 크게, D-Day+목표일 하단 |

**변경 파일:**
- [event.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/domain/event.dart) - `widgetLayoutType` 필드 추가
- [event_edit_page.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/pages/event_edit_page.dart) - 레이아웃 선택 팝업 UI
- [widget_service.dart](file:///Users/kihoonee/flutter/day_counter/lib/core/services/widget_service.dart) - `widget_layout_type` 저장
- [DaysPlusWidget.swift](file:///Users/kihoonee/flutter/day_counter/ios/DaysPlusWidget/DaysPlusWidget.swift) - 레이아웃 분기
- [DaysPlusWidget.kt](file:///Users/kihoonee/flutter/day_counter/android/app/src/main/kotlin/com/handroom/daysplus/DaysPlusWidget.kt) - 레이아웃 분기
- [widget_layout_title.xml](file:///Users/kihoonee/flutter/day_counter/android/app/src/main/res/layout/widget_layout_title.xml) - 타이틀 강조 레이아웃

---

### Phase 3: 위젯 이벤트 선택 기능 ✅

**Android:**
- [DaysPlusWidgetConfigureActivity.kt](file:///Users/kihoonee/flutter/day_counter/android/app/src/main/kotlin/com/handroom/daysplus/DaysPlusWidgetConfigureActivity.kt) - 이벤트 선택 Activity
- [widget_info.xml](file:///Users/kihoonee/flutter/day_counter/android/app/src/main/res/xml/widget_info.xml) - `android:configure` 속성 추가
- [AndroidManifest.xml](file:///Users/kihoonee/flutter/day_counter/android/app/src/main/AndroidManifest.xml) - Activity 등록

**iOS:**
- [SelectEventIntent.swift](file:///Users/kihoonee/flutter/day_counter/ios/DaysPlusWidget/SelectEventIntent.swift) - `AppIntentConfiguration` 구현
- 위젯 편집 시 이벤트 선택 가능 (iOS 17+)

**Flutter:**
- [widget_service.dart](file:///Users/kihoonee/flutter/day_counter/lib/core/services/widget_service.dart) - `saveEventsList()` 메서드 추가

---

## 빌드 검증

| 플랫폼 | 결과 |
|---|---|
| Android | ✅ `flutter build apk --debug` 성공 |
| iOS | ✅ `flutter build ios --debug --no-codesign` 성공 |

---

## 추가 수정 사항 (2026.01.30) ✅

### 1. 위젯 노출 문제 해결
- **Android**: `androidx.constraintlayout`이 앱 위젯에서 지원되지 않는 문제로 인해 레이아웃을 `RelativeLayout`으로 변경하여 호환성 확보.
- **iOS**: 프로젝트 파일(`pbxproj`)에 `SelectEventIntent.swift`가 누락된 문제를 스크립트로 해결하여 위젯 타겟이 파일을 인식하도록 수정.

### 2. UI 일관성 개선
- **이벤트 수정 페이지**: 레이아웃 선택 카드와 사진 추가 카드 사이의 간격을 다른 항목들과 동일하게 수정.
- **다이어리 탭**: 한줄 메모 삭제 제스처 시의 배경색을 할 일 목록 삭제 시의 색상(연한 회색 계열)과 동일하게 변경.

### 3. 수정 화면 UI 배치 조정 ✅
- **사진 추가 항목 위치 변경**: '새 이벤트' 등록 화면(`EventEditPage`)과 '이벤트 수정' 화면(`EditTab`)에서 '사진 추가' 카드를 '이벤트 제목' 입력 필드 바로 아래로 이동하여 접근성을 개선.
- **간격 최적화**: 섹션 이동 후 카드 간의 간격을 16px로 조정하여 시각적 일관성 유지.

### 3. 수정 화면 기능 보완 및 프리뷰 연동 ✅
- **이벤트 수정 화면(`EditTab` / `EventEditPage`)**: 새 이벤트 등록 화면과 동일하게 위젯 레이아웃(D-Day 강조 / 타이틀 강조) 변경 기능을 추가.
- **실시간 프리뷰**: `PosterCard` 위젯을 업데이트하여 레이아웃 선택 시 상세 페이지 및 수정 페이지에서 즉시 스타일 변화가 보이도록 프리뷰 기능을 연동.
- **데이터 저장**: 선택한 레이아웃 타입이 저장되어 실제 홈 화면 위젯에도 반영됨.

---

## 최종 검증 완료 (2026.01.30) ✅

### 검증 환경
- **iOS**: iPhone 17 Pro Simulator (iOS 18.2)
- **Android**: Pixel_6_API_33 Emulator (Android 13)

### 검증 결과
1. **위젯 노출 및 선택**:
   - iOS/Android 모두 위젯 갤러리에서 정상 노출 확인.
   - 위젯 추가 시 이벤트 선택 및 레이아웃 반영 확인.
2. **UI 레이아웃**:
   - 'D-Day 강조' 및 '타이틀 강조' 레이아웃이 각 플랫폼 위젯에서 정상 렌더링됨.
   - 레이아웃 선택 카드 상하 간격이 16px로 균일하게 적용됨.
3. **색상 및 스타일**:
   - 다이어리 한줄 메모 삭제 제스처 시 배경색(`surfaceContainerHighest`)이 할 일 목록과 동일하게 변경됨.
