import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/date_calc.dart';
import '../../../../core/widgets/banner_ad_widget.dart';
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
  DateTime _target = DateTime.now();
  bool _includeToday = false;
  bool _excludeWeekends = false;
  int _themeIndex = 0;
  int _iconIndex = 0;

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
      _target = e.targetDate;
      _includeToday = e.includeToday;
      _excludeWeekends = e.excludeWeekends;
      _themeIndex = e.themeIndex;
      _iconIndex = e.iconIndex;
    } else {
      _title.text = ''; // 새 이벤트는 빈 제목
      final now = DateTime.now();
      _target = DateTime(now.year, now.month, now.day);
      _includeToday = false;
      _excludeWeekends = false;
      _themeIndex = 0;
      _iconIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventsState = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventId == null ? '새 이벤트' : '이벤트 수정'),
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
                base: DateTime.now(), // Create preview using Today
                target: _target,
                includeToday: _includeToday,
                excludeWeekends: _excludeWeekends,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 미리보기 카드
                    SizedBox(
                      height: 220,
                      child: PosterCard(
                        title: _title.text.isEmpty ? '이벤트' : _title.text,
                        dateLine: DateFormat('yyyy.MM.dd').format(_target),
                        dText: _dText(diff),
                        themeIndex: _themeIndex,
                        iconIndex: _iconIndex,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 1. 이벤트 제목 입력
                    TextField(
                      controller: _title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                      decoration: InputDecoration(
                        labelText: '어떤 날인가요?',
                        hintText: '이벤트 제목을 입력하세요',
                        labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),

                    // 2. 아이콘 선택
                    Text(
                      '아이콘',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _IconPicker(
                      selected: _iconIndex,
                      onSelect: (i) => setState(() => _iconIndex = i),
                    ),
                    const SizedBox(height: 24),

                    // 3. 테마 선택
                    Text(
                      '테마 컬러',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ThemePicker(
                      selected: _themeIndex,
                      onSelect: (i) => setState(() => _themeIndex = i),
                    ),
                    const SizedBox(height: 24),

                    // 4. 목표일 선택
                    Text(
                      '날짜',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DateField(
                      label: '목표일',
                      value: _target,
                      onTap: () async {
                        final picked = await pickDate(context, initial: _target);
                        if (picked == null) return;
                        setState(() => _target = picked);
                      },
                    ),
                    const SizedBox(height: 24),

                    // 5. 옵션 (맨 아래로 이동)
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
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

                    // 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final id = widget.eventId ?? const Uuid().v4();
                          // 기존 이벤트가 있으면 할일/다이어리는 유지해야 함
                          List<dynamic> todos = [];
                          List<dynamic> diaryEntries = [];
                          
                          if (existing != null) {
                            todos = existing.todos;
                            diaryEntries = existing.diaryEntries;
                          }

                          final e = Event(
                            id: id,
                            title: _title.text.isEmpty ? '이벤트' : _title.text,
                            baseDate: DateTime.now(), // 기준일은 항상 오늘
                            targetDate: _target,
                            includeToday: _includeToday,
                            excludeWeekends: _excludeWeekends,
                            themeIndex: _themeIndex,
                            iconIndex: _iconIndex,
                            todos: (todos as List).cast(), // Safe casting
                            diaryEntries: (diaryEntries as List).cast(),
                          );

                          await ref.read(eventsProvider.notifier).upsert(e);
                          if (!mounted) return;
                          
                          final state = ref.read(eventsProvider);
                          if (state.hasError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('저장 실패: ${state.error}')),
                            );
                          } else {
                            if (widget.eventId == null) {
                              context.pop(); // 목록으로
                            } else {
                              context.pop(); // 상세로
                            }
                          }
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('저장'),
                      ),
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

class _IconPicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _IconPicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 60,
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
              width: 50,
              decoration: BoxDecoration(
                color: isSelected 
                    ? theme.colorScheme.primaryContainer 
                    : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
              ),
              child: Icon(
                icon,
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

class _ThemePicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _ThemePicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 50,
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
              width: 50,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: isSelected 
                  ? Icon(Icons.check, color: posterThemes[i].fg, size: 20) 
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class _BannerSlot extends StatelessWidget {
  const _BannerSlot();

  @override
  Widget build(BuildContext context) {
    return const BannerAdWidget();
  }
}
