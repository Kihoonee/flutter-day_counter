import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ads/ad_units.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;
    // AdMob 초기화 대기를 위해 약간의 지연 후 로드
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _loadAd();
    });
  }

  void _loadAd() {
    if (kIsWeb) return;
    if (_bannerAd != null) return;

    _bannerAd = BannerAd(
      adUnitId: AdUnits.bannerId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _isAdLoaded = true;
          });
          debugPrint('BannerAdWidget: BannerAd loaded successfully.');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAdWidget: BannerAd failed to load: $error');
          ad.dispose();
          _bannerAd = null;
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
            // 3초 후 재시도
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) _loadAd();
            });
          }
        },
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
    final theme = Theme.of(context);
    
    // Reserve space for layout stability
    return Container(
      width: double.infinity,
      height: 60,
      alignment: Alignment.center,
      color: theme.scaffoldBackgroundColor, // Match background
      child: _isAdLoaded && _bannerAd != null
          ? SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : Text(
              'Days+', // Subtle placeholder
              style: TextStyle(
                color: theme.hintColor.withOpacity(0.2),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
