import 'dart:async';

/// Representasi sesi pengguna yang seragam baik dari Firebase Auth maupun session provider.
class UserSession {
  final String uid;
  final String email;
  final String displayName;
  final bool isAnonymous;

  const UserSession({
    required this.uid,
    required this.email,
    required this.displayName,
    this.isAnonymous = false,
  });
}

abstract class AuthRepository {
  Stream<UserSession?> get authStateChanges;
  UserSession? get currentUser;

  Future<UserSession> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserSession> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();

  bool get isFirebaseAvailable;
}
