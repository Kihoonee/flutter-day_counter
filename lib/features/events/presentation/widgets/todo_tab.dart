import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

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
    final updatedTodos = widget.event.todos
        .where((t) => t.id != todo.id)
        .toList();
    final updatedEvent = widget.event.copyWith(todos: updatedTodos);
    await ref.read(eventsProvider.notifier).upsert(updatedEvent);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todos = widget.event.todos;

    // 미완료 항목을 위로, 완료 항목을 아래로 정렬
    final sortedTodos = [...todos]
      ..sort((a, b) {
        if (a.isCompleted == b.isCompleted) {
          return b.createdAt.compareTo(a.createdAt); // 최신순
        }
        return a.isCompleted ? 1 : -1; // 미완료 먼저
      });

    return Builder(
      builder: (context) {
        return CustomScrollView(
          slivers: [

            // 할 일 입력 필드
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 24),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                decoration: InputDecoration(
                                  hintText: '  할 일을 입력하세요',
                                  hintStyle: TextStyle(
                                    color: theme.colorScheme.outline
                                        .withOpacity(0.5),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.outlineVariant,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.outlineVariant,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.outlineVariant,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  isDense: true,
                                ),
                                onSubmitted: (_) => _addTodo(),
                              ),
                            ),
                            IconButton(
                              onPressed: _addTodo,
                              icon: const HugeIcon(
                                icon: HugeIcons.strokeRoundedAdd01,
                                color: Colors.black,
                                size: 20,
                              ),
                              style: IconButton.styleFrom(
                                padding: const EdgeInsets.all(8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 할 일 목록
            if (todos.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedTask01,
                        size: 48,
                        color: theme.colorScheme.outlineVariant.withOpacity(
                          0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '할 일을 추가해보세요',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.outline.withOpacity(
                            0.5,
                          ), // Softer color as per v1
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final todo = sortedTodos[index];
                  return Dismissible(
                    key: Key(todo.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _removeTodo(todo),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(
                        bottom: 8,
                        left: 16,
                        right: 16,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedDelete02,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        elevation: 0,
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: CheckboxListTile(
                          value: todo.isCompleted,
                          onChanged: (_) => _toggleTodo(todo),
                          dense: true, // Reduced height
                          visualDensity: VisualDensity.compact, // More compact
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
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
                          secondary: Text(
                            DateFormat('yyyy.MM.dd').format(todo.createdAt),
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  );
                }, childCount: sortedTodos.length),
              ),
          ],
        );
      },
    );
  }
}
