import '../entities/trip_entity.dart';

class TripMapPoint {
  final String id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;

  const TripMapPoint({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
  });
}

class BuildTripMapPointsUseCase {
  List<TripMapPoint> execute(List<TripEntity> trips) {
    return trips
        .where((trip) => trip.latitude != null && trip.longitude != null)
        .map(
          (trip) => TripMapPoint(
            id: trip.id ?? '${trip.name}_${trip.location}',
            name: trip.name,
            location: trip.location,
            latitude: trip.latitude!,
            longitude: trip.longitude!,
          ),
        )
        .toList();
  }
}
