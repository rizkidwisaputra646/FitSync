import '../models/user_profile.dart';
import '../models/workout_program.dart';
import '../models/workout_session.dart';

abstract class WorkoutRepository {
  Future<WorkoutProgram> getProgramForProfile(UserProfile profile);
  Future<List<WorkoutSession>> getWorkoutHistory(String userId);
  Stream<List<WorkoutSession>> watchWorkoutHistory(String userId);
  Future<void> saveWorkoutSession(WorkoutSession session);
  Future<int> getCompletedWorkoutsCount(String userId);
  Future<void> saveCustomizedDay(String userId, String programId, ProgramDay day);
  Future<Map<int, ProgramDay>> getCustomizedDays(String userId, String programId);
  Future<void> resetDayToDefault(String userId, String programId, int dayNumber);
}
