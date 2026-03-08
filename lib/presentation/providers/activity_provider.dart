import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/activity_model.dart';
import '../../data/services/activity_firestore_service.dart';
import '../../data/services/firebase_auth_service.dart';
import 'service_providers.dart';

final activitiesProvider =
    StateNotifierProvider<ActivitiesNotifier, AsyncValue<List<ActivityModel>>>((
      ref,
    ) {
      final activityService = ref.watch(activityFirestoreServiceProvider);
      final authService = ref.watch(firebaseAuthServiceProvider);
      return ActivitiesNotifier(activityService, authService);
    });

final activitiesByCategoryProvider =
    Provider.family<List<ActivityModel>, String>((ref, category) {
      final activitiesAsync = ref.watch(activitiesProvider);
      return activitiesAsync.when(
        data: (items) =>
            items.where((item) => item.category == category).toList(),
        loading: () => [],
        error: (_, __) => [],
      );
    });

final categoriesProvider = Provider((ref) {
  return const [
    'Sightseeing',
    'Restaurant',
    'Nightlife',
    'Hotel',
    'Shopping',
    'Cinema',
  ];
});

enum ActivityStatus { upcoming, ongoing, completed }

enum ActivitySort { startDateAsc, startDateDesc }

enum ActivityFilter { all, upcoming, ongoing, completed }

final activitySortProvider = StateProvider<ActivitySort>((ref) {
  return ActivitySort.startDateAsc;
});

final activityFilterProvider = StateProvider<ActivityFilter>((ref) {
  return ActivityFilter.all;
});

ActivityStatus getActivityStatus(ActivityModel item, DateTime now) {
  if (item.date == null) return ActivityStatus.upcoming;
  final date = DateTime(item.date!.year, item.date!.month, item.date!.day);
  final today = DateTime(now.year, now.month, now.day);

  if (date.isAfter(today)) return ActivityStatus.upcoming;
  if (date.isBefore(today)) return ActivityStatus.completed;
  return ActivityStatus.ongoing;
}

final isLoadingProvider = StateProvider((ref) => false);

class ActivitiesNotifier
    extends StateNotifier<AsyncValue<List<ActivityModel>>> {
  ActivitiesNotifier(this._activityService, this._authService)
    : super(const AsyncValue.loading()) {
    _authSubscription = _authService.authStateChanges.listen((_) {
      _subscribeActivities();
    });
    _subscribeActivities();
  }

  final ActivityFirestoreService _activityService;
  final FirebaseAuthService _authService;
  StreamSubscription<List<ActivityModel>>? _activitiesSubscription;
  StreamSubscription<User?>? _authSubscription;
  bool _isSeeding = false;

  void _subscribeActivities() {
    _activitiesSubscription?.cancel();

    final userId = _authService.currentUserId;
    if (userId == null || userId.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    _activitiesSubscription = _activityService
        .getActivitiesStream(userId)
        .listen(
          (activities) async {
            state = AsyncValue.data(activities);

            if (activities.isEmpty && !_isSeeding) {
              _isSeeding = true;
              try {
                await _activityService.seedSampleActivitiesIfEmpty(userId);
              } catch (error, stackTrace) {
                state = AsyncValue.error(error, stackTrace);
              } finally {
                _isSeeding = false;
              }
            }
          },
          onError: (error, stackTrace) {
            state = AsyncValue.error(error, stackTrace);
          },
        );
  }

  Future<void> addActivity(ActivityModel activity) async {
    final userId = _authService.currentUserId;
    if (userId == null || userId.isEmpty) {
      state = AsyncValue.error(
        'User belum login. Tidak bisa menambah activity.',
        StackTrace.current,
      );
      return;
    }

    try {
      await _activityService.addActivity(activity, userId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateActivity(String activityId, ActivityModel activity) async {
    try {
      await _activityService.updateActivity(activityId, activity);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      await _activityService.deleteActivity(activityId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refreshActivities() async {
    _subscribeActivities();
  }

  @override
  void dispose() {
    _activitiesSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
