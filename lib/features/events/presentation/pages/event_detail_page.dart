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
          base: event.baseDate,
          target: event.targetDate,
          includeToday: event.includeToday,
          excludeWeekends: event.excludeWeekends,
        );

        final dateLine = DateFormat('yyyy.MM.dd').format(event.targetDate);

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                pinned: true,
                expandedHeight: 280,
                backgroundColor: theme.scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + kToolbarHeight,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: PosterCard(
                      title: event.title,
                      dateLine: dateLine,
                      dText: _dText(diff),
                      themeIndex: event.themeIndex,
                      iconIndex: event.iconIndex,
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  tabBar: TabBar(
                    controller: _tabController,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    indicatorColor: theme.colorScheme.primary,
                    tabs: const [
                      Tab(text: '할 일'),
                      Tab(text: '다이어리'),
                      Tab(text: '수정'),
                    ],
                  ),
                  backgroundColor: theme.scaffoldBackgroundColor,
                ),
              ),
            ],
            body: Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      TodoTab(event: event),
                      DiaryTab(eventId: event.id),
                      EditTab(event: event),
                    ],
                  ),
                ),
                // 배너 광고 슬롯
                const SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: BannerAdWidget(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// TabBar를 SliverPersistentHeader에서 사용하기 위한 Delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _TabBarDelegate({
    required this.tabBar,
    required this.backgroundColor,
  });

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
