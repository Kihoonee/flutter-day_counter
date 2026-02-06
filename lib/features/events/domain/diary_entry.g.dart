// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DiaryEntry _$DiaryEntryFromJson(Map<String, dynamic> json) => _DiaryEntry(
  id: json['id'] as String,
  content: json['content'] as String,
  date: DateTime.parse(json['date'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  isCompletedFromTodo: json['isCompletedFromTodo'] as bool?,
);

Map<String, dynamic> _$DiaryEntryToJson(_DiaryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'date': instance.date.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'isCompletedFromTodo': instance.isCompletedFromTodo,
    };
