import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_auth_service.dart';

// Provider untuk Firebase Auth Service
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

// Provider untuk auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});

// Provider untuk current user
final currentUserProvider = Provider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.currentUser;
});

// Provider untuk loading state
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Provider untuk error message
final authErrorProvider = StateProvider<String?>((ref) => null);

// Auth notifier untuk handle login/register/logout
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final FirebaseAuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref)
    : super(const AsyncValue.loading()) {
    // Initialize with current user
    state = AsyncValue.data(_authService.currentUser);
  }

  // Sign in
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AsyncValue.data(userCredential.user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(authErrorProvider.notifier).state = e.toString();
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Register
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

  // Sign out
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

  // Check if logged in
  bool isLoggedIn() {
    return _authService.isLoggedIn();
  }
}

// Auth notifier provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
      final authService = ref.watch(firebaseAuthServiceProvider);
      return AuthNotifier(authService, ref);
    });
