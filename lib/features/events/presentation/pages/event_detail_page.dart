import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_calc.dart';
import '../../../../core/widgets/banner_ad_widget.dart';
import '../../application/event_controller.dart';
import '../../domain/event.dart';
import '../widgets/diary_tab.dart';
import '../widgets/edit_tab.dart';
import '../widgets/poster_card.dart';
import '../widgets/todo_tab.dart';

/// 이벤트 상세 페이지 (3탭: 투두 / 다이어리 / 수정)
class EventDetailPage extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailPage({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends ConsumerState<EventDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Live Preview State (null means use event data)
  int? _previewThemeIndex;
  int? _previewIconIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _dText(int diff) {
    if (diff == 0) return 'D-Day';
    if (diff > 0) return 'D-$diff';
    return 'D+${diff.abs()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventsState = ref.watch(eventsProvider);

    return eventsState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('에러: $e')),
      ),
      data: (List<Event> events) {
        final event = events.where((e) => e.id == widget.eventId).firstOrNull;

        if (event == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('이벤트를 찾을 수 없습니다.')),
          );
        }

        final diff = DateCalc.diffDays(
          base: DateTime.now(),
          target: event.targetDate,
          includeToday: event.includeToday,
          excludeWeekends: event.excludeWeekends,
        );

        final dateLine = DateFormat('yyyy.MM.dd').format(event.targetDate);

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  pinned: true,
                  expandedHeight: 320, // Slightly reduced for better balance
                  forceElevated: innerBoxIsScrolled,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin, // Fixed to prevent squishing
                    background: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: kToolbarHeight,
                          left: 16,
                          right: 16,
                          bottom: 64, // Space for TabBar
                        ),
                        child: PosterCard(
                          title: event.title,
                          dateLine: dateLine,
                          dText: _dText(diff),
                          themeIndex: _previewThemeIndex ?? event.themeIndex,
                          iconIndex: _previewIconIndex ?? event.iconIndex,
                          todoCount: event.todos.length,
                        ),
                      ),
                    ),
                  ),
                  bottom: PreferredSize(
                     preferredSize: const Size.fromHeight(48),
                     child: Container(
                       decoration: BoxDecoration(
                         color: theme.scaffoldBackgroundColor,
                         border: Border(
                           bottom: BorderSide(
                             color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                             width: 0.5,
                           ),
                         ),
                       ),
                       child: TabBar(
                        controller: _tabController,
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                        indicatorColor: theme.colorScheme.primary,
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(text: '할 일'),
                          Tab(text: '한줄메모'),
                          Tab(text: '수정'),
                        ],
                      ),
                     ),
                  ),
                ),
              ),
            ],
            body: Builder(
              builder: (BuildContext context) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    TodoTab(event: event),
                    DiaryTab(eventId: event.id),
                    EditTab(
                      event: event,
                      onIconChanged: (i) => setState(() => _previewIconIndex = i),
                      onThemeChanged: (i) => setState(() => _previewThemeIndex = i),
                    ),
                  ],
                );
              },
            ),
          ),
          bottomNavigationBar: const SafeArea(
            child: SizedBox(
               height: 60,
               child: BannerAdWidget(),
            ),
          ),
        );
      },
    );
  }
}


