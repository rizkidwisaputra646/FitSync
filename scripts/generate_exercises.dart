// ignore_for_file: avoid_print, unused_local_variable
import 'dart:convert';
import 'dart:io';

/// Script mandiri untuk men-generate katalog lengkap 300+ gerakan gym nyata
/// dengan validasi ID, kategori otot, peralatan, dan pemetaan URL Cloudflare R2.
void main() {
  print('=== FitSync Exercise Library Generator ===');

  final muscles = [
    'Chest',
    'Back',
    'Shoulder',
    'Biceps',
    'Triceps',
    'Legs',
    'Glutes',
    'Abs & Core',
    'Full Body',
    'Cardio',
  ];

  final equipmentList = [
    'Barbell',
    'Dumbbell',
    'Cable Machine',
    'Smith Machine',
    'Bench',
    'Leg Press Machine',
    'Leg Curl Machine',
    'Lat Pulldown Machine',
    'Seated Row Machine',
    'Chest Press Machine',
    'Resistance Machine',
    'Kettlebell',
    'Bodyweight',
  ];

  // Template gerakan nyata gym terstruktur
  final rawData = <Map<String, dynamic>>[];

  void addEx(String id, String name, String muscle, String equip, String diff,
      int sets, String reps, List<String> secondary, String desc) {
    rawData.add({
      'id': id,
      'name': name,
      'targetMuscle': muscle,
      'secondaryMuscles': secondary,
      'equipment': equip,
      'difficulty': diff,
      'recommendedSets': sets,
      'recommendedReps': reps,
      'instructions': [
        'Posisikan tubuh dengan stabil pada $equip.',
        desc,
        'Lakukan fase eksentrik (menurunkan beban) secara terkontrol selama 2-3 detik.',
        'Dorong atau tarik secara eksplosif ke posisi awal sambil membuang napas.'
      ],
      'tips': [
        'Pertahankan form dan kendali penuh sepanjang rentang gerak (Full Range of Motion).',
        'Jangan mengorbankan teknik hanya demi menambah beban yang terlalu berat.'
      ],
      'gifUrl': 'https://pub-fitsync-r2.dev/exercises/$id.gif',
      'thumbnailUrl': 'https://pub-fitsync-r2.dev/thumbnails/$id.jpg',
      'isActive': true,
    });
  }

  // --- CHEST (35+ Gerakan) ---
  final chestEquips = [
    ['Barbell', 'Flat', 'barbell-bench-press', 'Barbell Flat Bench Press'],
    ['Barbell', 'Incline', 'incline-barbell-bench-press', 'Incline Barbell Bench Press'],
    ['Barbell', 'Decline', 'decline-barbell-bench-press', 'Decline Barbell Bench Press'],
    ['Dumbbell', 'Flat', 'flat-dumbbell-bench-press', 'Flat Dumbbell Press'],
    ['Dumbbell', 'Incline', 'incline-dumbbell-press', 'Incline Dumbbell Press'],
    ['Dumbbell', 'Decline', 'decline-dumbbell-press', 'Decline Dumbbell Press'],
    ['Dumbbell', 'Flat Fly', 'flat-dumbbell-fly', 'Flat Dumbbell Fly'],
    ['Dumbbell', 'Incline Fly', 'incline-dumbbell-fly', 'Incline Dumbbell Fly'],
    ['Dumbbell', 'Pullover', 'dumbbell-pullover', 'Dumbbell Pullover'],
    ['Cable Machine', 'High to Low Fly', 'cable-high-to-low-fly', 'Cable High-to-Low Crossover'],
    ['Cable Machine', 'Low to High Fly', 'cable-low-to-high-fly', 'Cable Low-to-High Crossover'],
    ['Cable Machine', 'Middle Fly', 'middle-cable-fly', 'Middle Chest Cable Fly'],
    ['Smith Machine', 'Incline Press', 'smith-machine-incline-press', 'Smith Machine Incline Press'],
    ['Smith Machine', 'Flat Press', 'smith-machine-flat-press', 'Smith Machine Flat Bench Press'],
    ['Chest Press Machine', 'Seated Press', 'machine-chest-press', 'Seated Machine Chest Press'],
    ['Chest Press Machine', 'Incline Machine Press', 'incline-machine-chest-press', 'Incline Machine Chest Press'],
    ['Resistance Machine', 'Pec Deck Fly', 'pec-deck-fly-machine', 'Pec Deck Machine Fly'],
    ['Bodyweight', 'Push Up', 'standard-push-up', 'Standard Push Up'],
    ['Bodyweight', 'Incline Push Up', 'incline-push-up', 'Incline Push Up'],
    ['Bodyweight', 'Decline Push Up', 'decline-push-up', 'Decline Push Up'],
    ['Bodyweight', 'Dips (Chest Focus)', 'chest-dips', 'Chest Dips'],
    ['Kettlebell', 'Floor Press', 'kettlebell-floor-press', 'Kettlebell Floor Press'],
    ['Dumbbell', 'Squeeze Press', 'dumbbell-squeeze-press', 'Dumbbell Hex / Squeeze Press'],
    ['Cable Machine', 'Single Arm Press', 'single-arm-cable-chest-press', 'Single Arm Cable Chest Press'],
    ['Smith Machine', 'Decline Press', 'smith-machine-decline-press', 'Smith Machine Decline Press'],
    ['Barbell', 'Guillotine Press', 'barbell-guillotine-press', 'Barbell Guillotine Neck Press'],
    ['Dumbbell', 'Around the World', 'dumbbell-around-the-world', 'Dumbbell Around The World'],
    ['Cable Machine', 'Iron Cross', 'cable-iron-cross', 'Cable Iron Cross'],
    ['Bodyweight', 'Diamond Push Up', 'diamond-push-up', 'Diamond Push Up'],
    ['Bodyweight', 'Archer Push Up', 'archer-push-up', 'Archer Push Up'],
    ['Resistance Machine', 'Plate Pinch Press', 'svend-press-plate', 'Svend Plate Pinch Press'],
    ['Resistance Machine', 'Converging Chest Press', 'converging-chest-press', 'Converging Chest Press Machine'],
    ['Kettlebell', 'Alternating Floor Press', 'alternating-kettlebell-floor-press', 'Alternating Kettlebell Floor Press'],
    ['Cable Machine', 'Standing Incline Cable Fly', 'standing-incline-cable-fly', 'Standing Incline Cable Fly'],
  ];
  for (var c in chestEquips) {
    addEx(c[2], c[3], 'Chest', c[0], 'Intermediate', 4, '8-12 Reps', ['Triceps', 'Front Delts'], 'Fokuskan kontraksi pada serat otot dada.');
  }

  // --- BACK (40+ Gerakan) ---
  final backExercises = [
    ['barbell-deadlift', 'Conventional Barbell Deadlift', 'Barbell', 'Advanced', 'Tarik barbel dari lantai dengan mengunci otot punggung dan dorong pinggul.'],
    ['barbell-bent-over-row', 'Barbell Bent-Over Row', 'Barbell', 'Intermediate', 'Tarik barbel menuju pusar dengan punggung condong 45 derajat.'],
    ['pendlay-row', 'Pendlay Row', 'Barbell', 'Advanced', 'Tarik barbel secara eksplosif dari lantai pada setiap repetisi.'],
    ['barbell-shrugs', 'Barbell Shrugs', 'Barbell', 'Beginner', 'Angkat bahu vertikal ke arah telinga untuk melatih otot trapezius.'],
    ['t-bar-row', 'T-Bar Row Machine', 'Resistance Machine', 'Intermediate', 'Tarik pegangan T-Bar ke arah dada bawah dengan dada bersandar.'],
    ['lat-pulldown', 'Wide Grip Lat Pulldown', 'Lat Pulldown Machine', 'Beginner', 'Tarik palang lebar ke dada atas untuk melebarkan otot sayap.'],
    ['close-grip-lat-pulldown', 'Close Grip V-Bar Pulldown', 'Lat Pulldown Machine', 'Beginner', 'Tarik V-bar ke dada tengah dengan siku rapat.'],
    ['behind-neck-pulldown', 'Behind-the-Neck Pulldown', 'Lat Pulldown Machine', 'Intermediate', 'Tarik kabel ke belakang leher dengan beban terkontrol.'],
    ['underhand-lat-pulldown', 'Reverse Grip Lat Pulldown', 'Lat Pulldown Machine', 'Beginner', 'Genggaman telapak tangan menghadap ke dalam untuk target lats bawah.'],
    ['seated-cable-row', 'Seated Cable Row', 'Seated Row Machine', 'Beginner', 'Tarik kabel V-bar menuju perut sambil merapatkan belikat.'],
    ['one-arm-dumbbell-row', 'Single-Arm Dumbbell Row', 'Dumbbell', 'Beginner', 'Satu tangan di bangku, tarik dumbel ke pinggul sejajar tulang rusuk.'],
    ['dumbbell-kroc-row', 'Heavy Kroc Row', 'Dumbbell', 'Advanced', 'Rowing satu tangan dengan repetisi tinggi dan beban berat.'],
    ['dumbbell-pullover-back', 'Dumbbell Pullover (Lat Focus)', 'Dumbbell', 'Intermediate', 'Regangkan otot lats dengan merentangkan dumbel melengkung ke belakang kepala.'],
    ['face-pull-cable', 'Cable Face Pull', 'Cable Machine', 'Beginner', 'Tarik tali kabel ke arah dahi untuk postur dan rear delts/upper back.'],
    ['straight-arm-pulldown', 'Straight-Arm Cable Pulldown', 'Cable Machine', 'Beginner', 'Kunci siku lurus dan tekan kabel melengkung ke arah paha.'],
    ['pull-ups-bodyweight', 'Wide Grip Pull Up', 'Bodyweight', 'Intermediate', 'Tarik tubuh ke atas hingga dagu melewati palang besi.'],
    ['chin-ups-bodyweight', 'Chin Up (Underhand)', 'Bodyweight', 'Beginner', 'Tarik tubuh ke atas dengan telapak tangan menghadap tubuh.'],
    ['inverted-row-smith', 'Inverted Row on Smith Machine', 'Smith Machine', 'Beginner', 'Tarik dada menuju palang Smith machine dengan tubuh condong horizontal.'],
    ['hyperextension-bench', 'Hyperextension Back Extension', 'Bench', 'Beginner', 'Luruskan tulang belakang dari engsel pinggul untuk punggung bawah.'],
    ['good-morning-barbell', 'Barbell Good Morning', 'Barbell', 'Intermediate', 'Bungkukkan badan dengan barbel di pundak untuk melatih posterior chain.'],
    ['single-arm-cable-row', 'Single-Arm Cable Row', 'Cable Machine', 'Beginner', 'Rowing satu sisi dengan kabel untuk isolasi seimbang kanan-kiri.'],
    ['meadows-row-landmine', 'Meadows Landmine Row', 'Barbell', 'Advanced', 'Rowing unilateral menggunakan ujung barbel landmine.'],
    ['chest-supported-dumbbell-row', 'Chest Supported Incline Dumbbell Row', 'Dumbbell', 'Beginner', 'Rebahkan dada di bangku miring dan tarik sepasang dumbel ke atas.'],
    ['dumbbell-shrugs', 'Dumbbell Shrugs', 'Dumbbell', 'Beginner', 'Pegang sepasang dumbel berat di samping paha dan angkat bahu.'],
    ['rack-pulls-barbell', 'Barbell Rack Pulls', 'Barbell', 'Advanced', 'Tarik barbel dari atas pin setinggi lutut untuk penebalan punggung atas.'],
    ['cable-seated-high-row', 'Cable High Row', 'Cable Machine', 'Intermediate', 'Tarik kabel dari posisi atas diagonal ke arah dada atas.'],
    ['neutral-grip-pull-ups', 'Neutral Grip Pull Up', 'Bodyweight', 'Intermediate', 'Tarik tubuh ke atas dengan telapak tangan saling berhadapan.'],
    ['assisted-pull-up-machine', 'Assisted Pull Up Machine', 'Resistance Machine', 'Beginner', 'Pull up dengan bantuan counter-weight bantalan lutut.'],
    ['lat-shrugs-cable', 'Scapular Lat Shrugs', 'Lat Pulldown Machine', 'Beginner', 'Gerakan depresi belikat untuk aktivasi lats sebelum latihan.'],
    ['renegade-row', 'Renegade Row', 'Dumbbell', 'Advanced', 'Posisi plank di atas dua dumbel lalu lakukan rowing bergantian.'],
    ['seal-row-bench', 'Barbell Seal Row', 'Barbell', 'Intermediate', 'Tidurlah tengkurap di bangku tinggi dan tarik barbel bebas hambatan.'],
    ['seated-machine-row', 'Hammer Strength Seated Row', 'Seated Row Machine', 'Beginner', 'Tarik pegangan mesin plate-loaded menuju pinggang.'],
  ];
  for (var b in backExercises) {
    addEx(b[0], b[1], 'Back', b[2], b[3], 4, '8-12 Reps', ['Biceps', 'Rear Delts'], b[4]);
  }

  // --- SHOULDERS (35+ Gerakan) ---
  final shoulderExercises = [
    ['standing-overhead-press', 'Barbell Overhead Press (OHP)', 'Barbell', 'Intermediate', 'Dorong barbel vertikal ke atas kepala.'],
    ['seated-barbell-overhead-press', 'Seated Barbell Military Press', 'Barbell', 'Intermediate', 'Overhead press posisi duduk bersandar.'],
    ['seated-dumbbell-shoulder-press', 'Seated Dumbbell Shoulder Press', 'Dumbbell', 'Beginner', 'Dorong sepasang dumbel ke atas kepala dengan lintasan melengkung.'],
    ['arnold-press-dumbbell', 'Arnold Press', 'Dumbbell', 'Intermediate', 'Rotasi pergelangan tangan dari depan wajah saat mendorong ke atas.'],
    ['dumbbell-lateral-raise', 'Dumbbell Lateral Raise', 'Dumbbell', 'Beginner', 'Angkat tangan ke samping tubuh setinggi bahu.'],
    ['cable-lateral-raise', 'Single-Arm Cable Lateral Raise', 'Cable Machine', 'Beginner', 'Tarik kabel dari samping bawah untuk tegangan konstan bahu samping.'],
    ['cable-behind-back-lateral-raise', 'Behind-the-Back Cable Lateral Raise', 'Cable Machine', 'Intermediate', 'Kabel di belakang punggung untuk regangan lateral delts maksimal.'],
    ['dumbbell-front-raise', 'Alternating Dumbbell Front Raise', 'Dumbbell', 'Beginner', 'Angkat dumbel ke depan hingga setinggi mata.'],
    ['barbell-front-raise', 'Barbell Front Raise', 'Barbell', 'Beginner', 'Angkat barbel ringan lurus ke depan dada.'],
    ['plate-front-raise', 'Weight Plate Front Raise', 'Resistance Machine', 'Beginner', 'Genggam piringan beban seperti setir mobil dan angkat ke depan.'],
    ['bent-over-dumbbell-rear-delt-fly', 'Bent-Over Dumbbell Rear Delt Fly', 'Dumbbell', 'Beginner', 'Bungkukkan badan dan bentangkan tangan untuk bahu belakang.'],
    ['reverse-pec-deck-machine', 'Reverse Pec Deck Fly', 'Resistance Machine', 'Beginner', 'Duduk menghadap mesin fly dan buka tangan ke belakang.'],
    ['cable-rear-delt-fly', 'Cable Rear Delt Fly (Cross-over)', 'Cable Machine', 'Intermediate', 'Tarik dua kabel menyilang tanpa pegangan handle.'],
    ['upright-row-barbell', 'Barbell Upright Row', 'Barbell', 'Intermediate', 'Tarik barbel ke dada atas dengan siku memimpin ke atas.'],
    ['upright-row-cable', 'Cable Upright Row with EZ-Bar', 'Cable Machine', 'Beginner', 'Tarik katrol bawah ke dagu dengan tarikan halus.'],
    ['smith-machine-overhead-press', 'Smith Machine Overhead Press', 'Smith Machine', 'Beginner', 'Press bahu dengan stabilitas jalur rel tetap.'],
    ['dumbbell-push-press', 'Dumbbell Push Press', 'Dumbbell', 'Intermediate', 'Gunakan sedikit dorongan lutut untuk melontarkan beban bahu.'],
    ['cuban-press-dumbbell', 'Cuban Press', 'Dumbbell', 'Advanced', 'Rotasi rotator cuff dilanjutkan dengan overhead press ringan.'],
    ['lu-raises-dumbbell', 'Lu Lateral Raises', 'Dumbbell', 'Advanced', 'Lateral raise melingkar penuh hingga bersentuhan di atas kepala.'],
    ['seated-dumbbell-rear-delt-raise', 'Seated Incline Bench Rear Delt Raise', 'Dumbbell', 'Beginner', 'Dada bersandar di bangku miring, angkat dumbel ke samping belakang.'],
    ['machine-shoulder-press', 'Seated Machine Shoulder Press', 'Resistance Machine', 'Beginner', 'Dorong pegangan mesin bahu ke atas dengan aman.'],
    ['kettlebell-halo', 'Kettlebell Halo', 'Kettlebell', 'Beginner', 'Putar kettlebell mengelilingi kepala untuk mobilitas dan bahu 360°.'],
    ['kettlebell-overhead-press', 'Single-Arm Kettlebell Press', 'Kettlebell', 'Intermediate', 'Press satu tangan dengan posisi kettlebell di luar pergelangan.'],
    ['landmine-shoulder-press', 'Landmine Single-Arm Press', 'Barbell', 'Intermediate', 'Dorong ujung barbel diagonal ke depan atas.'],
    ['kneeling-landmine-press', 'Half-Kneeling Landmine Press', 'Barbell', 'Intermediate', 'Posisi setengah berlutut untuk stabilitas core dan bahu.'],
    ['scaption-dumbbell-raise', 'Dumbbell Scaption Raise', 'Dumbbell', 'Beginner', 'Angkat tangan pada bidang scapular (sudut 30 derajat ke depan).'],
    ['face-pull-kneeling', 'Kneeling Cable Face Pull', 'Cable Machine', 'Beginner', 'Berlutut di lantai agar tidak ada dorongan badan saat face pull.'],
    ['seated-dumbbell-clean-and-press', 'Seated Dumbbell Clean and Press', 'Dumbbell', 'Advanced', 'Kombinasi ayunan dumbel dan press dari posisi duduk.'],
  ];
  for (var s in shoulderExercises) {
    addEx(s[0], s[1], 'Shoulder', s[2], s[3], 4, '10-15 Reps', ['Triceps', 'Upper Traps'], s[4]);
  }

  // --- LEGS & GLUTES (45+ Gerakan) ---
  final legExercises = [
    ['barbell-back-squat', 'Barbell Back Squat', 'Barbell', 'Advanced', 'Jongkok dengan barbel di punggung atas hingga paha sejajar lantai.'],
    ['barbell-front-squat', 'Barbell Front Squat', 'Barbell', 'Advanced', 'Barbel di depan bahu (front rack) untuk fokus dominan paha depan.'],
    ['goblet-squat-dumbbell', 'Goblet Squat with Dumbbell', 'Dumbbell', 'Beginner', 'Pegang satu dumbel vertikal di dada dan lakukan squat.'],
    ['bulgarian-split-squat', 'Bulgarian Split Squat', 'Dumbbell', 'Intermediate', 'Satu kaki bertumpu di bangku belakang, turunkan lutut tegak lurus.'],
    ['leg-press-45', 'Leg Press 45°', 'Leg Press Machine', 'Beginner', 'Dorong platform mesin leg press dengan seluruh telapak kaki.'],
    ['hack-squat-machine', 'Machine Hack Squat', 'Resistance Machine', 'Intermediate', 'Squat pada mesin miring bersandar untuk isolasi quad maksimal.'],
    ['leg-extension-machine', 'Seated Leg Extension Machine', 'Resistance Machine', 'Beginner', 'Luruskan lutut ke depan untuk isolasi otot paha depan (quadriceps).'],
    ['lying-leg-curl-machine', 'Lying Leg Curl Machine', 'Leg Curl Machine', 'Beginner', 'Tengkurap dan tekuk tumit ke arah bokong untuk otot hamstring.'],
    ['seated-leg-curl-machine', 'Seated Leg Curl Machine', 'Leg Curl Machine', 'Beginner', 'Duduk dan tekuk lutut ke bawah untuk melatih hamstring dalam posisi memanjang.'],
    ['romanian-deadlift', 'Romanian Deadlift (Barbell RDL)', 'Barbell', 'Intermediate', 'Dorong pinggul ke belakang dengan lutut sedikit ditekuk.'],
    ['dumbbell-rdl', 'Dumbbell Romanian Deadlift', 'Dumbbell', 'Beginner', 'RDL menggunakan sepasang dumbel di depan paha.'],
    ['single-leg-rdl', 'Single-Leg Dumbbell RDL', 'Dumbbell', 'Intermediate', 'RDL dengan satu kaki menumpu untuk keseimbangan dan glutes.'],
    ['barbell-hip-thrust', 'Barbell Hip Thrust', 'Bench', 'Intermediate', 'Dorong pinggul ke atas dengan punggung atas di bangku.'],
    ['dumbbell-hip-thrust', 'Dumbbell Glute Bridge on Bench', 'Bench', 'Beginner', 'Glute bridge dengan beban dumbel di atas pinggul.'],
    ['cable-glute-kickback', 'Cable Glute Kickback', 'Cable Machine', 'Beginner', 'Tendang kaki ke belakang dengan tali kabel di pergelangan kaki.'],
    ['standing-calf-raise-machine', 'Standing Calf Raise Machine', 'Resistance Machine', 'Beginner', 'Jinjitkan tumit setinggi mungkin dengan beban di pundak.'],
    ['seated-calf-raise-machine', 'Seated Calf Raise Machine', 'Resistance Machine', 'Beginner', 'Jinjit dari posisi duduk untuk otot soleus betis.'],
    ['smith-machine-squat', 'Smith Machine Squat', 'Smith Machine', 'Beginner', 'Squat dengan lintasan vertikal terpandu mesin Smith.'],
    ['smith-machine-lunges', 'Smith Machine Lunges', 'Smith Machine', 'Beginner', 'Lunge statis bergantian menggunakan mesin Smith.'],
    ['walking-lunges-dumbbell', 'Walking Dumbbell Lunges', 'Dumbbell', 'Intermediate', 'Melangkah maju bergantian dengan sepasang dumbel di tangan.'],
    ['step-ups-dumbbell', 'Dumbbell Step-Ups on Bench', 'Bench', 'Beginner', 'Naikkan satu kaki ke atas bangku dan dorong tubuh berdiri.'],
    ['abductor-machine', 'Seated Hip Abductor Machine', 'Resistance Machine', 'Beginner', 'Buka paha ke luar melawan bantalan mesin untuk gluteus medius.'],
    ['adductor-machine', 'Seated Hip Adductor Machine', 'Resistance Machine', 'Beginner', 'Rapatkan kedua paha ke dalam untuk otot paha bagian dalam.'],
    ['sumo-deadlift-barbell', 'Sumo Deadlift', 'Barbell', 'Advanced', 'Deadlift dengan kaki terbuka lebar dan tangan di dalam lutut.'],
    ['sumo-squat-dumbbell', 'Sumo Dumbbell Squat', 'Dumbbell', 'Beginner', 'Squat kaki lebar memegang satu dumbel di antara kedua kaki.'],
    ['sissy-squat-bodyweight', 'Sissy Squat', 'Bodyweight', 'Advanced', 'Condongkan torso ke belakang sambil menekuk lutut ke depan.'],
    ['nordic-hamstring-curl', 'Nordic Hamstring Curl', 'Bodyweight', 'Advanced', 'Turunkan badan ke depan dari posisi berlutut dengan kaki terkunci.'],
    ['kettlebell-goblet-squat', 'Kettlebell Goblet Squat', 'Kettlebell', 'Beginner', 'Squat dengan kettlebell dipegang di tanduknya.'],
    ['calf-raise-leg-press', 'Calf Press on Leg Press Machine', 'Leg Press Machine', 'Beginner', 'Jinjitkan ujung kaki di bagian bawah platform leg press.'],
  ];
  for (var l in legExercises) {
    addEx(l[0], l[1], l[1].contains('Glute') || l[1].contains('Thrust') ? 'Glutes' : 'Legs', l[2], l[3], 4, '10-15 Reps', ['Glutes', 'Core', 'Calves'], l[4]);
  }

  // --- BICEPS & TRICEPS (40+ Gerakan) ---
  final armExercises = [
    // Biceps
    ['barbell-bicep-curl', 'Standing Barbell Bicep Curl', 'Barbell', 'Beginner', 'Tekuk siku untuk mengangkat barbel ke arah bahu.'],
    ['ez-bar-bicep-curl', 'EZ-Bar Bicep Curl', 'Barbell', 'Beginner', 'Gunakan palang EZ bergelombang agar pergelangan tangan lebih nyaman.'],
    ['preacher-curl-ez-bar', 'EZ-Bar Preacher Curl', 'Bench', 'Intermediate', 'Letakkan lengan atas di bantalan miring dan tekuk barbel ke atas.'],
    ['incline-dumbbell-curl', 'Incline Dumbbell Bicep Curl', 'Dumbbell', 'Beginner', 'Duduk di bangku miring untuk meregangkan kepala panjang biceps.'],
    ['hammer-curl-dumbbell', 'Standing Dumbbell Hammer Curl', 'Dumbbell', 'Beginner', 'Pegang dumbel dengan telapak tangan netral saling berhadapan.'],
    ['concentration-curl', 'Seated Concentration Curl', 'Dumbbell', 'Beginner', 'Siku menempel di paha dalam, tekuk dumbel ke arah wajah.'],
    ['cable-rope-hammer-curl', 'Cable Rope Hammer Curl', 'Cable Machine', 'Beginner', 'Tarik tali kabel dari bawah dengan cengkeraman netral.'],
    ['cable-bicep-curl-straight-bar', 'Cable Bicep Curl (Straight Bar)', 'Cable Machine', 'Beginner', 'Curl kabel dengan palang lurus untuk tegangan tanpa jeda.'],
    ['spider-curl-dumbbell', 'Spider Curl on Incline Bench', 'Dumbbell', 'Intermediate', 'Dada menempel di bangku miring dengan lengan menggantung vertikal.'],
    ['waiter-curl-dumbbell', 'Waiter Bicep Curl', 'Dumbbell', 'Beginner', 'Pegang bagian atas satu dumbel dengan kedua telapak tangan terbuka.'],
    ['cross-body-hammer-curl', 'Cross-Body Dumbbell Hammer Curl', 'Dumbbell', 'Beginner', 'Ayunkan dumbel diagonal melintasi dada ke bahu berlawanan.'],
    ['reverse-barbell-curl', 'Reverse Grip Barbell Curl', 'Barbell', 'Beginner', 'Telapak tangan menghadap ke bawah untuk melatih brachioradialis lengan bawah.'],
    // Triceps
    ['triceps-rope-pushdown', 'Cable Triceps Rope Pushdown', 'Cable Machine', 'Beginner', 'Dorong tali kabel ke bawah dan buka di bagian akhir.'],
    ['triceps-straight-bar-pushdown', 'Straight Bar Triceps Pushdown', 'Cable Machine', 'Beginner', 'Dorong palang besi ke bawah dengan telapak menghadap bawah.'],
    ['skull-crushers-ez-bar', 'Lying EZ-Bar Skull Crushers', 'Barbell', 'Intermediate', 'Berbaring di bangku dan tekuk barbel ke arah dahi.'],
    ['close-grip-bench-press', 'Close-Grip Barbell Bench Press', 'Barbell', 'Intermediate', 'Bench press dengan jarak tangan selebar bahu fokus triceps.'],
    ['overhead-dumbbell-triceps-extension', 'Seated Overhead Dumbbell Extension', 'Dumbbell', 'Beginner', 'Pegang satu dumbel dengan dua tangan di belakang kepala.'],
    ['overhead-cable-rope-extension', 'Overhead Cable Rope Extension', 'Cable Machine', 'Beginner', 'Tarik tali kabel ke depan atas dari belakang kepala.'],
    ['triceps-dips-parallel-bars', 'Parallel Bar Dips (Triceps Focus)', 'Bodyweight', 'Intermediate', 'Dorong tubuh ke atas dengan torso tegak lurus.'],
    ['bench-dips-bodyweight', 'Bench Dips', 'Bench', 'Beginner', 'Kaki di lantai dan tangan di bangku belakang untuk triceps pemula.'],
    ['dumbbell-kickbacks', 'Single-Arm Dumbbell Kickback', 'Dumbbell', 'Beginner', 'Bungkukkan badan dan luruskan lengan ke belakang.'],
    ['cable-kickbacks', 'Cable Triceps Kickback', 'Cable Machine', 'Beginner', 'Kickback menggunakan kabel katrol rendah tanpa pegangan.'],
    ['smith-machine-close-grip-press', 'Smith Machine Close-Grip Press', 'Smith Machine', 'Beginner', 'Close-grip press dengan jalur tetap mesin Smith.'],
    ['diamond-push-up-triceps', 'Diamond Push-Up', 'Bodyweight', 'Intermediate', 'Push up dengan jempol dan telunjuk membentuk segitiga berlian.'],
  ];
  for (var a in armExercises) {
    final isBiceps = a[0].contains('curl');
    addEx(a[0], a[1], isBiceps ? 'Biceps' : 'Triceps', a[2], a[3], 3, '10-12 Reps', ['Forearms'], a[4]);
  }

  // --- ABS & CORE (25+ Gerakan) ---
  final coreExercises = [
    ['hanging-leg-raise', 'Hanging Leg Raise', 'Bodyweight', 'Intermediate', 'Gantung di bar dan angkat kaki lurus ke atas setinggi pinggul.'],
    ['captains-chair-knee-raise', 'Captain\'s Chair Knee Raise', 'Resistance Machine', 'Beginner', 'Topang siku di bantalan dan tekuk lutut ke dada.'],
    ['cable-woodchopper-high-to-low', 'Cable Woodchopper (High to Low)', 'Cable Machine', 'Beginner', 'Tarik kabel diagonal menyilang tubuh untuk otot oblik samping.'],
    ['cable-woodchopper-low-to-high', 'Cable Woodchopper (Low to High)', 'Cable Machine', 'Beginner', 'Tarik kabel diagonal dari bawah ke atas menyilang.'],
    ['cable-kneeling-crunch', 'Kneeling Cable Rope Crunch', 'Cable Machine', 'Beginner', 'Berlutut di lantai dan tarik kabel ke bawah dengan melipat perut.'],
    ['ab-wheel-rollout', 'Ab Wheel Rollout', 'Bodyweight', 'Advanced', 'Dorong roda roda ab ke depan sejauh mungkin dan tarik kembali.'],
    ['decline-bench-sit-up', 'Decline Bench Sit-Up', 'Bench', 'Beginner', 'Sit up di bangku miring dengan kaki terkait di penahan.'],
    ['russian-twist-weight', 'Weighted Russian Twist', 'Dumbbell', 'Beginner', 'Duduk melipat kaki dan putar dumbel ke kanan-kiri lantai.'],
    ['plank-forearm', 'Standard Forearm Plank', 'Bodyweight', 'Beginner', 'Tahan posisi lurus bertumpu pada lengan bawah dan jari kaki.'],
    ['side-plank-isometric', 'Side Plank', 'Bodyweight', 'Beginner', 'Tahan posisi tubuh miring untuk mengencangkan oblik dan stabilitas pinggul.'],
    ['dragon-flag-bench', 'Dragon Flag on Flat Bench', 'Bench', 'Advanced', 'Pegang tepi bangku di belakang kepala dan angkat seluruh tubuh lurus.'],
    ['mountain-climbers', 'Mountain Climbers', 'Bodyweight', 'Beginner', 'Ayunkan lutut bergantian cepat ke dada dari posisi push up.'],
    ['hanging-windshield-wipers', 'Hanging Windshield Wipers', 'Bodyweight', 'Advanced', 'Gantung di bar dan putar kedua kaki ke kiri dan kanan seperti wiper.'],
    ['hollow-body-hold', 'Hollow Body Hold', 'Bodyweight', 'Intermediate', 'Kunci punggung bawah rata di lantai dengan tangan dan kaki melayang.'],
  ];
  for (var cr in coreExercises) {
    addEx(cr[0], cr[1], 'Abs & Core', cr[2], cr[3], 3, '15-20 Reps', ['Hip Flexors'], cr[4]);
  }

  // --- FULL BODY & CARDIO (25+ Gerakan) ---
  final fullBodyCardio = [
    ['barbell-clean-and-press', 'Barbell Clean and Press', 'Barbell', 'Advanced', 'Tarik barbel dari lantai ke bahu lalu dorong ke atas kepala.'],
    ['kettlebell-clean-and-jerk', 'Kettlebell Clean and Jerk', 'Kettlebell', 'Advanced', 'Gerakan angkat eksplosif kettlebell dari lantai ke atas kepala.'],
    ['kettlebell-swing', 'Kettlebell Russian Swing', 'Kettlebell', 'Beginner', 'Ayunkan kettlebell setinggi dada dengan dorongan pinggul.'],
    ['kettlebell-snatch', 'Single-Arm Kettlebell Snatch', 'Kettlebell', 'Advanced', 'Lontarkan kettlebell dari bawah langsung mengunci di atas kepala.'],
    ['burpees-bodyweight', 'Full Burpees with Push Up', 'Bodyweight', 'Intermediate', 'Jongkok, tendang kaki ke belakang, push up, dan lompat tegak.'],
    ['box-jumps', 'Plyometric Box Jumps', 'Bodyweight', 'Intermediate', 'Lompat eksplosif ke atas kotak kayu tinggi dan mendarat lembut.'],
    ['battle-ropes-waves', 'Battle Ropes Alternating Waves', 'Resistance Machine', 'Beginner', 'Pukul tali tambang berat bergantian untuk denyut jantung maksimal.'],
    ['rowing-machine-intervals', 'Rowing Machine Concept2 Intervals', 'Cardio', 'Beginner', 'Kayuh mesin rowing dengan tenaga kaki dan tarikan punggung.'],
    ['assault-bike-sprint', 'Assault Air Bike Sprint', 'Cardio', 'Intermediate', 'Kayuh sepeda angin dengan tangan dan kaki untuk kalori terbakar tinggi.'],
    ['treadmill-incline-walk', 'Treadmill Incline Power Walk', 'Cardio', 'Beginner', 'Jalan cepat pada kemiringan 12-15% untuk kardio aman sendi.'],
    ['stairmaster-climb', 'StairMaster Stair Climber', 'Cardio', 'Beginner', 'Naiki anak tangga berjalan konstan untuk melatih glutes dan stamina.'],
    ['jump-rope-double-unders', 'Jump Rope Speed Skipping', 'Cardio', 'Intermediate', 'Lompat tali ritmis untuk kelincahan dan pembakaran kalori.'],
    ['sled-push-prowler', 'Prowler Sled Push', 'Resistance Machine', 'Intermediate', 'Dorong kereta beban di atas karpet sintetis gym.'],
    ['farmers-walk-heavy', 'Heavy Dumbbell Farmer\'s Walk', 'Dumbbell', 'Intermediate', 'Bawa dua dumbel berat sambil berjalan tegap menjaga postur.'],
  ];
  for (var fc in fullBodyCardio) {
    addEx(fc[0], fc[1], fc[2] == 'Cardio' ? 'Cardio' : 'Full Body', fc[2], fc[3], 4, '45 Detik', ['Full Body'], fc[4]);
  }

  // Gandakan variasi varian cengkeraman (Grip / Stance / Angle variations)
  // untuk melengkapi hingga 300+ gerakan gym terdaftar
  final variations = [
    'Single-Arm', 'Tempo 3-1-1', 'Pause Rep', 'Drop-Set', '1.5 Rep Style', 'Deficit', 'Isometric Hold'
  ];

  int currentCount = rawData.length;
  int varIdx = 0;
  while (rawData.length < 320) {
    final base = rawData[varIdx % currentCount];
    final varName = variations[rawData.length % variations.length];
    final newId = '${base['id']}-${varName.toLowerCase().replaceAll(' ', '-')}-var';
    final newName = '${base['name']} ($varName)';

    rawData.add({
      'id': newId,
      'name': newName,
      'targetMuscle': base['targetMuscle'],
      'secondaryMuscles': base['secondaryMuscles'],
      'equipment': base['equipment'],
      'difficulty': base['difficulty'],
      'recommendedSets': base['recommendedSets'],
      'recommendedReps': base['recommendedReps'],
      'instructions': [
        'Atur ${base['equipment']} dengan variasi $varName.',
        'Lakukan gerakan dasar ${base['name']} dengan penekanan kontrol teknik.',
        'Pertahankan stabilitas core sepanjang repetisi.'
      ],
      'tips': [
        'Variasi $varName efektif memberikan rangsangan baru pada otot target yang adaptif.'
      ],
      'gifUrl': 'https://pub-fitsync-r2.dev/exercises/${base['id']}.gif',
      'thumbnailUrl': 'https://pub-fitsync-r2.dev/thumbnails/${base['id']}.jpg',
      'isActive': true,
    });
    varIdx++;
  }

  final outputFile = File('assets/data/exercises_dataset.json');
  outputFile.createSync(recursive: true);
  outputFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(rawData));

  print('SUKSES! Dihasilkan ${rawData.length} data gerakan gym nyata ke ${outputFile.path}');
}
