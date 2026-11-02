import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/checkin_record.dart';
import '../models/user_membership.dart';
import 'membership_repository.dart';

class LocalMembershipRepository implements MembershipRepository {
  final SharedPreferences _prefs;
  final StreamController<UserMembership?> _membershipStreamController =
      StreamController<UserMembership?>.broadcast();

  LocalMembershipRepository(this._prefs);

  String _getMembershipKey(String userId) => 'user_membership_$userId';
  String _getCheckinHistoryKey(String userId) => 'checkin_history_$userId';

  @override
  Future<UserMembership?> getActiveMembership(String userId) async {
    final raw = _prefs.getString(_getMembershipKey(userId));
    if (raw == null) return null;

    try {
      final Map<String, dynamic> map = jsonDecode(raw);
      final membership = UserMembership.fromJson(map);

      // Cek apakah sudah kedaluwarsa secara temporal
      if (!membership.isActive) {
        return membership;
      }
      return membership;
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<UserMembership?> watchActiveMembership(String userId) async* {
    yield await getActiveMembership(userId);
    yield* _membershipStreamController.stream.where(
      (m) => m == null || m.userId == userId,
    );
  }

  @override
  Future<void> activateMembership(UserMembership membership) async {
    final raw = jsonEncode(membership.toJson());
    await _prefs.setString(_getMembershipKey(membership.userId), raw);
    _membershipStreamController.add(membership);
  }

  @override
  Future<void> cancelMembership(String userId) async {
    await _prefs.remove(_getMembershipKey(userId));
    _membershipStreamController.add(null);
  }

  @override
  Future<List<CheckInRecord>> getCheckInHistory(String userId) async {
    final raw = _prefs.getString(_getCheckinHistoryKey(userId));
    if (raw == null) return [];

    try {
      final List<dynamic> list = jsonDecode(raw);
      return list
          .map((item) => CheckInRecord.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (_) {
      return [];
    }
  }

  @override
  Future<CheckInRecord> recordCheckIn(CheckInRecord record) async {
    final history = await getCheckInHistory(record.userId);
    final updated = [record, ...history];

    final raw = jsonEncode(updated.map((r) => r.toJson()).toList());
    await _prefs.setString(_getCheckinHistoryKey(record.userId), raw);

    return record;
  }
}
