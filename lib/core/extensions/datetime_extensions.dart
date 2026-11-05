import 'package:intl/intl.dart';

/// Ekstensi pemformat tanggal & waktu ramah pengguna lokal Indonesia.
extension DateTimeX on DateTime? {
  String formattedDateTime([String locale = 'id_ID']) {
    if (this == null) return 'N/A';
    return DateFormat('d MMMM yyyy, HH:mm', locale).format(this!);
  }

  String formattedDate([String locale = 'id_ID']) {
    if (this == null) return 'N/A';
    return DateFormat('d MMM yyyy', locale).format(this!);
  }

  String formattedTime() {
    if (this == null) return 'N/A';
    return DateFormat('HH:mm').format(this!);
  }

  bool get isToday {
    if (this == null) return false;
    final now = DateTime.now();
    return this!.year == now.year && this!.month == now.month && this!.day == now.day;
  }

  bool get isYesterday {
    if (this == null) return false;
    final yest = DateTime.now().subtract(const Duration(days: 1));
    return this!.year == yest.year && this!.month == yest.month && this!.day == yest.day;
  }

  /// Menampilkan "Hari ini", "Kemarin", atau tanggal jika lebih dari kemarin.
  String formattedDayOrDate([String locale = 'id_ID']) {
    if (this == null) return 'N/A';
    if (isToday) return 'Hari ini';
    if (isYesterday) return 'Kemarin';
    return formattedDate(locale);
  }
}

