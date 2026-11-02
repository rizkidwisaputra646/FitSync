class MembershipPlan {
  final String id;
  final String name;
  final String badge;
  final int price;
  final String formattedPrice;
  final String periodLabel;
  final int durationDays;
  final int durationHours;
  final String description;
  final List<String> features;
  final bool isPopular;

  const MembershipPlan({
    required this.id,
    required this.name,
    required this.badge,
    required this.price,
    required this.formattedPrice,
    required this.periodLabel,
    required this.durationDays,
    required this.durationHours,
    required this.description,
    required this.features,
    this.isPopular = false,
  });

  /// Dua paket utama membership FitSync sesuai instruksi pengguna:
  /// 1. Member Harian (Daily Pass) - 1 Hari (24 Jam)
  /// 2. Member 1 Bulan (Monthly Pass) - 30 Hari
  static const List<MembershipPlan> presetPlans = [
    MembershipPlan(
      id: 'daily-pass',
      name: 'Member Harian',
      badge: 'DAILY PASS',
      price: 35000,
      formattedPrice: 'Rp 35.000',
      periodLabel: '/ 24 Jam',
      durationDays: 1,
      durationHours: 24,
      description:
          'Akses fleksibel satu hari penuh tanpa komitmen jangka panjang. Sempurna untuk drop-in latihan atau mencoba fasilitas.',
      features: [
        'Akses penuh gym floor & area kardio 24 jam',
        'Loker harian & shower room air panas',
        'Gratis air minum isi ulang (water refill)',
        'Check-in instan dengan Kode QR Dinamis',
        'Bebas gunakan semua alat gym & beban bebas',
      ],
      isPopular: false,
    ),
    MembershipPlan(
      id: 'monthly-pass',
      name: 'Member 1 Bulan',
      badge: 'PILIHAN TERPOPULER',
      price: 250000,
      formattedPrice: 'Rp 250.000',
      periodLabel: '/ Bulan',
      durationDays: 30,
      durationHours: 720,
      description:
          'Investasi kebugaran terbaik selama 30 hari penuh. Akses tanpa batas setiap hari ke seluruh zona gym dan fasilitas premium.',
      features: [
        'Akses tak terbatas selama 30 hari penuh',
        'Semua zona: Free weights, machine gym & cardio',
        'Loker pribadi, shower air panas & handuk bersih',
        'Free Wi-Fi ultra cepat di seluruh area gym',
        '1x Sesi konsultasi program latihan & kalkulator MSJ',
        'Diskon 10% FitSync merchandise & protein lounge',
      ],
      isPopular: true,
    ),
  ];

  static MembershipPlan getById(String id) {
    return presetPlans.firstWhere(
      (p) => p.id == id,
      orElse: () => presetPlans.first,
    );
  }
}
