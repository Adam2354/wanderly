import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'trips';

  // Get trips collection reference
  CollectionReference get _tripsCollection =>
      _firestore.collection(collectionName);

  // Stream of trips for specific user
  Stream<List<TripModel>> getTripsStream(String userId) {
    return _tripsCollection.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final trips = snapshot.docs
          .map((doc) => TripModel.fromFirestore(doc))
          .toList();
      trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return trips;
    });
  }

  // Get all trips for user (one-time fetch)
  Future<List<TripModel>> getTrips(String userId) async {
    try {
      final querySnapshot = await _tripsCollection
          .where('userId', isEqualTo: userId)
          .get();
      final trips = querySnapshot.docs
          .map((doc) => TripModel.fromFirestore(doc))
          .toList();
      trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return trips;
    } catch (e) {
      throw Exception('Gagal mengambil data: $e');
    }
  }

  // Get single trip by ID
  Future<TripModel?> getTrip(String tripId) async {
    try {
      final doc = await _tripsCollection.doc(tripId).get();
      if (doc.exists) {
        return TripModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil data trip: $e');
    }
  }

  // Add new trip
  Future<String> addTrip(TripModel trip) async {
    try {
      final docRef = await _tripsCollection.add(trip.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambah trip: $e');
    }
  }

  // Update trip
  Future<void> updateTrip(String tripId, TripModel trip) async {
    try {
      await _tripsCollection
          .doc(tripId)
          .update(trip.copyWith(updatedAt: DateTime.now()).toFirestore());
    } catch (e) {
      throw Exception('Gagal mengupdate trip: $e');
    }
  }

  // Delete trip
  Future<void> deleteTrip(String tripId) async {
    try {
      await _tripsCollection.doc(tripId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus trip: $e');
    }
  }

  // Update trip status
  Future<void> updateTripStatus(String tripId, String status) async {
    try {
      await _tripsCollection.doc(tripId).update({
        'status': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Gagal mengupdate status: $e');
    }
  }

  // Get trips by category
  Future<List<TripModel>> getTripsByCategory(
    String userId,
    String category,
  ) async {
    try {
      final querySnapshot = await _tripsCollection
          .where('userId', isEqualTo: userId)
          .get();
      final trips = querySnapshot.docs
          .map((doc) => TripModel.fromFirestore(doc))
          .where((trip) => trip.category == category)
          .toList();
      trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return trips;
    } catch (e) {
      throw Exception('Gagal mengambil data berdasarkan kategori: $e');
    }
  }

  // Get trips by status
  Future<List<TripModel>> getTripsByStatus(String userId, String status) async {
    try {
      final querySnapshot = await _tripsCollection
          .where('userId', isEqualTo: userId)
          .get();
      final trips = querySnapshot.docs
          .map((doc) => TripModel.fromFirestore(doc))
          .where((trip) => trip.status == status)
          .toList();
      trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return trips;
    } catch (e) {
      throw Exception('Gagal mengambil data berdasarkan status: $e');
    }
  }

  // Batch delete (for testing/admin)
  Future<void> deleteAllUserTrips(String userId) async {
    try {
      final querySnapshot = await _tripsCollection
          .where('userId', isEqualTo: userId)
          .get();
      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Gagal menghapus semua trip: $e');
    }
  }

  Future<void> seedSampleTripsIfEmpty(String userId) async {
    final existing = await _tripsCollection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return;
    }

    final samples = <TripModel>[
      TripModel(
        name: 'Kyoto Exploration',
        location: 'Kyoto, Japan',
        notes: 'Perjalanan budaya dan kuliner di Kyoto',
        category: 'Sightseeing',
        userId: userId,
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 12)),
        status: 'upcoming',
        latitude: 35.0116,
        longitude: 135.7681,
      ),
      TripModel(
        name: 'Osaka Food Tour',
        location: 'Osaka, Japan',
        notes: 'Jelajah street food Osaka',
        category: 'Restaurant',
        userId: userId,
        startDate: DateTime.now().subtract(const Duration(days: 14)),
        endDate: DateTime.now().subtract(const Duration(days: 10)),
        status: 'completed',
        latitude: 34.6937,
        longitude: 135.5023,
      ),
      TripModel(
        name: 'Tokyo City Lights',
        location: 'Tokyo, Japan',
        notes: 'City trip dan nightlife Tokyo',
        category: 'Nightlife',
        userId: userId,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 2)),
        status: 'ongoing',
        latitude: 35.6762,
        longitude: 139.6503,
      ),
    ];

    final batch = _firestore.batch();
    for (final trip in samples) {
      final docRef = _tripsCollection.doc();
      batch.set(docRef, trip.toFirestore());
    }
    await batch.commit();
  }
}
