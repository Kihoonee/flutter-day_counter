import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../../features/events/domain/event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // 1. Initialize Timezone
    tz.initializeTimeZones();
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

    // 2. Android Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS Settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // 4. Initialize Plugin
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    _isInitialized = true;
  }

  Future<void> scheduleEvent(Event event) async {
    if (!_isInitialized) await init();

    await cancelEvent(event.id);

    final now = tz.TZDateTime.now(tz.local);
    final target = tz.TZDateTime.from(event.targetDate, tz.local);
    final targetDay9AM = tz.TZDateTime(tz.local, target.year, target.month, target.day, 9, 0, 0);

    if (targetDay9AM.isAfter(now)) {
      await _schedule(
        id: _generateId(event.id, 'dday'),
        title: '${event.title} D-Day!',
        body: '오늘은 ${event.title} 날입니다.',
        scheduledDate: targetDay9AM,
      );

      final dMinus1 = targetDay9AM.subtract(const Duration(days: 1));
      if (dMinus1.isAfter(now)) {
        await _schedule(
          id: _generateId(event.id, 'dminus1'),
          title: '${event.title} D-1',
          body: '하루 남았습니다! 준비되셨나요?',
          scheduledDate: dMinus1,
        );
      }
    } else {
      final diff = now.difference(targetDay9AM).inDays;
      int nextMilestone = ((diff / 100).ceil()) * 100;
      if (nextMilestone == diff) nextMilestone += 100;
      if (nextMilestone <= 0) nextMilestone = 100;

      final nextDate = targetDay9AM.add(Duration(days: nextMilestone));
      
      await _schedule(
        id: _generateId(event.id, 'anniv'),
        title: '${event.title} +$nextMilestone일',
        body: '시작한 지 $nextMilestone일이 되었습니다.',
        scheduledDate: nextDate,
      );
    }
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'event_channel',
            'Events',
            channelDescription: 'Event D-Day Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      print('DEBUG: Notification schedule failed: $e');
    }
  }

  Future<void> cancelEvent(String eventId) async {
    if (!_isInitialized) return;
    await flutterLocalNotificationsPlugin.cancel(_generateId(eventId, 'dday'));
    await flutterLocalNotificationsPlugin.cancel(_generateId(eventId, 'dminus1'));
    await flutterLocalNotificationsPlugin.cancel(_generateId(eventId, 'anniv'));
  }

  int _generateId(String eventId, String type) {
    return (eventId + type).hashCode & 0x7FFFFFFF; 
  }
}
