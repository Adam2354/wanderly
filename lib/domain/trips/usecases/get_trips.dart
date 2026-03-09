import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class GetTripsUseCase {
  final TripRepository _repository;

  GetTripsUseCase(this._repository);

  Stream<List<TripEntity>> execute(String userId) {
    return _repository.watchTrips(userId);
  }
}
