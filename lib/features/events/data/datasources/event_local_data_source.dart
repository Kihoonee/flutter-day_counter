import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/event.dart';

abstract class EventLocalDataSource {
  Future<List<Event>> getLastEvents();
  Future<void> cacheEvents(List<Event> events);
  Future<void> upsertEvent(Event event);
  Future<void> deleteEvent(String id);
}

class EventLocalDataSourceImpl implements EventLocalDataSource {
  final SharedPreferences sharedPreferences;

  EventLocalDataSourceImpl({required this.sharedPreferences});

  static const cachedEventsKey = 'CACHED_EVENTS';

  @override
  Future<List<Event>> getLastEvents() async {
    final jsonString = sharedPreferences.getString(cachedEventsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  }

  @override
  Future<void> cacheEvents(List<Event> events) {
    return sharedPreferences.setString(
      cachedEventsKey,
      jsonEncode(events.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> upsertEvent(Event event) async {
    final events = await getLastEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index >= 0) {
      events[index] = event;
    } else {
      events.insert(0, event);
    }
    await cacheEvents(events);
  }

  @override
  Future<void> deleteEvent(String id) async {
    final events = await getLastEvents();
    events.removeWhere((e) => e.id == id);
    await cacheEvents(events);
  }
}
