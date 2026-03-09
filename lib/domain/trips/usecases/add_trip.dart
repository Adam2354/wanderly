import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class AddTripUseCase {
  final TripRepository _repository;

  AddTripUseCase(this._repository);

  Future<void> execute(TripEntity trip) {
    return _repository.addTrip(trip);
  }
}
