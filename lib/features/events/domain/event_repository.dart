import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import 'event.dart';

abstract class EventRepository {
  Future<Either<Failure, List<Event>>> fetchAll();
  Future<Either<Failure, Unit>> upsert(Event event);
  Future<Either<Failure, Unit>> remove(String id);
}