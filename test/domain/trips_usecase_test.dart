import 'package:flutter_test/flutter_test.dart';
import 'package:wanderly/domain/trips/entities/trip_entity.dart';
import 'package:wanderly/domain/trips/usecases/build_trip_map_points_usecase.dart';
import 'package:wanderly/domain/trips/usecases/query_trips_usecase.dart';

void main() {
  group('Trip domain logic', () {
    test('getAutoStatus returns ongoing when today is inside trip range', () {
      final trip = TripEntity(
        name: 'Bandung Trip',
        location: 'Bandung',
        notes: 'Notes',
        category: 'Sightseeing',
        userId: 'u1',
        startDate: DateTime(2026, 3, 5),
        endDate: DateTime(2026, 3, 10),
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
      );

      final status = trip.getAutoStatus(now: DateTime(2026, 3, 7));

      expect(status, 'ongoing');
    });

    test('QueryTripsUseCase filters upcoming and sorts by name ascending', () {
      final useCase = QueryTripsUseCase();
      final trips = <TripEntity>[
        TripEntity(
          id: '1',
          name: 'Zurich',
          location: 'CH',
          notes: '',
          category: 'Sightseeing',
          userId: 'u1',
          startDate: DateTime(2030, 1, 1),
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
        TripEntity(
          id: '2',
          name: 'Amsterdam',
          location: 'NL',
          notes: '',
          category: 'Sightseeing',
          userId: 'u1',
          startDate: DateTime(2030, 2, 1),
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ];

      final result = useCase.filterAndSort(
        trips,
        TripFilterStatus.upcoming,
        TripSortBy.nameAsc,
      );

      expect(result.length, 2);
      expect(result.first.name, 'Amsterdam');
      expect(result.last.name, 'Zurich');
      expect(result.every((trip) => trip.status == 'upcoming'), isTrue);
    });

    test('BuildTripMapPointsUseCase only includes trips with coordinates', () {
      final useCase = BuildTripMapPointsUseCase();
      final trips = <TripEntity>[
        TripEntity(
          id: 'a',
          name: 'Tokyo',
          location: 'Japan',
          notes: '',
          category: 'Nightlife',
          userId: 'u1',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
          latitude: 35.6762,
          longitude: 139.6503,
        ),
        TripEntity(
          id: 'b',
          name: 'No Coordinate Trip',
          location: 'Unknown',
          notes: '',
          category: 'Sightseeing',
          userId: 'u1',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ];

      final points = useCase.execute(trips);

      expect(points.length, 1);
      expect(points.first.id, 'a');
      expect(points.first.latitude, 35.6762);
      expect(points.first.longitude, 139.6503);
    });
  });
}