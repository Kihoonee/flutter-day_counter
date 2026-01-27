# 하단 바 그라데이션 경계 및 라인 제거

사용자가 요청한 대로 하단 바의 상단 경계선(Line)을 제거하고, 스크롤되는 콘텐츠가 바와 만나는 지점을 그라데이션을 통해 자연스럽게 처리합니다.

## 제안된 변경 사항

### [Presentation Layer]

#### [MODIFY] [event_list_page.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/pages/event_list_page.dart)
- `Positioned` 하단 바의 `Container`에서 `border` 속성 제거.
- `BoxDecoration`의 `color`를 `gradient`로 교체하여 상단에서부터 투명 -> 반투명으로 이어지는 자연스러운 경계 생성.
- `BackdropFilter`의 블러 효과와 조화되도록 그라데이션 색상 및 투명도 조정.

## 검증 계획

### 수동 검증
- 안드로이드 에뮬레이터 및 iOS 시뮬레이터에서 리스트를 스크롤하며 하단 바와의 경계가 부드럽게 이어지는지 확인.
- 상단 라인이 성공적으로 제거되었는지 확인.
