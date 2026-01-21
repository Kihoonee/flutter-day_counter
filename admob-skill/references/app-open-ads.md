# 앱 오픈 광고 (App Open Ads)

앱 시작 시 또는 백그라운드에서 포그라운드로 복귀할 때 표시되는 전체 화면 광고입니다. 스플래시 화면 대체 또는 앱 복귀 시 수익화에 적합합니다.

## 기본 구현

### 1. AppOpenAd 매니저 만들기

```dart
// lib/core/ads/app_open_ad_manager.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_units.dart';

class AppOpenAdManager {
  static final AppOpenAdManager _instance = AppOpenAdManager._internal();
  factory AppOpenAdManager() => _instance;
  AppOpenAdManager._internal();

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _isLoaded = false;
  
  /// 광고 유효 시간 (4시간)
  DateTime? _appOpenLoadTime;
  static const Duration _maxCacheDuration = Duration(hours: 4);

  bool get isLoaded => _isLoaded && _isAdValid();

  bool _isAdValid() {
    if (_appOpenLoadTime == null) return false;
    return DateTime.now().difference(_appOpenLoadTime!) < _maxCacheDuration;
  }

  /// 광고 로드
  void loadAd() {
    AppOpenAd.load(
      adUnitId: AdUnits.appOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isLoaded = true;
          _appOpenLoadTime = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          _isLoaded = false;
          print('앱 오픈 광고 로드 실패: ${error.message}');
        },
      ),
    );
  }

  /// 광고 표시
  void showAdIfAvailable() {
    if (!isLoaded) {
      loadAd();
      return;
    }

    if (_isShowingAd) {
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        _isLoaded = false;
        loadAd(); // 다음 광고 미리 로드
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        _isLoaded = false;
        loadAd();
      },
    );

    _appOpenAd!.show();
  }
}
```

### 2. 앱 라이프사이클 관찰자 설정

```dart
// lib/core/ads/app_lifecycle_reactor.dart
import 'package:flutter/material.dart';
import 'app_open_ad_manager.dart';

class AppLifecycleReactor extends WidgetsBindingObserver {
  final AppOpenAdManager appOpenAdManager;
  
  AppLifecycleReactor({required this.appOpenAdManager});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 복귀할 때 광고 표시
      appOpenAdManager.showAdIfAvailable();
    }
  }
}
```

### 3. main.dart에서 초기화

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/ads/app_open_ad_manager.dart';
import 'core/ads/app_lifecycle_reactor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  
  // 앱 오픈 광고 매니저 초기화 및 광고 로드
  final appOpenAdManager = AppOpenAdManager();
  appOpenAdManager.loadAd();
  
  // 라이프사이클 관찰자 등록
  final appLifecycleReactor = AppLifecycleReactor(
    appOpenAdManager: appOpenAdManager,
  );
  WidgetsBinding.instance.addObserver(appLifecycleReactor);
  
  runApp(const MyApp());
}
```

## 앱 시작 시에만 광고 표시하기

포그라운드 복귀 시에는 광고를 표시하지 않고, 앱 시작 시에만 표시하고 싶은 경우:

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  
  final appOpenAdManager = AppOpenAdManager();
  appOpenAdManager.loadAd();
  
  // 스플래시 화면 후 광고 표시
  runApp(MyApp(appOpenAdManager: appOpenAdManager));
}

// lib/features/splash/presentation/splash_screen.dart
class SplashScreen extends StatefulWidget {
  final AppOpenAdManager appOpenAdManager;
  
  const SplashScreen({super.key, required this.appOpenAdManager});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 앱 초기화 작업 (예: 2초 대기)
    await Future.delayed(const Duration(seconds: 2));
    
    // 앱 오픈 광고 표시
    widget.appOpenAdManager.showAdIfAvailable();
    
    // 메인 화면으로 이동
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

## 광고 표시 빈도 제어

매번 복귀할 때마다 광고를 표시하면 사용자 경험이 저하됩니다:

```dart
class AppOpenAdManager {
  // ... 기존 코드 ...
  
  DateTime? _lastAdShownTime;
  static const Duration _minTimeBetweenAds = Duration(minutes: 5);

  bool _canShowAd() {
    if (_lastAdShownTime == null) return true;
    return DateTime.now().difference(_lastAdShownTime!) >= _minTimeBetweenAds;
  }

  void showAdIfAvailable() {
    if (!isLoaded || !_canShowAd()) {
      if (!isLoaded) loadAd();
      return;
    }

    // ... 광고 표시 로직 ...
    
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        _lastAdShownTime = DateTime.now(); // 표시 시간 기록
      },
      // ... 나머지 콜백 ...
    );

    _appOpenAd!.show();
  }
}
```

## 앱 오픈 광고 표시 시점

| 상황 | 권장 여부 | 이유 |
|:---|:---|:---|
| 앱 첫 시작 | ✅ 권장 | 스플래시 화면 대체 |
| 백그라운드 복귀 | ⚠️ 주의 | 빈도 제한 필요 |
| 특정 화면 진입 | ❌ 비권장 | 전면 광고 사용 권장 |

## 모범 사례

- 광고를 **미리 로드**해서 앱 시작 시 바로 표시
- 캐시된 광고의 **유효 시간 확인** (4시간 제한)
- 포그라운드 복귀 시 **빈도 제한** 적용
- 중요한 작업 중(결제, 로그인 등)에는 **표시하지 않음**
- 사용자 동의가 필요한 경우 **동의 후 로드**
