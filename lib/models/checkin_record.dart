class CheckInRecord {
  final String id;
  final String userId;
  final String membershipId;
  final String planName;
  final DateTime timestamp;
  final String location;
  final String status; // 'granted', 'denied'
  final String notes;

  const CheckInRecord({
    required this.id,
    required this.userId,
    required this.membershipId,
    required this.planName,
    required this.timestamp,
    this.location = 'FitSync Hub - Main Turnstile',
    this.status = 'granted',
    this.notes = 'Verifikasi QR Berhasil',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'membershipId': membershipId,
      'planName': planName,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'status': status,
      'notes': notes,
    };
  }

  factory CheckInRecord.fromJson(Map<String, dynamic> json) {
    return CheckInRecord(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      membershipId: json['membershipId'] as String? ?? '',
      planName: json['planName'] as String? ?? 'Member Pass',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      location: json['location'] as String? ?? 'FitSync Hub - Main Turnstile',
      status: json['status'] as String? ?? 'granted',
      notes: json['notes'] as String? ?? '',
    );
  }
}
