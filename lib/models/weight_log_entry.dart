/// Model riwayat pencatatan berat badan pengguna.
class WeightLogEntry {
  final String id;
  final double weightKg;
  final DateTime loggedAt;
  final String? note;

  const WeightLogEntry({
    required this.id,
    required this.weightKg,
    required this.loggedAt,
    this.note,
  });

  factory WeightLogEntry.fromMap(Map<String, dynamic> map, String id) {
    return WeightLogEntry(
      id: id,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      loggedAt: map['loggedAt'] != null
          ? DateTime.tryParse(map['loggedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weightKg': weightKg,
      'loggedAt': loggedAt.toIso8601String(),
      'note': note,
    };
  }
}
