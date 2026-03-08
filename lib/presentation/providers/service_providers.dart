import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/activity_firestore_service.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../data/services/firestore_service.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final activityFirestoreServiceProvider = Provider<ActivityFirestoreService>((
  ref,
) {
  return ActivityFirestoreService();
});
