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

  ActivityModel({
    this.id,
    this.userId = '',
    required this.name,
    required this.location,
    required this.notes,
    required this.category,
    this.date,
    this.imagePath,
  });

  ActivityModel.empty()
    : id = null,
      userId = '',
      name = '',
      location = '',
      notes = '',
      category = '',
      date = null,
      imagePath = null;

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
    );
  }
}
