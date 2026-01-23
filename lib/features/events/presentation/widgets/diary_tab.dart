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

    return Stack(
      children: [
        // 메인 리스트
        entries.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      size: 48, // 조금 작게
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '소중한 기억을 기록해보세요',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // FAB 공간 확보
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Dismissible(
                    key: Key(entry.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _deleteEntry(ref, entry),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    child: _DiaryCard(
                      entry: entry,
                      onEdit: () => _showDiaryDialog(context, ref, entry: entry),
                    ),
                  );
                },
              ),

        // 작성 버튼 (FAB 위치 커스텀)
        Positioned(
          bottom: 24,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => _showDiaryDialog(context, ref),
            shape: const CircleBorder(),
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }

  void _showDiaryDialog(BuildContext context, WidgetRef ref, {DiaryEntry? entry}) {
    showDialog(
      context: context,
      builder: (context) => _DiaryDialog(
        initialEntry: entry,
        onSave: (content, date) async {
          if (entry == null) {
            // 새로 작성
            final newEntry = DiaryEntry(
              id: const Uuid().v4(),
              content: content,
              date: date,
              createdAt: DateTime.now(),
            );
            final updatedEntries = [...event.diaryEntries, newEntry];
            final updatedEvent = event.copyWith(diaryEntries: updatedEntries);
            await ref.read(eventsProvider.notifier).upsert(updatedEvent);
          } else {
            // 수정
            final updatedEntry = entry.copyWith(
              content: content,
              date: date,
            );
            final updatedEntries = event.diaryEntries.map((e) {
              if (e.id == entry.id) return updatedEntry;
              return e;
            }).toList();
            final updatedEvent = event.copyWith(diaryEntries: updatedEntries);
            await ref.read(eventsProvider.notifier).upsert(updatedEvent);
          }
        },
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

/// 다이어리 작성/수정 다이얼로그 (커스텀 디자인)
class _DiaryDialog extends StatefulWidget {
  final DiaryEntry? initialEntry;
  final Function(String content, DateTime date) onSave;

  const _DiaryDialog({this.initialEntry, required this.onSave});

  @override
  State<_DiaryDialog> createState() => _DiaryDialogState();
}

class _DiaryDialogState extends State<_DiaryDialog> {
  late TextEditingController _controller;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialEntry?.content ?? '');
    _selectedDate = widget.initialEntry?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 헤더
              Text(
                widget.initialEntry == null ? '오늘의 기록' : '기록 수정',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // 달력 (CalendarDatePicker)
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Theme(
                  data: theme.copyWith(
                    colorScheme: theme.colorScheme.copyWith(
                      // 달력 크기를 조금 작게 보이게 하기 위해 텍스트 스타일 조정 가능하지만
                      // 기본 캘린더 위젯은 크기가 거의 고정적임.
                      // 대신 컨테이너로 감싸서 패딩을 조절함.
                    ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    onDateChanged: (date) => setState(() => _selectedDate = date),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 내용 입력
              TextField(
                controller: _controller,
                maxLines: 5,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: '무슨 일이 있었나요?',
                  hintStyle: TextStyle(color: theme.colorScheme.outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),

              // 버튼
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (_controller.text.trim().isEmpty) return;
                        widget.onSave(_controller.text.trim(), _selectedDate);
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('저장'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 다이어리 카드 위젯
class _DiaryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onEdit;

  const _DiaryCard({
    required this.entry,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('yyyy.MM.dd (E)', 'ko').format(entry.date),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  color: theme.colorScheme.outline,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              entry.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
