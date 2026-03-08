import '../../domain/trips/entities/trip_entity.dart';
import '../models/trip_model.dart';

class TripMapper {
  TripEntity toEntity(TripModel model) {
    return TripEntity(
      id: model.id,
      name: model.name,
      location: model.location,
      notes: model.notes,
      startDate: model.startDate,
      endDate: model.endDate,
      imagePath: model.imagePath,
      category: model.category,
      userId: model.userId,
      status: model.status,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      latitude: model.latitude,
      longitude: model.longitude,
    );
  }

  TripModel toModel(TripEntity entity) {
    return TripModel(
      id: entity.id,
      name: entity.name,
      location: entity.location,
      notes: entity.notes,
      startDate: entity.startDate,
      endDate: entity.endDate,
      imagePath: entity.imagePath,
      category: entity.category,
      userId: entity.userId,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }
}
