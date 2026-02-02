# 앱 오픈 광고 무한 루프 수정 계획

앱 오픈 광고가 닫힌 후 앱이 다시 포커스를 얻을 때(`resumed` 상태), 테스트 모드에서 빈도 제한이 무시되어 광고가 즉시 다시 노출되는 문제를 해결합니다.

## 제안된 변경 사항

### [광고 매니저 - 진단 강화]
#### [MODIFY] [ad_manager.dart](file:///Users/kihoonee/flutter/day_counter/lib/core/ads/ad_manager.dart)
- `FullScreenContentCallback`의 모든 콜백(`onAdImpression`, `onAdClicked` 등)에 로그 추가.
- `onAdFailedToShowFullScreenContent`에서 에러 메시지 상세 출력.
- `MobileAds.instance.initialize()`의 결과를 명시적으로 확인하는 로그 추가.
- **임시 테스트**: `showAppOpenAdIfAvailable`에서 빈도 제한을 완전히 끄고(테스트 시) 노출 시도 여부 확인.

### [앱 메인 - 진단 강화]
#### [MODIFY] [app.dart](file:///Users/kihoonee/flutter/day_counter/lib/app/app.dart)
- 생명주기 변경(`/inactive`, `/paused`, `/resumed`) 시 더 상세한 상태 로그 추가.
- `resumed` 후 광고 호출 대기 시간을 1.2초에서 2초로 늘려 안정성 확보 시도.

### [테스트용 위젯 - UI 격리 테스트]
#### [MODIFY] [settings_page.dart](file:///Users/kihoonee/flutter/day_counter/lib/features/events/presentation/pages/settings_page.dart)
- 설정 화면 하단에 **"앱 오픈 광고 수동 테스트"** 버튼 추가 (시그널 전달 여부 확인용).

## 검증 계획

### 수동 검증
- **로그 분석**: `Calling _appOpenAd!.show()` 호출 이후 `onAdShowedFullScreenContent`가 찍히는지, 아니면 `onAdFailedToShow`가 찍히는지 끝까지 추적.
- **수동 버튼**: 설정에서 버튼을 눌렀을 때도 광고가 나오지 않는다면 SDK/환경 문제, 나온다면 타이밍 문제로 격리.
- **iOS 시뮬레이터**: "테스트 장비 등록" 메시지가 로그에 있는지 확인.
