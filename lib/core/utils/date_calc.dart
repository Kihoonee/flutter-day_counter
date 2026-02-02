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

    var d = t.difference(b).inDays;
    if (includeToday) {
      // 같은 날짜면 0 -> 1, D-0을 D-1로 보이게 하는 스타일
      d = d >= 0 ? d + 1 : d - 1;
    }
    return d;
  }
}
