import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mappers/trip_mapper.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/trip_model.dart';
import '../../data/datasources/firebase/firebase_auth_datasource.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/repositories/trip_repository.dart';
import '../../domain/trips/usecases/query_activity_fallback_usecase.dart';
import '../../domain/trips/usecases/build_trip_map_points_usecase.dart';
import '../../domain/trips/usecases/query_trips_usecase.dart';
import 'activity_provider.dart';
import 'service_providers.dart';

export '../../domain/trips/usecases/query_trips_usecase.dart'
    show TripFilterStatus, TripSortBy;

final tripMapperProvider = Provider<TripMapper>((ref) {
  return TripMapper();
});

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final firestoreService = ref.watch(firestoreDatasourceProvider);
  final mapper = ref.watch(tripMapperProvider);
  return TripRepositoryImpl(firestoreService, mapper);
});

final queryTripsUseCaseProvider = Provider<QueryTripsUseCase>((ref) {
  return QueryTripsUseCase();
});

final queryActivityFallbackUseCaseProvider =
    Provider<QueryActivityFallbackUseCase>((ref) {
      return QueryActivityFallbackUseCase();
    });

final buildTripMapPointsUseCaseProvider = Provider<BuildTripMapPointsUseCase>((
  ref,
) {
  return BuildTripMapPointsUseCase();
});

final tripFilterStatusProvider = StateProvider<TripFilterStatus>((ref) {
  return TripFilterStatus.all;
});

final tripSortByProvider = StateProvider<TripSortBy>((ref) {
  return TripSortBy.dateDesc;
});

final tripsStreamProvider = StreamProvider<List<TripModel>>((ref) {
  final tripRepository = ref.watch(tripRepositoryProvider);
  final mapper = ref.watch(tripMapperProvider);
  final authService = ref.watch(firebaseAuthDatasourceProvider);

  return authService.authStateChanges.asyncExpand((user) async* {
    if (user == null) {
      yield <TripModel>[];
      return;
    }

    await tripRepository.seedSampleTripsIfEmpty(user.uid);
    yield* tripRepository
        .watchTrips(user.uid)
        .map((items) => items.map(mapper.toModel).toList());
  });
});

final filteredSortedTripsProvider = Provider<List<TripModel>>((ref) {
  final tripsAsync = ref.watch(tripsStreamProvider);
  final filterStatus = ref.watch(tripFilterStatusProvider);
  final sortBy = ref.watch(tripSortByProvider);
  final queryTrips = ref.watch(queryTripsUseCaseProvider);
  final mapper = ref.watch(tripMapperProvider);

  return tripsAsync.when(
    data: (trips) {
      final entities = trips.map(mapper.toEntity).toList();
      final result = queryTrips.filterAndSort(entities, filterStatus, sortBy);
      return result.map(mapper.toModel).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final tripMapPointsProvider = Provider<List<TripMapPoint>>((ref) {
  final buildMapPoints = ref.watch(buildTripMapPointsUseCaseProvider);
  final mapper = ref.watch(tripMapperProvider);
  final trips = ref.watch(filteredSortedTripsProvider);
  final entities = trips.map(mapper.toEntity).toList();
  return buildMapPoints.execute(entities);
});

final allTripMapPointsProvider = Provider<List<TripMapPoint>>((ref) {
  final buildMapPoints = ref.watch(buildTripMapPointsUseCaseProvider);
  final mapper = ref.watch(tripMapperProvider);
  final tripsAsync = ref.watch(tripsStreamProvider);

  return tripsAsync.when(
    data: (trips) {
      final entities = trips.map(mapper.toEntity).toList();
      return buildMapPoints.execute(entities);
    },
    loading: () => const <TripMapPoint>[],
    error: (_, __) => const <TripMapPoint>[],
  );
});

class TripNotifier extends StateNotifier<AsyncValue<void>> {
  final TripRepository _tripRepository;
  final TripMapper _tripMapper;
  final FirebaseAuthDatasource _authService;

  TripNotifier(this._tripRepository, this._tripMapper, this._authService)
    : super(const AsyncValue.data(null));

  Future<void> addTrip(TripModel trip) async {
    final userId = _authService.currentUserId;
    if (userId == null || userId.isEmpty) {
      state = AsyncValue.error(
        'User belum login. Tidak bisa menambah trip.',
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final entity = _tripMapper.toEntity(trip.copyWith(userId: userId));
      await _tripRepository.addTrip(entity);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTrip(String tripId, TripModel trip) async {
    state = const AsyncValue.loading();
    try {
      await _tripRepository.updateTrip(tripId, _tripMapper.toEntity(trip));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTrip(String tripId) async {
    state = const AsyncValue.loading();
    try {
      await _tripRepository.deleteTrip(tripId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTripStatus(String tripId, String status) async {
    state = const AsyncValue.loading();
    try {
      await _tripRepository.updateTripStatus(tripId, status);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final tripNotifierProvider =
    StateNotifierProvider<TripNotifier, AsyncValue<void>>((ref) {
      final tripRepository = ref.watch(tripRepositoryProvider);
      final mapper = ref.watch(tripMapperProvider);
      final authService = ref.watch(firebaseAuthDatasourceProvider);
      return TripNotifier(tripRepository, mapper, authService);
    });

final categoriesProvider = Provider<List<String>>((ref) {
  return const [
    'Sightseeing',
    'Restaurant',
    'Nightlife',
    'Hotel',
    'Shopping',
    'Cinema',
  ];
});

final tripStatsProvider = Provider<Map<String, int>>((ref) {
  final queryTrips = ref.watch(queryTripsUseCaseProvider);
  final mapper = ref.watch(tripMapperProvider);
  final trips = ref.watch(filteredSortedTripsProvider).map(mapper.toEntity);
  return queryTrips.buildStats(trips.toList());
});

class TripFallbackData {
  final List<ActivityModel> activities;
  final Map<String, int> stats;

  const TripFallbackData({required this.activities, required this.stats});
}

final tripFallbackDataProvider = Provider<TripFallbackData>((ref) {
  final activitiesAsync = ref.watch(activitiesProvider);
  final filterStatus = ref.watch(tripFilterStatusProvider);
  final sortBy = ref.watch(tripSortByProvider);
  final fallbackUseCase = ref.watch(queryActivityFallbackUseCaseProvider);

  return activitiesAsync.when(
    data: (activities) {
      final entities = activities
          .asMap()
          .entries
          .map(
            (entry) => ActivityFallbackEntity(
              sourceIndex: entry.key,
              name: entry.value.name,
              date: entry.value.date,
            ),
          )
          .toList();

      final stats = fallbackUseCase.buildStats(entities);
      final filteredSorted = fallbackUseCase.filterAndSort(
        entities,
        filterStatus,
        sortBy,
      );
      final sortedActivities = filteredSorted
          .map((entity) => activities[entity.sourceIndex])
          .toList();

      return TripFallbackData(activities: sortedActivities, stats: stats);
    },
    loading: () => const TripFallbackData(
      activities: <ActivityModel>[],
      stats: {'total': 0, 'upcoming': 0, 'ongoing': 0, 'completed': 0},
    ),
    error: (_, __) => const TripFallbackData(
      activities: <ActivityModel>[],
      stats: {'total': 0, 'upcoming': 0, 'ongoing': 0, 'completed': 0},
    ),
  );
});
