import '../../domain/trips/entities/trip_entity.dart';
import '../../domain/trips/repositories/trip_repository.dart';
import '../mappers/trip_mapper.dart';
import '../services/firestore_service.dart';

class FirebaseTripRepository implements TripRepository {
  FirebaseTripRepository(this._firestoreService, this._mapper);

  final FirestoreService _firestoreService;
  final TripMapper _mapper;

  @override
  Future<void> addTrip(TripEntity trip) async {
    await _firestoreService.addTrip(_mapper.toModel(trip));
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    await _firestoreService.deleteTrip(tripId);
  }

  @override
  Future<void> seedSampleTripsIfEmpty(String userId) async {
    await _firestoreService.seedSampleTripsIfEmpty(userId);
  }

  @override
  Future<void> updateTrip(String tripId, TripEntity trip) async {
    await _firestoreService.updateTrip(tripId, _mapper.toModel(trip));
  }

  @override
  Future<void> updateTripStatus(String tripId, String status) async {
    await _firestoreService.updateTripStatus(tripId, status);
  }

  @override
  Stream<List<TripEntity>> watchTrips(String userId) {
    return _firestoreService
        .getTripsStream(userId)
        .map((items) => items.map(_mapper.toEntity).toList());
  }
}
