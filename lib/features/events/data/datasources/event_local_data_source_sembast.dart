import 'package:sembast/sembast.dart';
import '../../domain/event.dart';
import 'event_local_data_source.dart';

class EventLocalDataSourceSembast implements EventLocalDataSource {
  final Database database;
  final StoreRef<String, Map<String, dynamic>> _store = stringMapStoreFactory.store('events');

  EventLocalDataSourceSembast({required this.database});

  @override
  Future<List<Event>> getLastEvents() async {
    print('EventLocalDataSourceSembast: Fetching events from store "${_store.name}"...');
    try {
      final snapshots = await _store.find(database);
      print('EventLocalDataSourceSembast: Found ${snapshots.length} raw records in DB.');
      
      final events = <Event>[];
      for (final snapshot in snapshots) {
        try {
          // print('EventLocalDataSourceSembast: Processing record ${snapshot.key} -> ${snapshot.value}');
          final data = Map<String, dynamic>.from(snapshot.value);
          
          // Ensure baseDate and targetDate are Strings
          if (data['baseDate'] is DateTime) {
            data['baseDate'] = (data['baseDate'] as DateTime).toIso8601String();
          }
          if (data['targetDate'] is DateTime) {
            data['targetDate'] = (data['targetDate'] as DateTime).toIso8601String();
          }
          
          final event = Event.fromJson(data);
          events.add(event);
        } catch (e) {
          print('EventLocalDataSourceSembast: Failed to parse event ${snapshot.key}: $e');
        }
      }
      print('EventLocalDataSourceSembast: Successfully loaded ${events.length} events.');
      return events;
    } catch (e, st) {
      print('EventLocalDataSourceSembast: Critical Error in getLastEvents: $e\n$st');
      return [];
    }
  }

  @override
  Future<void> cacheEvents(List<Event> events) async {
    // Deprecated: Prefer using upsertEvent
    print('EventLocalDataSourceSembast: Mass caching ${events.length} events...');
    await database.transaction((txn) async {
      await _store.delete(txn);
      for (final event in events) {
        await _store.record(event.id).put(txn, event.toJson());
      }
    });
  }

  @override
  Future<void> upsertEvent(Event event) async {
    print('EventLocalDataSourceSembast: Upserting event ${event.id}...');
    try {
      final json = event.toJson();
      print('DEBUG: event.toJson() result: $json');
      await _store.record(event.id).put(database, json);
      print('EventLocalDataSourceSembast: Upsert successful.');
    } catch (e) {
      print('EventLocalDataSourceSembast Error in upsertEvent: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    print('EventLocalDataSourceSembast: Deleting event $id...');
    try {
      await _store.record(id).delete(database);
      print('EventLocalDataSourceSembast: Delete successful.');
    } catch (e) {
      print('EventLocalDataSourceSembast Error in deleteEvent: $e');
      rethrow;
    }
  }
}
