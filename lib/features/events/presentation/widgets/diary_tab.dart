import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../application/event_controller.dart';
import '../../domain/diary_entry.dart';
import '../../domain/event.dart';
import 'date_field.dart'; // pickDate 재사용

/// 다이어리 탭 - 날짜별 메모 기록
class DiaryTab extends ConsumerWidget {
  final String eventId; // Event 객체 대신 ID를 받아서 직접 구독
  const DiaryTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final eventsState = ref.watch(eventsProvider);

    return eventsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('에러: $e')),
      data: (events) {
        final event = events.where((e) => e.id == eventId).firstOrNull;
        if (event == null) return const Center(child: Text('이벤트를 찾을 수 없습니다.'));

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
                          size: 48,
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
                        onDismissed: (_) => _deleteEntry(ref, event, entry),
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
                          onEdit: () => _showDiaryDialog(context, ref, event, entry: entry),
                        ),
                      );
                    },
                  ),

            // 작성 버튼 (FAB 위치 커스텀)
            Positioned(
              bottom: 24,
              right: 16,
              child: FloatingActionButton(
                onPressed: () => _showDiaryDialog(context, ref, event),
                shape: const CircleBorder(),
                elevation: 2, // 쉐도우 감소
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: const Icon(Icons.edit_rounded),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDiaryDialog(BuildContext context, WidgetRef ref, Event event, {DiaryEntry? entry}) {
    showDialog(
      context: context,
      builder: (context) => _DiaryDialog(
        initialEntry: entry,
        onSave: (content, date) async {
          // 여기서도 최신 상태를 보장하기 위해 ref.read를 쓰는 것이 좋지만,
          // 이미 build에서 최신 event를 받아왔으므로 그 event를 기반으로 업데이트하면 됨.
          // 단, 비동기 갭 동안 event가 바뀔 수 있으므로...
          // 가장 안전한 건 controller의 특정 메소드를 호출하는 것.
          // 일단은 기존 로직 유지하되 event 인자 사용.

          // 새로 읽어오기 (안전장치)
          final currentEvents = ref.read(eventsProvider).asData?.value ?? [];
          final currentEvent = currentEvents.where((e) => e.id == event.id).firstOrNull;
          if (currentEvent == null) return;

          List<DiaryEntry> nextEntries;
          if (entry == null) {
            // 새 작성
            final newEntry = DiaryEntry(
              id: const Uuid().v4(),
              content: content,
              date: date,
              createdAt: DateTime.now(),
            );
            nextEntries = [...currentEvent.diaryEntries, newEntry];
          } else {
            // 수정
            final updatedEntry = entry.copyWith(
              content: content,
              date: date,
            );
            nextEntries = currentEvent.diaryEntries.map((e) {
              if (e.id == entry.id) return updatedEntry;
              return e;
            }).toList();
          }

          final nextEvent = currentEvent.copyWith(diaryEntries: nextEntries);
          await ref.read(eventsProvider.notifier).upsert(nextEvent);
        },
      ),
    );
  }

  Future<void> _deleteEntry(WidgetRef ref, Event event, DiaryEntry entry) async {
    // 삭제 시에도 최신 이벤트 기준
    final currentEvents = ref.read(eventsProvider).asData?.value ?? [];
    final currentEvent = currentEvents.where((e) => e.id == event.id).firstOrNull;
    if (currentEvent == null) return;

    final updatedEntries =
        currentEvent.diaryEntries.where((e) => e.id != entry.id).toList();
    final updatedEvent = currentEvent.copyWith(diaryEntries: updatedEntries);
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
    final dateStr = DateFormat('yyyy.MM.dd (E)', 'ko').format(_selectedDate);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent, // 틴트 제거
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더 & 날짜 선택
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.initialEntry == null ? '기록하기' : '수정하기',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final picked = await pickDate(context, initial: _selectedDate);
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dateStr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 내용 입력
            TextField(
              controller: _controller,
              maxLines: 8,
              minLines: 4,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              decoration: InputDecoration(
                hintText: '오늘 어떤 일이 있었나요?',
                hintStyle: TextStyle(color: theme.colorScheme.outline.withOpacity(0.7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('저장'),
                  ),
                ),
              ],
            ),
          ],
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        // Border 제거 (요청사항)
        // 테두리 대신 그림자를 살짝 줄 수도 있지만, 깔끔하게 flat하게 감.
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit, // 카드 전체 클릭 시 수정
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 날짜만 표시 (아이콘 제거)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy.MM.dd (E)', 'ko').format(entry.date),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary, // Primary color for date
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // 수정 아이콘은 유지할지? 카드 전체 탭으로 대체 가능하면 삭제.
                    // 명시적인 것이 좋으므로 작게 유지.
                    Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  entry.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
