// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Event _$EventFromJson(Map<String, dynamic> json) => _Event(
  id: json['id'] as String,
  title: json['title'] as String,
  baseDate: DateTime.parse(json['baseDate'] as String),
  targetDate: DateTime.parse(json['targetDate'] as String),
  includeToday: json['includeToday'] as bool? ?? false,
  isNotificationEnabled: json['isNotificationEnabled'] as bool? ?? true,
  themeIndex: (json['themeIndex'] as num?)?.toInt() ?? 0,
  iconIndex: (json['iconIndex'] as num?)?.toInt() ?? 0,
  photoPath: json['photoPath'] as String?,
  todos:
      (json['todos'] as List<dynamic>?)
          ?.map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  diaryEntries:
      (json['diaryEntries'] as List<dynamic>?)
          ?.map((e) => DiaryEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  widgetLayoutType: (json['widgetLayoutType'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$EventToJson(_Event instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'baseDate': instance.baseDate.toIso8601String(),
  'targetDate': instance.targetDate.toIso8601String(),
  'includeToday': instance.includeToday,
  'isNotificationEnabled': instance.isNotificationEnabled,
  'themeIndex': instance.themeIndex,
  'iconIndex': instance.iconIndex,
  'photoPath': instance.photoPath,
  'todos': instance.todos.map((e) => e.toJson()).toList(),
  'diaryEntries': instance.diaryEntries.map((e) => e.toJson()).toList(),
  'sortOrder': instance.sortOrder,
  'widgetLayoutType': instance.widgetLayoutType,
};
