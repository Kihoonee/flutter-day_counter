import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/services/image_service.dart';
import '../../application/event_controller.dart';
import '../../domain/event.dart';
import 'date_field.dart';
import 'poster_card.dart';

/// 수정 탭 - 이벤트 정보 수정
class EditTab extends ConsumerStatefulWidget {
  final Event event;
  final ValueChanged<int>? onIconChanged;
  final ValueChanged<int>? onThemeChanged;
  final ValueChanged<String>? onTitleChanged;
  final ValueChanged<DateTime>? onDateChanged;
  final ValueChanged<bool>? onIncludeTodayChanged;
  final ValueChanged<bool>? onExcludeWeekendsChanged;
  final ValueChanged<String?>? onPhotoChanged;
  final ValueChanged<int>? onWidgetLayoutTypeChanged;
  const EditTab({
    super.key,
    required this.event,
    this.onIconChanged,
    this.onThemeChanged,
    this.onTitleChanged,
    this.onDateChanged,
    this.onIncludeTodayChanged,
    this.onExcludeWeekendsChanged,
    this.onPhotoChanged,
    this.onWidgetLayoutTypeChanged,
  });

  @override
  ConsumerState<EditTab> createState() => _EditTabState();
}

class _EditTabState extends ConsumerState<EditTab> {
  late TextEditingController _title;
  late DateTime _target;
  late bool _includeToday;
  late bool _excludeWeekends;
  late bool _isNotificationEnabled;
  late int _themeIndex;
  late int _iconIndex;
  String? _photoPath;
  late int _widgetLayoutType;

  final ImageService _imageService = ImageService();
  bool _initialized = false;
  bool _isPickingPhoto = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _initFrom(Event e) {
    if (_initialized) return;
    _initialized = true;

    _title.text = e.title;
    _target = e.targetDate;
    _includeToday = e.includeToday;
    _excludeWeekends = e.excludeWeekends;
    _isNotificationEnabled = e.isNotificationEnabled;
    _themeIndex = e.themeIndex;
    _iconIndex = e.iconIndex;
    _photoPath = e.photoPath;
    _widgetLayoutType = e.widgetLayoutType;
  }

  Future<void> _pickPhoto() async {
    debugPrint('EditTab: _pickPhoto started');
    setState(() => _isPickingPhoto = true);
    try {
      final path = await _imageService.pickAndCropImage(context);
      debugPrint('EditTab: Result path: $path');

      if (path != null) {
        if (_photoPath != null && _photoPath!.isNotEmpty) {
          debugPrint('EditTab: Evicting old image cache: $_photoPath');
          await FileImage(File(_photoPath!)).evict();
          await _imageService.deleteImage(_photoPath);
        }

        setState(() {
          debugPrint('EditTab: Setting new photo path: $path');
          _photoPath = path;
        });
        widget.onPhotoChanged?.call(path);
      }
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  Future<void> _deletePhoto() async {
    if (_photoPath == null || _photoPath!.isEmpty) return;

    await _imageService.deleteImage(_photoPath);
    setState(() => _photoPath = null);
    widget.onPhotoChanged?.call(null);
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

    // 초기화
    _initFrom(widget.event);

    final scrollView = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Title
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.zero,
            child: TextField(
              controller: _title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.normal,
              ),
              decoration: InputDecoration(
                labelText: '어떤 날인가요?',
                hintText: '이벤트 제목을 입력하세요',
                labelStyle: TextStyle(color: theme.hintColor),
                hintStyle: TextStyle(
                  color: theme.hintColor.withOpacity(0.5),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 24,
                  bottom: 16,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              onChanged: (v) {
                setState(() {});
                widget.onTitleChanged?.call(v);
              },
            ),
          ),
          const SizedBox(height: 16),

          // 2. Photo (Simplified UX)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () async {
                if (_photoPath == null || _photoPath!.isEmpty) {
                  await _pickPhoto();
                } else {
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
                            leading: Icon(Icons.delete_outline,
                                color: theme.colorScheme.error),
                            title: Text('사진 삭제',
                                style:
                                    TextStyle(color: theme.colorScheme.error)),
                            onTap: () => Navigator.pop(ctx, 'delete'),
                          ),
                        ],
                      ),
                    ),
                  );
                  if (action == 'change') await _pickPhoto();
                  else if (action == 'delete') await _deletePhoto();
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: theme.colorScheme.surfaceContainerHighest,
                        border: Border.all(
                            color: theme.colorScheme.outlineVariant
                                .withOpacity(0.3)),
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
                    Expanded(
                      child: Text(
                        '사진 추가',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 3. Icon & Theme
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text('아이콘', style: theme.textTheme.bodyMedium),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _IconPicker(
                            selected: _iconIndex,
                            onSelect: (i) {
                              setState(() => _iconIndex = i);
                              widget.onIconChanged?.call(i);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                      height: 1,
                      color: theme.colorScheme.outlineVariant
                          .withOpacity(0.2)),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text('테마', style: theme.textTheme.bodyMedium),
                        const SizedBox(width: 28),
                        Expanded(
                          child: _ThemePicker(
                            selected: _themeIndex,
                            onSelect: (i) {
                              setState(() => _themeIndex = i);
                              widget.onThemeChanged?.call(i);
                            },
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

          // 4. Target Date
          DateField(
            label: '목표일',
            value: _target,
            onTap: () async {
              final picked = await pickDate(context, initial: _target);
              if (picked == null) return;
              setState(() => _target = picked);
              widget.onDateChanged?.call(picked);
            },
          ),
          const SizedBox(height: 16),

          // 5. Options
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('당일 포함 (1일차 시작)',
                      style: theme.textTheme.bodyMedium),
                  value: _includeToday,
                  onChanged: (v) {
                    setState(() => _includeToday = v);
                    widget.onIncludeTodayChanged?.call(v);
                  },
                ),
                Divider(
                    height: 1,
                    color: theme.colorScheme.outlineVariant
                        .withOpacity(0.2)),
                SwitchListTile(
                  title: Text('알림 켜기', style: theme.textTheme.bodyMedium),
                  value: _isNotificationEnabled,
                  onChanged: (v) =>
                      setState(() => _isNotificationEnabled = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 32),

          // Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('삭제할까요?'),
                        content: const Text('이 이벤트를 삭제합니다.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('취소')),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('삭제')),
                        ],
                      ),
                    );
                    if (ok != true) return;
                    await ref
                        .read(eventsProvider.notifier)
                        .remove(widget.event.id);
                    if (!mounted) return;
                    context.go('/events');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface
                        .withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('이벤트 삭제'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () async {
                    final updatedEvent = widget.event.copyWith(
                      title: _title.text.isEmpty ? '이벤트' : _title.text,
                      baseDate: DateTime.now(),
                      targetDate: _target,
                      includeToday: _includeToday,
                      excludeWeekends: _excludeWeekends,
                      isNotificationEnabled: _isNotificationEnabled,
                      themeIndex: _themeIndex,
                      iconIndex: _iconIndex,
                      photoPath: _photoPath,
                      widgetLayoutType: _widgetLayoutType,
                    );
                    await ref
                        .read(eventsProvider.notifier)
                        .upsert(updatedEvent);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('저장되었습니다.')));
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('변경사항 저장'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );

    return Stack(
      children: [
        scrollView,
        if (_isPickingPhoto)
          const ModalBarrier(dismissible: false, color: Colors.black54),
        if (_isPickingPhoto)
          const Center(
              child: CircularProgressIndicator(color: Colors.white)),
      ],
    );
  }
}

/// 아이콘 선택 위젯
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
              width: 28, // Reduced from 32
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                shape: BoxShape.circle,
                // Border 제거
              ),
              child: HugeIcon(
                icon: icon,
                size: 16, // Reduced from 18
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

/// 테마 선택 위젯
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
              width: 26, // Reduced from 28
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
                        ),
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
