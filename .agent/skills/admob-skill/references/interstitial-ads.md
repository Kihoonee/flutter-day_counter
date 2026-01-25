# 전면 광고 (Interstitial Ads)

화면 전체를 덮는 풀스크린 광고입니다. 자연스러운 전환 지점(레벨 클리어, 화면 이동 등)에서 표시합니다.

## 기본 구현

### 1. InterstitialAd 서비스 만들기

```dart
// lib/core/ads/interstitial_ad_service.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_units.dart';

class InterstitialAdService {
  InterstitialAd? _interstitialAd;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  /// 광고 미리 로드 (화면 진입 시 호출)
  void loadAd() {
    InterstitialAd.load(
      adUnitId: AdUnits.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoaded = true;
          
          // 광고 이벤트 리스너 설정
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isLoaded = false;
              loadAd(); // 다음 광고 미리 로드
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isLoaded = false;
              loadAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isLoaded = false;
          print('전면 광고 로드 실패: ${error.message}');
        },
      ),
    );
  }

  /// 광고 표시
  Future<void> showAd({VoidCallback? onAdClosed}) async {
    if (!_isLoaded || _interstitialAd == null) {
      print('전면 광고가 아직 로드되지 않음');
      onAdClosed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isLoaded = false;
        loadAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isLoaded = false;
        loadAd();
        onAdClosed?.call();
      },
    );

    await _interstitialAd!.show();
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
```

### 2. 사용 예시

```dart
// 레벨 클리어 시 전면 광고 표시
class GameScreen extends StatefulWidget {
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _interstitialAdService = InterstitialAdService();
  int _levelCount = 0;

  @override
  void initState() {
    super.initState();
    _interstitialAdService.loadAd(); // 미리 로드
  }

  void _onLevelComplete() {
    _levelCount++;
    
    // 3레벨마다 광고 표시
    if (_levelCount % 3 == 0) {
      _interstitialAdService.showAd(
        onAdClosed: () {
          _goToNextLevel();
        },
      );
    } else {
      _goToNextLevel();
    }
  }

  void _goToNextLevel() {
    // 다음 레벨로 이동
  }

  @override
  void dispose() {
    _interstitialAdService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _onLevelComplete,
          child: const Text('레벨 클리어!'),
        ),
      ),
    );
  }
}
```

## 전면 광고 표시 타이밍

| 상황 | 권장 여부 | 이유 |
|:---|:---|:---|
| 레벨 클리어 후 | ✅ 권장 | 자연스러운 전환점 |
| 화면 전환 시 | ✅ 권장 | 사용자 기대에 맞음 |
| 앱 시작 직후 | ❌ 비권장 | 사용자 이탈 위험 |
| 버튼 클릭 직후 | ❌ 비권장 | 실수 클릭 유발 |
| 콘텐츠 열람 중 | ❌ 비권장 | 사용자 경험 저하 |

## 빈도 제한 (Frequency Capping)

과도한 광고는 사용자 이탈을 유발합니다:

```dart
class InterstitialAdManager {
  static const int _minIntervalSeconds = 60; // 최소 1분 간격
  static const int _maxAdsPerSession = 5;    // 세션당 최대 5회
  
  DateTime? _lastAdShownTime;
  int _adsShownInSession = 0;

  bool canShowAd() {
    // 세션 제한 확인
    if (_adsShownInSession >= _maxAdsPerSession) {
      return false;
    }
    
    // 시간 간격 확인
    if (_lastAdShownTime != null) {
      final elapsed = DateTime.now().difference(_lastAdShownTime!);
      if (elapsed.inSeconds < _minIntervalSeconds) {
        return false;
      }
    }
    
    return true;
  }

  void onAdShown() {
    _lastAdShownTime = DateTime.now();
    _adsShownInSession++;
  }
}
```

## Riverpod으로 전면 광고 관리

[provider-patterns.md](provider-patterns.md)의 InterstitialAdNotifier 참조.

## 모범 사례

- 광고를 **미리 로드**해서 표시 시 지연 방지
- 자연스러운 **전환 지점**에서만 표시
- 세션당 광고 표시 **횟수 제한**
- 광고 닫힘 후 **다음 광고 미리 로드**
- 사용자가 중요한 작업 중에는 **표시하지 않음**
