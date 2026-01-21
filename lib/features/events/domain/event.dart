import 'package:freezed_annotation/freezed_annotation.dart';

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

  }) = _Event;



  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

}
