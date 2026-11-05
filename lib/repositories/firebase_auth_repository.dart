import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  bool get isFirebaseAvailable => true;

  @override
  Stream<UserSession?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserSession(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        isAnonymous: user.isAnonymous,
      );
    });
  }

  @override
  UserSession? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserSession(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      isAnonymous: user.isAnonymous,
    );
  }

  bool _isDemoAccount(String email) {
    final lower = email.toLowerCase();
    return lower == 'admin@fitsync.com' ||
        lower == 'petugas@fitsync.com' ||
        lower == 'staff@fitsync.com' ||
        lower == 'member@fitsync.com';
  }

  String _getDemoDisplayName(String email) {
    final lower = email.toLowerCase();
    if (lower.contains('admin')) return 'Administrator Gym';
    if (lower.contains('petugas') || lower.contains('staff')) {
      return 'Petugas Front Desk';
    }
    return 'FitSync Member';
  }

  @override
  Future<UserSession> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      final user = credential.user!;
      return UserSession(
        uid: user.uid,
        email: user.email ?? cleanEmail,
        displayName: user.displayName ?? _getDemoDisplayName(cleanEmail),
      );
    } on FirebaseAuthException catch (e) {
      // Jika akun demo resmi belum terdaftar di Firebase Console pengguna,
      // otomatis daftarkan akun baru agar pengguna bisa langsung masuk tanpa hambatan!
      if ((e.code == 'user-not-found' || e.code == 'invalid-credential') &&
          _isDemoAccount(cleanEmail)) {
        try {
          final credential = await _firebaseAuth.createUserWithEmailAndPassword(
            email: cleanEmail,
            password: password,
          );
          final user = credential.user!;
          final displayName = _getDemoDisplayName(cleanEmail);
          try {
            await user.updateDisplayName(displayName);
          } catch (_) {}
          return UserSession(
            uid: user.uid,
            email: user.email ?? cleanEmail,
            displayName: displayName,
          );
        } on FirebaseAuthException catch (regError) {
          if (regError.code == 'email-already-in-use') {
            // Email sudah terdaftar dengan password lain
            throw 'Akun $cleanEmail sudah terdaftar dengan password lain di Firebase. Silakan reset password atau gunakan form pendaftaran.';
          }
          throw _mapFirebaseAuthError(regError);
        } catch (_) {
          throw _mapFirebaseAuthError(e);
        }
      }
      throw _mapFirebaseAuthError(e);
    }
  }

  @override
  Future<UserSession> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(name.trim());

      return UserSession(
        uid: user.uid,
        email: user.email ?? '',
        displayName: name.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'operation-not-allowed':
        return 'Provider Email/Password belum diaktifkan di Firebase Console (Authentication > Sign-in method).';
      case 'user-not-found':
        return 'Akun dengan email ini tidak ditemukan.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah. Silakan periksa kembali.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan gunakan email lain atau login.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan gagal. Silakan tunggu beberapa saat.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa jaringan Anda.';
      default:
        return e.message ?? 'Terjadi kesalahan autentikasi.';
    }
  }
}
