import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Status sinkronisasi realtime kode QR FitSync
enum QrSyncStatus {
  active, // QR aktif, countdown berjalan normal
  refreshing, // Sedang menyinkronkan token baru ke Firebase
  expired, // Masa berlaku 60 detik habis
  used, // Baru saja sukses di-scan di turnstile (realtime feedback!)
  error, // Gagal memuat atau jaringan bermasalah
}

/// Mengelola pembuatan dan validasi kode QR dinamis 60 detik
/// Anti-fraud: Dilengkapi tokenId unik, timestamp epoch, dan signature HMAC-SHA256
class QrCheckinToken {
  static const String _secretKey = 'fitsync_secure_vault_pass_key_2026';
  static const int tokenTtlSeconds = 60;

  final String userId;
  final String membershipId;
  final String memberCode;
  final int epochSeconds;
  final String tokenId;
  final String signature;
  final String rawPayload;
  final bool isUsed;

  const QrCheckinToken({
    required this.userId,
    required this.membershipId,
    required this.memberCode,
    required this.epochSeconds,
    required this.tokenId,
    required this.signature,
    required this.rawPayload,
    this.isUsed = false,
  });

  /// Buat token baru untuk saat ini dengan tokenId unik
  factory QrCheckinToken.create({
    required String userId,
    required String membershipId,
    required String memberCode,
    int? customEpoch,
    String? customTokenId,
  }) {
    final epoch = customEpoch ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final nowMicro = DateTime.now().microsecondsSinceEpoch;
    final generatedTokenId = customTokenId ??
        't_${epoch}_${md5.convert(utf8.encode('$userId:$membershipId:$nowMicro')).toString().substring(0, 8)}';

    final dataToSign = '$userId:$membershipId:$memberCode:$epoch:$generatedTokenId';

    final hmac = Hmac(sha256, utf8.encode(_secretKey));
    final digest = hmac.convert(utf8.encode(dataToSign));
    final signature = digest.toString().substring(0, 16); // 16 char signature for compact QR

    final payload =
        'FITSYNC:$userId:$membershipId:$memberCode:$epoch:$generatedTokenId:$signature';

    return QrCheckinToken(
      userId: userId,
      membershipId: membershipId,
      memberCode: memberCode,
      epochSeconds: epoch,
      tokenId: generatedTokenId,
      signature: signature,
      rawPayload: payload,
      isUsed: false,
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
  bool get isValid => secondsRemaining > 0 && !isUsed;

  /// Verifikasi awal format dan signature payload raw dari scanner gym
  static QrValidationResult validate(String payload) {
    if (!payload.startsWith('FITSYNC:')) {
      return const QrValidationResult(
        isValid: false,
        message: 'Format QR Code tidak dikenali oleh FitSync scanner.',
      );
    }

    final parts = payload.split(':');
    if (parts.length != 6 && parts.length != 7) {
      return const QrValidationResult(
        isValid: false,
        message: 'Struktur payload QR tidak valid atau korup.',
      );
    }

    final userId = parts[1];
    final membershipId = parts[2];
    final memberCode = parts[3];
    final epoch = int.tryParse(parts[4]);

    if (epoch == null) {
      return const QrValidationResult(
        isValid: false,
        message: 'Data timestamp QR tidak valid.',
      );
    }

    String tokenId = '';
    String givenSignature = '';

    if (parts.length == 7) {
      // Format Baru (Realtime Token Id)
      tokenId = parts[5];
      givenSignature = parts[6];

      final dataToSign = '$userId:$membershipId:$memberCode:$epoch:$tokenId';
      final hmac = Hmac(sha256, utf8.encode(_secretKey));
      final expectedSignature =
          hmac.convert(utf8.encode(dataToSign)).toString().substring(0, 16);

      if (givenSignature != expectedSignature) {
        return const QrValidationResult(
          isValid: false,
          message: 'Signature QR palsu atau tidak cocok dengan sistem.',
        );
      }
    } else {
      // Format Legacy 6 bagian
      givenSignature = parts[5];
      tokenId = 'legacy_$epoch';

      final dataToSign = '$userId:$membershipId:$memberCode:$epoch';
      final hmac = Hmac(sha256, utf8.encode(_secretKey));
      final expectedSignature =
          hmac.convert(utf8.encode(dataToSign)).toString().substring(0, 16);

      if (givenSignature != expectedSignature) {
        return const QrValidationResult(
          isValid: false,
          message: 'Signature QR palsu atau tidak cocok dengan sistem.',
        );
      }
    }

    // Cek selisih waktu awal (toleransi clock skew 10 detik)
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final diff = nowEpoch - epoch;

    if (diff > (tokenTtlSeconds + 10)) {
      return QrValidationResult(
        isValid: false,
        message:
            'Kode QR telah kedaluwarsa ($diff detik yang lalu). Gunakan QR terbaru.',
        userId: userId,
        membershipId: membershipId,
        memberCode: memberCode,
        tokenId: tokenId,
      );
    }

    return QrValidationResult(
      isValid: true,
      message: 'Format & Signature QR Valid. Melanjutkan verifikasi server...',
      userId: userId,
      membershipId: membershipId,
      memberCode: memberCode,
      tokenId: tokenId,
      epochSeconds: epoch,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'tokenId': tokenId,
      'userId': userId,
      'membershipId': membershipId,
      'memberCode': memberCode,
      'epochSeconds': epochSeconds,
      'rawPayload': rawPayload,
      'used': false,
      'status': 'active',
    };
  }
}

class QrValidationResult {
  final bool isValid;
  final String message;
  final String? userId;
  final String? membershipId;
  final String? memberCode;
  final String? tokenId;
  final int? epochSeconds;

  const QrValidationResult({
    required this.isValid,
    required this.message,
    this.userId,
    this.membershipId,
    this.memberCode,
    this.tokenId,
    this.epochSeconds,
  });
}
