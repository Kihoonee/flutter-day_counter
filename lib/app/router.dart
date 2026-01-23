import 'package:go_router/go_router.dart';
import '../features/events/presentation/pages/home_page.dart';
import '../features/events/presentation/pages/result_page.dart';
import '../features/events/presentation/pages/event_list_page.dart';
import '../features/events/presentation/pages/event_detail_page.dart';
import '../features/events/presentation/pages/event_edit_page.dart';
import '../features/events/presentation/pages/settings_page.dart';

final router = GoRouter(
  initialLocation: '/events',
  routes: [
    GoRoute(path: '/', redirect: (_, __) => '/events'),
    GoRoute(path: '/calc', builder: (_, __) => const HomePage()),
    GoRoute(path: '/result', builder: (_, __) => const ResultPage()),
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
);
