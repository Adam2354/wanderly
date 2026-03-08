class TripEntity {
  final String? id;
  final String name;
  final String location;
  final String notes;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? imagePath;
  final String category;
  final String userId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? latitude;
  final double? longitude;

  const TripEntity({
    this.id,
    required this.name,
    required this.location,
    required this.notes,
    required this.category,
    required this.userId,
    this.startDate,
    this.endDate,
    this.imagePath,
    this.status = 'upcoming',
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
  });

  TripEntity copyWith({
    String? id,
    String? name,
    String? location,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
    String? imagePath,
    String? category,
    String? userId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? latitude,
    double? longitude,
  }) {
    return TripEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  String getAutoStatus({DateTime? now}) {
    if (startDate == null) return 'upcoming';

    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final start = DateTime(startDate!.year, startDate!.month, startDate!.day);

    if (endDate != null) {
      final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (today.isAfter(end)) return 'completed';
      if (today.isAtSameMomentAs(start) ||
          (today.isAfter(start) && today.isBefore(end)) ||
          today.isAtSameMomentAs(end)) {
        return 'ongoing';
      }
    } else {
      if (today.isAfter(start)) return 'completed';
      if (today.isAtSameMomentAs(start)) return 'ongoing';
    }

    return 'upcoming';
  }
}
