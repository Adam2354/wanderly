import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/firebase/activity_firestore_datasource.dart';
import '../../data/datasources/firebase/firebase_auth_datasource.dart';
import '../../data/datasources/firebase/firestore_datasource.dart';

final firebaseAuthDatasourceProvider = Provider<FirebaseAuthDatasource>((ref) {
  return FirebaseAuthDatasource();
});

final firestoreDatasourceProvider = Provider<FirestoreDatasource>((ref) {
  return FirestoreDatasource();
});

final activityFirestoreDatasourceProvider =
    Provider<ActivityFirestoreDatasource>((ref) {
      return ActivityFirestoreDatasource();
    });
