/// Ekstensi pengaman string agar tidak menampilkan literal "null" atau teks kosong ke layar.
extension StringX on String? {
  bool get isUsable {
    return this != null && this!.trim().isNotEmpty && this != 'null';
  }

  String orPlaceholder([String placeholder = '-']) {
    if (!isUsable) return placeholder;
    return this!;
  }
}

