# 네이티브 광고 (Native Ads)

앱의 UI와 자연스럽게 어울리도록 맞춤 디자인할 수 있는 광고입니다. 피드, 리스트, 콘텐츠 사이에 배치하기 적합합니다.

## 기본 구현

### 1. NativeAd 위젯 만들기

```dart
// lib/core/ads/native_ad_widget.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_units.dart';

class NativeAdWidget extends StatefulWidget {
  final String templateType; // 'small' 또는 'medium'
  
  const NativeAdWidget({
    super.key,
    this.templateType = 'medium',
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: AdUnits.nativeId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('네이티브 광고 로드 실패: ${error.message}');
          ad.dispose();
        },
      ),
      // 네이티브 템플릿 사용
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.templateType == 'small'
            ? TemplateType.small
            : TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.blue,
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _nativeAd == null) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      constraints: BoxConstraints(
        maxHeight: widget.templateType == 'small' ? 100 : 300,
      ),
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
```

### 2. 리스트에서 사용하기

```dart
class FeedScreen extends StatelessWidget {
  final List<FeedItem> items;

  const FeedScreen({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length + (items.length ~/ 5), // 5개마다 광고 삽입
      itemBuilder: (context, index) {
        // 5개 아이템마다 네이티브 광고 삽입
        final adFrequency = 5;
        final adsBeforeIndex = index ~/ (adFrequency + 1);
        final isAdPosition = (index - adsBeforeIndex) % (adFrequency + 1) == adFrequency;
        
        if (isAdPosition) {
          return const NativeAdWidget(templateType: 'medium');
        }
        
        final itemIndex = index - adsBeforeIndex - (isAdPosition ? 1 : 0);
        return FeedItemCard(item: items[itemIndex]);
      },
    );
  }
}
```

### 3. 네이티브 광고 리스트 헬퍼

```dart
// lib/core/ads/native_ad_list_helper.dart

/// 리스트에 네이티브 광고를 삽입하는 헬퍼
class NativeAdListHelper<T> {
  final List<T> items;
  final int adFrequency; // 몇 개 아이템마다 광고 삽입

  NativeAdListHelper({
    required this.items,
    this.adFrequency = 5,
  });

  int get totalCount {
    if (items.isEmpty) return 0;
    return items.length + (items.length ~/ adFrequency);
  }

  bool isAdPosition(int index) {
    return (index + 1) % (adFrequency + 1) == 0;
  }

  T? getItem(int index) {
    if (isAdPosition(index)) return null;
    
    final adCount = index ~/ (adFrequency + 1);
    final itemIndex = index - adCount;
    
    if (itemIndex >= items.length) return null;
    return items[itemIndex];
  }
}

// 사용 예시
final helper = NativeAdListHelper(items: myItems, adFrequency: 5);

ListView.builder(
  itemCount: helper.totalCount,
  itemBuilder: (context, index) {
    if (helper.isAdPosition(index)) {
      return const NativeAdWidget();
    }
    final item = helper.getItem(index);
    return ItemWidget(item: item!);
  },
);
```

## 네이티브 템플릿 스타일

| 템플릿 | 크기 | 적합한 용도 |
|:---|:---|:---|
| `TemplateType.small` | 높이 ~90dp | 피드 아이템 사이, 컴팩트한 레이아웃 |
| `TemplateType.medium` | 높이 ~300dp | 콘텐츠 중간, 상세 정보 표시 |

## 스타일 커스터마이징

```dart
NativeTemplateStyle(
  templateType: TemplateType.medium,
  mainBackgroundColor: Theme.of(context).cardColor,
  cornerRadius: 16.0,
  callToActionTextStyle: NativeTemplateTextStyle(
    textColor: Colors.white,
    backgroundColor: Theme.of(context).primaryColor,
    style: NativeTemplateFontStyle.bold,
    size: 14.0,
  ),
  // 앱 테마에 맞게 스타일 조정
)
```

## 모범 사례

- 콘텐츠와 **자연스럽게 어울리는** 디자인 사용
- 광고임을 **명확히 표시** (AdMob이 자동으로 "광고" 라벨 추가)
- 피드에서 **일정 간격**으로 배치 (5~10개 아이템마다)
- **사용자 경험** 저해하지 않는 선에서 배치
- 로딩 중 **플레이스홀더** 표시
