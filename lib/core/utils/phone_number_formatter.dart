import 'package:flutter/services.dart';

/// Formatter nomor telepon format Indonesia (+62 8xx-xxxx-xxxx)
/// Dibuat murni dengan Flutter TextInputFormatter tanpa perlu package eksternal.
class IndonesianPhoneFormatter extends TextInputFormatter {
  const IndonesianPhoneFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) {
      return newValue;
    }

    // Hanya ambil digit angka
    String digits = text.replaceAll(RegExp(r'\D'), '');

    // Jika diawali 62, jangan dobel
    if (digits.startsWith('62')) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    // Maksimal 12 digit setelah 62 (misal 812 3456 7890)
    if (digits.length > 12) {
      digits = digits.substring(0, 12);
    }

    final buffer = StringBuffer('+62 ');
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 7) {
        buffer.write('-');
      }
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

extension PhoneFormattingX on String? {
  String formatAsIndonesianPhone() {
    if (this == null || this!.trim().isEmpty) return '-';
    String digits = this!.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('62')) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    final buffer = StringBuffer('+62 ');
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 7) {
        buffer.write('-');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

