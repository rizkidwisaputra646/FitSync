import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/user_profile.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/dev_auth_repository.dart';
import '../../../repositories/dev_user_repository.dart';
import '../../../repositories/firebase_auth_repository.dart';
import '../../../repositories/firestore_user_repository.dart';
import '../../../repositories/user_repository.dart';
import '../../../services/firebase_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (FirebaseService.isInitialized) {
    return FirebaseAuthRepository();
  }
  final prefs = ref.watch(sharedPreferencesProvider);
  return DevAuthRepository(prefs);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  if (FirebaseService.isInitialized) {
    return FirestoreUserRepository();
  }
  final prefs = ref.watch(sharedPreferencesProvider);
  return DevUserRepository(prefs);
});

final authStateProvider = StreamProvider<UserSession?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) {
    return Stream.value(null);
  }
  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.watchUserProfile(authState.uid);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;

  AuthController({
    required AuthRepository authRepo,
    required UserRepository userRepo,
  })  : _authRepo = authRepo,
        _userRepo = userRepo,
        super(const AsyncValue.data(null));

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final session = await _authRepo.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Cek apakah profil sudah ada, jika belum buat profil empty
      final profile = await _userRepo.getUserProfile(session.uid);
      if (profile == null) {
        await _userRepo.saveUserProfile(
          UserProfile.empty(
            uid: session.uid,
            email: session.email,
            displayName: session.displayName.isNotEmpty
                ? session.displayName
                : email.split('@').first,
          ),
        );
      }
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final session = await _authRepo.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );

      // Inisialisasi profil dasar di repository (profileCompleted = false)
      final newProfile = UserProfile.empty(
        uid: session.uid,
        email: session.email,
        displayName: name.trim(),
      );
      await _userRepo.saveUserProfile(newProfile);
    });
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepo.sendPasswordResetEmail(email);
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepo.signOut();
    });
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  return AuthController(authRepo: authRepo, userRepo: userRepo);
});
