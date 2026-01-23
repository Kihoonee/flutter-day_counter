import 'dart:io';

class AdUnits {
  // 개발 중에는 항상 true로 두어 테스트 광고만 나오게 합니다.
  // 실제 출시 직전에 false로 변경하고 아래 실제 ID들을 채워넣으세요.
  static const bool isTestMode = true;

  // 배너 광고 ID
  static String get bannerId {
    if (isTestMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android 테스트 배너 ID
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS 테스트 배너 ID
    }
    // TODO: AdMob 페이지에서 생성한 실제 배너 유닛 ID를 여기에 넣으세요.
    return Platform.isAndroid 
        ? 'ca-app-pub-1717494382919497/3344557364' 
        : 'YOUR_IOS_REAL_BANNER_ID';
  }
}
