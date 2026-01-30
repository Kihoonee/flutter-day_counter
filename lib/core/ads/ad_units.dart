import 'dart:io';

class AdUnits {
  // 개발 중에는 항상 true로 두어 테스트 광고만 나오게 합니다.
  // 실제 출시 직전에 false로 변경하세요.
  static const bool isTestMode = true;

  // 배너 광고 ID
  static String get bannerId {
    if (isTestMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android 테스트 배너 ID
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS 테스트 배너 ID
    }
    return Platform.isAndroid 
        ? 'ca-app-pub-1982911804853023/4633068782' 
        : 'ca-app-pub-1982911804853023/7909968814';
  }

  // 전면 광고 ID
  static String get interstitialId {
    if (isTestMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    // TODO: 실제 전면 광고 ID 발급 시 교체하세요.
    return bannerId; 
  }

  // 보상형 광고 ID
  static String get rewardedId {
    if (isTestMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    }
    // TODO: 실제 보상형 광고 ID 발급 시 교체하세요.
    return bannerId;
  }
}
