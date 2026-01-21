import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/database_provider.dart'; // Correct import
import '../data/datasources/event_local_data_source_sembast.dart';
import '../data/repositories/event_repository_impl.dart';
import '../domain/event.dart';
import '../domain/event_repository.dart';

final eventRepoProvider = FutureProvider<EventRepository>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  final localDataSource = EventLocalDataSourceSembast(database: database);
  return EventRepositoryImpl(localDataSource: localDataSource);
});

final eventsProvider = AsyncNotifierProvider<EventsController, List<Event>>(EventsController.new);

class EventsController extends AsyncNotifier<List<Event>> {
  
  // Repo is now async
  Future<EventRepository> get _repo => ref.read(eventRepoProvider.future);

  @override
  Future<List<Event>> build() async {
    final repo = await _repo;
    final result = await repo.fetchAll();
    return result.fold(
      (failure) => throw Exception(failure),
      (events) => events,
    );
  }

  Future<void> upsert(Event e) async {
    state = const AsyncValue.loading();
    try {
      final repo = await _repo;
      final result = await repo.upsert(e);
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (_) => ref.invalidateSelf(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> remove(String id) async {
    state = const AsyncValue.loading();
    try {
      final repo = await _repo;
      final result = await repo.remove(id);
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (_) => ref.invalidateSelf(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
