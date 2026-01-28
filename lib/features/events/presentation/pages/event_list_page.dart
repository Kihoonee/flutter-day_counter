import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/utils/date_calc.dart';
import '../../../../core/widgets/banner_ad_widget.dart';
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
    final theme = Theme.of(context);
    final state = ref.watch(eventsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        toolbarHeight: 56, // Standard height
        title: Text(
          'Days+',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.95), // Fixed subtle bg
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          // 1. Main Content List
          state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('에러: $e')),
            data: (List<Event> events) {
              if (events.isEmpty) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 56 + 16, // Match toolbarHeight
                  ),
                  child: _Empty(
                    onCreate: () => context.push('/edit', extra: null),
                  ),
                );
              }

              return ReorderableListView.builder(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 56 + 16, // Match toolbarHeight
                  bottom: 160, // Space for Bottom Bar
                  left: 16,
                  right: 16,
                ),
                itemCount: events.length,
                onReorder: (oldIndex, newIndex) {
                  ref.read(eventsProvider.notifier).reorder(oldIndex, newIndex);
                },
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      final double animValue = Curves.easeInOut.transform(animation.value);
                      final double scale = 1.0 + (0.02 * animValue);
                      return Transform.scale(
                        scale: scale,
                        child: Material(
                          color: Colors.transparent,
                          shadowColor: Colors.black.withOpacity(0.1),
                          elevation: 4,
                          child: child,
                        ),
                      );
                    },
                    child: child,
                  );
                },
                itemBuilder: (context, i) {
                  final e = events[i];
                  final diff = DateCalc.diffDays(
                    base: DateTime.now(),
                    target: e.targetDate,
                    includeToday: e.includeToday,
                    excludeWeekends: e.excludeWeekends,
                  );

                  final dateLine = DateFormat('yyyy.MM.dd').format(e.targetDate);

                  return Padding(
                    key: Key(e.id),
                    padding: const EdgeInsets.only(bottom: 8), 
                    child: SizedBox(
                      height: 185,
                      child: PosterCard(
                        title: e.title,
                        dateLine: dateLine,
                        dText: _dText(diff),
                        themeIndex: e.themeIndex,
                        iconIndex: e.iconIndex,
                        todoCount: e.todos.length,
                        photoPath: e.photoPath,
                        onTap: () => context.push('/detail', extra: e.id),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // 2. Minimalist Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: theme.scaffoldBackgroundColor.withOpacity(0.95),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Add Button
                    InkWell(
                      onTap: () => context.push('/edit', extra: null),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedAdd01,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '기념일 추가하기',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Banner Slot
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: _BannerSlot(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '아직 등록된 D-Day가 없어요',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '첫 번째 D-Day를 추가해보세요!',
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
