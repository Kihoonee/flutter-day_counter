import 'package:flutter/material.dart';
import 'package:days_plus/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_calc.dart';
import '../../application/event_controller.dart';
import '../../domain/event.dart';
import '../widgets/diary_tab.dart';
import '../widgets/edit_tab.dart';
import '../widgets/poster_card.dart';
import '../widgets/todo_tab.dart';
import '../../../../core/ads/ad_manager.dart';

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
  String? _previewTitle;
  DateTime? _previewTargetDate;
  bool? _previewIncludeToday;
  String? _previewPhotoPath;
  int? _previewWidgetLayoutType;

  @override
  void initState() {
    super.initState();
    // 2 tabs: (Todo OR Memo) + Edit
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _dText(BuildContext context, int diff) {
    final l10n = AppLocalizations.of(context)!;
    if (diff == 0) return l10n.dDay;
    if (diff > 0) return l10n.dMinus(diff);
    return l10n.dPlus(diff.abs());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final eventsState = ref.watch(eventsProvider);

    return eventsState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.error(e.toString()))),
      ),
      data: (List<Event> events) {
        final event = events.where((e) => e.id == widget.eventId).firstOrNull;

        if (event == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.eventNotFound)),
          );
        }

        final targetDate = _previewTargetDate ?? event.targetDate;
        final includeToday = _previewIncludeToday ?? event.includeToday;
        
        final diff = DateCalc.diffDays(
          base: DateTime.now(),
          target: targetDate,
          includeToday: includeToday,
        );

        final isPast = diff < 0;
        final dateLine = DateFormat('yyyy.MM.dd').format(targetDate);

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              // 뒤로가기 시 전면 광고 노출 시도 (빈도 제어 포함)
              AdManager.instance.showInterstitialAdWithCount();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
            ),
            body: Column(
              children: [
                // 1. 고정된 PosterCard (스크롤되지 않음)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                  height: 185,
                  child: Hero(
                    tag: event.id,
                    child: PosterCard(
                      title: _previewTitle ?? event.title,
                      dateLine: dateLine,
                      dText: _dText(context, diff),
                      themeIndex: _previewThemeIndex ?? event.themeIndex,
                      iconIndex: _previewIconIndex ?? event.iconIndex,
                      todoCount: event.todos.length,
                      photoPath: _previewPhotoPath ?? event.photoPath,
                      widgetLayoutType: _previewWidgetLayoutType ?? event.widgetLayoutType,
                    ),
                  ),
                ),
                ),
                const SizedBox(height: 8),
                // 2. 고정된 TabBar (스크롤되지 않음)
                Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
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
                    tabs: [
                      Tab(text: isPast ? l10n.diaryTab : l10n.todoTab),
                      Tab(text: l10n.editTab),
                    ],
                  ),
                ),
                // 3. 스크롤 가능한 TabBarView (탭 내용만 스크롤)
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      if (isPast)
                        DiaryTab(eventId: event.id)
                      else
                        TodoTab(event: event),
                      EditTab(
                        event: event,
                        onTitleChanged: (v) => setState(() => _previewTitle = v),
                        onDateChanged: (v) => setState(() => _previewTargetDate = v),
                        onIncludeTodayChanged: (v) => setState(() => _previewIncludeToday = v),
                        onIconChanged: (i) => setState(() => _previewIconIndex = i),
                        onThemeChanged: (i) => setState(() => _previewThemeIndex = i),
                        onPhotoChanged: (p) => setState(() => _previewPhotoPath = p),
                        onWidgetLayoutTypeChanged: (v) => setState(() => _previewWidgetLayoutType = v),
                      ),
                    ],
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
