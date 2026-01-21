# Riverpod Provider 패턴

AdMob 광고를 Riverpod으로 관리하기 위한 패턴입니다.

## 광고 서비스 Provider

### 1. 기본 광고 서비스 Provider

```dart
// lib/core/ads/providers/ad_service_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 광고 SDK 초기화 상태
final adInitializationProvider = FutureProvider<InitializationStatus>((ref) async {
  return await MobileAds.instance.initialize();
});
```

### 2. 배너 광고 Provider

```dart
// lib/core/ads/providers/banner_ad_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_units.dart';

part 'banner_ad_provider.g.dart';

@riverpod
class BannerAdNotifier extends _$BannerAdNotifier {
  BannerAd? _bannerAd;

  @override
  AsyncValue<BannerAd?> build() {
    ref.onDispose(() => _bannerAd?.dispose());
    _loadAd();
    return const AsyncValue.loading();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdUnits.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          state = AsyncValue.data(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          state = AsyncValue.error(error, StackTrace.current);
        },
      ),
    )..load();
  }

  void reload() {
    _bannerAd?.dispose();
    state = const AsyncValue.loading();
    _loadAd();
  }
}
```

### 3. 전면 광고 Provider

```dart
// lib/core/ads/providers/interstitial_ad_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_units.dart';

part 'interstitial_ad_provider.g.dart';

@riverpod
class InterstitialAdNotifier extends _$InterstitialAdNotifier {
  InterstitialAd? _interstitialAd;

  @override
  bool build() {
    ref.onDispose(() => _interstitialAd?.dispose());
    _loadAd();
    return false; // isLoaded 상태
  }

  void _loadAd() {
    InterstitialAd.load(
      adUnitId: AdUnits.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          state = true;
        },
        onAdFailedToLoad: (error) {
          state = false;
        },
      ),
    );
  }

  Future<void> showAd({VoidCallback? onAdClosed}) async {
    if (!state || _interstitialAd == null) {
      onAdClosed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        state = false;
        _loadAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        state = false;
        _loadAd();
        onAdClosed?.call();
      },
    );

    await _interstitialAd!.show();
  }
}
```

### 4. 보상형 광고 Provider

```dart
// lib/core/ads/providers/rewarded_ad_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_units.dart';

part 'rewarded_ad_provider.g.dart';

@riverpod
class RewardedAdNotifier extends _$RewardedAdNotifier {
  RewardedAd? _rewardedAd;

  @override
  bool build() {
    ref.onDispose(() => _rewardedAd?.dispose());
    _loadAd();
    return false;
  }

  void _loadAd() {
    RewardedAd.load(
      adUnitId: AdUnits.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          state = true;
        },
        onAdFailedToLoad: (error) {
          state = false;
        },
      ),
    );
  }

  Future<void> showAd({
    required void Function(RewardItem reward) onRewarded,
    VoidCallback? onAdClosed,
  }) async {
    if (!state || _rewardedAd == null) return;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        state = false;
        _loadAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        state = false;
        _loadAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) => onRewarded(reward),
    );
  }
}
```

## 사용 예시

### Screen에서 광고 사용하기

```dart
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerAd = ref.watch(bannerAdNotifierProvider);
    final isRewardedReady = ref.watch(rewardedAdNotifierProvider);

    return Scaffold(
      body: Column(
        children: [
          // 콘텐츠
          Expanded(child: GameContent()),
          
          // 배너 광고
          bannerAd.when(
            data: (ad) => ad != null
                ? SizedBox(
                    height: ad.size.height.toDouble(),
                    child: AdWidget(ad: ad),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox(height: 50),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isRewardedReady
            ? () => ref.read(rewardedAdNotifierProvider.notifier).showAd(
                  onRewarded: (reward) {
                    // 보상 처리
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${reward.amount} 획득!')),
                    );
                  },
                )
            : null,
        child: Icon(isRewardedReady ? Icons.play_arrow : Icons.hourglass_empty),
      ),
    );
  }
}
```

### 전면 광고 표시 (레벨 클리어)

```dart
void _onLevelComplete(WidgetRef ref) {
  final interstitialNotifier = ref.read(interstitialAdNotifierProvider.notifier);
  
  interstitialNotifier.showAd(
    onAdClosed: () {
      // 다음 레벨로 이동
      context.go('/level/${currentLevel + 1}');
    },
  );
}
```

## 광고 빈도 관리 Provider

```dart
// lib/core/ads/providers/ad_frequency_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ad_frequency_provider.g.dart';

@riverpod
class AdFrequencyManager extends _$AdFrequencyManager {
  static const int _maxAdsPerSession = 5;
  static const Duration _minInterval = Duration(seconds: 60);

  @override
  AdFrequencyState build() {
    return AdFrequencyState(
      adsShown: 0,
      lastAdTime: null,
    );
  }

  bool canShowAd() {
    if (state.adsShown >= _maxAdsPerSession) return false;
    if (state.lastAdTime != null) {
      final elapsed = DateTime.now().difference(state.lastAdTime!);
      if (elapsed < _minInterval) return false;
    }
    return true;
  }

  void onAdShown() {
    state = state.copyWith(
      adsShown: state.adsShown + 1,
      lastAdTime: DateTime.now(),
    );
  }
}

class AdFrequencyState {
  final int adsShown;
  final DateTime? lastAdTime;

  AdFrequencyState({required this.adsShown, this.lastAdTime});

  AdFrequencyState copyWith({int? adsShown, DateTime? lastAdTime}) {
    return AdFrequencyState(
      adsShown: adsShown ?? this.adsShown,
      lastAdTime: lastAdTime ?? this.lastAdTime,
    );
  }
}
```

## 파일 구조

```
lib/core/ads/
├── constants/
│   └── ad_units.dart
├── providers/
│   ├── ad_service_provider.dart
│   ├── banner_ad_provider.dart
│   ├── interstitial_ad_provider.dart
│   ├── rewarded_ad_provider.dart
│   └── ad_frequency_provider.dart
└── widgets/
    ├── banner_ad_widget.dart
    └── native_ad_widget.dart
```
