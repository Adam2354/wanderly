import 'package:cloud_firestore/cloud_firestore.dart';
import '../activity_store.dart';
import '../models/activity_model.dart';

class ActivityFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'activities';

  CollectionReference get _activitiesCollection =>
      _firestore.collection(collectionName);

  Stream<List<ActivityModel>> getActivitiesStream(String userId) {
    return _activitiesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final activities = snapshot.docs
              .map((doc) => ActivityModel.fromFirestore(doc))
              .toList();

          activities.sort((a, b) {
            if (a.date == null && b.date == null) return 0;
            if (a.date == null) return 1;
            if (b.date == null) return -1;
            return a.date!.compareTo(b.date!);
          });

          return activities;
        });
  }

  Future<String> addActivity(ActivityModel activity, String userId) async {
    final payload = activity.copyWith(userId: userId).toFirestore();
    final docRef = await _activitiesCollection.add(payload);
    return docRef.id;
  }

  Future<void> updateActivity(String activityId, ActivityModel activity) async {
    await _activitiesCollection
        .doc(activityId)
        .update(activity.toFirestoreUpdate());
  }

  Future<void> deleteActivity(String activityId) async {
    await _activitiesCollection.doc(activityId).delete();
  }

  Future<void> seedSampleActivitiesIfEmpty(String userId) async {
    final existing = await _activitiesCollection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return;
    }

    final store = ActivityStore.instance;
    final batch = _firestore.batch();

    for (final category in store.categories) {
      for (final item in store.itemsFor(category)) {
        final docRef = _activitiesCollection.doc();
        final model = ActivityModel(
          userId: userId,
          name: item.name,
          location: item.location,
          notes: item.notes,
          category: category,
          date: item.date,
          imagePath: item.imagePath,
        );
        batch.set(docRef, model.toFirestore());
      }
    }

    await batch.commit();
  }
}
