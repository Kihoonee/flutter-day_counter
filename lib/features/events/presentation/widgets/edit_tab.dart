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
  late DateTime _target;
  late bool _includeToday;
  late bool _excludeWeekends;
  late int _themeIndex;
  late int _iconIndex;

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
    _target = e.targetDate;
    _includeToday = e.includeToday;
    _excludeWeekends = e.excludeWeekends;
    _themeIndex = e.themeIndex;
    _iconIndex = e.iconIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 초기화
    _initFrom(widget.event);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. 이벤트 제목 입력 (Card로 감싸서 통일)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // DateField와 동일
            margin: EdgeInsets.zero,
            child: TextField(
              controller: _title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.normal,
              ),
              decoration: InputDecoration(
                labelText: '어떤 날인가요?',
                hintText: '이벤트 제목을 입력하세요',
                labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                border: InputBorder.none, // Card 내부이므로 테두리 제거
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 24), // 간격 확보

          // 2. 아이콘 & 테마 선택
          Card(
            elevation: 0,
            // color 제거 -> 기본 Card 컬러 사용
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          '아이콘',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _IconPicker(
                            selected: _iconIndex,
                            onSelect: (i) => setState(() => _iconIndex = i),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.2)), // 구분선 더 연하게
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          '테마',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          child: _ThemePicker(
                            selected: _themeIndex,
                            onSelect: (i) => setState(() => _themeIndex = i),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4. 목표일 선택
          DateField(
            label: '목표일',
            value: _target,
            onTap: () async {
              final picked = await pickDate(context, initial: _target);
              if (picked == null) return;
              setState(() => _target = picked);
            },
          ),
          const SizedBox(height: 16),

          // 5. 옵션
          Card(
            elevation: 0,
            // color 제거 -> 기본 Card 컬러 사용
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    '당일 포함 (1일차 시작)',
                    style: theme.textTheme.bodyMedium,
                  ),
                  value: _includeToday,
                  onChanged: (v) => setState(() => _includeToday = v),
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.2)),
                SwitchListTile(
                  title: Text(
                    '주말 제외 (평일만 계산)',
                    style: theme.textTheme.bodyMedium,
                  ),
                  value: _excludeWeekends,
                  onChanged: (v) => setState(() => _excludeWeekends = v),
                ),
              ],
            ),
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
                    context.go('/events');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface.withOpacity(0.4), // Changed to Grey
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('이벤트 삭제'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () async {
                    final updatedEvent = widget.event.copyWith(
                      title: _title.text.isEmpty ? '이벤트' : _title.text,
                      baseDate: DateTime.now(), // 기준일은 항상 오늘
                      targetDate: _target,
                      includeToday: _includeToday,
                      excludeWeekends: _excludeWeekends,
                      themeIndex: _themeIndex,
                      iconIndex: _iconIndex,
                    );

                    await ref
                        .read(eventsProvider.notifier)
                        .upsert(updatedEvent);

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('저장되었습니다.')),
                    );
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('변경사항 저장'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// 아이콘 선택 위젯
class _IconPicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _IconPicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: eventIcons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final icon = eventIcons[i];
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              width: 40,
              decoration: BoxDecoration(
                color: isSelected 
                    ? theme.colorScheme.primary.withOpacity(0.1) 
                    : Colors.transparent,
                shape: BoxShape.circle,
                // Border 제거
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        },
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
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: posterThemes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final c = posterThemes[i].bg;
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              width: 32,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                // Border 제거
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: isSelected 
                  ? Icon(Icons.check, color: posterThemes[i].fg, size: 16) 
                  : null,
            ),
          );
        },
      ),
    );
  }
}
