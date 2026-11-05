import 'package:intl/intl.dart';

/// Ekstensi pemformat angka untuk tampilan ramah lokal Indonesia.
extension NumX on num {
  /// Format angka biasa dengan pemisah ribuan (contoh: 12.500 atau 1.324).
  String humanizedCount({int? decimalDigits}) {
    return NumberFormat.decimalPatternDigits(
      locale: 'id_ID',
      decimalDigits: decimalDigits,
    ).format(this);
  }

  /// Format mata uang rupiah Indonesia (contoh: Rp 250.000).
  String humanizedCurrency() {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(this);
  }

  /// Format angka ringkas untuk statistik (contoh: 12K atau 1.5M).
  String humanizedCompact() {
    return NumberFormat.compact(locale: 'id_ID').format(this);
  }
}

