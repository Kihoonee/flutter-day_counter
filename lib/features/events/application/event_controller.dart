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
      (events) {
        // 정렬: sortOrder 오름차순
        final sorted = [...events]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return sorted;
      },
    );
  }

  Future<void> upsert(Event e) async {
    // state = const AsyncValue.loading(); // 로딩 상태로 변경하면 화면 깜빡임 발생 가능. 낙관적 업데이트 권장.
    // 여기서는 간단히 invalidate만 함.
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
    // state = const AsyncValue.loading();
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

  Future<void> reorder(int oldIndex, int newIndex) async {
    final currentList = state.asData?.value;
    if (currentList == null) return;

    if (oldIndex < newIndex) newIndex -= 1;
    
    final items = [...currentList];
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    // 1. 낙관적 업데이트 (UI 즉시 반영)
    state = AsyncValue.data(items);

    try {
      final repo = await _repo;
      // 2. DB 업데이트 (순서 변경된 모든 항목 업데이트)
      for (var i = 0; i < items.length; i++) {
        // sortOrder가 변경된 항목만 업데이트하면 더 좋음
        if (items[i].sortOrder != i) {
          final updated = items[i].copyWith(sortOrder: i);
          await repo.upsert(updated);
        }
      }
      // 3. 최종 동기화 (선택적)
      // 이미 낙관적 업데이트 했으므로 invalidate 안 해도 되지만, 
      // DB와 일치성 보장을 위해 invalidate. 
      // 단, 깜빡임 방지 위해 silent update가 좋으나 Riverpod 2.0 AsyncNotifier는 invalidate하면 새로 load함.
      // 여기서는 그냥 둠 (이미 state update 했으므로 다음 load 전까지 유지)
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      ref.invalidateSelf(); // 에러 시 롤백
    }
  }
}
