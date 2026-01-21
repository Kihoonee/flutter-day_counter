// lib/core/utils/date_calc.dart
class DateCalc {
  /// base -> target 일수 차이
  /// includeToday: 당일 포함이면 +1 처리(방향에 맞게)
  /// excludeWeekends: 토/일은 카운트에서 제외
  static int diffDays({
    required DateTime base,
    required DateTime target,
    required bool includeToday,
    required bool excludeWeekends,
  }) {
    final b = DateTime(base.year, base.month, base.day);
    final t = DateTime(target.year, target.month, target.day);

    if (!excludeWeekends) {
      var d = t.difference(b).inDays;
      if (includeToday) {
        // 같은 날짜면 0 -> 1, D-0을 D-1로 보이게 하는 스타일
        d = d >= 0 ? d + 1 : d - 1;
      }
      return d;
    }

    // 주말 제외: 하루씩 순회(최소 MVP에서는 단순/명확이 최고)
    int step = t.isAfter(b) ? 1 : -1;
    int count = 0;
    var cur = b;

    while (cur != t) {
      cur = cur.add(Duration(days: step));
      if (!_isWeekend(cur)) count += step;
    }

    if (includeToday && !_isWeekend(b)) {
      count = count >= 0 ? count + 1 : count - 1;
    }
    return count;
  }

  static bool _isWeekend(DateTime d) {
    return d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;
  }
}
