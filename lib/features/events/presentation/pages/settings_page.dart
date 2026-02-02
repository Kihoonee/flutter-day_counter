import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/notification_service.dart';
import '../../application/event_controller.dart';
import '../../../../app/theme_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  static const kIncludeTodayDefault = 'default_includeToday';
  static const kGlobalNotifications = 'global_notifications_enabled';

  bool _loading = true;
  bool _includeToday = false;
  bool _globalNotifications = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _includeToday = prefs.getBool(kIncludeTodayDefault) ?? true;
      _globalNotifications = prefs.getBool(kGlobalNotifications) ?? true;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kIncludeTodayDefault, _includeToday);
    await prefs.setBool(kGlobalNotifications, _globalNotifications);
    
    // 알림 설정이 변경되었을 경우 즉시 반영
    await NotificationService().updateGlobalPreference(_globalNotifications);
    if (_globalNotifications) {
      // 켜진 경우 모든 이벤트 재등록 요철
      await ref.read(eventsProvider.notifier).rescheduleAllNotifications();
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('설정이 저장되었습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '설정',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _card(
                        context,
                        title: '화면 설정',
                        icon: HugeIcons.strokeRoundedPaintBrush01,
                        child: Consumer(
                          builder: (context, ref, child) {
                            final themeMode = ref.watch(themeModeProvider);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        HugeIcon(
                                          icon: HugeIcons.strokeRoundedMoon01,
                                          color: theme.colorScheme.onSurfaceVariant,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '테마 모드',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: SegmentedButton<ThemeMode>(
                                      segments: [
                                        ButtonSegment<ThemeMode>(
                                          value: ThemeMode.system,
                                          label: const Text('시스템'),
                                          icon: HugeIcon(
                                            icon: HugeIcons.strokeRoundedSettings01,
                                            size: 18,
                                            color: themeMode == ThemeMode.system ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        ButtonSegment<ThemeMode>(
                                          value: ThemeMode.light,
                                          label: const Text('라이트'),
                                          icon: HugeIcon(
                                            icon: HugeIcons.strokeRoundedSun01,
                                            size: 18,
                                            color: themeMode == ThemeMode.light ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        ButtonSegment<ThemeMode>(
                                          value: ThemeMode.dark,
                                          label: const Text('다크'),
                                          icon: HugeIcon(
                                            icon: HugeIcons.strokeRoundedMoon02,
                                            size: 18,
                                            color: themeMode == ThemeMode.dark ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                      selected: {themeMode},
                                      onSelectionChanged: (Set<ThemeMode> selection) {
                                        ref.read(themeModeProvider.notifier).setThemeMode(selection.first);
                                      },
                                      showSelectedIcon: false,
                                      style: SegmentedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        side: BorderSide(
                                          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      _card(
                        context,
                        title: '알림 및 기본값',
                        icon: HugeIcons.strokeRoundedNotification03,
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: Text(
                                '전역 알림 설정',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: const Text('꺼두면 모든 이벤트의 알림이 울리지 않습니다.'),
                              value: _globalNotifications,
                              onChanged: (v) => setState(() => _globalNotifications = v),
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              title: Text(
                                '새 이벤트 당일 포함',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              value: _includeToday,
                              onChanged: (v) => setState(() => _includeToday = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(height: 12),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _save,
                          child: const Text('저장'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _card(BuildContext context, {required String title, dynamic icon, required Widget child}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              if (icon != null) ...[
                HugeIcon(icon: icon as List<List<dynamic>>, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withOpacity(0.3),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ],
    );
  }

  Widget _actionRow(
    BuildContext context,
    String label, {
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: enabled ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
      onTap: enabled ? onTap : null,
    );
  }
}

