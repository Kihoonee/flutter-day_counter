import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:days_plus/l10n/app_localizations.dart';

import '../../application/event_controller.dart';
import '../../domain/diary_entry.dart';
import '../../domain/event.dart';

import 'date_field.dart'; // pickDate 재사용
import '../../../../core/utils/date_calc.dart';
import '../../../../core/utils/haptic_helper.dart';

/// 다이어리 탭 - 날짜별 메모 기록
class DiaryTab extends ConsumerWidget {
  final String eventId; // Event 객체 대신 ID를 받아서 직접 구독
  const DiaryTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final eventsState = ref.watch(eventsProvider);

    return eventsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.error(e.toString()))),
      data: (events) {
        final event = events.where((e) => e.id == eventId).firstOrNull;
        if (event == null) return Center(child: Text(l10n.eventNotFound));

        final entries = [...event.diaryEntries]
          ..sort((a, b) => b.date.compareTo(a.date)); // 최신순

        return Stack(
          children: [
            // 메인 리스트
            Builder(
              builder: (context) {
                return CustomScrollView(
                  slivers: [

                    if (entries.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedNoteEdit,
                                size: 48, 
                                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                l10n.diaryEmptyTitle,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.diaryEmptySubtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      // 날짜별 그룹화 로직 (TodoTab과 동일)
                      Builder(
                        builder: (context) {
                          // 1. D-Day diff로 그룹화
                          final Map<int, List<DiaryEntry>> grouped = {};
                          for (var entry in entries) {
                            final diff = DateCalc.diffDays(
                              base: entry.date,
                              target: event.targetDate,
                              includeToday: event.includeToday,
                            );
                            if (!grouped.containsKey(diff)) grouped[diff] = [];
                            grouped[diff]!.add(entry);
                          }

                          // 2. 키 정렬 (D-Day에 가까운 순서)
                          final keys = grouped.keys.toList()..sort((a, b) => a.compareTo(b));

                          // 3. 평면 리스트 생성 [Header, Entry, Entry, Header, ...]
                          final List<dynamic> flatList = [];
                          for (var diff in keys) {
                            flatList.add(diff); // 헤더 마커 (int)
                            final items = grouped[diff]!;
                            // 그룹 내 항목은 최신순 정렬
                            items.sort((a, b) => b.date.compareTo(a.date));
                            flatList.addAll(items);
                          }

                          return SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = flatList[index];

                                  // 날짜 헤더
                                  if (item is int) {
                                    final diff = item;
                                    String label;
                                    if (diff == 0) {
                                      label = l10n.dDay;
                                    } else if (diff > 0) {
                                      label = l10n.dMinus(diff);
                                    } else {
                                      label = l10n.dPlus(diff.abs());
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(8, 24, 0, 8),
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
                                              color: theme.colorScheme.outlineVariant,
                                              thickness: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  // 메모 항목
                                  final entry = item as DiaryEntry;
                                  final diff = DateCalc.diffDays(
                                    base: entry.date,
                                    target: event.targetDate,
                                    includeToday: event.includeToday,
                                  );
                                  String dDayText;
                                  if (diff == 0) {
                                    dDayText = l10n.dDay;
                                  } else if (diff > 0) {
                                    dDayText = l10n.dMinus(diff);
                                  } else {
                                    dDayText = l10n.dPlus(diff.abs());
                                  }

                                  return Dismissible(
                                    key: Key(entry.id),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (_) => _deleteEntry(ref, event, entry),
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: HugeIcon(
                                        icon: HugeIcons.strokeRoundedDelete02,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    child: _DiaryCard(
                                      entry: entry,
                                      dDayText: dDayText,
                                      onEdit: () => _showDiaryDialog(context, ref, event, entry: entry),
                                    ),
                                  );
                                },
                                childCount: flatList.length,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                );
              }
            ),

            // 작성 버튼 (FAB 위치 커스텀)
            Positioned(
              bottom: 24,
              right: 16,
              child: FloatingActionButton(
                onPressed: () async {
                  await HapticHelper.medium();
                  _showDiaryDialog(context, ref, event);
                },
                shape: const CircleBorder(),
                elevation: 4,
                backgroundColor: theme.colorScheme.primary, // Brand Color
                foregroundColor: theme.colorScheme.onPrimary,
                child: const HugeIcon(icon: HugeIcons.strokeRoundedPencilEdit01, color: Colors.white), 
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDiaryDialog(BuildContext context, WidgetRef ref, Event event, {DiaryEntry? entry}) {
    // 메모가 있는 날짜 목록 추출
    final markers = event.diaryEntries.map((e) => e.date).toList();

    showDialog(
      context: context,
      builder: (context) => _DiaryDialog(
        initialEntry: entry,
        markerDates: markers,
        dDayDate: event.targetDate,
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
    // 햅틱 피드백: 스와이프 삭제 (중간 강도)
    await HapticHelper.medium();
    
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
  final List<DateTime>? markerDates;
  final DateTime? dDayDate;

  const _DiaryDialog({this.initialEntry, required this.onSave, this.markerDates, this.dDayDate});

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
    final l10n = AppLocalizations.of(context)!;
    final dateStr = DateFormat('yyyy.MM.dd (E)', l10n.localeName).format(_selectedDate);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), // M3 Standard
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.all(20), // More width
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더 & 날짜 선택
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.initialEntry == null ? l10n.diaryDialogTitleNew : l10n.diaryDialogTitleEdit,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    // 현재 이벤트의 메모 날짜 목록 추출
                    List<DateTime> markers = [];
                    // 상위 위젯(DiaryTab)에서 event객체를 직접 접근하기 어려우므로
                    // 여기서는 build메소드 내에서 event를 조회하지 않고,
                    // DiaryDialog를 호출할 때 event를 넘겨주거나,
                    // 필요한 markerDates를 인자로 받아야 함.
                    // 현재 구조상 _DiaryDialog는 event를 직접 가지고 있지 않음.
                    // 간단히 initialEntry가 있는 경우 그 날짜만이라도... 가 아니라,
                    // 전체 마커를 보고 싶어하심.
                    // 따라서 _DiaryDialog 생성자에 markerDates를 추가로 받아야 함.
                    
                    final picked = await pickDate(
                      context, 
                      initial: _selectedDate,
                      markerDates: widget.markerDates, // 전달받은 마커 사용
                      dDayDate: widget.dDayDate, // D-Day 전달
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dateStr,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedCalendar03,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 내용 입력 (Cleaner Look)
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 8,
                minLines: 4,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                decoration: InputDecoration(
                  hintText: l10n.diaryHint,
                  hintStyle: TextStyle(color: theme.colorScheme.outline.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
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
                    child: Text(l10n.cancel),
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
                    child: Text(l10n.save),
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
  final String dDayText;
  final VoidCallback onEdit;

  const _DiaryCard({
    required this.entry,
    required this.dDayText,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 완료 상태 표시 여부 확인
    final isFromTodo = entry.isCompletedFromTodo != null;
    final isCompleted = entry.isCompletedFromTodo == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜 + D-Day + 완료 상태 뱃지
              Row(
                children: [
                  Text(
                    DateFormat('M월 d일 (E)', 'ko').format(entry.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      dDayText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // 할일에서 전환된 메모인 경우 완료 상태 뱃지 표시
                  if (isFromTodo) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? theme.colorScheme.tertiaryContainer
                            : theme.colorScheme.errorContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: isCompleted 
                                ? HugeIcons.strokeRoundedCheckmarkCircle02
                                : HugeIcons.strokeRoundedCancelCircle,
                            size: 12,
                            color: isCompleted
                                ? theme.colorScheme.onTertiaryContainer
                                : theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isCompleted ? '완료' : '미완료',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isCompleted
                                  ? theme.colorScheme.onTertiaryContainer
                                  : theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              // 내용 (완료된 항목은 취소선 스타일)
              Text(
                entry.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  decoration: isCompleted 
                      ? TextDecoration.lineThrough 
                      : null,
                  color: isCompleted
                      ? theme.colorScheme.onSurface.withOpacity(0.5)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
