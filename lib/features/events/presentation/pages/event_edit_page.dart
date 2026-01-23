import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/date_calc.dart';
import '../../application/event_controller.dart';
import '../../domain/event.dart';
import '../widgets/date_field.dart';
import '../widgets/poster_card.dart';

class EventEditPage extends ConsumerStatefulWidget {
  final String? eventId; // null이면 새 이벤트
  const EventEditPage({super.key, this.eventId});

  @override
  ConsumerState<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends ConsumerState<EventEditPage> {
  final _title = TextEditingController();
  DateTime _base = DateTime.now();
  DateTime _target = DateTime.now();
  bool _includeToday = false;
  bool _excludeWeekends = false;
  int _themeIndex = 0;

  bool _initialized = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  String _dText(int diff) {
    if (diff == 0) return 'D-Day';
    if (diff > 0) return 'D-$diff';
    return 'D+${diff.abs()}';
  }

  void _initFrom(Event? e) {
    if (_initialized) return;
    _initialized = true;

    if (e != null) {
      _title.text = e.title;
      _base = e.baseDate;
      _target = e.targetDate;
      _includeToday = e.includeToday;
      _excludeWeekends = e.excludeWeekends;
      _themeIndex = e.themeIndex;
    } else {
      _title.text = '새 이벤트';
      final now = DateTime.now();
      _base = DateTime(now.year, now.month, now.day);
      _target = _base;
      _includeToday = false;
      _excludeWeekends = false;
      _themeIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventsState = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventId == null ? 'Add' : 'Edit'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: eventsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('에러: $e')),
            data: (List<Event> events) {
              final existing = widget.eventId == null
                  ? null
                  : events
                        .where((e) => e.id == widget.eventId)
                        .cast<Event?>()
                        .firstOrNull;

              _initFrom(existing);

              final diff = DateCalc.diffDays(
                base: _base,
                target: _target,
                includeToday: _includeToday,
                excludeWeekends: _excludeWeekends,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 220,
                      child: PosterCard(
                        title: _title.text.isEmpty ? '이벤트' : _title.text,
                        dateLine: DateFormat('yyyy.MM.dd').format(_target),
                        dText: _dText(diff),
                        themeIndex: _themeIndex,
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: _title,
                      decoration: const InputDecoration(
                        labelText: '이벤트 제목',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),

                    DateField(
                      label: '기준일',
                      value: _base,
                      onTap: () async {
                        final picked = await pickDate(context, initial: _base);
                        if (picked == null) return;
                        setState(() => _base = picked);
                      },
                    ),
                    const SizedBox(height: 12),

                    DateField(
                      label: '목표일',
                      value: _target,
                      onTap: () async {
                        final picked = await pickDate(context, initial: _target);
                        if (picked == null) return;
                        setState(() => _target = picked);
                      },
                    ),

                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: Text(
                              '당일 포함',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            value: _includeToday,
                            onChanged: (v) => setState(() => _includeToday = v),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            title: Text(
                              '주말 제외',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            value: _excludeWeekends,
                            onChanged: (v) => setState(() => _excludeWeekends = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    _ThemePicker(
                      selected: _themeIndex,
                      onSelect: (i) => setState(() => _themeIndex = i),
                    ),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        if (widget.eventId != null) ...[
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('삭제할까요?'),
                                    content: const Text('이 이벤트를 삭제합니다.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('삭제'),
                                      ),
                                    ],
                                  ),
                                );
                                if (ok != true) return;
                                await ref
                                    .read(eventsProvider.notifier)
                                    .remove(widget.eventId!);
                                if (!mounted) return;
                                context.pop();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.error, // Red text
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('삭제'),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              print('UI: Save button clicked'); // Debug Log
                              final id = widget.eventId ?? const Uuid().v4();
                              final e = Event(
                                id: id,
                                title: _title.text.isEmpty ? '이벤트' : _title.text,
                                baseDate: _base,
                                targetDate: _target,
                                includeToday: _includeToday,
                                excludeWeekends: _excludeWeekends,
                                themeIndex: _themeIndex,
                              );
                              print('UI: Calling upsert for event ${e.id}'); // Debug Log
                              await ref.read(eventsProvider.notifier).upsert(e);
                              if (!mounted) return;
                              
                              final state = ref.read(eventsProvider);
                              if (state.hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('저장 실패: ${state.error}')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('이벤트가 저장되었습니다.')),
                                );
                                context.pop();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0, // Flat look
                              backgroundColor: theme.colorScheme.primaryContainer,
                              foregroundColor: theme.colorScheme.onPrimaryContainer,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('저장'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _BannerSlot(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _ThemePicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(
              '테마',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(posterThemes.length, (i) {
                    final c = posterThemes[i].bg;
                    final isOn = i == selected;
                    return GestureDetector(
                      onTap: () => onSelect(i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isOn ? theme.colorScheme.primary : Colors.transparent,
                            width: isOn ? 2 : 1,
                          ),
                          boxShadow: isOn
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerSlot extends StatelessWidget {
  const _BannerSlot();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 60,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Banner Ad Slot (하단 고정)',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
