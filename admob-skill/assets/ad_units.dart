import 'dart:io';

/// AdMob 광고 유닛 ID 관리
/// 
/// 사용법:
/// 1. AdMob 콘솔에서 앱 등록 후 광고 유닛 ID를 받습니다.
/// 2. 아래 '실제_XXX_ID' 부분을 실제 ID로 교체합니다.
/// 3. 배포 시 isTestMode를 false로 변경합니다.
class AdUnits {
  // ==========================================
  // 🔧 설정: 배포 시 false로 변경하세요
  // ==========================================
  static const bool isTestMode = true;

  // ==========================================
  // 📱 앱 ID (AndroidManifest.xml, Info.plist에 설정)
  // ==========================================
  static String get appId {
    if (isTestMode) {
      // 테스트 앱 ID는 필요 없음 (테스트 광고 유닛 ID만 사용)
      return '';
    }
    return Platform.isAndroid 
        ? 'ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY' // TODO: 실제 Android 앱 ID
        : 'ca-app-pub-XXXXXXXXXXXXXXXX~ZZZZZZZZZZ'; // TODO: 실제 iOS 앱 ID
  }

  // ==========================================
  // 🎯 배너 광고
  // ==========================================
  static String get bannerId {
    if (isTestMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    return Platform.isAndroid 
        ? '실제_Android_배너_ID'   // TODO: 실제 ID로 교체
        : '실제_iOS_배너_ID';       // TODO: 실제 ID로 교체
  }

  // ==========================================
  // 📺 전면 광고
  // ==========================================
  static String get interstitialId {
    if (isTestMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    return Platform.isAndroid 
        ? '실제_Android_전면_ID'   // TODO: 실제 ID로 교체
        : '실제_iOS_전면_ID';       // TODO: 실제 ID로 교체
  }

  // ==========================================
  // 🎁 보상형 광고
  // ==========================================
  static String get rewardedId {
    if (isTestMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    }
    return Platform.isAndroid 
        ? '실제_Android_보상형_ID' // TODO: 실제 ID로 교체
        : '실제_iOS_보상형_ID';     // TODO: 실제 ID로 교체
  }

  // ==========================================
  // 📰 네이티브 광고
  // ==========================================
  static String get nativeId {
    if (isTestMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/2247696110'
          : 'ca-app-pub-3940256099942544/3986624511';
    }
    return Platform.isAndroid 
        ? '실제_Android_네이티브_ID' // TODO: 실제 ID로 교체
        : '실제_iOS_네이티브_ID';     // TODO: 실제 ID로 교체
  }

  // ==========================================
  // 🚀 앱 오픈 광고
  // ==========================================
  static String get appOpenId {
    if (isTestMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/9257395921'
          : 'ca-app-pub-3940256099942544/5575463023';
    }
    return Platform.isAndroid 
        ? '실제_Android_앱오픈_ID' // TODO: 실제 ID로 교체
        : '실제_iOS_앱오픈_ID';     // TODO: 실제 ID로 교체
  }
}
