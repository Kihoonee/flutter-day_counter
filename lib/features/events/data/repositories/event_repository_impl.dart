import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/event.dart';
import '../../domain/event_repository.dart';
import '../datasources/event_local_data_source.dart';

class EventRepositoryImpl implements EventRepository {
  final EventLocalDataSource localDataSource;

  EventRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Event>>> fetchAll() async {
    try {
      final events = await localDataSource.getLastEvents();
      return Right(events);
    } catch (e, st) {
      print('EventRepositoryImpl.fetchAll Error: $e\n$st');
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> remove(String id) async {
    try {
      await localDataSource.deleteEvent(id);
      return const Right(unit);
    } catch (e, st) {
      print('EventRepositoryImpl.remove Error: $e\n$st');
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> upsert(Event event) async {
    try {
      await localDataSource.upsertEvent(event);
      return const Right(unit);
    } catch (e, st) {
      print('EventRepositoryImpl.upsert Error: $e\n$st');
      return const Left(CacheFailure());
    }
  }
}
