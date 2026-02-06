import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/shared_prefs_provider.dart';

/// 광고 시청으로 얻은 추가 기념일 슬롯 개수를 관리하는 프로바이더
final earnedSlotsProvider = NotifierProvider<EarnedSlotsNotifier, int>(() {
  return EarnedSlotsNotifier();
});

class EarnedSlotsNotifier extends Notifier<int> {
  static const _key = 'earned_slots_count';

  @override
  int build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getInt(_key) ?? 0;
  }

  /// 슬롯 추가 (광고 시청 완료 시)
  Future<void> addSlot() async {
    final prefs = ref.read(sharedPreferencesProvider);
    state = state + 1;
    await prefs.setInt(_key, state);
  }

  /// 슬롯 사용 (기념일 저장 완료 시)
  Future<void> useSlot() async {
    if (state > 0) {
      final prefs = ref.read(sharedPreferencesProvider);
      state = state - 1;
      await prefs.setInt(_key, state);
    }
  }
}
