/// Biological sex used specifically for Mifflin-St Jeor BMR calculation.
enum BiologicalSex {
  male('Laki-laki', 'male'),
  female('Perempuan', 'female');

  final String label;
  final String code;
  const BiologicalSex(this.label, this.code);

  static BiologicalSex fromCode(String code) {
    return BiologicalSex.values.firstWhere(
      (e) => e.code == code,
      orElse: () => BiologicalSex.male,
    );
  }
}

/// Daily activity level representing routine outside the gym.
enum ActivityLevel {
  sedentary(
    'Sedentary',
    'Sebagian besar duduk, bekerja di meja, minim aktivitas fisik.',
    1.2,
  ),
  lightlyActive(
    'Lightly Active',
    'Aktivitas ringan sehari-hari atau jalan santai 1-3 hari/minggu.',
    1.375,
  ),
  moderatelyActive(
    'Moderately Active',
    'Banyak bergerak, berdiri saat kerja, atau aktif 3-5 hari/minggu.',
    1.55,
  ),
  veryActive(
    'Very Active',
    'Pekerjaan fisik aktif atau latihan intensif 6-7 hari/minggu.',
    1.725,
  ),
  extraActive(
    'Extra Active',
    'Pekerjaan fisik sangat berat atau atlet profesional 2x sehari.',
    1.9,
  );

  final String title;
  final String description;
  final double multiplier;

  const ActivityLevel(this.title, this.description, this.multiplier);

  static ActivityLevel fromName(String name) {
    return ActivityLevel.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ActivityLevel.moderatelyActive,
    );
  }
}

/// Primary fitness goal driving calorie targets and workout intensity.
enum FitnessGoal {
  weightLoss(
    'Menurunkan Berat Badan',
    'Defisit kalori terkontrol untuk pembakaran lemak optimal.',
    -400, // Target defisit rata-rata 300-500 kkal
  ),
  maintain(
    'Mempertahankan Berat Badan',
    'Keseimbangan energi untuk menjaga berat badan dan kebugaran.',
    0,
  ),
  muscleBuilding(
    'Membangun Otot / Menaikkan Berat',
    'Surplus kalori terkontrol untuk mendukung hipertrofi otot.',
    250, // Target surplus rata-rata 150-300 kkal
  );

  final String title;
  final String description;
  final int calorieAdjustment;

  const FitnessGoal(this.title, this.description, this.calorieAdjustment);

  static FitnessGoal fromName(String name) {
    return FitnessGoal.values.firstWhere(
      (e) => e.name == name,
      orElse: () => FitnessGoal.maintain,
    );
  }
}

/// Workout experience level.
enum ExperienceLevel {
  beginner('Pemula', 'Baru mulai gym atau < 6 bulan latihan konsisten.'),
  intermediate('Menengah', 'Terbiasa dengan teknik angkat beban 6 bln - 2 thn.'),
  advanced('Lanjutan', 'Berpengalaman > 2 tahun dengan form & progressive overload terarah.');

  final String title;
  final String description;

  const ExperienceLevel(this.title, this.description);

  static ExperienceLevel fromName(String name) {
    return ExperienceLevel.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ExperienceLevel.beginner,
    );
  }
}
