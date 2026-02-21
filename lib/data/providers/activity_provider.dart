import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/activity_model.dart';
import '../services/hive_service.dart';

final hiveServiceProvider = Provider((ref) {
  return HiveService.instance;
});

final activitiesProvider =
    StateNotifierProvider<ActivitiesNotifier, AsyncValue<List<ActivityModel>>>((
      ref,
    ) {
      final hiveService = ref.watch(hiveServiceProvider);
      return ActivitiesNotifier(hiveService);
    });

final activitiesByCategoryProvider =
    StateNotifierProvider.family<
      ActivitiesByCategoryNotifier,
      List<ActivityModel>,
      String
    >((ref, category) {
      final hiveService = ref.watch(hiveServiceProvider);
      return ActivitiesByCategoryNotifier(hiveService, category);
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
  final HiveService _hiveService;

  ActivitiesNotifier(this._hiveService) : super(const AsyncValue.loading()) {
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final activities = _hiveService.getActivities();
      state = AsyncValue.data(activities);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addActivity(ActivityModel activity) async {
    try {
      await _hiveService.addActivity(activity);
      await _loadActivities();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateActivity(int index, ActivityModel activity) async {
    try {
      await _hiveService.updateActivity(index, activity);
      await _loadActivities();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteActivity(int index) async {
    try {
      await _hiveService.deleteActivity(index);
      await _loadActivities();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refreshActivities() async {
    await _loadActivities();
  }
}

class ActivitiesByCategoryNotifier extends StateNotifier<List<ActivityModel>> {
  final HiveService _hiveService;
  final String _category;

  ActivitiesByCategoryNotifier(this._hiveService, this._category) : super([]) {
    _loadActivitiesByCategory();
  }

  void _loadActivitiesByCategory() {
    try {
      state = _hiveService.getActivitiesByCategory(_category);
    } catch (e) {
      print('Error loading activities by category: $e');
      state = [];
    }
  }

  Future<void> addActivity(ActivityModel activity) async {
    try {
      await _hiveService.addActivity(activity);
      _loadActivitiesByCategory();
    } catch (e) {
      print('Error adding activity: $e');
    }
  }

  Future<void> updateActivity(int index, ActivityModel activity) async {
    try {
      await _hiveService.updateActivity(index, activity);
      _loadActivitiesByCategory();
    } catch (e) {
      print('Error updating activity: $e');
    }
  }

  Future<void> deleteActivity(int index) async {
    try {
      await _hiveService.deleteActivity(index);
      _loadActivitiesByCategory();
    } catch (e) {
      print('Error deleting activity: $e');
    }
  }

  Future<void> refreshActivities() async {
    _loadActivitiesByCategory();
  }
}
