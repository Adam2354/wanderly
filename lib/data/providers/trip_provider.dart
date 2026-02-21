import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip_model.dart';
import '../services/firestore_service.dart';
import '../services/firebase_auth_service.dart';

// Firestore Service Provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Filter Status Provider
enum TripFilterStatus { all, upcoming, ongoing, completed }

final tripFilterStatusProvider = StateProvider<TripFilterStatus>((ref) {
  return TripFilterStatus.all;
});

// Sort Provider
enum TripSortBy { dateAsc, dateDesc, nameAsc, nameDesc }

final tripSortByProvider = StateProvider<TripSortBy>((ref) {
  return TripSortBy.dateDesc;
});

// Trips Stream Provider (dari Firestore)
final tripsStreamProvider = StreamProvider<List<TripModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authService = FirebaseAuthService();
  final userId = authService.currentUserId;

  if (userId == null) {
    return Stream.value([]);
  }

  return firestoreService.getTripsStream(userId);
});

// Filtered and Sorted Trips Provider
final filteredSortedTripsProvider = Provider<List<TripModel>>((ref) {
  final tripsAsync = ref.watch(tripsStreamProvider);
  final filterStatus = ref.watch(tripFilterStatusProvider);
  final sortBy = ref.watch(tripSortByProvider);

  return tripsAsync.when(
    data: (trips) {
      // Update auto status based on dates
      final updatedTrips = trips.map((trip) {
        final autoStatus = trip.getAutoStatus();
        if (autoStatus != trip.status) {
          // Update status di Firestore jika berbeda
          final firestoreService = ref.read(firestoreServiceProvider);
          if (trip.id != null) {
            firestoreService.updateTripStatus(trip.id!, autoStatus);
          }
          return trip.copyWith(status: autoStatus);
        }
        return trip;
      }).toList();

      // Filter berdasarkan status
      List<TripModel> filtered = updatedTrips;
      if (filterStatus != TripFilterStatus.all) {
        filtered = updatedTrips.where((trip) {
          switch (filterStatus) {
            case TripFilterStatus.upcoming:
              return trip.status == 'upcoming';
            case TripFilterStatus.ongoing:
              return trip.status == 'ongoing';
            case TripFilterStatus.completed:
              return trip.status == 'completed';
            default:
              return true;
          }
        }).toList();
      }

      // Sort berdasarkan pilihan
      filtered.sort((a, b) {
        switch (sortBy) {
          case TripSortBy.dateAsc:
            if (a.startDate == null && b.startDate == null) return 0;
            if (a.startDate == null) return 1;
            if (b.startDate == null) return -1;
            return a.startDate!.compareTo(b.startDate!);

          case TripSortBy.dateDesc:
            if (a.startDate == null && b.startDate == null) return 0;
            if (a.startDate == null) return 1;
            if (b.startDate == null) return -1;
            return b.startDate!.compareTo(a.startDate!);

          case TripSortBy.nameAsc:
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());

          case TripSortBy.nameDesc:
            return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        }
      });

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Trip Notifier untuk CRUD operations
class TripNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;
  final String _userId;

  TripNotifier(this._firestoreService, this._userId)
    : super(const AsyncValue.data(null));

  Future<void> addTrip(TripModel trip) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.addTrip(trip.copyWith(userId: _userId));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTrip(String tripId, TripModel trip) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.updateTrip(tripId, trip);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTrip(String tripId) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.deleteTrip(tripId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTripStatus(String tripId, String status) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.updateTripStatus(tripId, status);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Trip Notifier Provider
final tripNotifierProvider =
    StateNotifierProvider<TripNotifier, AsyncValue<void>>((ref) {
      final firestoreService = ref.watch(firestoreServiceProvider);
      final authService = FirebaseAuthService();
      final userId = authService.currentUserId ?? '';
      return TripNotifier(firestoreService, userId);
    });

// Categories Provider
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

// Stats Provider untuk dashboard
final tripStatsProvider = Provider<Map<String, int>>((ref) {
  final trips = ref.watch(filteredSortedTripsProvider);

  int upcoming = 0;
  int ongoing = 0;
  int completed = 0;

  for (var trip in trips) {
    switch (trip.status) {
      case 'upcoming':
        upcoming++;
        break;
      case 'ongoing':
        ongoing++;
        break;
      case 'completed':
        completed++;
        break;
    }
  }

  return {
    'total': trips.length,
    'upcoming': upcoming,
    'ongoing': ongoing,
    'completed': completed,
  };
});
