import 'package:flutter/services.dart';

/// 햅틱 피드백 헬퍼 유틸리티
/// 
/// 앱 전체에서 일관된 햅틱 피드백을 제공합니다.
class HapticHelper {
  /// 가벼운 햅틱 (체크박스, 일반 버튼)
  static Future<void> light() => HapticFeedback.lightImpact();

  /// 중간 강도 햅틱 (저장, 삭제)
  static Future<void> medium() => HapticFeedback.mediumImpact();

  /// 무거운 햅틱 (중요한 액션, 경고)
  static Future<void> heavy() => HapticFeedback.heavyImpact();

  /// 선택 클릭 햅틱 (아이콘/테마 탐색)
  static Future<void> selection() => HapticFeedback.selectionClick();

  /// 보상 획득 특별 햅틱 (2단계: 무거움 → 가벼움)
  /// 
  /// 광고 시청 완료 등 긍정적인 보상 획득 순간에 사용
  static Future<void> reward() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// 에러/실패 햅틱 (연속 2회 중간 강도)
  /// 
  /// 작업 실패나 에러 발생 시 사용 (선택사항)
  static Future<void> error() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }
}
