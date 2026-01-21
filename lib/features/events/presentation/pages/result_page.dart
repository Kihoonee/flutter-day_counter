import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/date_calc.dart';
import '../../application/event_controller.dart';
import '../../application/selected_event_controller.dart';
import '../../domain/event.dart';
import '../widgets/poster_card.dart';

class ResultPage extends ConsumerStatefulWidget {
  const ResultPage({super.key});

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage> {
  final _title = TextEditingController(text: '새 이벤트');
  int _themeIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(draftProvider);
    final target = draft.targetDate;

    if (target == null) {
      // 홈으로 되돌림
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/'));
      return const SizedBox.shrink();
    }

    final diff = DateCalc.diffDays(
      base: draft.baseDate,
      target: target,
      includeToday: draft.includeToday,
      excludeWeekends: draft.excludeWeekends,
    );

    final dateLine = DateFormat('yyyy.MM.dd').format(target);
    final dText = _dText(diff);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 260,
                  child: PosterCard(
                    title: _title.text.isEmpty ? '새 이벤트' : _title.text,
                    dateLine: dateLine,
                    dText: dText,
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

                _ThemePicker(
                  selected: _themeIndex,
                  onSelect: (i) => setState(() => _themeIndex = i),
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final txt = '${_title.text}  $dText  (target: $dateLine)';
                          await Clipboard.setData(ClipboardData(text: txt));
                          if (!mounted) return;
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(const SnackBar(content: Text('복사 완료')));
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('복사'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final e = Event(
                            id: const Uuid().v4(),
                            title: _title.text.isEmpty ? '새 이벤트' : _title.text,
                            baseDate: draft.baseDate,
                            targetDate: target,
                            includeToday: draft.includeToday,
                            excludeWeekends: draft.excludeWeekends,
                            themeIndex: _themeIndex,
                          );
                          await ref.read(eventsProvider.notifier).upsert(e);
                          if (!mounted) return;
                          context.go('/events');
                        },
                        child: const Text('저장'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _BannerSlot(),
              ],
            ),
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
                                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
