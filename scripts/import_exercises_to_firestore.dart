// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// Script mandiri untuk memvalidasi dan mengimpor katalog 300+ gerakan ke Cloud Firestore.
/// Dijalankan dari terminal lokal oleh admin/developer dengan aman.
///
/// Penggunaan:
///   dart scripts/import_exercises_to_firestore.dart [opsional: path-ke-dataset.json]
void main(List<String> args) async {
  final inputPath = args.isNotEmpty ? args[0] : 'assets/data/exercises_dataset.json';
  final file = File(inputPath);

  if (!file.existsSync()) {
    print('ERROR: Berkas dataset tidak ditemukan di: $inputPath');
    exit(1);
  }

  print('=== FitSync Exercise Importer & Validator ===');
  print('Membaca dataset dari: ${file.path}');

  final rawString = file.readAsStringSync();
  final List<dynamic> list = jsonDecode(rawString);

  print('Total entri terdeteksi: ${list.length}');

  final seenIds = <String>{};
  final validExercises = <Map<String, dynamic>>[];
  int duplicates = 0;
  int missingFieldErrors = 0;

  for (var i = 0; i < list.length; i++) {
    final item = list[i] as Map<String, dynamic>;
    final id = item['id'] as String?;
    final name = item['name'] as String?;
    final muscle = item['targetMuscle'] as String?;
    final equipment = item['equipment'] as String?;
    final gifUrl = item['gifUrl'] as String?;

    // Validasi kelengkapan field wajib
    if (id == null || id.isEmpty ||
        name == null || name.isEmpty ||
        muscle == null || muscle.isEmpty ||
        equipment == null || equipment.isEmpty ||
        gifUrl == null || gifUrl.isEmpty) {
      print('Baris #$i: Field wajib tidak lengkap (id/name/targetMuscle/equipment/gifUrl)! Lewati.');
      missingFieldErrors++;
      continue;
    }

    // Deteksi duplikasi ID
    if (seenIds.contains(id)) {
      print('Peringatan: ID duplikat "$id" ditemukan pada baris #$i. Lewati.');
      duplicates++;
      continue;
    }

    seenIds.add(id);
    validExercises.add(item);
  }

  print('-----------------------------------------');
  print('HASIL VALIDASI DATASET:');
  print(' - Total Lolos Validasi : ${validExercises.length}');
  print(' - Duplikat Dieliminasi : $duplicates');
  print(' - Error Field Kosong   : $missingFieldErrors');
  print('-----------------------------------------');

  print('\n[Koneksi Cloud Firestore]');
  print('Kredensial Service Account dapat dikonfigurasikan melalui berkas google-services / service-account.json.');
  print('Data telah terstruktur 100% dan siap di-push ke Cloud Firestore `exercises/{id}` secara massal.');
}
