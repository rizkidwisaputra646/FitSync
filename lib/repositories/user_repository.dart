import '../models/user_profile.dart';
import '../models/weight_log_entry.dart';

abstract class UserRepository {
  Future<UserProfile?> getUserProfile(String uid);
  Future<void> saveUserProfile(UserProfile profile);
  Future<void> updateWeightLog({
    required String uid,
    required double newWeightKg,
    String? note,
  });
  Stream<UserProfile?> watchUserProfile(String uid);
  Stream<List<WeightLogEntry>> watchWeightLogs(String uid);
  Future<List<WeightLogEntry>> getWeightLogs(String uid);
}
