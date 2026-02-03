// lib/core/utils/date_calc.dart
class DateCalc {
  /// base -> target 일수 차이
  /// includeToday: 당일 포함이면 +1 처리(방향에 맞게)
  static int diffDays({
    required DateTime base,
    required DateTime target,
    required bool includeToday,
  }) {
    final b = DateTime(base.year, base.month, base.day);
    final t = DateTime(target.year, target.month, target.day);

    int d = t.difference(b).inDays;
    if (includeToday && d <= 0) {
      // 오늘이거나 과거일 때만 1일차부터 시작하도록 처리
      // 0(오늘) -> -1 -> UI에서 D+1로 표시
      // -1(어제) -> -2 -> UI에서 D+2로 표시
      d -= 1;
    }
    return d;
  }
}
