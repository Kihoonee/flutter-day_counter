import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:days_plus/l10n/app_localizations.dart';
import '../../../../core/services/notification_service.dart';
import '../../application/event_controller.dart';
import '../../../../app/theme_provider.dart';
import '../../../../app/locale_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  static const kGlobalNotifications = 'global_notifications_enabled';

  bool _loading = true;
  bool _globalNotifications = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _globalNotifications = prefs.getBool(kGlobalNotifications) ?? true;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kGlobalNotifications, _globalNotifications);

    // 알림 설정이 변경되었을 경우 즉시 반영
    await NotificationService().updateGlobalPreference(_globalNotifications);
    if (_globalNotifications) {
      // 켜진 경우 모든 이벤트 재등록 요철
      await ref.read(eventsProvider.notifier).rescheduleAllNotifications();
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _card(
                                context,
                                title: l10n.appearanceSettings,
                                icon: HugeIcons.strokeRoundedPaintBrush01,
                                child: Column(
                                  children: [
                                    Consumer(
                                      builder: (context, ref, child) {
                                        final themeMode = ref.watch(
                                          themeModeProvider,
                                        );
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 20.0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedMoon01,
                                                      color: theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      l10n.themeMode,
                                                      style: theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: theme
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                ),
                                                child:
                                                    SegmentedButton<ThemeMode>(
                                                  segments: [
                                                    ButtonSegment<ThemeMode>(
                                                      value: ThemeMode.system,
                                                      label: Text(l10n.system),
                                                      icon: HugeIcon(
                                                        icon: HugeIcons
                                                            .strokeRoundedSettings01,
                                                        size: 18,
                                                        color: themeMode ==
                                                                ThemeMode.system
                                                            ? theme.colorScheme
                                                                .onPrimaryContainer
                                                            : theme.colorScheme
                                                                .onSurfaceVariant,
                                                      ),
                                                    ),
                                                    ButtonSegment<ThemeMode>(
                                                      value: ThemeMode.light,
                                                      label: Text(l10n.light),
                                                      icon: HugeIcon(
                                                        icon: HugeIcons
                                                            .strokeRoundedSun01,
                                                        size: 18,
                                                        color: themeMode ==
                                                                ThemeMode.light
                                                            ? theme.colorScheme
                                                                .onPrimaryContainer
                                                            : theme.colorScheme
                                                                .onSurfaceVariant,
                                                      ),
                                                    ),
                                                    ButtonSegment<ThemeMode>(
                                                      value: ThemeMode.dark,
                                                      label: Text(l10n.dark),
                                                      icon: HugeIcon(
                                                        icon: HugeIcons
                                                            .strokeRoundedMoon02,
                                                        size: 18,
                                                        color: themeMode ==
                                                                ThemeMode.dark
                                                            ? theme.colorScheme
                                                                .onPrimaryContainer
                                                            : theme.colorScheme
                                                                .onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                  selected: {themeMode},
                                                  onSelectionChanged:
                                                      (Set<ThemeMode>
                                                          selection) {
                                                    ref
                                                        .read(
                                                          themeModeProvider
                                                              .notifier,
                                                        )
                                                        .setThemeMode(
                                                          selection.first,
                                                        );
                                                  },
                                                  showSelectedIcon: false,
                                                  style:
                                                      SegmentedButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 12,
                                                    ),
                                                    side: BorderSide(
                                                      color: theme
                                                          .colorScheme
                                                          .outlineVariant
                                                          .withOpacity(0.5),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    Divider(
                                      height: 1,
                                      color: theme.colorScheme.outlineVariant
                                          .withOpacity(0.2),
                                    ),
                                    Consumer(
                                      builder: (context, ref, child) {
                                        final currentLocale =
                                            ref.watch(localeProvider);
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 20.0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedLanguageSkill,
                                                      color: theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      l10n.language,
                                                      style: theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: theme
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                ),
                                                child: SegmentedButton<String>(
                                                  segments: [
                                                    ButtonSegment<String>(
                                                      value: 'auto',
                                                      label: Text(l10n.auto),
                                                    ),
                                                    ButtonSegment<String>(
                                                      value: 'ko',
                                                      label: Text(l10n.korean),
                                                    ),
                                                    ButtonSegment<String>(
                                                      value: 'en',
                                                      label: Text(l10n.english),
                                                    ),
                                                  ],
                                                  selected: {
                                                    currentLocale
                                                            ?.languageCode ??
                                                        'auto'
                                                  },
                                                  onSelectionChanged:
                                                      (Set<String> selection) {
                                                    final code =
                                                        selection.first;
                                                    ref
                                                        .read(
                                                          localeProvider
                                                              .notifier,
                                                        )
                                                        .setLocale(
                                                          code == 'auto'
                                                              ? null
                                                              : Locale(code),
                                                        );
                                                  },
                                                  showSelectedIcon: false,
                                                  style:
                                                      SegmentedButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 12,
                                                    ),
                                                    side: BorderSide(
                                                      color: theme
                                                          .colorScheme
                                                          .outlineVariant
                                                          .withOpacity(0.5),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              _card(
                                context,
                                title: l10n.notificationSettings,
                                icon: HugeIcons.strokeRoundedNotification03,
                                child: SwitchListTile(
                                  title: Text(
                                    l10n.globalNotificationSetting,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(l10n.globalNotificationSubtitle),
                                  value: _globalNotifications,
                                  onChanged: (v) =>
                                      setState(() => _globalNotifications = v),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 하단 고정 저장 버튼
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton(
                            onPressed: _save,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(l10n.save),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String title,
    dynamic icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              if (icon != null) ...[
                HugeIcon(
                  icon: icon as List<List<dynamic>>,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
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
          color: enabled
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
      onTap: enabled ? onTap : null,
    );
  }
}
