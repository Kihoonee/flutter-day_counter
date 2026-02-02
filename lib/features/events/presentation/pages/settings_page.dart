import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const kIncludeTodayDefault = 'default_includeToday';
  static const kExcludeWeekendsDefault = 'default_excludeWeekends';

  bool _loading = true;
  bool _includeToday = false;
  bool _excludeWeekends = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _includeToday = prefs.getBool(kIncludeTodayDefault) ?? true;
      _excludeWeekends = prefs.getBool(kExcludeWeekendsDefault) ?? false;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kIncludeTodayDefault, _includeToday);
    await prefs.setBool(kExcludeWeekendsDefault, _excludeWeekends);
    if (!mounted) return;
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
                        title: '기본값',
                        icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: Text(
                                '당일 포함',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              value: _includeToday,
                              onChanged: (v) => setState(() => _includeToday = v),
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              title: Text(
                                '주말 제외',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              value: _excludeWeekends,
                              onChanged: (v) => setState(() => _excludeWeekends = v),
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
                HugeIcon(icon: icon, color: theme.colorScheme.primary, size: 20),
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

