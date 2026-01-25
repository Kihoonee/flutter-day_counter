---
name: admob-integration
description: Flutter 앱에 Google AdMob 광고를 통합하는 가이드. 배너 광고, 전면 광고, 보상형 광고, 네이티브 광고, 앱 오픈 광고 등 모든 광고 유형을 지원합니다. "광고를 추가해줘", "배너 광고를 넣어줘", "보상형 광고를 구현해줘", "AdMob을 설정해줘" 등의 요청에 사용하세요.
---

# AdMob 통합 스킬

Flutter 앱에 Google Mobile Ads (AdMob)를 통합하기 위한 가이드입니다.

## 빠른 시작

### 1. 의존성 추가

```yaml
# pubspec.yaml
dependencies:
  google_mobile_ads: ^7.0.0
```

### 2. 플랫폼별 설정

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<manifest>
    <application>
        <!-- AdMob App ID -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713"/> <!-- 테스트용 샘플 ID -->
    </application>
</manifest>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string> <!-- 테스트용 샘플 ID -->
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
  <!-- 추가 SKAdNetwork ID는 Google 문서 참조 -->
</array>
```

### 3. 초기화

```dart
// main.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const MyApp());
}
```

## 광고 유형별 가이드

광고 유형에 따라 적절한 참조 파일을 확인하세요:

| 광고 유형 | 설명 | 참조 파일 |
|:---|:---|:---|
| 배너 광고 | 화면 상단/하단에 고정되는 직사각형 광고 | [banner-ads.md](references/banner-ads.md) |
| 전면 광고 | 화면 전체를 덮는 광고 (레벨 클리어, 화면 전환 시) | [interstitial-ads.md](references/interstitial-ads.md) |
| 보상형 광고 | 시청 시 보상을 주는 광고 (게임 아이템, 추가 기능) | [rewarded-ads.md](references/rewarded-ads.md) |
| 네이티브 광고 | 앱 UI와 자연스럽게 어울리는 맞춤형 광고 | [native-ads.md](references/native-ads.md) |
| 앱 오픈 광고 | 앱 시작/포그라운드 복귀 시 표시되는 광고 | [app-open-ads.md](references/app-open-ads.md) |

## 테스트 광고 ID

개발 중에는 항상 테스트 광고 ID를 사용하세요:

```dart
// lib/core/constants/ad_units.dart

class AdUnits {
  // 테스트 모드 여부 (배포 시 false로 변경)
  static const bool isTestMode = true;

  // 배너 광고
  static String get bannerId {
    if (isTestMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    return Platform.isAndroid ? '실제_Android_배너_ID' : '실제_iOS_배너_ID';
  }

  // 전면 광고
  static String get interstitialId {
    if (isTestMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    return Platform.isAndroid ? '실제_Android_전면_ID' : '실제_iOS_전면_ID';
  }

  // 보상형 광고
  static String get rewardedId {
    if (isTestMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    }
    return Platform.isAndroid ? '실제_Android_보상형_ID' : '실제_iOS_보상형_ID';
  }

  // 네이티브 광고
  static String get nativeId {
    if (isTestMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/2247696110'
          : 'ca-app-pub-3940256099942544/3986624511';
    }
    return Platform.isAndroid ? '실제_Android_네이티브_ID' : '실제_iOS_네이티브_ID';
  }

  // 앱 오픈 광고
  static String get appOpenId {
    if (isTestMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/9257395921'
          : 'ca-app-pub-3940256099942544/5575463023';
    }
    return Platform.isAndroid ? '실제_Android_앱오픈_ID' : '실제_iOS_앱오픈_ID';
  }
}
```

## Riverpod과 함께 사용하기

광고 상태를 Riverpod으로 관리하려면 [provider-patterns.md](references/provider-patterns.md)를 참조하세요.

## 주의사항

> [!CAUTION]
> - 실제 광고 ID로 개발 중 테스트하면 계정이 정지될 수 있습니다.
> - 광고를 너무 자주 표시하면 사용자 경험이 저하되고 정책 위반이 될 수 있습니다.
> - 앱 스토어 심사 전 AdMob 정책을 반드시 확인하세요.

## 권장 광고 배치 전략

| 시나리오 | 권장 광고 유형 |
|:---|:---|
| 메인 화면 하단 | 배너 광고 |
| 레벨 클리어 후 | 전면 광고 (3~5회 플레이당 1회) |
| 추가 목숨/아이템 획득 | 보상형 광고 |
| 피드 사이사이 | 네이티브 광고 |
| 앱 시작/복귀 | 앱 오픈 광고 |
