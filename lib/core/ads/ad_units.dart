import 'package:flutter/foundation.dart';

class AdUnits {
  // 개발 중에는 항상 true로 두어 테스트 광고만 나오게 합니다.
  // 실제 출시 직전에 false로 변경하세요.
  static const bool isTestMode = true;

  // 배너 광고 ID
  static String get bannerId {
    if (kIsWeb) return ''; // Web not supported
    if (isTestMode) {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/6300978111' // Android 테스트 배너 ID
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS 테스트 배너 ID
    }
    return defaultTargetPlatform == TargetPlatform.android 
        ? 'ca-app-pub-1982911804853023/4633068782' 
        : 'ca-app-pub-1982911804853023/7909968814';
  }

  // 전면 광고 ID (Fullscreen)
  static String get interstitialId {
    if (kIsWeb) return '';
    if (isTestMode) {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? 'ca-app-pub-1982911804853023/5577311339'
        : 'ca-app-pub-1982911804853023/8586618058';
  }

  // 앱 오픈 광고 ID
  static String get appOpenId {
    if (kIsWeb) return '';
    if (isTestMode) {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/9257395921' // Official Android Test ID (App Open)
          : 'ca-app-pub-3940256099942544/5575463023'; // Official iOS Test ID (App Open)
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? 'ca-app-pub-1982911804853023/9198225679'
        : 'ca-app-pub-1982911804853023/8076715698';
  }

  // 네이티브 광고 ID
  static String get nativeId {
    if (kIsWeb) return '';
    if (isTestMode) {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/2247696110'
          : 'ca-app-pub-3940256099942544/3986624511';
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? 'ca-app-pub-1982911804853023/4684265592'
        : 'ca-app-pub-1982911804853023/2117812006';
  }

  // 보상형 광고 ID
  static String get rewardedId {
    if (kIsWeb) return '';
    if (isTestMode) {
    return defaultTargetPlatform == TargetPlatform.android
        ? 'ca-app-pub-3940256099942544/5224354917'
        : 'ca-app-pub-3940256099942544/1712485313';
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? 'ca-app-pub-1982911804853023/1234567890' // TODO: 실제 ID
        : 'ca-app-pub-1982911804853023/0987654321'; // TODO: 실제 ID
  }
}
