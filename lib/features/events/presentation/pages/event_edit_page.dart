import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/services/image_service.dart';

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
  bool _isNotificationEnabled = true;
  int _themeIndex = 0;
  int _iconIndex = 0;
  String? _photoPath;
  int _widgetLayoutType = 0; // 0: D-Day 강조, 1: 타이틀 강조

  final ImageService _imageService = ImageService();

  bool _initialized = false;
  bool _isPickingPhoto = false;

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
      _isNotificationEnabled = e.isNotificationEnabled;
      _themeIndex = e.themeIndex;
      _iconIndex = e.iconIndex;
      _photoPath = e.photoPath;
      _widgetLayoutType = e.widgetLayoutType;
    } else {
      _title.text = ''; // 새 이벤트는 빈 제목
      final now = DateTime.now();
      _target = DateTime(now.year, now.month, now.day);
      _includeToday = false;
      _excludeWeekends = false;
      _isNotificationEnabled = true; // Default true
      _themeIndex = 0;
      _iconIndex = 0;
      _photoPath = null;
      _widgetLayoutType = 0;
    }
  }

  Future<void> _pickPhoto() async {
    setState(() => _isPickingPhoto = true);
    try {
      final path = await _imageService.pickAndCropImage(context);
      
      if (path != null) {
        if (_photoPath != null && _photoPath!.isNotEmpty) {
          await FileImage(File(_photoPath!)).evict();
          await _imageService.deleteImage(_photoPath);
        }
        
        setState(() => _photoPath = path);
      }
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  Future<void> _deletePhoto() async {
    if (_photoPath == null || _photoPath!.isEmpty) return;
    
    await _imageService.deleteImage(_photoPath);
    setState(() => _photoPath = null);
  }

  Widget _buildPhotoIcon(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.add_photo_alternate_outlined,
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        size: 28,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventsState = ref.watch(eventsProvider);

    final scaffold = Scaffold(
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
                      height: 200, // Increased to Prevent overflow
                      child: PosterCard(
                        title: _title.text.isEmpty ? '이벤트' : _title.text,
                        dateLine: DateFormat('yyyy.MM.dd').format(_target),
                        dText: _dText(diff),
                        themeIndex: _themeIndex,
                        todoCount: 0,
                        photoPath: _photoPath,
                        widgetLayoutType: _widgetLayoutType,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 1. 이벤트 제목 입력 (Card로 감싸서 통일)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: EdgeInsets.zero,
                      child: TextField(
                        controller: _title,
                        style: theme.textTheme.titleMedium, 
                        decoration: InputDecoration(
                          labelText: '어떤 날인가요?',
                          hintText: '이벤트 제목을 입력하세요',
                          labelStyle: TextStyle(color: theme.hintColor), // Gray color
                          hintStyle: TextStyle(
                            color: theme.hintColor.withOpacity(0.5), 
                            fontSize: 16, // Smaller font size
                          ),
                          border: InputBorder.none,
                          // Increased vertical padding to lower the input text relative to label
                          contentPadding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 16),
                          floatingLabelBehavior: FloatingLabelBehavior.always, // Ensure label stays up
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 6. 사진 추가 (단순화된 UX) - 타이틀 하단으로 이동
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () async {
                          if (_photoPath == null || _photoPath!.isEmpty) {
                            // 사진 없으면 바로 갤러리
                            await _pickPhoto();
                          } else {
                            // 사진 있으면 ActionSheet
                            final action = await showModalBottomSheet<String>(
                              context: context,
                              builder: (ctx) => SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.photo_library_outlined),
                                      title: const Text('사진 변경'),
                                      onTap: () => Navigator.pop(ctx, 'change'),
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.delete_outline,
                                        color: theme.colorScheme.error,
                                      ),
                                      title: Text(
                                        '사진 삭제',
                                        style: TextStyle(color: theme.colorScheme.error),
                                      ),
                                      onTap: () => Navigator.pop(ctx, 'delete'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            if (action == 'change') {
                              await _pickPhoto();
                            } else if (action == 'delete') {
                              await _deletePhoto();
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // 사진 미리보기
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                                  ),
                                ),
                                child: _photoPath != null && _photoPath!.isNotEmpty
                                    ? FutureBuilder<bool>(
                                        future: File(_photoPath!).exists(),
                                        builder: (context, snapshot) {
                                          if (snapshot.data == true) {
                                            return ClipRRect(
                                              borderRadius: BorderRadius.circular(11),
                                              child: Image.file(
                                                File(_photoPath!),
                                                key: ValueKey(_photoPath),
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _buildPhotoIcon(theme),
                                              ),
                                            );
                                          }
                                          return _buildPhotoIcon(theme);
                                        },
                                      )
                                    : _buildPhotoIcon(theme),
                              ),
                              const SizedBox(width: 16),
                              // 텍스트
                              Expanded(
                                child: Text(
                                  '사진 추가',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. 아이콘 & 테마 선택
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // 기본 Card 컬러
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adjusted padding
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 60, // Fixed width for alignment
                                    child: Text(
                                      '아이콘',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.hintColor, // Gray label
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: _IconPicker(
                                      selected: _iconIndex,
                                      onSelect: (i) => setState(() => _iconIndex = i),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.2)),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 60, // Fixed width for alignment
                                    child: Text(
                                      '테마',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.hintColor, // Gray label
                                      ),
                                    ),
                                  ),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // 기본 Card 컬러
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
                              '알림 켜기',
                              style: theme.textTheme.bodyMedium,
                            ),
                            value: _isNotificationEnabled,
                            onChanged: (v) => setState(() => _isNotificationEnabled = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 32),

                    // 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final id = widget.eventId ?? const Uuid().v4();
                          // 기존 이벤트가 있으면 할일/다이어리는 유지해야 함
                          var todos = existing?.todos ?? [];
                          var diaryEntries = existing?.diaryEntries ?? [];
                          
                          final e = Event(
                            id: id,
                            title: _title.text.isEmpty ? '이벤트' : _title.text,
                            baseDate: DateTime.now(), // 기준일은 항상 오늘
                            targetDate: _target,
                            includeToday: _includeToday,
                            excludeWeekends: _excludeWeekends,
                            isNotificationEnabled: _isNotificationEnabled,
                            themeIndex: _themeIndex,
                            iconIndex: _iconIndex,
                            photoPath: _photoPath,
                            todos: todos,
                            diaryEntries: diaryEntries,
                            widgetLayoutType: _widgetLayoutType,
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
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: _BannerSlot(),
      ),
    );

    // Stack으로 감싸서 로딩 오버레이 추가
    return Stack(
      children: [
        scaffold,
        // 사진 선택 중 로딩 오버레이
        if (_isPickingPhoto)
          const ModalBarrier(
            dismissible: false,
            color: Colors.black54,
          ),
        if (_isPickingPhoto)
          const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
      ],
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
              width: 28, // Reduced from 40 -> 32 -> 28
              decoration: BoxDecoration(
                color: isSelected 
                    ? theme.colorScheme.primary.withOpacity(0.1) 
                    : Colors.transparent,
                shape: BoxShape.circle,
                // Border 제거
              ),
              child: HugeIcon(
                icon: icon,
                size: 16, // Reduced from 20 -> 18 -> 16
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
              width: 26, // Reduced from 32 -> 28 -> 26
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

class _BannerSlot extends StatelessWidget {
  const _BannerSlot();

  @override
  Widget build(BuildContext context) {
    return const BannerAdWidget();
  }
}
