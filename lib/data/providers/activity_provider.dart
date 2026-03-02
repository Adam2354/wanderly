import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../activity_store.dart';
import '../models/activity_model.dart';
import 'theme_provider.dart';

final activitiesProvider =
    StateNotifierProvider<ActivitiesNotifier, AsyncValue<List<ActivityModel>>>(
      (ref) => ActivitiesNotifier(ref.watch(sharedPreferencesProvider)),
    );

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
  ActivitiesNotifier(this._prefs) : super(const AsyncValue.loading()) {
    _loadFromPrefs();
  }

  final SharedPreferences _prefs;
  static const String _storageKey = 'local_activities_v1';
  final List<ActivityModel> _items = [];
  int _idCounter = 0;

  Future<void> _loadFromPrefs() async {
    final raw = _prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      _seedSampleData();
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        _seedSampleData();
        return;
      }

      _items
        ..clear()
        ..addAll(
          decoded.whereType<Map>().map(
            (entry) => _fromLocalMap(Map<String, dynamic>.from(entry)),
          ),
        );

      _recalculateIdCounter();
      if (_items.isEmpty) {
        _seedSampleData();
        return;
      }

      _emitSorted();
    } catch (_) {
      _seedSampleData();
    }
  }

  ActivityModel _fromLocalMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] as String?,
      userId: (map['userId'] as String?) ?? 'local-user',
      name: (map['name'] as String?) ?? '',
      location: (map['location'] as String?) ?? '',
      notes: (map['notes'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'Sightseeing',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'] as String)
          : null,
      imagePath: map['imagePath'] as String?,
    );
  }

  Map<String, dynamic> _toLocalMap(ActivityModel item) {
    return {
      'id': item.id,
      'userId': item.userId,
      'name': item.name,
      'location': item.location,
      'notes': item.notes,
      'category': item.category,
      'date': item.date?.toIso8601String(),
      'imagePath': item.imagePath,
    };
  }

  Future<void> _persist() async {
    final payload = _items.map(_toLocalMap).toList();
    await _prefs.setString(_storageKey, jsonEncode(payload));
  }

  void _recalculateIdCounter() {
    int maxId = 0;
    for (final item in _items) {
      final id = item.id ?? '';
      if (!id.startsWith('local-activity-')) continue;
      final number = int.tryParse(id.replaceFirst('local-activity-', '')) ?? 0;
      if (number > maxId) {
        maxId = number;
      }
    }
    _idCounter = maxId;
  }

  void _seedSampleData() {
    if (_items.isNotEmpty) {
      _emitSorted();
      return;
    }

    final store = ActivityStore.instance;
    for (final category in store.categories) {
      for (final item in store.itemsFor(category)) {
        _idCounter++;
        _items.add(
          ActivityModel(
            id: 'local-activity-$_idCounter',
            userId: 'local-user',
            name: item.name,
            location: item.location,
            notes: item.notes,
            category: category,
            date: item.date,
            imagePath: item.imagePath,
          ),
        );
      }
    }

    _emitSorted();
    _persist();
  }

  void _emitSorted() {
    final sorted = List<ActivityModel>.from(_items)
      ..sort((a, b) {
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return a.date!.compareTo(b.date!);
      });

    state = AsyncValue.data(sorted);
  }

  Future<void> addActivity(ActivityModel activity) async {
    _idCounter++;
    _items.add(
      activity.copyWith(
        id: 'local-activity-$_idCounter',
        userId: activity.userId.isEmpty ? 'local-user' : activity.userId,
      ),
    );
    _emitSorted();
    await _persist();
  }

  Future<void> updateActivity(String activityId, ActivityModel activity) async {
    final index = _items.indexWhere((item) => item.id == activityId);
    if (index == -1) {
      return;
    }

    final current = _items[index];
    _items[index] = activity.copyWith(id: current.id, userId: current.userId);
    _emitSorted();
    await _persist();
  }

  Future<void> deleteActivity(String activityId) async {
    _items.removeWhere((item) => item.id == activityId);
    _emitSorted();
    await _persist();
  }

  Future<void> refreshActivities() async {
    if (_items.isEmpty) {
      _seedSampleData();
      return;
    }
    _emitSorted();
  }
}
