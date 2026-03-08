import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String? id;
  final String userId;

  late String name;

  late String location;

  late String notes;

  late DateTime? date;

  late String? imagePath;

  late String category;

  late double? latitude;

  late double? longitude;

  ActivityModel({
    this.id,
    this.userId = '',
    required this.name,
    required this.location,
    required this.notes,
    required this.category,
    this.date,
    this.imagePath,
    this.latitude,
    this.longitude,
  });

  ActivityModel.empty()
    : id = null,
      userId = '',
      name = '',
      location = '',
      notes = '',
      category = '',
      date = null,
      imagePath = null,
      latitude = null,
      longitude = null;

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      notes: data['notes'] ?? '',
      category: data['category'] ?? '',
      date: data['date'] != null ? (data['date'] as Timestamp).toDate() : null,
      imagePath: data['imagePath'],
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'location': location,
      'notes': notes,
      'category': category,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toFirestoreUpdate() {
    return {
      'name': name,
      'location': location,
      'notes': notes,
      'category': category,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ActivityModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? location,
    String? notes,
    DateTime? date,
    String? imagePath,
    String? category,
    double? latitude,
    double? longitude,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
