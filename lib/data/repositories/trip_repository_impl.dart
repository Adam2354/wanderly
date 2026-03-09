import '../../domain/trips/entities/trip_entity.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/firebase/firestore_datasource.dart';
import '../mappers/trip_mapper.dart';

class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl(this._firestoreDatasource, this._mapper);

  final FirestoreDatasource _firestoreDatasource;
  final TripMapper _mapper;

  @override
  Future<void> addTrip(TripEntity trip) async {
    await _firestoreDatasource.addTrip(_mapper.toModel(trip));
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    await _firestoreDatasource.deleteTrip(tripId);
  }

  @override
  Future<void> seedSampleTripsIfEmpty(String userId) async {
    await _firestoreDatasource.seedSampleTripsIfEmpty(userId);
  }

  @override
  Future<void> updateTrip(String tripId, TripEntity trip) async {
    await _firestoreDatasource.updateTrip(tripId, _mapper.toModel(trip));
  }

  @override
  Future<void> updateTripStatus(String tripId, String status) async {
    await _firestoreDatasource.updateTripStatus(tripId, status);
  }

  @override
  Stream<List<TripEntity>> watchTrips(String userId) {
    return _firestoreDatasource
        .getTripsStream(userId)
        .map((items) => items.map(_mapper.toEntity).toList());
  }
}
