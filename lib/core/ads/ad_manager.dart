import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_units.dart';

/// 광고 노출 빈도 및 상태 관리를 담당하는 매니저
class AdManager {
  AdManager._();
  static final AdManager instance = AdManager._();

  AppOpenAd? _appOpenAd;
  InterstitialAd? _interstitialAd;
  
  bool _isAppOpenAdLoading = false;
  bool _isInterstitialAdLoading = false;
  
  // 로드 완료 즉시 노출 여부 (콜드 스타트용)
  bool _showOnLoad = false;

  DateTime? _lastAppOpenAdShownAt;
  int _appOpenAdShownCountToday = 0;
  DateTime? _lastCountResetDate;

  int _interstitialCounter = 0;
  int _interstitialShownCountSession = 0;

  // 상수 설정
  static const int minAppOpenIntervalMinutes = 15; // 실제 서비스는 60분 (테스트를 위해 단축)
  static const int maxAppOpenAdsPerDay = 10;      // 하루 최대 10회
  static const int interstitialFrequency = 3;    // 3회 전환당 1회 (테스트 용이성)
  static const int maxInterstitialPerSession = 5; // 세션당 최대 5회

  /// 앱 오픈 광고 로드
  void loadAppOpenAd() {
    if (kIsWeb) return;
    if (_appOpenAd != null || _isAppOpenAdLoading) {
      debugPrint('AdManager: loadAppOpenAd skipped. Ad exists: ${_appOpenAd != null}, Loading: $_isAppOpenAdLoading');
      return;
    }

    _isAppOpenAdLoading = true;
    debugPrint('AdManager: Starting to load AppOpenAd with ID: ${AdUnits.appOpenId}');
    AppOpenAd.load(
      adUnitId: AdUnits.appOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdLoading = false;
          debugPrint('AdManager: AppOpenAd loaded successfully.');
          
          if (_showOnLoad) {
            debugPrint('AdManager: _showOnLoad is true, showing ad after short delay.');
            _showOnLoad = false;
            Future.delayed(const Duration(milliseconds: 500), () {
              showAppOpenAdIfAvailable();
            });
          }
        },
        onAdFailedToLoad: (error) {
          _isAppOpenAdLoading = false;
          debugPrint('AdManager: AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  /// 앱 오픈 광고 노출 시도
  void showAppOpenAdIfAvailable({bool isColdStart = false}) {
    if (kIsWeb) return;
    
    debugPrint('AdManager: showAppOpenAdIfAvailable called. ColdStart: $isColdStart');

    if (_appOpenAd == null) {
      debugPrint('AdManager: AppOpenAd not ready.');
      if (isColdStart) {
        debugPrint('AdManager: Enabling _showOnLoad for cold start.');
        _showOnLoad = true;
      }
      loadAppOpenAd();
      return;
    }

    // 빈도 제한 체크
    if (!shouldShowAppOpenAd()) {
      debugPrint('AdManager: AppOpenAd skipped due to frequency capping.');
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('AdManager: [SUCCESS] AppOpenAd showed full screen content.');
        _lastAppOpenAdShownAt = DateTime.now();
        _updateAppOpenCount();
      },
      onAdImpression: (ad) {
        debugPrint('AdManager: [EVENT] AppOpenAd impression registered.');
      },
      onAdClicked: (ad) {
        debugPrint('AdManager: [EVENT] AppOpenAd clicked.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdManager: [EVENT] AppOpenAd dismissed.');
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdManager: [ERROR] AppOpenAd failed to show: ${error.code} - ${error.message}');
        debugPrint('AdManager: [ERROR] Error domain: ${error.domain}');
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
    );

    debugPrint('AdManager: Final check before show - Ad object: ${_appOpenAd!.hashCode}');
    debugPrint('AdManager: Calling _appOpenAd!.show() now...');
    _appOpenAd!.show();
  }

  bool shouldShowAppOpenAd() {
    if (kIsWeb) return false;
    
    final now = DateTime.now();

    // 테스트 모드에서도 최소한의 간격(30초)은 강제하여 안드로이드 루프 방지
    if (AdUnits.isTestMode) {
      if (_lastAppOpenAdShownAt != null) {
        final secondsDiff = now.difference(_lastAppOpenAdShownAt!).inSeconds;
        if (secondsDiff < 30) {
          debugPrint('AdManager: [TestMode] Interval not reached: ${secondsDiff}s < 30s');
          return false;
        }
      }
      return true;
    }

    // 1. 하루 횟수 초기화 체크
    if (_lastCountResetDate == null || 
        _lastCountResetDate!.day != now.day) {
      _appOpenAdShownCountToday = 0;
      _lastCountResetDate = now;
    }

    // 2. 최대 횟수 도달 여부
    if (_appOpenAdShownCountToday >= maxAppOpenAdsPerDay) {
      debugPrint('AdManager: Max AppOpenAds per day reached.');
      return false;
    }

    // 3. 마지막 노출 후 경과 시간 체크
    if (_lastAppOpenAdShownAt != null) {
      final diff = now.difference(_lastAppOpenAdShownAt!).inMinutes;
      if (diff < minAppOpenIntervalMinutes) {
        debugPrint('AdManager: Minute interval not reached: $diff < $minAppOpenIntervalMinutes');
        return false;
      }
    }

    return true;
  }

  void _updateAppOpenCount() {
    _appOpenAdShownCountToday++;
  }

  /// 전면 광고 로드
  void loadInterstitialAd() {
    if (kIsWeb) return;
    if (_interstitialAd != null || _isInterstitialAdLoading) return;

    _isInterstitialAdLoading = true;
    InterstitialAd.load(
      adUnitId: AdUnits.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
          debugPrint('AdManager: InterstitialAd loaded.');
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoading = false;
          debugPrint('AdManager: InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  bool shouldShowInterstitial() {
    // 1. 세션당 최대 횟수 체크
    if (_interstitialShownCountSession >= maxInterstitialPerSession) {
      debugPrint('AdManager: Max Interstitials per session reached.');
      return false;
    }

    // 2. 빈도 체크
    if (_interstitialCounter % interstitialFrequency != 0) {
      debugPrint('AdManager: Interstitial frequency not reached: $_interstitialCounter % $interstitialFrequency != 0');
      return false;
    }

    return true;
  }

  /// 전면 광고 노출 시도 (화면 전환 카운트 기반)
  void showInterstitialAdWithCount() {
    if (kIsWeb) return;
    _interstitialCounter++;
    debugPrint('AdManager: showInterstitialAdWithCount: counter is now $_interstitialCounter');

    if (_interstitialAd == null) {
      debugPrint('AdManager: InterstitialAd not ready, loading...');
      loadInterstitialAd();
      return;
    }

    if (!shouldShowInterstitial()) return;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('AdManager: InterstitialAd showed full screen content.');
        _interstitialShownCountSession++;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdManager: InterstitialAd dismissed.');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdManager: InterstitialAd failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
      },
    );

    _interstitialAd!.show();
  }
}
