import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_calc.dart';
import '../../../../core/widgets/banner_ad_widget.dart';
import '../../application/event_controller.dart';
import '../../domain/event.dart';
import '../widgets/poster_card.dart';

class EventListPage extends ConsumerWidget {
  const EventListPage({super.key});

  String _dText(int diff) {
    if (diff == 0) return 'D-Day';
    if (diff > 0) return '-$diff';
    return '+${diff.abs()}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(eventsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to scroll behind AppBar
      appBar: AppBar(
        title: Text(
          'Days+',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Completely transparent
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              Expanded(
                child: state.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('에러: $e')),
                  data: (List<Event> events) {
                    if (events.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
                        ),
                        child: _Empty(
                          onCreate: () => context.push('/edit', extra: null),
                        ),
                      );
                    }

                    // 드래그 앤 드롭을 위한 ReorderableListView
                    return ReorderableListView.builder(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
                        bottom: 80, // FAB Space
                        left: 16,
                        right: 16,
                      ),
                      itemCount: events.length,
                      onReorder: (oldIndex, newIndex) {
                        ref.read(eventsProvider.notifier).reorder(oldIndex, newIndex);
                      },
                      proxyDecorator: (child, index, animation) {
                        // 드래그 중인 아이템 스타일 (약간의 그림자 추가 등)
                        return Material(
                          color: Colors.transparent,
                          shadowColor: Colors.black.withOpacity(0.2),
                          elevation: 10,
                          child: child,
                        );
                      },
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

                        return Padding(
                          key: Key(e.id), // 필수: 고유 키
                          padding: const EdgeInsets.only(bottom: 10), // 간격 줄임 (16 -> 10)
                          child: SizedBox(
                            height: 180,
                            child: PosterCard(
                              title: e.title,
                              dateLine: dateLine,
                              dText: _dText(diff),
                              themeIndex: e.themeIndex,
                              iconIndex: e.iconIndex,
                              onTap: () => context.push('/detail', extra: e.id),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Banner Slot Fixed at Bottom
              const SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: _BannerSlot(),
                ),
              ),
            ],
          ),

          // Floating Action Button (Manually positioned to avoid Banner)
          Positioned(
            bottom: 120, // Check: Increased to avoid Banner overlap
            right: 16,
            child: FloatingActionButton(
              onPressed: () => context.push('/edit', extra: null),
              shape: const CircleBorder(), // Explicitly circular
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      // No Scaffold FAB since we positioned it manually
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
    return const BannerAdWidget();
  }
}
