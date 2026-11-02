import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_repository.dart';

/// Local sandbox repository for testing full flows before Firebase credentials are configured.
/// Persists current test session into SharedPreferences.
class DevAuthRepository implements AuthRepository {
  final SharedPreferences _prefs;
  final _controller = StreamController<UserSession?>.broadcast();
  UserSession? _currentSession;

  static const _keyUid = 'dev_auth_uid';
  static const _keyEmail = 'dev_auth_email';
  static const _keyName = 'dev_auth_name';

  DevAuthRepository(this._prefs) {
    _restoreSession();
  }

  void _restoreSession() {
    final uid = _prefs.getString(_keyUid);
    final email = _prefs.getString(_keyEmail);
    final name = _prefs.getString(_keyName);

    if (uid != null && email != null) {
      _currentSession = UserSession(
        uid: uid,
        email: email,
        displayName: name ?? 'FitSync Athlete',
      );
    } else {
      _currentSession = null;
    }
    _controller.add(_currentSession);
  }

  @override
  bool get isFirebaseAvailable => false;

  /// Memancarkan sesi saat ini secara instan begitu didengarkan, lalu memperbarui saat ada perubahan
  @override
  Stream<UserSession?> get authStateChanges async* {
    yield _currentSession;
    yield* _controller.stream;
  }

  @override
  UserSession? get currentUser => _currentSession;

  @override
  Future<UserSession> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!email.contains('@') || password.length < 6) {
      throw 'Email tidak valid atau password minimal 6 karakter.';
    }

    final uid = 'dev_user_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    final name = email.split('@').first;

    await _prefs.setString(_keyUid, uid);
    await _prefs.setString(_keyEmail, email);
    await _prefs.setString(_keyName, name);

    _currentSession = UserSession(
      uid: uid,
      email: email,
      displayName: name,
    );
    _controller.add(_currentSession);
    return _currentSession!;
  }

  @override
  Future<UserSession> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!email.contains('@')) {
      throw 'Format email tidak valid.';
    }
    if (password.length < 6) {
      throw 'Password minimal 6 karakter.';
    }

    final uid = 'dev_user_${DateTime.now().millisecondsSinceEpoch}';

    await _prefs.setString(_keyUid, uid);
    await _prefs.setString(_keyEmail, email);
    await _prefs.setString(_keyName, name);

    _currentSession = UserSession(
      uid: uid,
      email: email,
      displayName: name,
    );
    _controller.add(_currentSession);
    return _currentSession!;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!email.contains('@')) {
      throw 'Format email tidak valid.';
    }
  }

  @override
  Future<void> signOut() async {
    await _prefs.remove(_keyUid);
    await _prefs.remove(_keyEmail);
    await _prefs.remove(_keyName);
    _currentSession = null;
    _controller.add(null);
  }
}
