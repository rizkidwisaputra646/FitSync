import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Inisialisasi Firebase secara aman dengan graceful fallback di seluruh platform (Web, Android, iOS, Windows).
  static Future<bool> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        return true;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('[FirebaseService] Firebase successfully initialized.');
      }
      return true;
    } catch (e) {
      _isInitialized = false;
      if (kDebugMode) {
        debugPrint(
          '[FirebaseService] Firebase belum terkonfigurasi ($e). '
          'Berjalan mulus dalam Local Development Mode.',
        );
      }
      return false;
    }
  }
}
