import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Analytics 이벤트를 중앙 관리하는 서비스
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// 기본 이벤트 로그
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      debugPrint('Analytics: EventLogged -> $name, params: $parameters');
    } catch (e) {
      debugPrint('AnalyticsError: $e');
    }
  }

  /// 기념일 한도 도달
  Future<void> logLimitReached(int currentCount) async {
    await logEvent(
      name: 'limit_reached',
      parameters: {'current_count': currentCount},
    );
  }

  /// 보상형 광고 시청 시작
  Future<void> logAdRewardStart() async {
    await logEvent(name: 'ad_reward_start');
  }

  /// 보상형 광고 시청 완료 (보상 획득)
  Future<void> logAdRewardComplete() async {
    await logEvent(name: 'ad_reward_complete');
  }

  /// 보상형 광고 시청 취소/실패
  Future<void> logAdRewardCancel() async {
    await logEvent(name: 'ad_reward_cancel');
  }
}
