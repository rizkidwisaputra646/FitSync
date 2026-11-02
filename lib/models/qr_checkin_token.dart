import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Mengelola pembuatan dan validasi kode QR dinamis 60 detik
/// Anti-fraud: Dilengkapi timestamp epoch dan signature HMAC-SHA256
class QrCheckinToken {
  static const String _secretKey = 'fitsync_secure_vault_pass_key_2026';
  static const int tokenTtlSeconds = 60;

  final String userId;
  final String membershipId;
  final String memberCode;
  final int epochSeconds;
  final String signature;
  final String rawPayload;

  const QrCheckinToken({
    required this.userId,
    required this.membershipId,
    required this.memberCode,
    required this.epochSeconds,
    required this.signature,
    required this.rawPayload,
  });

  /// Buat token baru untuk saat ini
  factory QrCheckinToken.create({
    required String userId,
    required String membershipId,
    required String memberCode,
    int? customEpoch,
  }) {
    final epoch = customEpoch ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final dataToSign = '$userId:$membershipId:$memberCode:$epoch';
    
    final hmac = Hmac(sha256, utf8.encode(_secretKey));
    final digest = hmac.convert(utf8.encode(dataToSign));
    final signature = digest.toString().substring(0, 16); // 16 char signature for compact QR

    final payload = 'FITSYNC:$userId:$membershipId:$memberCode:$epoch:$signature';

    return QrCheckinToken(
      userId: userId,
      membershipId: membershipId,
      memberCode: memberCode,
      epochSeconds: epoch,
      signature: signature,
      rawPayload: payload,
    );
  }

  /// Cek sisa waktu detik dari token ini sebelum berganti (0 s/d 60)
  int get secondsRemaining {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final elapsed = nowEpoch - epochSeconds;
    final remaining = tokenTtlSeconds - elapsed;
    return remaining < 0 ? 0 : remaining;
  }

  /// Cek apakah token masih valid (< 60 detik)
  bool get isValid => secondsRemaining > 0;

  /// Verifikasi payload raw dari scanner gym
  static QrValidationResult validate(String payload) {
    if (!payload.startsWith('FITSYNC:')) {
      return const QrValidationResult(
        isValid: false,
        message: 'Format QR Code tidak dikenali oleh FitSync scanner.',
      );
    }

    final parts = payload.split(':');
    if (parts.length != 6) {
      return const QrValidationResult(
        isValid: false,
        message: 'Struktur payload QR tidak valid atau korup.',
      );
    }

    final userId = parts[1];
    final membershipId = parts[2];
    final memberCode = parts[3];
    final epoch = int.tryParse(parts[4]);
    final givenSignature = parts[5];

    if (epoch == null) {
      return const QrValidationResult(
        isValid: false,
        message: 'Data timestamp QR tidak valid.',
      );
    }

    // 1. Cek Signature HMAC
    final dataToSign = '$userId:$membershipId:$memberCode:$epoch';
    final hmac = Hmac(sha256, utf8.encode(_secretKey));
    final expectedDigest = hmac.convert(utf8.encode(dataToSign));
    final expectedSignature = expectedDigest.toString().substring(0, 16);

    if (givenSignature != expectedSignature) {
      return const QrValidationResult(
        isValid: false,
        message: 'Signature QR palsu atau tidak cocok dengan sistem.',
      );
    }

    // 2. Cek Expiration (60 detik + toleransi 5 detik untuk clock skew)
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final diff = nowEpoch - epoch;

    if (diff > (tokenTtlSeconds + 5)) {
      return QrValidationResult(
        isValid: false,
        message: 'Kode QR telah kedaluwarsa ($diff detik yang lalu). Silakan gunakan QR terbaru.',
        userId: userId,
        membershipId: membershipId,
        memberCode: memberCode,
      );
    }

    if (diff < -15) {
      return const QrValidationResult(
        isValid: false,
        message: 'Jam pada perangkat tidak sinkron dengan waktu server.',
      );
    }

    return QrValidationResult(
      isValid: true,
      message: 'Kode QR Valid! Akses gym diberikan.',
      userId: userId,
      membershipId: membershipId,
      memberCode: memberCode,
    );
  }
}

class QrValidationResult {
  final bool isValid;
  final String message;
  final String? userId;
  final String? membershipId;
  final String? memberCode;

  const QrValidationResult({
    required this.isValid,
    required this.message,
    this.userId,
    this.membershipId,
    this.memberCode,
  });
}
