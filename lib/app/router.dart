import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/events/presentation/pages/event_list_page.dart';
import '../features/events/presentation/pages/event_detail_page.dart';
import '../features/events/presentation/pages/event_edit_page.dart';
import '../features/events/presentation/pages/settings_page.dart';
import '../core/widgets/banner_ad_widget.dart';

final router = GoRouter(
  initialLocation: '/events',
  routes: [
    GoRoute(path: '/', redirect: (_, __) => '/events'),
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: const SafeArea(
            child: SizedBox(
              height: 60,
              child: BannerAdWidget(),
            ),
          ),
        );
      },
      routes: [
        GoRoute(path: '/events', builder: (_, __) => const EventListPage()),
        GoRoute(
          path: '/detail',
          builder: (_, state) => EventDetailPage(eventId: state.extra as String),
        ),
        GoRoute(
          path: '/edit',
          builder: (_, state) => EventEditPage(eventId: state.extra as String?),
        ),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      ],
    ),
  ],
);
