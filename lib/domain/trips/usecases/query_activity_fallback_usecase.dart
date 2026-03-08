import 'query_trips_usecase.dart';

class ActivityFallbackEntity {
  final int sourceIndex;
  final String name;
  final DateTime? date;

  const ActivityFallbackEntity({
    required this.sourceIndex,
    required this.name,
    required this.date,
  });
}

class QueryActivityFallbackUseCase {
  String resolveStatus(ActivityFallbackEntity activity, {DateTime? now}) {
    if (activity.date == null) return 'upcoming';

    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final date = DateTime(
      activity.date!.year,
      activity.date!.month,
      activity.date!.day,
    );

    if (date.isAfter(today)) return 'upcoming';
    if (date.isBefore(today)) return 'completed';
    return 'ongoing';
  }

  List<ActivityFallbackEntity> filterAndSort(
    List<ActivityFallbackEntity> activities,
    TripFilterStatus filterStatus,
    TripSortBy sortBy,
  ) {
    final filtered = activities.where((activity) {
      final status = resolveStatus(activity);
      switch (filterStatus) {
        case TripFilterStatus.upcoming:
          return status == 'upcoming';
        case TripFilterStatus.ongoing:
          return status == 'ongoing';
        case TripFilterStatus.completed:
          return status == 'completed';
        case TripFilterStatus.all:
          return true;
      }
    }).toList();

    filtered.sort((a, b) {
      switch (sortBy) {
        case TripSortBy.dateAsc:
          final aDate = a.date ?? DateTime(9999);
          final bDate = b.date ?? DateTime(9999);
          return aDate.compareTo(bDate);
        case TripSortBy.dateDesc:
          final aDate = a.date ?? DateTime(0);
          final bDate = b.date ?? DateTime(0);
          return bDate.compareTo(aDate);
        case TripSortBy.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case TripSortBy.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
      }
    });

    return filtered;
  }

  Map<String, int> buildStats(List<ActivityFallbackEntity> activities) {
    var upcoming = 0;
    var ongoing = 0;
    var completed = 0;

    for (final activity in activities) {
      switch (resolveStatus(activity)) {
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
      'total': activities.length,
      'upcoming': upcoming,
      'ongoing': ongoing,
      'completed': completed,
    };
  }
}
