import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip_model.dart';
import 'theme_provider.dart';

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

final localTripsProvider =
    StateNotifierProvider<LocalTripsNotifier, List<TripModel>>(
      (ref) => LocalTripsNotifier(ref.watch(sharedPreferencesProvider)),
    );

final tripsStreamProvider = Provider<List<TripModel>>((ref) {
  return ref.watch(localTripsProvider);
});

// Filtered and Sorted Trips Provider
final filteredSortedTripsProvider = Provider<List<TripModel>>((ref) {
  final trips = ref.watch(tripsStreamProvider);
  final filterStatus = ref.watch(tripFilterStatusProvider);
  final sortBy = ref.watch(tripSortByProvider);

  final computedTrips = trips
      .map((trip) => trip.copyWith(status: trip.getAutoStatus()))
      .toList();

  List<TripModel> filtered = computedTrips;
  if (filterStatus != TripFilterStatus.all) {
    filtered = computedTrips.where((trip) {
      switch (filterStatus) {
        case TripFilterStatus.upcoming:
          return trip.status == 'upcoming';
        case TripFilterStatus.ongoing:
          return trip.status == 'ongoing';
        case TripFilterStatus.completed:
          return trip.status == 'completed';
        case TripFilterStatus.all:
          return true;
      }
    }).toList();
  }

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
});

class LocalTripsNotifier extends StateNotifier<List<TripModel>> {
  LocalTripsNotifier(this._prefs) : super([]) {
    _loadFromPrefs();
  }

  final SharedPreferences _prefs;
  static const String _storageKey = 'local_trips_v1';

  static List<TripModel> _seedTrips() {
    return [
      TripModel(
        id: 'local-trip-1',
        name: 'Kyoto Exploration',
        location: 'Kyoto, Japan',
        notes: 'Trip budaya dan kuliner Kyoto',
        category: 'Sightseeing',
        userId: 'local-user',
        startDate: DateTime(2026, 3, 15),
        endDate: DateTime(2026, 3, 20),
        status: 'upcoming',
      ),
      TripModel(
        id: 'local-trip-2',
        name: 'Osaka Food Tour',
        location: 'Osaka, Japan',
        notes: 'Jelajah street food Osaka',
        category: 'Restaurant',
        userId: 'local-user',
        startDate: DateTime(2026, 2, 10),
        endDate: DateTime(2026, 2, 14),
        status: 'completed',
      ),
      TripModel(
        id: 'local-trip-3',
        name: 'Tokyo City Lights',
        location: 'Tokyo, Japan',
        notes: 'Wisata kota modern dan nightlife',
        category: 'Nightlife',
        userId: 'local-user',
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 2)),
        status: 'ongoing',
      ),
    ];
  }

  Future<void> _loadFromPrefs() async {
    final raw = _prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      state = _seedTrips();
      await _persist();
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        state = _seedTrips();
        await _persist();
        return;
      }

      final trips = decoded
          .whereType<Map>()
          .map((entry) => _fromLocalMap(Map<String, dynamic>.from(entry)))
          .toList();

      if (trips.isEmpty) {
        state = _seedTrips();
        await _persist();
        return;
      }

      state = trips;
    } catch (_) {
      state = _seedTrips();
      await _persist();
    }
  }

  TripModel _fromLocalMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'] as String?,
      name: (map['name'] as String?) ?? '',
      location: (map['location'] as String?) ?? '',
      notes: (map['notes'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'Sightseeing',
      userId: (map['userId'] as String?) ?? 'local-user',
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate'] as String)
          : null,
      endDate: map['endDate'] != null
          ? DateTime.tryParse(map['endDate'] as String)
          : null,
      imagePath: map['imagePath'] as String?,
      status: (map['status'] as String?) ?? 'upcoming',
      createdAt: map['createdAt'] != null
          ? (DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> _toLocalMap(TripModel trip) {
    return {
      'id': trip.id,
      'name': trip.name,
      'location': trip.location,
      'notes': trip.notes,
      'category': trip.category,
      'userId': trip.userId,
      'startDate': trip.startDate?.toIso8601String(),
      'endDate': trip.endDate?.toIso8601String(),
      'imagePath': trip.imagePath,
      'status': trip.status,
      'createdAt': trip.createdAt.toIso8601String(),
      'updatedAt': trip.updatedAt.toIso8601String(),
    };
  }

  Future<void> _persist() async {
    final payload = state.map(_toLocalMap).toList();
    await _prefs.setString(_storageKey, jsonEncode(payload));
  }

  int _nextTripNumber() {
    final localIds = state
        .map((trip) => trip.id ?? '')
        .where((id) => id.startsWith('local-trip-'))
        .toList();

    if (localIds.isEmpty) {
      return 1;
    }

    final numbers =
        localIds
            .map((id) => int.tryParse(id.replaceFirst('local-trip-', '')) ?? 0)
            .toList()
          ..sort();

    return numbers.last + 1;
  }

  Future<void> addTrip(TripModel trip) async {
    final id = 'local-trip-${_nextTripNumber()}';
    state = [
      ...state,
      trip.copyWith(
        id: id,
        userId: trip.userId.isEmpty ? 'local-user' : trip.userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    await _persist();
  }

  Future<void> updateTrip(String tripId, TripModel trip) async {
    state = state.map((item) {
      if (item.id != tripId) return item;
      return trip.copyWith(
        id: item.id,
        userId: item.userId,
        createdAt: item.createdAt,
        updatedAt: DateTime.now(),
      );
    }).toList();
    await _persist();
  }

  Future<void> deleteTrip(String tripId) async {
    state = state.where((item) => item.id != tripId).toList();
    await _persist();
  }

  Future<void> updateTripStatus(String tripId, String status) async {
    state = state.map((item) {
      if (item.id != tripId) return item;
      return item.copyWith(status: status, updatedAt: DateTime.now());
    }).toList();
    await _persist();
  }
}

// Trip Notifier untuk CRUD operations
class TripNotifier extends StateNotifier<AsyncValue<void>> {
  final LocalTripsNotifier _localTripsNotifier;

  TripNotifier(this._localTripsNotifier) : super(const AsyncValue.data(null));

  Future<void> addTrip(TripModel trip) async {
    state = const AsyncValue.loading();
    try {
      await _localTripsNotifier.addTrip(trip);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTrip(String tripId, TripModel trip) async {
    state = const AsyncValue.loading();
    try {
      await _localTripsNotifier.updateTrip(tripId, trip);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTrip(String tripId) async {
    state = const AsyncValue.loading();
    try {
      await _localTripsNotifier.deleteTrip(tripId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTripStatus(String tripId, String status) async {
    state = const AsyncValue.loading();
    try {
      await _localTripsNotifier.updateTripStatus(tripId, status);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Trip Notifier Provider
final tripNotifierProvider =
    StateNotifierProvider<TripNotifier, AsyncValue<void>>((ref) {
      final localTripsNotifier = ref.read(localTripsProvider.notifier);
      return TripNotifier(localTripsNotifier);
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
