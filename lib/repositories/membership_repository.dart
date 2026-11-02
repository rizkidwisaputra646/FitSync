import '../models/checkin_record.dart';
import '../models/user_membership.dart';

abstract class MembershipRepository {
  /// Mengambil data membership aktif user
  Future<UserMembership?> getActiveMembership(String userId);

  /// Stream membership untuk update realtime
  Stream<UserMembership?> watchActiveMembership(String userId);

  /// Aktivasi paket membership baru
  Future<void> activateMembership(UserMembership membership);

  /// Batalkan / Reset membership
  Future<void> cancelMembership(String userId);

  /// Ambil riwayat check-in pengguna
  Future<List<CheckInRecord>> getCheckInHistory(String userId);

  /// Catat scan check-in baru di gate/turnstile gym
  Future<CheckInRecord> recordCheckIn(CheckInRecord record);
}
