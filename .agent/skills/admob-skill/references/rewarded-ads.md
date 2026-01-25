# 보상형 광고 (Rewarded Ads)

사용자가 광고를 시청하면 보상(게임 아이템, 추가 기능 등)을 받는 광고입니다. 사용자가 자발적으로 선택하므로 만족도가 높습니다.

## 기본 구현

### 1. RewardedAd 서비스 만들기

```dart
// lib/core/ads/rewarded_ad_service.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_units.dart';

class RewardedAdService {
  RewardedAd? _rewardedAd;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  /// 광고 미리 로드
  void loadAd() {
    RewardedAd.load(
      adUnitId: AdUnits.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _isLoaded = false;
          print('보상형 광고 로드 실패: ${error.message}');
        },
      ),
    );
  }

  /// 광고 표시 및 보상 처리
  Future<void> showAd({
    required void Function(RewardItem reward) onRewarded,
    VoidCallback? onAdClosed,
  }) async {
    if (!_isLoaded || _rewardedAd == null) {
      print('보상형 광고가 아직 로드되지 않음');
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isLoaded = false;
        loadAd(); // 다음 광고 미리 로드
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isLoaded = false;
        loadAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded(reward);
      },
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}
```

### 2. 사용 예시: 추가 목숨 얻기

```dart
class GameOverScreen extends StatefulWidget {
  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  final _rewardedAdService = RewardedAdService();

  @override
  void initState() {
    super.initState();
    _rewardedAdService.loadAd();
  }

  void _watchAdForExtraLife() {
    _rewardedAdService.showAd(
      onRewarded: (reward) {
        // 보상 지급
        setState(() {
          // 예: 목숨 +1
          GameState.lives += reward.amount.toInt();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${reward.amount} 목숨을 획득했습니다!')),
        );
      },
      onAdClosed: () {
        // 광고 닫힌 후 처리
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('게임 오버!', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 20),
            
            // 광고 시청 버튼
            ElevatedButton.icon(
              onPressed: _rewardedAdService.isLoaded 
                  ? _watchAdForExtraLife 
                  : null,
              icon: const Icon(Icons.play_circle),
              label: Text(
                _rewardedAdService.isLoaded 
                    ? '광고 보고 목숨 얻기' 
                    : '광고 로딩 중...',
              ),
            ),
            
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('메인으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rewardedAdService.dispose();
    super.dispose();
  }
}
```

## 보상 유형 및 설정

AdMob 콘솔에서 보상을 설정합니다:

| 보상 유형 | 예시 | amount 값 |
|:---|:---|:---|
| 코인 | 게임 내 화폐 | 100 |
| 목숨 | 추가 플레이 기회 | 1 |
| 아이템 | 특별 아이템 | 1 |
| 시간 | 쿨다운 스킵 | 1 (시간 단위) |

```dart
// 보상 처리 예시
void _handleReward(RewardItem reward) {
  final type = reward.type;    // String: "coins", "lives" 등
  final amount = reward.amount; // num: 보상 수량
  
  switch (type) {
    case 'coins':
      UserWallet.addCoins(amount.toInt());
      break;
    case 'lives':
      GameState.addLives(amount.toInt());
      break;
    default:
      // 기본 보상 처리
      break;
  }
}
```

## 보상 확정 타이밍

> [!IMPORTANT]
> 보상은 `onUserEarnedReward` 콜백에서 지급해야 합니다.
> `onAdDismissedFullScreenContent`에서 지급하면 사용자가 광고를 끝까지 보지 않아도 보상을 받게 됩니다.

## 보상형 광고 UX 모범 사례

1. **명확한 가치 제안**: "광고 보고 100 코인 받기" 처럼 보상을 명시
2. **선택적 시청**: 사용자가 원할 때만 광고 볼 수 있도록
3. **로딩 상태 표시**: 광고 준비 중일 때 버튼 비활성화
4. **확인 다이얼로그**: 실수 클릭 방지 (선택적)
5. **보상 확인 표시**: 보상 지급 후 피드백 제공

## Riverpod으로 보상형 광고 관리

[provider-patterns.md](provider-patterns.md)의 RewardedAdNotifier 참조.
