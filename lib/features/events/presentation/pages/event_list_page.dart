import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:days_plus/l10n/app_localizations.dart';

import '../../../../core/utils/date_calc.dart';
import '../../application/event_controller.dart';
import '../../domain/event.dart';
import '../widgets/poster_card.dart';

class EventListPage extends ConsumerWidget {
  const EventListPage({super.key});

  String _dText(BuildContext context, int diff) {
    final l10n = AppLocalizations.of(context)!;
    if (diff == 0) return l10n.dDay;
    if (diff > 0) return l10n.dMinus(diff);
    return l10n.dPlus(diff.abs());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedSettings01,
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            tooltip: l10n.settings,
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.95), // Fixed subtle bg
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          // 1. Main Content List
          state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.error(e.toString()))),
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
                  bottom: 100, // Space for Bottom Bar
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
                  );

                  final dateLine = DateFormat('yyyy.MM.dd').format(e.targetDate);

                  return _StaggeredItem(
                    index: i,
                    key: Key(e.id),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        height: 185,
                        child: Hero(
                        tag: e.id,
                        child: PosterCard(
                          title: e.title,
                          dateLine: dateLine,
                          dText: _dText(context, diff),
                          themeIndex: e.themeIndex,
                          iconIndex: e.iconIndex,
                          todoCount: e.todos.length,
                          photoPath: e.photoPath,
                          onTap: () => context.push('/detail', extra: e.id),
                        ),
                      ),
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
                    _ScaleButton(
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
                              l10n.addAnniversary,
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
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.emptyEventsTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.emptyEventsSubtitle,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onCreate,
              child: Text(AppLocalizations.of(context)!.createNewEvent),
            ),
          ],
        ),
      ),
    );
  }
}

/// 순차적 진입 애니메이션 위젯
class _StaggeredItem extends StatefulWidget {
  final int index;
  final Widget child;
  const _StaggeredItem({super.key, required this.index, required this.child});

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.65, curve: Curves.easeOut)),
    );

    _offset = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutSine),
    );

    // 인덱스에 따른 지연 실행
    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}

/// 클릭 시 살짝 눌리는 애니메이션 버튼
class _ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _ScaleButton({required this.child, required this.onTap});

  @override
  State<_ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<_ScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Material( // InkWell 효과를 유지하기 위해 child 내부에 사용됨
          color: Colors.transparent,
          child: widget.child,
        ),
      ),
    );
  }
}
