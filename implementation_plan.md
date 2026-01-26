# EventDetailPage 스크롤 이슈 수정 계획

## 문제점
- `NestedScrollView`의 `body`가 `Column`으로 감싸져 있어 내부 `TabBarView`의 스크롤이 헤더(`SliverAppBar`, `SliverPersistentHeader`)와 연동되지 않음.
- 이로 인해 스크롤 시 컨텐츠가 헤더 밑으로 숨거나 겹치는 현상 발생.

## 해결 방안
- `NestedScrollView`의 `body`에 `TabBarView`를 직접 할당.
- 배너 광고는 `Scaffold`의 `bottomNavigationBar`로 이동하여 화면 하단에 고정하고 `body` 영역과 분리.

## 변경 내용

### [MODIFY] [event_detail_page.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/pages/event_detail_page.dart)

1. `Scaffold`의 `bottomNavigationBar` 속성 추가: `BannerAdWidget` 배치.
2. `NestedScrollView`의 `body` 변경:
   - 기존: `Column` > `Expanded` > `TabBarView`, `SafeArea` > `BannerAdWidget`
   - 변경: `TabBarView` (직접 할당)

```dart
Scaffold(
  body: NestedScrollView(
    headerSliverBuilder: ...,
    body: TabBarView(...),
  ),
  bottomNavigationBar: SafeArea(
    child: Container(
      height: 60, // 배너 높이만큼 공간 확보
      alignment: Alignment.topCenter,
      child: BannerAdWidget(),
    ),
  ),
)
```

## Verification Plan
- **수동 테스트**: 시뮬레이터에서 앱 실행 후 상세 페이지 진입.
- **체크 포인트**:
  - 스크롤 시 포스터 카드(헤더)가 부드럽게 말려 올라가는지 확인.
  - 탭 바(TabBar)가 상단에 고정(pinned)되었을 때 컨텐츠가 그 아래에서 자연스럽게 스크롤되는지 확인 (겹침 현상 해결).
  - 배너 광고가 하단에 잘 표시되는지 확인.
