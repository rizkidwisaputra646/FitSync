class UserMembership {
  final String id;
  final String userId;
  final String planId;
  final String planName;
  final DateTime startDate;
  final DateTime expiryDate;
  final int pricePaid;
  final String status; // 'active', 'expired', 'cancelled'
  final String paymentMethod;
  final String? memberCode; // Unique athletic code, e.g. FS-9824

  const UserMembership({
    required this.id,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.startDate,
    required this.expiryDate,
    required this.pricePaid,
    this.status = 'active',
    this.paymentMethod = 'QRIS Instant',
    this.memberCode,
  });

  bool get isActive {
    if (status != 'active') return false;
    return expiryDate.isAfter(DateTime.now());
  }

  Duration get remainingDuration {
    final now = DateTime.now();
    if (now.isAfter(expiryDate)) return Duration.zero;
    return expiryDate.difference(now);
  }

  int get remainingDays => remainingDuration.inDays;
  int get remainingHours => remainingDuration.inHours;

  String get remainingLabel {
    if (!isActive) return 'Kedaluwarsa';
    final dur = remainingDuration;
    if (dur.inDays > 1) {
      return '${dur.inDays} Hari Tersisa';
    } else if (dur.inHours > 0) {
      return '${dur.inHours} Jam Tersisa';
    } else {
      return '${dur.inMinutes} Menit Tersisa';
    }
  }

  String get generatedCode {
    if (memberCode != null && memberCode!.isNotEmpty) return memberCode!;
    final hash = (userId.hashCode.abs() % 90000) + 10000;
    return 'FS-$hash';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'planId': planId,
      'planName': planName,
      'startDate': startDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'pricePaid': pricePaid,
      'status': status,
      'paymentMethod': paymentMethod,
      'memberCode': memberCode ?? generatedCode,
    };
  }

  factory UserMembership.fromJson(Map<String, dynamic> json) {
    return UserMembership(
      id: json['id'] as String? ?? 'membership-id',
      userId: json['userId'] as String? ?? '',
      planId: json['planId'] as String? ?? 'monthly-pass',
      planName: json['planName'] as String? ?? 'Member 1 Bulan',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'] as String) ??
              DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 30)),
      pricePaid: (json['pricePaid'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'active',
      paymentMethod: json['paymentMethod'] as String? ?? 'QRIS Instant',
      memberCode: json['memberCode'] as String?,
    );
  }
}
