// lib/features/events/application/selected_event_controller.dart
import 'package:flutter_riverpod/legacy.dart';

class DraftInput {
  final DateTime baseDate;
  final DateTime? targetDate;
  final bool includeToday;
  final bool excludeWeekends;

  const DraftInput({
    required this.baseDate,
    required this.targetDate,
    required this.includeToday,
    required this.excludeWeekends,
  });

  DraftInput copyWith({
    DateTime? baseDate,
    DateTime? targetDate,
    bool? includeToday,
    bool? excludeWeekends,
  }) {
    return DraftInput(
      baseDate: baseDate ?? this.baseDate,
      targetDate: targetDate ?? this.targetDate,
      includeToday: includeToday ?? this.includeToday,
      excludeWeekends: excludeWeekends ?? this.excludeWeekends,
    );
  }
}

final draftProvider = StateProvider<DraftInput>((ref) {
  return DraftInput(
    baseDate: DateTime.now(),
    targetDate: null,
    includeToday: false,
    excludeWeekends: false,
  );
});
