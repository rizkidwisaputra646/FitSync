import 'package:flutter/services.dart';

/// Helper getaran halus (haptic feedback) bawaan Flutter untuk respon interaksi fisik.
class HapticsHelper {
  HapticsHelper._();

  /// Getaran lembut saat berpindah tab atau menyeleksi item
  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  static Future<void> selectionClick() => selection();

  /// Getaran ringan saat tombol ditekan atau aksi sukses kecil
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static Future<void> lightImpact() => light();

  /// Getaran mantap saat menyelesaikan set atau konfirmasi sukses
  static Future<void> success() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  static Future<void> mediumImpact() => success();

  /// Getaran peringatan atau error
  static Future<void> warning() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}

