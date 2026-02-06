import 'package:flutter/foundation.dart';
import '../../../../core/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:days_plus/l10n/app_localizations.dart';

import '../../../../core/services/image_service.dart';
import '../../../../core/utils/haptic_helper.dart';
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
  final ValueChanged<String?>? onPhotoChanged;
  final ValueChanged<int>? onWidgetLayoutTypeChanged;
  final VoidCallback? onSaved;  // 저장 완료 콜백
  const EditTab({
    super.key,
    required this.event,
    this.onIconChanged,
    this.onThemeChanged,
    this.onTitleChanged,
    this.onDateChanged,
    this.onIncludeTodayChanged,
    this.onPhotoChanged,
    this.onWidgetLayoutTypeChanged,
    this.onSaved,
  });

  @override
  ConsumerState<EditTab> createState() => _EditTabState();
}

class _EditTabState extends ConsumerState<EditTab> {
  late TextEditingController _title;
  late DateTime _target;
  late bool _includeToday;
  late bool _isNotificationEnabled;
  late bool _notifyDDay;
  late bool _notifyDMinus1;
  late bool _notifyAnniv;
  int _themeIndex = 0;
  int _iconIndex = 0;
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
    _isNotificationEnabled = e.isNotificationEnabled;
    _notifyDDay = e.notifyDDay;
    _notifyDMinus1 = e.notifyDMinus1;
    _notifyAnniv = e.notifyAnniv;
    _themeIndex = e.themeIndex;
    _iconIndex = e.iconIndex;
    _photoPath = e.photoPath;
    _widgetLayoutType = e.widgetLayoutType;
  }

  Future<void> _pickPhoto() async {
    if (kIsWeb) return;
    debugPrint('EditTab: _pickPhoto started');
    setState(() => _isPickingPhoto = true);
    try {
      final path = await _imageService.pickAndCropImage(context);
      debugPrint('EditTab: Result path: $path');

      if (path != null) {
        if (_photoPath != null && _photoPath!.isNotEmpty) {
          debugPrint('EditTab: Evicting old image cache: $_photoPath');
          await PlatformUtilsImpl.evictImage(_photoPath!);
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
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedImageAdd02,
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        size: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
                labelText: l10n.eventTitleLabel,
                hintText: l10n.eventTitleHint,
                labelStyle: TextStyle(color: theme.hintColor),
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
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
                            title: Text(l10n.changePhoto),
                            onTap: () => Navigator.pop(ctx, 'change'),
                          ),
                          ListTile(
                            leading: Icon(Icons.delete_outline,
                                color: theme.colorScheme.error),
                            title: Text(l10n.deletePhoto,
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
                          ? FutureBuilder<ImageProvider?>(
                              key: ValueKey(_photoPath),
                              future: PlatformUtilsImpl.getImageProviderAsync(_photoPath!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                }
                                final provider = snapshot.data;
                                if (provider != null) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(11),
                                    child: Image(
                                      image: provider,
                                      key: ValueKey('img_$_photoPath'),
                                      fit: BoxFit.cover,
                                      width: 64,
                                      height: 64,
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
                        l10n.addPhoto,
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
                        Text(l10n.icon, style: theme.textTheme.bodyMedium),
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
                        Text(l10n.theme, style: theme.textTheme.bodyMedium),
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
            label: l10n.targetDate,
            value: _target,
            onTap: () async {
              final picked = await pickDate(context, initial: _target);
              if (picked == null) return;
              setState(() => _target = picked);
              widget.onDateChanged?.call(picked);
            },
          ),
          const SizedBox(height: 16),

          // 5. 옵션 - 당일 포함 (그룹 분리)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              title: Text(l10n.includeTodayLabel,
                  style: TextStyle(fontSize: 14)),
              value: _includeToday,
              onChanged: (v) {
                setState(() => _includeToday = v);
                widget.onIncludeTodayChanged?.call(v);
              },
            ),
          ),
          const SizedBox(height: 16),

          // 6. 옵션 - 알림 (그룹 분리)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.enableNotifications, style: TextStyle(fontSize: 14)),
                  value: _isNotificationEnabled,
                  onChanged: (v) {
                    setState(() {
                      _isNotificationEnabled = v;
                      if (!v) {
                        _notifyDDay = false;
                        _notifyDMinus1 = false;
                        _notifyAnniv = false;
                      } else {
                        _notifyDDay = true;
                        _notifyDMinus1 = true;
                        _notifyAnniv = true;
                      }
                    });
                  },
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
                ),
                SwitchListTile(
                  //title: const Text('D-Day 알림', style: TextStyle(fontSize: 14)),
                  title: Text(l10n.notifyDDayLabel, style: theme.textTheme.bodyMedium),
                  value: _notifyDDay,
                  onChanged: (v) {
                    setState(() {
                      _notifyDDay = v;
                      if (v) {
                        _isNotificationEnabled = true;
                      } else if (!_notifyDMinus1 && !_notifyAnniv) {
                        _isNotificationEnabled = false;
                      }
                    });
                  },
                  dense: true,
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.05),
                ),
                SwitchListTile(
                  title: Text(l10n.notifyDMinus1Label, style: theme.textTheme.bodyMedium),
                  value: _notifyDMinus1,
                  onChanged: (v) {
                    setState(() {
                      _notifyDMinus1 = v;
                      if (v) {
                        _isNotificationEnabled = true;
                      } else if (!_notifyDDay && !_notifyAnniv) {
                        _isNotificationEnabled = false;
                      }
                    });
                  },
                  dense: true,
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.05),
                ),
                SwitchListTile(
                  title: Text(l10n.notifyAnniversaryLabel,
                      style: theme.textTheme.bodyMedium),
                  value: _notifyAnniv,
                  onChanged: (v) {
                    setState(() {
                      _notifyAnniv = v;
                      if (v) {
                        _isNotificationEnabled = true;
                      } else if (!_notifyDDay && !_notifyDMinus1) {
                        _isNotificationEnabled = false;
                      }
                    });
                  },
                  dense: true,
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
                      builder: (dialogContext) => AlertDialog(
                        title: Text(l10n.deleteConfirmTitle),
                        content: Text(l10n.deleteConfirmContent),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(false),
                              child: Text(l10n.cancel)),
                          TextButton(
                              onPressed: () async {
                                // 햅틱 피드백: 삭제 확인 (무거운 햅틱 - 중요한 액션)
                                await HapticHelper.heavy();
                                if (dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop(true);
                                }
                              },
                              child: Text(l10n.delete)),
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
                  child: Text(l10n.deleteEvent),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () async {
                    final updatedEvent = widget.event.copyWith(
                      title: _title.text.isEmpty ? l10n.eventDefaultTitle : _title.text,
                      baseDate: DateTime.now(),
                      targetDate: _target,
                      includeToday: _includeToday,
                      isNotificationEnabled: _isNotificationEnabled,
                      notifyDDay: _notifyDDay,
                      notifyDMinus1: _notifyDMinus1,
                      notifyAnniv: _notifyAnniv,
                      themeIndex: _themeIndex,
                      iconIndex: _iconIndex,
                      photoPath: _photoPath,
                      widgetLayoutType: _widgetLayoutType,
                    );
                    await ref
                        .read(eventsProvider.notifier)
                        .upsert(updatedEvent);
                    if (!mounted) return;
                    
                    // 저장 성공 콜백 호출 (전환 가이드 체크용)
                    widget.onSaved?.call();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.saveSuccess)));
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.saveChanges),
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
                icon: icon as List<List<dynamic>>,
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
