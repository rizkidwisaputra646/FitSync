enum UserRole {
  admin,
  staff,
  member;

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.staff:
        return 'Petugas Gym';
      case UserRole.member:
        return 'Member';
    }
  }

  bool get canManageMembers => this == UserRole.admin;
  bool get canVerifyPayments => this == UserRole.admin;
  bool get canManagePlans => this == UserRole.admin;
  bool get canManageExercises => this == UserRole.admin;
  bool get canScanQrCheckin => this == UserRole.admin || this == UserRole.staff;
  bool get canViewReports => this == UserRole.admin;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'staff':
      case 'petugas':
        return UserRole.staff;
      case 'member':
      default:
        return UserRole.member;
    }
  }
}
