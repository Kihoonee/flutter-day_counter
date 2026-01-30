import 'package:days_plus/core/errors/exceptions.dart';
import 'package:days_plus/core/errors/failures.dart';
import 'package:days_plus/features/events/data/datasources/event_local_data_source.dart';
import 'package:days_plus/features/events/data/repositories/event_repository_impl.dart';
import 'package:days_plus/features/events/domain/event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'event_repository_impl_test.mocks.dart';

@GenerateMocks([EventLocalDataSource])
void main() {
  late EventRepositoryImpl repository;
  late MockEventLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockEventLocalDataSource();
    repository = EventRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  final tEvent = Event(
    id: '1',
    title: 'Test Event',
    baseDate: DateTime(2023, 1, 1),
    targetDate: DateTime(2023, 12, 31),
    includeToday: false,
    excludeWeekends: false,
    themeIndex: 0,
  );

  group('fetchAll', () {
    test(
      'should return list of events when call to data source is successful',
      () async {
        // arrange
        when(mockLocalDataSource.getLastEvents())
            .thenAnswer((_) async => [tEvent]);
        // act
        final result = await repository.fetchAll();
        // assert
        verify(mockLocalDataSource.getLastEvents());
        expect(result.isRight(), true);
        final events = result.getOrElse((_) => []);
        expect(events, equals([tEvent]));
      },
    );

    test(
      'should return CacheFailure when call to data source throws CacheException',
      () async {
        // arrange
        when(mockLocalDataSource.getLastEvents()).thenThrow(CacheException());
        // act
        final result = await repository.fetchAll();
        // assert
        verify(mockLocalDataSource.getLastEvents());
        expect(result, equals(const Left<Failure, List<Event>>(CacheFailure())));
      },
    );
  });

  group('upsert', () {
    test(
      'should cache the data locally when the call to data source is successful',
      () async {
        // arrange
        when(mockLocalDataSource.getLastEvents()).thenAnswer((_) async => []);
        when(mockLocalDataSource.cacheEvents(any))
            .thenAnswer((_) async => Future.value());
        // act
        final result = await repository.upsert(tEvent);
        // assert
        verify(mockLocalDataSource.getLastEvents());
        verify(mockLocalDataSource.cacheEvents([tEvent]));
        expect(result, equals(const Right<Failure, Unit>(unit)));
      },
    );
  });
}
