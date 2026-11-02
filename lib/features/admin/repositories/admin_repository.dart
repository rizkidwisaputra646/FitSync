import '../../../models/checkin_record.dart';
import '../../../models/exercise.dart';
import '../../../models/membership_plan.dart';
import '../../../models/qr_checkin_token.dart';
import '../models/admin_stats.dart';
import '../models/payment_transaction.dart';

abstract class AdminRepository {
  /// 1. Dashboard Stats
  Future<AdminStats> getDashboardStats();
  Stream<AdminStats> watchDashboardStats();

  /// 2. Member Management
  Future<List<Map<String, dynamic>>> getAllMembers();
  Future<void> updateMemberStatus(
    String userId,
    String status, {
    DateTime? customExpiry,
    String? adminNotes,
  });

  /// 3. Payment Verification
  Future<List<PaymentTransaction>> getAllPayments({String? statusFilter});
  Future<void> createPaymentRequest(PaymentTransaction transaction);
  Future<void> approvePayment(String paymentId, String adminUid);
  Future<void> rejectPayment(
      String paymentId, String adminUid, String reason);

  /// 4. Gym Check-In & Scanner
  Future<List<CheckInRecord>> getCheckins({DateTime? date});
  Future<QrValidationResult> verifyAndProcessQrCheckin({
    required String qrPayload,
    required String gateName,
    required String staffUid,
  });

  /// 5. Membership Plans Management
  Future<List<MembershipPlan>> getMembershipPlans();
  Future<void> saveMembershipPlan(MembershipPlan plan);

  /// 6. Exercise Catalog & Bulk Import
  Future<List<Exercise>> getExercises();
  Future<void> saveExercise(Exercise exercise);
  Future<void> deleteExercise(String exerciseId);
  Future<int> bulkImportExercises(List<Exercise> exercises);
}
