import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/workout/data/preset_workout_programs.dart';
import '../models/user_profile.dart';
import '../models/workout_program.dart';
import '../models/workout_session.dart';
import 'workout_repository.dart';

class LocalWorkoutRepository implements WorkoutRepository {
  final SharedPreferences _prefs;
  final StreamController<List<WorkoutSession>> _historyController =
      StreamController<List<WorkoutSession>>.broadcast();

  LocalWorkoutRepository(this._prefs);

  String _getKey(String userId) => 'workout_sessions_$userId';

  String _getCustomDaysKey(String userId, String programId) =>
      'custom_days_${userId}_$programId';

  @override
  Future<WorkoutProgram> getProgramForProfile(UserProfile profile) async {
    final preset = PresetWorkoutPrograms.getProgramForGoal(
      goal: profile.fitnessGoal,
      level: profile.experienceLevel,
    );

    final customizedDays = await getCustomizedDays(profile.uid, preset.id);
    if (customizedDays.isEmpty) {
      return preset;
    }

    final updatedDays = preset.days.map((day) {
      if (customizedDays.containsKey(day.dayNumber)) {
        return customizedDays[day.dayNumber]!;
      }
      return day;
    }).toList();

    return WorkoutProgram(
      id: preset.id,
      title: preset.title,
      description: preset.description,
      targetGoal: preset.targetGoal,
      experienceLevel: preset.experienceLevel,
      durationDays: preset.durationDays,
      days: updatedDays,
    );
  }

  @override
  Future<Map<int, ProgramDay>> getCustomizedDays(
      String userId, String programId) async {
    final raw = _prefs.getString(_getCustomDaysKey(userId, programId));
    if (raw == null) return {};

    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      final result = <int, ProgramDay>{};
      decoded.forEach((key, val) {
        final dayNum = int.tryParse(key);
        if (dayNum != null && val is Map<String, dynamic>) {
          result[dayNum] = ProgramDay.fromMap(val);
        }
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> saveCustomizedDay(
      String userId, String programId, ProgramDay day) async {
    final customDays = await getCustomizedDays(userId, programId);
    customDays[day.dayNumber] = day;

    final map = customDays.map((k, v) => MapEntry(k.toString(), v.toMap()));
    await _prefs.setString(_getCustomDaysKey(userId, programId), jsonEncode(map));
  }

  @override
  Future<void> resetDayToDefault(
      String userId, String programId, int dayNumber) async {
    final customDays = await getCustomizedDays(userId, programId);
    customDays.remove(dayNumber);

    final map = customDays.map((k, v) => MapEntry(k.toString(), v.toMap()));
    await _prefs.setString(_getCustomDaysKey(userId, programId), jsonEncode(map));
  }

  @override
  Future<List<WorkoutSession>> getWorkoutHistory(String userId) async {
    final raw = _prefs.getStringList(_getKey(userId)) ?? [];
    final list = raw.map((item) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      return WorkoutSession.fromMap(map);
    }).toList();

    // Urutkan dari yang terbaru ke terlama
    list.sort((a, b) => b.startTime.compareTo(a.startTime));
    return list;
  }

  @override
  Stream<List<WorkoutSession>> watchWorkoutHistory(String userId) async* {
    yield await getWorkoutHistory(userId);
    yield* _historyController.stream;
  }

  @override
  Future<void> saveWorkoutSession(WorkoutSession session) async {
    final history = await getWorkoutHistory(session.userId);
    // Masukkan ke posisi pertama (terbaru)
    history.insert(0, session);

    final rawList = history.map((s) => jsonEncode(s.toMap())).toList();
    await _prefs.setStringList(_getKey(session.userId), rawList);

    _historyController.add(history);
  }

  @override
  Future<int> getCompletedWorkoutsCount(String userId) async {
    final history = await getWorkoutHistory(userId);
    return history.length;
  }
}
