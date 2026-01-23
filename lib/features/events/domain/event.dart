import 'package:freezed_annotation/freezed_annotation.dart';

import 'todo_item.dart';
import 'diary_entry.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
abstract class Event with _$Event {
  const factory Event({
    required String id,
    required String title,

    // 기준일
    required DateTime baseDate,

    // 목표일
    required DateTime targetDate,

    // 당일 포함
    @Default(false) bool includeToday,

    // 주말 제외
    @Default(false) bool excludeWeekends,

    // 카드 테마(0~n)
    @Default(0) int themeIndex,

    // 투두 리스트
    @Default([]) List<TodoItem> todos,

    // 다이어리
    @Default([]) List<DiaryEntry> diaryEntries,

  }) = _Event;



  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

}
