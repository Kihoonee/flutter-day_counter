import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/events/domain/event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (kIsWeb) return;
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
      settings: initializationSettings,
    );

    _isInitialized = true;
  }

  /// 전역 알림 설정이 변경되었을 때 호출
  Future<void> updateGlobalPreference(bool enabled) async {
    if (kIsWeb) return;
    if (!_isInitialized) await init();

    if (!enabled) {
      // 전역 알림이 꺼지면 모든 예약된 알림 취소
      await flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('NotificationService: Global notifications disabled. Cancelled all.');
    } else {
      // 전역 알림이 켜지면 필요한 알림 재등록 로직은 
      // 앱을 다시 그리거나 EventController에서 다시 훑어주는 것이 안전함.
      // 하지만 여기서는 명시적으로 '전체 재스케줄링'이 필요하다고 알리는 용도.
      debugPrint('NotificationService: Global notifications enabled. Please reschedule events.');
    }
  }

  Future<void> scheduleEvent(Event event) async {
    if (kIsWeb) return;
    if (!_isInitialized) await init();

    // 1. 기존 알림 취소
    await cancelEvent(event.id);

    // 2. 전체 알림 설정 확인
    final prefs = await SharedPreferences.getInstance();
    
    // 알림 전체 마스터 스위치 또는 이벤트 개별 알림 확인
    final masterEnabled = prefs.getBool('global_notifications_enabled') ?? true;
    if (!masterEnabled || !event.isNotificationEnabled) {
      debugPrint('NotificationService: Skipping schedule for [${event.title}]. Master: $masterEnabled, Event: ${event.isNotificationEnabled}');
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    final target = tz.TZDateTime.from(event.targetDate, tz.local);
    final targetDay9AM = tz.TZDateTime(tz.local, target.year, target.month, target.day, 9, 0, 0);

    if (targetDay9AM.isAfter(now)) {
      if (event.notifyDDay) {
        await _schedule(
          id: _generateId(event.id, 'dday'),
          title: '${event.title} D-Day!',
          body: '오늘은 ${event.title} 날입니다.',
          scheduledDate: targetDay9AM,
        );
      }

      final dMinus1 = targetDay9AM.subtract(const Duration(days: 1));
      if (event.notifyDMinus1 && dMinus1.isAfter(now)) {
        await _schedule(
          id: _generateId(event.id, 'dminus1'),
          title: '${event.title} D-1',
          body: '하루 남았습니다! 준비되셨나요?',
          scheduledDate: dMinus1,
        );
      }
    } else {
      if (event.notifyAnniv) {
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
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
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
    if (kIsWeb) return;
    if (!_isInitialized) return;
    await flutterLocalNotificationsPlugin.cancel(id: _generateId(eventId, 'dday'));
    await flutterLocalNotificationsPlugin.cancel(id: _generateId(eventId, 'dminus1'));
    await flutterLocalNotificationsPlugin.cancel(id: _generateId(eventId, 'anniv'));
  }

  int _generateId(String eventId, String type) {
    return (eventId + type).hashCode & 0x7FFFFFFF; 
  }
}
