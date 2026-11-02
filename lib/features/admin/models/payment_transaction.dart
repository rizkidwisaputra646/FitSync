enum PaymentStatus {
  pending,
  approved,
  rejected;

  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'Menunggu Verifikasi';
      case PaymentStatus.approved:
        return 'Disetujui';
      case PaymentStatus.rejected:
        return 'Ditolak';
    }
  }

  static PaymentStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return PaymentStatus.approved;
      case 'rejected':
        return PaymentStatus.rejected;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }
}

class PaymentTransaction {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String memberCode;
  final String planId;
  final String planName;
  final int amount;
  final String paymentMethod;
  final String? paymentProofUrl;
  final PaymentStatus status;
  final String? rejectionReason;
  final String? processedByAdminId;
  final DateTime createdAt;
  final DateTime? processedAt;

  const PaymentTransaction({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.memberCode,
    required this.planId,
    required this.planName,
    required this.amount,
    required this.paymentMethod,
    this.paymentProofUrl,
    this.status = PaymentStatus.pending,
    this.rejectionReason,
    this.processedByAdminId,
    required this.createdAt,
    this.processedAt,
  });

  String get formattedAmount {
    // Format nominal ke Rupiah
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'memberCode': memberCode,
      'planId': planId,
      'planName': planName,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentProofUrl': paymentProofUrl,
      'status': status.name,
      'rejectionReason': rejectionReason,
      'processedByAdminId': processedByAdminId,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
    };
  }

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Member FitSync',
      userEmail: json['userEmail'] as String? ?? '',
      memberCode: json['memberCode'] as String? ?? 'FS-00000',
      planId: json['planId'] as String? ?? 'monthly-pass',
      planName: json['planName'] as String? ?? 'Member 1 Bulan',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      paymentMethod: json['paymentMethod'] as String? ?? 'QRIS Instant',
      paymentProofUrl: json['paymentProofUrl'] as String?,
      status: PaymentStatus.fromString(json['status'] as String?),
      rejectionReason: json['rejectionReason'] as String?,
      processedByAdminId: json['processedByAdminId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      processedAt: json['processedAt'] != null
          ? DateTime.tryParse(json['processedAt'] as String)
          : null,
    );
  }

  PaymentTransaction copyWith({
    PaymentStatus? status,
    String? rejectionReason,
    String? processedByAdminId,
    DateTime? processedAt,
  }) {
    return PaymentTransaction(
      id: id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      memberCode: memberCode,
      planId: planId,
      planName: planName,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentProofUrl: paymentProofUrl,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      processedByAdminId: processedByAdminId ?? this.processedByAdminId,
      createdAt: createdAt,
      processedAt: processedAt ?? this.processedAt,
    );
  }
}
