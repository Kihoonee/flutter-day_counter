import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/banner_ad_widget.dart';
import '../../application/selected_event_controller.dart';
import '../widgets/date_field.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(draftProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Days+'),
        actions: [
          IconButton(
            onPressed: () => context.push('/events'),
            icon: const Icon(Icons.view_agenda_rounded),
            tooltip: 'Events',
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DateField(
                  label: '기준일',
                  value: draft.baseDate,
                  helper: '기본: 오늘',
                  onTap: () async {
                    final picked = await pickDate(context, initial: draft.baseDate);
                    if (picked == null) return;
                    ref.read(draftProvider.notifier).state = draft.copyWith(
                      baseDate: picked,
                    );
                  },
                ),
                const SizedBox(height: 14),
                DateField(
                  label: '목표일',
                  value: draft.targetDate ?? draft.baseDate,
                  helper: draft.targetDate == null ? '선택하세요' : null,
                  onTap: () async {
                    final init = draft.targetDate ?? draft.baseDate;
                    final picked = await pickDate(context, initial: init);
                    if (picked == null) return;
                    ref.read(draftProvider.notifier).state = draft.copyWith(
                      targetDate: picked,
                    );
                  },
                ),
                const SizedBox(height: 16),

                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          '당일 포함',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: draft.includeToday,
                        onChanged: (v) => ref.read(draftProvider.notifier).state =
                            draft.copyWith(includeToday: v),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: Text(
                          '주말 제외',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: draft.excludeWeekends,
                        onChanged: (v) => ref.read(draftProvider.notifier).state =
                            draft.copyWith(excludeWeekends: v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: (draft.targetDate == null)
                        ? null
                        : () {
                            context.push('/result');
                          },
                    child: const Text('계산하기'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: _BannerSlot(),
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
