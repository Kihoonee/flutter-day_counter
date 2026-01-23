import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../application/event_controller.dart';
import '../../domain/diary_entry.dart';
import '../../domain/event.dart';

/// 다이어리 탭 - 날짜별 메모 기록
class DiaryTab extends ConsumerWidget {
  final Event event;
  const DiaryTab({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entries = [...event.diaryEntries]
      ..sort((a, b) => b.date.compareTo(a.date)); // 최신순

    return Scaffold(
      body: entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '다이어리를 작성해보세요',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _DiaryCard(
                  entry: entry,
                  onEdit: () => _showEditDialog(context, ref, entry),
                  onDelete: () => _deleteEntry(ref, entry),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.edit),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('다이어리 작성'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 날짜 선택
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(DateFormat('yyyy.MM.dd').format(selectedDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 8),
              // 내용 입력
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: '오늘의 기록을 남겨보세요...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;

                final newEntry = DiaryEntry(
                  id: const Uuid().v4(),
                  content: controller.text.trim(),
                  date: selectedDate,
                  createdAt: DateTime.now(),
                );

                final updatedEntries = [...event.diaryEntries, newEntry];
                final updatedEvent =
                    event.copyWith(diaryEntries: updatedEntries);

                await ref.read(eventsProvider.notifier).upsert(updatedEvent);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, DiaryEntry entry) {
    final controller = TextEditingController(text: entry.content);
    DateTime selectedDate = entry.date;

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('다이어리 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(DateFormat('yyyy.MM.dd').format(selectedDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;

                final updatedEntry = entry.copyWith(
                  content: controller.text.trim(),
                  date: selectedDate,
                );

                final updatedEntries = event.diaryEntries.map((e) {
                  if (e.id == entry.id) return updatedEntry;
                  return e;
                }).toList();

                final updatedEvent =
                    event.copyWith(diaryEntries: updatedEntries);
                await ref.read(eventsProvider.notifier).upsert(updatedEvent);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteEntry(WidgetRef ref, DiaryEntry entry) async {
    final updatedEntries =
        event.diaryEntries.where((e) => e.id != entry.id).toList();
    final updatedEvent = event.copyWith(diaryEntries: updatedEntries);
    await ref.read(eventsProvider.notifier).upsert(updatedEvent);
  }
}

/// 다이어리 카드 위젯
class _DiaryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DiaryCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yyyy.MM.dd (E)', 'ko').format(entry.date),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('수정')),
                    const PopupMenuItem(value: 'delete', child: Text('삭제')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.content,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
