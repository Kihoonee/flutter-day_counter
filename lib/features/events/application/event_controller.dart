import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/widget_service.dart';
import '../../../../core/storage/database_provider.dart'; // Correct import
import '../data/datasources/event_local_data_source_sembast.dart';
import '../data/repositories/event_repository_impl.dart';
import '../domain/event.dart';
import '../domain/event_repository.dart';
import '../domain/diary_entry.dart';
import '../domain/todo_item.dart';
import '../../../../core/utils/date_calc.dart';
import 'package:uuid/uuid.dart';

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
      (events) async {
        // 최초 실행 시 기본 이벤트 생성
        if (events.isEmpty) {
          final isFirstLaunch = await _checkAndSetFirstLaunch();
          if (isFirstLaunch) {
            final now = DateTime.now();
            final defaultEvent = Event(
              id: 'days-plus-start-${now.millisecondsSinceEpoch}',
              title: 'Days+ 시작',
              baseDate: DateTime(now.year, now.month, now.day),
              targetDate: DateTime(now.year, now.month, now.day),
              themeIndex: 0,
              iconIndex: 16, // 별 아이콘
            );
            await repo.upsert(defaultEvent);
            return [defaultEvent];
          }
        }
        // 정렬: sortOrder 오름차순
        final sorted = [...events]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        
        // 과거 이벤트의 할일을 메모로 자동 전환
        final processed = await _checkAndConvertTodosToMemos(sorted);

        // App 시작 시 위젯 명시적 갱신
        unawaited(_updateWidget()); 
        
        return processed;
      },
    );
  }

  Future<List<Event>> _checkAndConvertTodosToMemos(List<Event> events) async {
    final now = DateTime.now();
    final repo = await _repo;
    bool changed = false;
    final updatedList = <Event>[];

    for (var e in events) {
      final diff = DateCalc.diffDays(
        base: now,
        target: e.targetDate,
        includeToday: e.includeToday,
        excludeWeekends: e.excludeWeekends,
      );

      // 과거(D+N)이면서 할일이 있는 경우 전환
      if (diff < 0 && e.todos.isNotEmpty) {
        final newMemos = e.todos.map((t) => DiaryEntry(
          id: const Uuid().v4(),
          content: t.isCompleted ? '[완료] ${t.content}' : t.content,
          date: t.createdAt, // 할일 작성일 기준
          createdAt: DateTime.now(),
        )).toList();

        final updatedEvent = e.copyWith(
          diaryEntries: [...e.diaryEntries, ...newMemos],
          todos: [], // 할일 비우기
        );

        await repo.upsert(updatedEvent);
        updatedList.add(updatedEvent);
        changed = true;
      } else {
        updatedList.add(e);
      }
    }

    if (changed) {
      // 만약 정렬 순서가 필요하면 여기서 다시 수행
      return updatedList;
    }
    return events;
  }

  Future<bool> _checkAndSetFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('first_launch') ?? true;
    if (isFirstLaunch) {
      await prefs.setBool('first_launch', false);
    }
    return isFirstLaunch;
  }
  Future<void> upsert(Event e) async {
    try {
      final repo = await _repo;
      final result = await repo.upsert(e);
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (_) async {
          await NotificationService().scheduleEvent(e);
          // 저장 후에도 한 번 더 체크 (미래 날짜를 과거로 수정했을 경우 대비)
          final repo = await _repo;
          final all = await repo.fetchAll();
          all.fold((l) => null, (events) => _checkAndConvertTodosToMemos(events));
          
          await _updateWidget(); // Update Widget
          ref.invalidateSelf();
        },
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
        (_) async {
          await NotificationService().cancelEvent(id);
          await _updateWidget(); // Update Widget
          ref.invalidateSelf();
        },
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
      await _updateWidget(); // Update Widget (Top item might have changed)
      
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

  Future<void> _updateWidget() async {
    try {
      final repo = await _repo;
      final result = await repo.fetchAll();
      result.fold(
        (l) => null, // Ignore error
        (events) {
           // Get top event (sortOrder 0 or first)
           final sorted = [...events]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
           final top = sorted.firstOrNull;
           WidgetService().updateWidget(top);
        },
      );
    } catch (_) {}
  }
}
