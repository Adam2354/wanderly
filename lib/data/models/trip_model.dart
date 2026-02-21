import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String? id;
  final String name;
  final String location;
  final String notes;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? imagePath;
  final String category;
  final String userId; // untuk security rules
  final String status; // upcoming, ongoing, completed
  final DateTime createdAt;
  final DateTime updatedAt;

  TripModel({
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Factory dari Firestore Document
  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TripModel(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      notes: data['notes'] ?? '',
      category: data['category'] ?? '',
      userId: data['userId'] ?? '',
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : null,
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      imagePath: data['imagePath'],
      status: data['status'] ?? 'upcoming',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convert ke Map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location,
      'notes': notes,
      'category': category,
      'userId': userId,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'imagePath': imagePath,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with
  TripModel copyWith({
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
  }) {
    return TripModel(
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
    );
  }

  // Helper untuk cek status berdasarkan tanggal
  String getAutoStatus() {
    if (startDate == null) return 'upcoming';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
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
