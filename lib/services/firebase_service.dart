import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  FirebaseService._();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Inisialisasi Firebase secara aman dengan graceful fallback di seluruh platform (Web, Android, iOS, Windows).
  static Future<bool> initialize() async {
    // Pada platform Web dan Desktop, Firebase memerlukan parameter options yang dihasilkan oleh flutterfire configure.
    // Jika dijalankan di Web tanpa options sebelum flutterfire configure dijalankan, langsung aktifkan Local Dev Mode
    // agar browser Chrome tidak crash atau memicu assertion runtime error.
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        return true;
      }

      if (kIsWeb) {
        // Di Web tanpa file options terkonfigurasi, langsung gunakan Local Development Mode
        _isInitialized = false;
        if (kDebugMode) {
          debugPrint(
            '[FirebaseService] Mode Web terdeteksi tanpa FirebaseOptions manual. '
            'Menggunakan Local Development Mode.',
          );
        }
        return false;
      }

      await Firebase.initializeApp();
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
