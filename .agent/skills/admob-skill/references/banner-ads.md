# 배너 광고 (Banner Ads)

화면 상단 또는 하단에 고정되는 직사각형 광고입니다. 가장 기본적이고 사용하기 쉬운 광고 형태입니다.

## 기본 구현

### 1. BannerAd 위젯 만들기

```dart
// lib/core/ads/banner_ad_widget.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_units.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  
  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdUnits.bannerId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('배너 광고 로드 실패: ${error.message}');
          ad.dispose();
        },
        onAdOpened: (ad) => debugPrint('배너 광고 열림'),
        onAdClosed: (ad) => debugPrint('배너 광고 닫힘'),
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return SizedBox(
        height: widget.adSize.height.toDouble(),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      width: widget.adSize.width.toDouble(),
      height: widget.adSize.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
```

### 2. 화면에서 사용하기

```dart
// 예: 홈 화면
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('홈')),
      body: const Center(child: Text('콘텐츠')),
      // 하단에 배너 광고 배치
      bottomNavigationBar: const BannerAdWidget(),
    );
  }
}
```

## 배너 크기 옵션

| 크기 | 상수 | 설명 |
|:---|:---|:---|
| 320x50 | `AdSize.banner` | 표준 배너 (가장 일반적) |
| 320x100 | `AdSize.largeBanner` | 큰 배너 |
| 300x250 | `AdSize.mediumRectangle` | 중간 직사각형 |
| 468x60 | `AdSize.fullBanner` | 풀 배너 |
| 728x90 | `AdSize.leaderboard` | 리더보드 (태블릿) |

## 적응형 배너 (권장)

화면 너비에 맞게 자동 조절되는 배너:

```dart
// 적응형 배너 크기 계산
Future<AdSize> _getAdaptiveBannerSize() async {
  final AnchoredAdaptiveBannerAdSize? size =
      await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
    MediaQuery.of(context).size.width.truncate(),
  );
  return size ?? AdSize.banner;
}
```

## Riverpod으로 배너 광고 관리

[provider-patterns.md](provider-patterns.md)의 BannerAdNotifier 참조.

## 모범 사례

- 콘텐츠와 겹치지 않게 배치
- 스크롤 중에도 고정 위치 유지
- 광고가 로드되지 않았을 때 빈 공간 처리
- 화면당 1개의 배너만 표시 권장
