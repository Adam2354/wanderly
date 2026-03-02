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
}
