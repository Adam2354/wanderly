import '../entities/trip_entity.dart';

enum TripFilterStatus { all, upcoming, ongoing, completed }

enum TripSortBy { dateAsc, dateDesc, nameAsc, nameDesc }

class QueryTripsUseCase {
  List<TripEntity> filterAndSort(
    List<TripEntity> trips,
    TripFilterStatus filterStatus,
    TripSortBy sortBy,
  ) {
    final withComputedStatus = trips
        .map((trip) => trip.copyWith(status: trip.getAutoStatus()))
        .toList();

    var filtered = withComputedStatus.where((trip) {
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
  }

  Map<String, int> buildStats(List<TripEntity> trips) {
    var upcoming = 0;
    var ongoing = 0;
    var completed = 0;

    for (final trip in trips) {
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
  }
}
