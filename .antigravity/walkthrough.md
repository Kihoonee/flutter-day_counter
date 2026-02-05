# 소셜 공유 기능 구현 완료

## 목표
이벤트 상세 페이지에서 포스터 카드를 고해상도 이미지로 캡처하여 소셜 미디어에 공유할 수 있는 기능을 구현합니다.

## 구현 내용

### 1. 패키지 추가
- `screenshot: ^3.0.0` - 위젯을 이미지로 캡처
- `share_plus: ^10.1.3` - iOS/Android 네이티브 공유 기능

### 2. ShareService 클래스 구현
[`ShareService`](file:///Users/kihoonee/flutter/day_counter/lib/core/services/share_service.dart)를 생성하여 포스터 카드 캡처 및 공유 로직을 캡슐화했습니다.

### 3. 이벤트 상세 페이지 수정
[`EventDetailPage`](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/pages/event_detail_page.dart)에 다음 기능을 추가했습니다:

- `ScreenshotController`를 사용하여 포스터 카드를 Screenshot 위젯으로 감쌈
- AppBar에 공유 버튼 추가 (HugeIcons.strokeRoundedShare08)
- 공유 버튼 클릭 시:
  1. 포스터 카드를 고해상도(pixelRatio: 3.0) 이미지로 캡처
  2. 임시 디렉토리에 PNG 파일로 저장
  3. iOS 공유 시트 표시 (sharePositionOrigin 설정)

### 4. iOS sharePositionOrigin 문제 해결
iOS에서 공유 시트를 표시할 때 `sharePositionOrigin`을 반드시 설정해야 하는 문제를 발견했습니다.

**해결 방법**: MediaQuery를 사용하여 화면 우측 상단 영역을 sharePositionOrigin으로 설정:
```dart
final screenSize = MediaQuery.of(context).size;
final sharePositionOrigin = Rect.fromLTWH(
  screenSize.width - 100,  // 우측에서 100px
  50,  // 상단에서 50px (AppBar 영역)
  50,  // width
  50,  // height
);
```

### 5. 다국어 지원
- 한국어: "공유에 실패했습니다."
- 영어: "Failed to share."

## 검증 결과

### 테스트 환경
- iOS 시뮬레이터 (iPhone 17 Pro)

### 테스트 결과
✅ 포스터 카드 캡처 성공
✅ iOS 공유 시트 표시 성공
✅ 이미지 및 텍스트 공유 준비 완료

![공유 시트 표시](file:///Users/kihoonee/.gemini/antigravity/brain/66e50669-2954-4dd4-8a3c-95ff25955085/share_sheet_success.png)

### 로그 확인
```
flutter: ShareButton: Starting capture...
flutter: ShareButton: Capture successful, preparing to share...
flutter: ShareButton: Position origin: Rect.fromLTRB(302.0, 50.0, 352.0, 100.0)
flutter: ShareButton: Share completed
```

## 주요 이슈 및 해결

### 이슈 1: MissingPluginException
**문제**: Hot Restart로는 네이티브 플러그인 변경사항이 적용되지 않음
**해결**: flutter run 재실행하여 앱 완전 재빌드

### 이슈 2: sharePositionOrigin 필수
**문제**: iOS에서 sharePositionOrigin이 {{0, 0}, {0, 0}}일 경우 PlatformException 발생
**해결**: MediaQuery를 사용하여 화면 우측 상단 영역을 sharePositionOrigin으로 설정

## 다음 단계
- [ ] Apple 심사 대응 UI (설정 페이지 보강)
- [ ] 감성 UX (할일-메모 전환 안내 팝업)

## Hero Animation Flickering Fix (Foundational Fix)

**Issue**: The image would flicker (disappear briefly) at the end of the Hero animation when transitioning from the list to the detail page. This was because the `PosterCard` loaded the image asynchronously (`_loadImage()`), causing a frame delay where no image was available.

**Solution**:
1.  **Synchronous Path Resolution**: Updated `PlatformUtilsImpl` to cache the Application Documents Directory at app startup (`init()`). Added `getImageProviderSync` to resolve paths and return a `FileImage` provider synchronously.
2.  **Immediate State Initialization**: Modified `PosterCard` to attempt synchronous image loading in `initState` and `didUpdateWidget`.
3.  **Result**: The image provider is available *immediately* when the widget is built, preventing any empty frames during or after the Hero transition.

**Code Changes**:
- `lib/core/utils/platform_utils_io.dart`: Added `init()` and `getImageProviderSync`.
- `lib/main.dart`: Called `PlatformUtilsImpl.init()` before `runApp`.
- `lib/features/events/presentation/widgets/poster_card.dart`: Implemented synchronous loading logic.

**Verification**:
- Verified on iOS Simulator (iPhone 17 Pro). Flickering is completely eliminated.
