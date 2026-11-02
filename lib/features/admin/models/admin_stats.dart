class AdminStats {
  final int totalMembers;
  final int activeMembers;
  final int expiredMembers;
  final int pendingPayments;
  final int todayCheckins;
  final List<CheckinDayStat> weeklyCheckins;
  final List<RecentAdminActivity> recentActivities;

  const AdminStats({
    required this.totalMembers,
    required this.activeMembers,
    required this.expiredMembers,
    required this.pendingPayments,
    required this.todayCheckins,
    required this.weeklyCheckins,
    required this.recentActivities,
  });

  factory AdminStats.initial() {
    return const AdminStats(
      totalMembers: 0,
      activeMembers: 0,
      expiredMembers: 0,
      pendingPayments: 0,
      todayCheckins: 0,
      weeklyCheckins: [],
      recentActivities: [],
    );
  }
}

class CheckinDayStat {
  final String dayName;
  final int count;

  const CheckinDayStat({
    required this.dayName,
    required this.count,
  });
}

class RecentAdminActivity {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String type; // 'checkin', 'payment', 'member', 'plan'

  const RecentAdminActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'type': type,
      };

  factory RecentAdminActivity.fromJson(Map<String, dynamic> json) =>
      RecentAdminActivity(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        type: json['type'] as String? ?? 'info',
      );
}
