import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_calc.dart';
import '../../application/event_controller.dart';
import '../../domain/event.dart';
import '../widgets/poster_card.dart';

class EventListPage extends ConsumerWidget {
  const EventListPage({super.key});

  String _dText(int diff) {
    if (diff == 0) return 'D-Day';
    if (diff > 0) return 'D-$diff';
    return 'D+${diff.abs()}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            onPressed: () => context.push('/edit', extra: null),
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Add',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: state.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('에러: $e')),
                    data: (List<Event> events) {
                      print('EventListPage UI: Received ${events.length} events');
                      if (events.isEmpty) {
                        return _Empty(
                          onCreate: () => context.push('/edit', extra: null),
                        );
                      }

                      return ListView.separated(
                        itemCount: events.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final e = events[i];
                          final diff = DateCalc.diffDays(
                            base: e.baseDate,
                            target: e.targetDate,
                            includeToday: e.includeToday,
                            excludeWeekends: e.excludeWeekends,
                          );

                          final dateLine = DateFormat(
                            'yyyy.MM.dd',
                          ).format(e.targetDate);

                          return SizedBox(
                            height: 170,
                            child: PosterCard(
                              title: e.title,
                              dateLine: dateLine,
                              dText: _dText(diff),
                              themeIndex: e.themeIndex,
                              onTap: () => context.push('/edit', extra: e.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const _BannerSlot(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final VoidCallback onCreate;
  const _Empty({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '저장된 이벤트가 없습니다.',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '오른쪽 위 + 버튼으로 추가해보세요.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onCreate,
                child: const Text('새 이벤트 만들기'),
              ),
            ],
          ),
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
