import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_item.freezed.dart';
part 'todo_item.g.dart';

/// 이벤트에 연결된 할 일 항목
@freezed
abstract class TodoItem with _$TodoItem {
  const factory TodoItem({
    required String id,
    required String content,
    @Default(false) bool isCompleted,
    required DateTime createdAt,
  }) = _TodoItem;

  factory TodoItem.fromJson(Map<String, dynamic> json) => _$TodoItemFromJson(json);
}
