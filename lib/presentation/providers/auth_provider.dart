import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/firebase/activity_firestore_datasource.dart';
import '../../data/datasources/firebase/firebase_auth_datasource.dart';
import '../../data/datasources/firebase/firestore_datasource.dart';
import 'service_providers.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthDatasourceProvider);
  return authService.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final authService = ref.watch(firebaseAuthDatasourceProvider);
  return authService.currentUser;
});

final authLoadingProvider = StateProvider<bool>((ref) => false);

final authErrorProvider = StateProvider<String?>((ref) => null);

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final FirebaseAuthDatasource _authService;
  final FirestoreDatasource _firestoreService;
  final ActivityFirestoreDatasource _activityFirestoreService;
  final Ref _ref;

  AuthNotifier(
    this._authService,
    this._firestoreService,
    this._activityFirestoreService,
    this._ref,
  ) : super(const AsyncValue.loading()) {
    state = AsyncValue.data(_authService.currentUser);
  }

  Future<void> _seedUserData(String userId) async {
    await _firestoreService.seedSampleTripsIfEmpty(userId);
    await _activityFirestoreService.seedSampleActivitiesIfEmpty(userId);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user?.uid;
      if (uid != null && uid.isNotEmpty) {
        await _seedUserData(uid);
      }
      state = AsyncValue.data(userCredential.user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(authErrorProvider.notifier).state = e.toString();
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> register(
    String email,
    String password, {
    String? displayName,
  }) async {
    state = const AsyncValue.loading();
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      final userCredential = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user?.uid;
      if (uid != null && uid.isNotEmpty) {
        await _seedUserData(uid);
      }
      if (displayName != null && displayName.trim().isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName.trim());
        await userCredential.user?.reload();
      }
      state = AsyncValue.data(_authService.currentUser);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(authErrorProvider.notifier).state = e.toString();
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    _ref.read(authLoadingProvider.notifier).state = true;

    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(authErrorProvider.notifier).state = e.toString();
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  bool isLoggedIn() {
    return _authService.isLoggedIn();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
      final authService = ref.watch(firebaseAuthDatasourceProvider);
      final firestoreService = ref.watch(firestoreDatasourceProvider);
      final activityFirestoreService = ref.watch(
        activityFirestoreDatasourceProvider,
      );
      return AuthNotifier(
        authService,
        firestoreService,
        activityFirestoreService,
        ref,
      );
    });
