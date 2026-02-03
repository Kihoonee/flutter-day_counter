import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:days_plus/l10n/app_localizations.dart';

import '../../../../core/utils/date_calc.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
                                  hintText: '  ${l10n.todoHint}',
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
                        l10n.todoEmptyTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.outline.withOpacity(
                            0.5,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Grouping Logic
              Builder(
                builder: (context) {
                  // 1. Group by D-Day diff
                  final Map<int, List<TodoItem>> grouped = {};
                  for (var todo in todos) {
                    final diff = DateCalc.diffDays(
                      base: todo.createdAt,
                      target: widget.event.targetDate,
                      includeToday: widget.event.includeToday,
                    );
                    if (!grouped.containsKey(diff)) grouped[diff] = [];
                    grouped[diff]!.add(todo);
                  }

                  // 2. Sort keys (D-Day gap)
                  // "D-Day가 클수록 아래로" -> Gap 1 (D-1) -> Gap 100 (D-100)
                  // Note: diff values: D-10 => 10, D-1 => 1. D-Day => 0. D+1 => -1?
                  // DateCalc behavior needs check. Usually diffDays(base, target) returns target - base.
                  // If base < target (D-minus), returns positive? Let's assume standard behavior.
                  // Let's rely on standard logic: Closest (Small Diff) to Furthest (Large Diff).
                  // But we also have "Future" vs "Past".
                  // Let's sort by absolute value or just raw logic.
                  // I'll assume Newest Created (Start of timeline) -> Oldest (End)?
                  // Actually, let's sort keys descending?
                  // If I created on D-100 (long ago), and D-1 (yesterday).
                  // I probably want to see D-1 items first.
                  // D-1 => Diff is 1. D-100 => Diff is 100.
                  // Sort: 1 -> 100. Ascending.
                  
                  final keys = grouped.keys.toList()..sort((a, b) {
                     // Sort by closeness to D-Day (small number first)?
                     // Or Newest Date first?
                     // diffDays returns (target - base).
                     // D-10 means target is 10 days after base. diff = 10.
                     // D-1 means diff = 1.
                     // Sort: 1, 10... (Ascending) -> Recent items top. 
                     return a.compareTo(b);
                  });

                  return SliverList( // Wrap all groups in one list or use multiple slivers?
                    // We can't return a list of slivers from Builder here easily without a specialized widget.
                    // Instead, we should return a specific generic Sliver.
                    // Actually, simpler approach:
                    // Flatten the list into [Header, Item, Item, Header, Item...]
                    // This avoids multiple Slivers and complexities.
                    
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                         // We need to map linear index to group/item
                         // Pre-calculate flat list
                         final List<dynamic> flatList = [];
                         for (var diff in keys) {
                           flatList.add(diff); // Header marker (int)
                           final items = grouped[diff]!;
                           // Sort items within group? created desc
                           items.sort((a,b) => b.createdAt.compareTo(a.createdAt));
                           flatList.addAll(items);
                         }
                         
                         final item = flatList[index];

                         // Header
                         if (item is int) {
                           final diff = item;
                           String label;
                           if (diff == 0) label = l10n.dDay;
                           else if (diff > 0) label = l10n.dMinus(diff);
                           else label = l10n.dPlus(diff.abs());
                           
                           return Padding(
                             padding: const EdgeInsets.fromLTRB(24, 24, 16, 8),
                             child: Row(
                               children: [
                                 Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                   decoration: BoxDecoration(
                                     color: theme.colorScheme.primaryContainer,
                                     borderRadius: BorderRadius.circular(8),
                                   ),
                                   child: Text(
                                     label,
                                     style: TextStyle(
                                       color: theme.colorScheme.onPrimaryContainer,
                                       fontWeight: FontWeight.bold,
                                       fontSize: 12,
                                     ),
                                   ),
                                 ),
                                 const SizedBox(width: 8),
                                 Expanded(
                                   child: Divider(
                                     color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                                   ),
                                 ),
                               ],
                             ),
                           );
                         }
                         
                         // Todo Item
                         final todo = item as TodoItem;
                         return Dismissible(
                    key: Key(todo.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _removeTodo(todo),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                        margin: const EdgeInsets.only(bottom: 4), // Reduced margin
                        child: CheckboxListTile(
                          value: todo.isCompleted,
                          onChanged: (_) => _toggleTodo(todo),
                          dense: true, 
                          visualDensity: VisualDensity.compact,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
                          // Subtitle: Time 
                          secondary: Text(
                            DateFormat('HH:mm').format(todo.createdAt),
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
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
                      },
                      childCount: todos.length + grouped.keys.length, // Total items + Headers
                    ),
                  );
                }
              ),
            ],
          ],
        );
      },
    );
  }
}
