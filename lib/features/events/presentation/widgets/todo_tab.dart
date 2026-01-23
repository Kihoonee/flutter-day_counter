import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../application/event_controller.dart';
import '../../domain/event.dart';
import '../../domain/todo_item.dart';

/// 할 일 탭 - 체크리스트 형태의 투두 목록
class TodoTab extends ConsumerStatefulWidget {
  final Event event;
  const TodoTab({super.key, required this.event});

  @override
  ConsumerState<TodoTab> createState() => _TodoTabState();
}

class _TodoTabState extends ConsumerState<TodoTab> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _addTodo() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final newTodo = TodoItem(
      id: const Uuid().v4(),
      content: content,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    final updatedTodos = [...widget.event.todos, newTodo];
    final updatedEvent = widget.event.copyWith(todos: updatedTodos);

    await ref.read(eventsProvider.notifier).upsert(updatedEvent);
    
    if (!mounted) return;
    _controller.clear();
    _focusNode.requestFocus();
  }

  Future<void> _toggleTodo(TodoItem todo) async {
    final updatedTodos = widget.event.todos.map((t) {
      if (t.id == todo.id) {
        return t.copyWith(isCompleted: !t.isCompleted);
      }
      return t;
    }).toList();

    final updatedEvent = widget.event.copyWith(todos: updatedTodos);
    await ref.read(eventsProvider.notifier).upsert(updatedEvent);
  }

  Future<void> _removeTodo(TodoItem todo) async {
    final updatedTodos =
        widget.event.todos.where((t) => t.id != todo.id).toList();
    final updatedEvent = widget.event.copyWith(todos: updatedTodos);
    await ref.read(eventsProvider.notifier).upsert(updatedEvent);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todos = widget.event.todos;

    // 미완료 항목을 위로, 완료 항목을 아래로 정렬
    final sortedTodos = [...todos]..sort((a, b) {
        if (a.isCompleted == b.isCompleted) {
          return b.createdAt.compareTo(a.createdAt); // 최신순
        }
        return a.isCompleted ? 1 : -1; // 미완료 먼저
      });

    return Column(
      children: [
        // 할 일 입력 필드
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: '할 일 추가...',
                    hintStyle: TextStyle(color: theme.colorScheme.outline.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (_) => _addTodo(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addTodo,
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),
        ),

        // 할 일 목록
        Expanded(
          child: todos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.checklist_rounded,
                        size: 64,
                        color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '할 일을 추가해보세요',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '작은 목표부터 시작해볼까요?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sortedTodos.length,
                  itemBuilder: (context, index) {
                    final todo = sortedTodos[index];
                    return Dismissible(
                      key: Key(todo.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _removeTodo(todo),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                           color: theme.colorScheme.errorContainer,
                           borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.delete_rounded,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                      child: Card(
                        elevation: 0,
                        color: theme.colorScheme.surfaceContainerLow.withOpacity(0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: CheckboxListTile(
                          value: todo.isCompleted,
                          onChanged: (_) => _toggleTodo(todo),
                          title: Text(
                            todo.content,
                            style: TextStyle(
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: todo.isCompleted
                                  ? theme.colorScheme.outline
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
