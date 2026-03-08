import '../entities/trip_entity.dart';

abstract class TripRepository {
  Stream<List<TripEntity>> watchTrips(String userId);
  Future<void> seedSampleTripsIfEmpty(String userId);
  Future<void> addTrip(TripEntity trip);
  Future<void> updateTrip(String tripId, TripEntity trip);
  Future<void> deleteTrip(String tripId);
  Future<void> updateTripStatus(String tripId, String status);
}
