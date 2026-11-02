import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/weight_log_entry.dart';
import 'user_repository.dart';

class DevUserRepository implements UserRepository {
  final SharedPreferences _prefs;
  final _profileController = StreamController<UserProfile?>.broadcast();
  final _weightLogsController = StreamController<List<WeightLogEntry>>.broadcast();

  static const _profilePrefix = 'dev_profile_';
  static const _weightLogsPrefix = 'dev_weight_logs_';

  DevUserRepository(this._prefs);

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    final raw = _prefs.getString('$_profilePrefix$uid');
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final profile = UserProfile.fromMap(map, uid);
      return profile;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    final raw = jsonEncode(profile.toMap());
    await _prefs.setString('$_profilePrefix${profile.uid}', raw);
    _profileController.add(profile);
  }

  @override
  Future<void> updateWeightLog({
    required String uid,
    required double newWeightKg,
    String? note,
  }) async {
    final logsKey = '$_weightLogsPrefix$uid';
    final existingList = _prefs.getStringList(logsKey) ?? [];
    final id = 'log_${DateTime.now().millisecondsSinceEpoch}';
    final entry = WeightLogEntry(
      id: id,
      weightKg: newWeightKg,
      loggedAt: DateTime.now(),
      note: note,
    );
    existingList.insert(0, jsonEncode(entry.toMap()..['id'] = id));
    await _prefs.setStringList(logsKey, existingList);

    // Kirim event ke stream
    final currentLogs = await getWeightLogs(uid);
    _weightLogsController.add(currentLogs);

    final current = await getUserProfile(uid);
    if (current != null) {
      final updated = current.copyWith(
        currentWeightKg: newWeightKg,
        updatedAt: DateTime.now(),
      );
      await saveUserProfile(updated);
    }
  }

  @override
  Stream<UserProfile?> watchUserProfile(String uid) async* {
    final initial = await getUserProfile(uid);
    yield initial;
    yield* _profileController.stream;
  }

  @override
  Stream<List<WeightLogEntry>> watchWeightLogs(String uid) async* {
    final initial = await getWeightLogs(uid);
    yield initial;
    yield* _weightLogsController.stream;
  }

  @override
  Future<List<WeightLogEntry>> getWeightLogs(String uid) async {
    final logsKey = '$_weightLogsPrefix$uid';
    final rawList = _prefs.getStringList(logsKey) ?? [];
    final result = <WeightLogEntry>[];
    for (var raw in rawList) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        result.add(WeightLogEntry.fromMap(map, map['id'] ?? 'log'));
      } catch (_) {}
    }
    // Urutkan terbaru lebih dulu
    result.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    return result;
  }
}
