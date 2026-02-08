import 'dart:io';
import 'package:flutter/material.dart';
import 'package:days_plus/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/date_calc.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../../core/services/share_service.dart';
import '../../application/event_controller.dart';
import '../../domain/event.dart';
import '../widgets/diary_tab.dart';
import '../widgets/edit_tab.dart';
import '../widgets/poster_card.dart';
import '../widgets/todo_tab.dart';
import '../../../../core/ads/ad_manager.dart';
import '../widgets/transition_guide_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;  // 공유 중복 방지 플래그
  bool _hasCheckedTransition = false;  // 전환 가이드 체크 완료 플래그 (첫 진입 시에만)
  
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

        // 탭 결정은 **저장된 이벤트 데이터**만 사용 (미리보기 데이터로 탭이 바뀔면 안 됨!)
        final savedTargetDate = event.targetDate;
        final savedIncludeToday = event.includeToday;
        
        final savedDiff = DateCalc.diffDays(
          base: DateTime.now(),
          target: savedTargetDate,
          includeToday: savedIncludeToday,
        );
        final isPast = savedDiff <= 0;  // D-Day부터 전환 (D-Day, D+1, D+2...)

        // 카드 표시용 (미리보기 데이터 사용)
        final targetDate = _previewTargetDate ?? event.targetDate;
        final includeToday = _previewIncludeToday ?? event.includeToday;
        
        final diff = DateCalc.diffDays(
          base: DateTime.now(),
          target: targetDate,
          includeToday: includeToday,
        );
        final dateLine = DateFormat('yyyy.MM.dd').format(targetDate);

        // DEBUG: 전환 가이드 디버깅
        debugPrint('[TRANSITION_DEBUG] Event: ${event.title}');
        debugPrint('[TRANSITION_DEBUG] savedDiff: $savedDiff, isPast: $isPast (for tabs)');
        debugPrint('[TRANSITION_DEBUG] diff: $diff (for card display)');
        debugPrint('[TRANSITION_DEBUG] targetDate: $targetDate, includeToday: $includeToday');

        // NOTE: 전환 가이드는 저장 후에만 표시하므로, 여기서는 체크하지 않음

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
              actions: [
                // 공유 버튼
                Builder(
                  builder: (btnContext) => IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedShare08,
                      color: theme.colorScheme.onSurface,
                    ),
                    onPressed: _isSharing ? null : () async {
                      // 햅틱 피드백: 공유 버튼
                      await HapticHelper.medium();
                      // 중복 클릭 방지
                      if (_isSharing) return;
                      setState(() => _isSharing = true);
                      
                      try {
                        debugPrint('ShareButton: Starting capture...');
                        // 포스터 카드 캡처
                        final imageBytes = await _screenshotController.capture(
                          pixelRatio: 3.0,
                        );

                        if (imageBytes == null) {
                          debugPrint('ShareButton: Failed to capture');
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.shareFailed)),
                          );
                          return;
                        }

                        debugPrint('ShareButton: Capture successful, preparing to share...');
                        // 임시 파일로 저장
                        final directory = await getTemporaryDirectory();
                        final imagePath = '${directory.path}/days_plus_${event.title}.png';
                        final imageFile = File(imagePath);
                        await imageFile.writeAsBytes(imageBytes);

                        // iOS용 sharePositionOrigin 계산 (화면 우측 상단)
                        final screenSize = MediaQuery.of(context).size;
                        final sharePositionOrigin = Rect.fromLTWH(
                          screenSize.width - 100,  // 우측에서 100px
                          50,  // 상단에서 50px (AppBar 영역)
                          50,  // width
                          50,  // height
                        );
                        
                        debugPrint('ShareButton: Position origin: $sharePositionOrigin');

                        // 공유 (이미지만 공유하여 깔끔한 프리뷰 표시)
                        await Share.shareXFiles(
                          [XFile(imagePath)],
                          sharePositionOrigin: sharePositionOrigin,
                        );
                        debugPrint('ShareButton: Share completed');
                      } catch (e) {
                        debugPrint('ShareButton: Error - $e');
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.shareFailed)),
                        );
                      } finally {
                        // 공유 완료 후 플래그 해제
                        if (mounted) {
                          setState(() => _isSharing = false);
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Column(
              children: [
                // 1. 고정된 PosterCard (스크롤되지 않음)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 185,
                    child: Screenshot(
                      controller: _screenshotController,
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
                    onTap: (index) async {
                      await HapticHelper.selection();
                    },
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
                    physics: const NeverScrollableScrollPhysics(), // 탭 스와이프 비활성화 (Dismissible 충돌 방지)
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
                        onSaved: () async {
                          // 저장 후 전환 가이드 체크
                          debugPrint('[TRANSITION_DEBUG] onSaved callback triggered');
                          
                          // 저장된 이벤트 다시 가져오기
                          final events = ref.read(eventsProvider).value ?? [];
                          final savedEvent = events.firstWhere((e) => e.id == event.id);
                          
                          // diff 계산
                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          final diff = DateCalc.diffDays(
                            base: today,
                            target: savedEvent.targetDate,
                            includeToday: savedEvent.includeToday,
                          );
                          final isPast = diff <= 0;  // D-Day + 과거
                          
                          debugPrint('[TRANSITION_DEBUG] After save - diff: $diff, isPast: $isPast');
                          
                          if (isPast) {
                            final prefs = await SharedPreferences.getInstance();
                            final key = 'transition_guide_shown_${event.id}';
                            final hasShown = prefs.getBool(key) ?? false;
                            
                            debugPrint('[TRANSITION_DEBUG] hasShown: $hasShown');
                            
                            if (!hasShown && mounted && savedEvent.todos.isNotEmpty) {
                              // 팝업 표시
                              debugPrint('[TRANSITION_DEBUG] Showing transition guide after save!');
                              await showTransitionGuideDialog(context, savedEvent.title);
                              await prefs.setBool(key, true);
                              
                              // 탭을 메모 탭으로 전환 (index 0)
                              if (mounted) {
                                _tabController.animateTo(0);
                                debugPrint('[TRANSITION_DEBUG] Switched to memo tab');
                              }
                            }
                          }
                        },
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
