import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/event_controller.dart';
import '../../domain/event.dart';
import 'date_field.dart';
import 'poster_card.dart';

/// 수정 탭 - 이벤트 정보 수정
class EditTab extends ConsumerStatefulWidget {
  final Event event;
  const EditTab({super.key, required this.event});

  @override
  ConsumerState<EditTab> createState() => _EditTabState();
}

class _EditTabState extends ConsumerState<EditTab> {
  late TextEditingController _title;
  late DateTime _base;
  late DateTime _target;
  late bool _includeToday;
  late bool _excludeWeekends;
  late int _themeIndex;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _initFrom(Event e) {
    if (_initialized) return;
    _initialized = true;

    _title.text = e.title;
    _base = e.baseDate;
    _target = e.targetDate;
    _includeToday = e.includeToday;
    _excludeWeekends = e.excludeWeekends;
    _themeIndex = e.themeIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 초기화
    _initFrom(widget.event);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 제목 입력
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: '이벤트 제목',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),

          // 기준일
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

          // 목표일
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

          // 옵션 카드
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

          // 테마 선택
          _ThemePicker(
            selected: _themeIndex,
            onSelect: (i) => setState(() => _themeIndex = i),
          ),

          const SizedBox(height: 32),

          // 저장 / 삭제 버튼
          Row(
            children: [
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
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('삭제'),
                          ),
                        ],
                      ),
                    );
                    if (ok != true) return;
                    await ref
                        .read(eventsProvider.notifier)
                        .remove(widget.event.id);
                    if (!mounted) return;
                    context.go('/events'); // 목록으로 돌아가기
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('삭제'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final updatedEvent = widget.event.copyWith(
                      title: _title.text.isEmpty ? '이벤트' : _title.text,
                      baseDate: _base,
                      targetDate: _target,
                      includeToday: _includeToday,
                      excludeWeekends: _excludeWeekends,
                      themeIndex: _themeIndex,
                    );

                    await ref
                        .read(eventsProvider.notifier)
                        .upsert(updatedEvent);

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('저장되었습니다.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('저장'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 테마 선택 위젯
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
                            color: isOn
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: isOn ? 2 : 1,
                          ),
                          boxShadow: isOn
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.3),
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
