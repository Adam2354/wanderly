import 'package:flutter_test/flutter_test.dart';
import 'package:wanderly/domain/trips/usecases/query_activity_fallback_usecase.dart';
import 'package:wanderly/domain/trips/usecases/query_trips_usecase.dart';
import 'package:wanderly/domain/trips/usecases/resolve_destination_location_usecase.dart';

void main() {
  group('QueryActivityFallbackUseCase', () {
    test('resolveStatus maps null/past/today/future dates correctly', () {
      final useCase = QueryActivityFallbackUseCase();
      final now = DateTime(2026, 3, 8, 10, 0);

      final noDate = ActivityFallbackEntity(
        sourceIndex: 0,
        name: 'No Date',
        date: null,
      );
      final past = ActivityFallbackEntity(
        sourceIndex: 1,
        name: 'Past',
        date: DateTime(2026, 3, 7),
      );
      final today = ActivityFallbackEntity(
        sourceIndex: 2,
        name: 'Today',
        date: DateTime(2026, 3, 8, 22, 0),
      );
      final future = ActivityFallbackEntity(
        sourceIndex: 3,
        name: 'Future',
        date: DateTime(2026, 3, 9),
      );

      expect(useCase.resolveStatus(noDate, now: now), 'upcoming');
      expect(useCase.resolveStatus(past, now: now), 'completed');
      expect(useCase.resolveStatus(today, now: now), 'ongoing');
      expect(useCase.resolveStatus(future, now: now), 'upcoming');
    });

    test('filterAndSort filters completed and sorts by date descending', () {
      final useCase = QueryActivityFallbackUseCase();
      final activities = <ActivityFallbackEntity>[
        ActivityFallbackEntity(
          sourceIndex: 0,
          name: 'Upcoming A',
          date: DateTime.now().add(const Duration(days: 2)),
        ),
        ActivityFallbackEntity(
          sourceIndex: 1,
          name: 'Completed A',
          date: DateTime.now().subtract(const Duration(days: 5)),
        ),
        ActivityFallbackEntity(
          sourceIndex: 2,
          name: 'Completed B',
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      final result = useCase.filterAndSort(
        activities,
        TripFilterStatus.completed,
        TripSortBy.dateDesc,
      );

      expect(result.length, 2);
      expect(result.first.name, 'Completed B');
      expect(result.last.name, 'Completed A');
    });

    test('buildStats returns accurate totals per status', () {
      final useCase = QueryActivityFallbackUseCase();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final activities = <ActivityFallbackEntity>[
        ActivityFallbackEntity(
          sourceIndex: 0,
          name: 'Upcoming',
          date: today.add(const Duration(days: 2)),
        ),
        ActivityFallbackEntity(sourceIndex: 1, name: 'Ongoing', date: today),
        ActivityFallbackEntity(
          sourceIndex: 2,
          name: 'Completed',
          date: today.subtract(const Duration(days: 3)),
        ),
      ];

      final stats = useCase.buildStats(
        activities.map((item) {
          return ActivityFallbackEntity(
            sourceIndex: item.sourceIndex,
            name: item.name,
            date: item.date,
          );
        }).toList(),
      );

      expect(stats['total'], 3);
      expect(stats['upcoming'], 1);
      expect(stats['ongoing'], 1);
      expect(stats['completed'], 1);

      expect(useCase.resolveStatus(activities[0], now: now), 'upcoming');
      expect(useCase.resolveStatus(activities[1], now: now), 'ongoing');
      expect(useCase.resolveStatus(activities[2], now: now), 'completed');
    });
  });

  group('ResolveDestinationLocationUseCase', () {
    test('resolveCoordinates prioritizes explicit activity coordinates', () {
      final useCase = ResolveDestinationLocationUseCase();

      final coordinates = useCase.resolveCoordinates(
        destinationName: 'Golden Pavilion',
        location: 'Kyoto, Japan',
        activityLatitude: 1.23,
        activityLongitude: 4.56,
      );

      expect(coordinates, isNotNull);
      expect(coordinates![0], 1.23);
      expect(coordinates[1], 4.56);
    });

    test('resolveCoordinates falls back to known destination map', () {
      final useCase = ResolveDestinationLocationUseCase();

      final coordinates = useCase.resolveCoordinates(
        destinationName: 'Golden Pavilion',
        location: 'Unknown Place',
      );

      expect(coordinates, isNotNull);
      expect(coordinates![0], closeTo(35.0394, 0.0001));
      expect(coordinates[1], closeTo(135.7292, 0.0001));
    });

    test('buildGoogleMapsUri returns empty string when query is empty', () {
      final useCase = ResolveDestinationLocationUseCase();

      final uri = useCase.buildGoogleMapsUri(
        destinationName: '   ',
        destinationLocation: '   ',
      );

      expect(uri, '');
    });
  });
}
