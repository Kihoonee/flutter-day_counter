# UI 정교화 및 배너 광고 구현 계획

사용자의 피드백을 반영하여 화려함을 덜어낸 미니멀 디자인을 구현하고, 앱 가이드라인에 따라 모든 화면에 배너 광고를 배치했습니다.

## 주요 변경 사항

### 1. 미니멀 디자인 전면 수정
- **기념일 추가 버튼**: 강한 그라데이션과 그림자를 제거하고, 아주 연한 테두리와 파스텔톤 배경을 가진 미니멀한 바 형태로 수정했습니다.
- **앱바(AppBar)**: 투명도를 조절하고 불필요한 장식을 제거하여 컨텐츠(PosterCard)가 더 돋보이도록 했습니다.

### 2. 배너 광고 복구 및 표준화 (Always Visible)
- **전 화면 적용**: `EventListPage`, `EventDetailPage`, `EventEditPage`, `HomePage`, `ResultPage`, `SettingsPage` 전 화면 하단에 배너 광고 배치.
- **레이아웃 안정성**: `BannerAdWidget`에 60px 고정 높이를 할당하여 광고 로딩 시 화면이 흔들리는 현상(Layout Shift)을 방지했습니다.
- **고정 위치**: `Scaffold`의 `bottomNavigationBar`를 활용하여 스크롤 시에도 항상 하단에 고정되도록 구현했습니다.

## 검증 계획

### Automated Tests
- `flutter run`을 통해 양대 플랫폼(Android Emulator, iOS Simulator)에서 실행 확인.

### Manual Verification
- [x] 각 페이지 전환 시 배너 광고가 끊김 없이 하단에 유지되는지 확인.
- [x] '기념일 추가' 버튼의 가독성과 미적인 정돈 상태 확인.
- [x] D-Day 형식이 일관되게 (D-N, D+N) 표시되는지 확인.

## 현재 상태
- **안드로이드 에뮬레이터**: 실행 중 (최신 반영 완료)
- **iOS 시뮬레이터**: 실행 중 (최신 반영 완료)
