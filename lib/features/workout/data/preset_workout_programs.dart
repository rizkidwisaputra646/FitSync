import '../../../models/fitness_enums.dart';
import '../../../models/workout_program.dart';

class PresetWorkoutPrograms {
  PresetWorkoutPrograms._();

  static WorkoutProgram getProgramForGoal({
    required FitnessGoal goal,
    required ExperienceLevel level,
  }) {
    switch (goal) {
      case FitnessGoal.muscleBuilding:
        return _buildHypertrophyPPL(level);
      case FitnessGoal.weightLoss:
        return _buildFatLossConditioning(level);
      case FitnessGoal.maintain:
        return _buildStrengthRecomp(level);
    }
  }

  // --- 1. MUSCLE BUILDING: 30-Day PPL (Push - Pull - Legs) ---
  static WorkoutProgram _buildHypertrophyPPL(ExperienceLevel level) {
    final sets = level == ExperienceLevel.advanced ? 4 : 3;

    final days = <ProgramDay>[];

    for (int day = 1; day <= 30; day++) {
      final cycleIndex = (day - 1) % 7; // 7-day microcycle

      switch (cycleIndex) {
        case 0: // Day 1, 8, 15, 22, 29: Push (Chest, Shoulders, Triceps)
          days.add(
            ProgramDay(
              dayNumber: day,
              title: 'Hari $day: Push Hypertrophy (Dada, Bahu & Triceps)',
              isRestDay: false,
              targetMuscles: ['Chest', 'Shoulder', 'Triceps'],
              description:
                  'Fokuskan dorongan beban terkontrol untuk stimulasi serat otot dada, deltoid depan/samping, dan triceps.',
              exercises: [
                ProgramExerciseItem(
                  exerciseId: 'barbell-bench-press',
                  exerciseName: 'Barbell Flat Bench Press',
                  targetMuscle: 'Chest',
                  targetSets: sets,
                  targetReps: '8-10',
                  restSeconds: 90,
                  notes: 'Kunci skapula ke belakang dan turunkan barbel hingga menyentuh dada tengah.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'incline-dumbbell-press',
                  exerciseName: 'Incline Dumbbell Press',
                  targetMuscle: 'Chest',
                  targetSets: sets,
                  targetReps: '10-12',
                  restSeconds: 75,
                  notes: 'Sudut bangku 30 derajat untuk dominasi dada bagian atas.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'seated-dumbbell-shoulder-press',
                  exerciseName: 'Seated Dumbbell Shoulder Press',
                  targetMuscle: 'Shoulder',
                  targetSets: sets,
                  targetReps: '10-12',
                  restSeconds: 75,
                  notes: 'Dorong ke atas kepala secara halus tanpa mengunci siku sepenuhnya di puncak.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'dumbbell-lateral-raise',
                  exerciseName: 'Dumbbell Lateral Raise',
                  targetMuscle: 'Shoulder',
                  targetSets: sets + 1,
                  targetReps: '12-15',
                  restSeconds: 60,
                  notes: 'Angkat dengan siku sedikit menekuk hingga setinggi bahu.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'triceps-rope-pushdown',
                  exerciseName: 'Cable Triceps Rope Pushdown',
                  targetMuscle: 'Triceps',
                  targetSets: sets,
                  targetReps: '12-15',
                  restSeconds: 60,
                  notes: 'Rentangkan ujung tali ke samping pada titik kontraksi bawah.',
                ),
              ],
            ),
          );
          break;

        case 1: // Day 2, 9, 16, 23, 30: Pull (Back, Biceps, Rear Delts)
          days.add(
            ProgramDay(
              dayNumber: day,
              title: 'Hari $day: Pull Hypertrophy (Punggung & Biceps)',
              isRestDay: false,
              targetMuscles: ['Back', 'Biceps', 'Shoulder'],
              description:
                  'Tarikan horizontal dan vertikal untuk membangun ketebalan dan lebar sayap punggung serta isolasi biceps.',
              exercises: [
                ProgramExerciseItem(
                  exerciseId: 'lat-pulldown',
                  exerciseName: 'Wide Grip Lat Pulldown',
                  targetMuscle: 'Back',
                  targetSets: sets,
                  targetReps: '10-12',
                  restSeconds: 90,
                  notes: 'Tarik palang ke dada atas dengan mengaktifkan otot lats, bukan lengan.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'barbell-bent-over-row',
                  exerciseName: 'Barbell Bent-Over Row',
                  targetMuscle: 'Back',
                  targetSets: sets,
                  targetReps: '8-10',
                  restSeconds: 90,
                  notes: 'Jaga punggung tetap lurus netral dan tarik barbel menuju pusar.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'seated-cable-row',
                  exerciseName: 'Seated Cable Row',
                  targetMuscle: 'Back',
                  targetSets: sets,
                  targetReps: '10-12',
                  restSeconds: 75,
                  notes: 'Rapatkan tulang belikat di titik puncak tarikan selama 1 detik.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'face-pull-cable',
                  exerciseName: 'Cable Face Pull',
                  targetMuscle: 'Shoulder',
                  targetSets: sets + 1,
                  targetReps: '12-15',
                  restSeconds: 60,
                  notes: 'Tarik ke arah dahi untuk kesehatan bahu belakang dan postur tegap.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'barbell-bicep-curl',
                  exerciseName: 'Standing Barbell Bicep Curl',
                  targetMuscle: 'Biceps',
                  targetSets: sets,
                  targetReps: '10-12',
                  restSeconds: 60,
                  notes: 'Kunci posisi siku di samping pinggang tanpa mengayunkan pinggul.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'hammer-curl-dumbbell',
                  exerciseName: 'Standing Dumbbell Hammer Curl',
                  targetMuscle: 'Biceps',
                  targetSets: sets,
                  targetReps: '12-15',
                  restSeconds: 60,
                  notes: 'Genggaman netral untuk melatih brachialis dan ketebalan lengan bawah.',
                ),
              ],
            ),
          );
          break;

        case 2: // Day 3, 10, 17, 24: Legs (Quads, Hamstrings, Calves)
          days.add(
            ProgramDay(
              dayNumber: day,
              title: 'Hari $day: Leg Power & Hypertrophy (Paha & Betis)',
              isRestDay: false,
              targetMuscles: ['Legs', 'Glutes'],
              description:
                  'Stimulasi pondasi tubuh bagian bawah untuk peningkatan massa otot dan pembakaran metabolik optimal.',
              exercises: [
                ProgramExerciseItem(
                  exerciseId: 'barbell-back-squat',
                  exerciseName: 'Barbell Back Squat',
                  targetMuscle: 'Legs',
                  targetSets: sets,
                  targetReps: '8-10',
                  restSeconds: 120,
                  notes: 'Turun hingga paha minimal sejajar lantai dengan dada tegap.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'leg-press-45',
                  exerciseName: 'Leg Press 45°',
                  targetMuscle: 'Legs',
                  targetSets: sets,
                  targetReps: '10-12',
                  restSeconds: 90,
                  notes: 'Posisikan telapak kaki selebar bahu dan dorong melalui tumit.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'romanian-deadlift',
                  exerciseName: 'Romanian Deadlift (Barbell RDL)',
                  targetMuscle: 'Legs',
                  targetSets: sets,
                  targetReps: '8-10',
                  restSeconds: 90,
                  notes: 'Dorong pinggul ke belakang hingga terasa regangan penuh pada otot hamstring.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'lying-leg-curl-machine',
                  exerciseName: 'Lying Leg Curl Machine',
                  targetMuscle: 'Legs',
                  targetSets: sets,
                  targetReps: '12-15',
                  restSeconds: 60,
                  notes: 'Tekuk tumit ke arah bokong dengan kontraksi terkendali.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'standing-calf-raise-machine',
                  exerciseName: 'Standing Calf Raise Machine',
                  targetMuscle: 'Legs',
                  targetSets: sets + 1,
                  targetReps: '15-20',
                  restSeconds: 45,
                  notes: 'Regangkan tumit ke bawah penuh lalu jinjit maksimal di puncak.',
                ),
              ],
            ),
          );
          break;

        case 3: // Day 4, 11, 18, 25: Rest & Recovery
          days.add(
            ProgramDay(
              dayNumber: day,
              title: 'Hari $day: Istirahat Aktif & Pemulihan Otot',
              isRestDay: true,
              targetMuscles: ['Rest'],
              description:
                  'Fase sintesis protein dan pemulihan sistem saraf pusat. Penuhi target protein harian, cukupi hidrasi air, dan tidur minimal 7-8 jam.',
            ),
          );
          break;

        case 4: // Day 5, 12, 19, 26: Upper Body Volume
          days.add(
            ProgramDay(
              dayNumber: day,
              title: 'Hari $day: Upper Body Volume (Dada, Punggung & Bahu)',
              isRestDay: false,
              targetMuscles: ['Chest', 'Back', 'Shoulder'],
              description:
                  'Kombinasi superset dada dan punggung untuk pompa darah maksimal dan simetri tubuh atas.',
              exercises: [
                ProgramExerciseItem(
                  exerciseId: 'flat-dumbbell-bench-press',
                  exerciseName: 'Flat Dumbbell Press',
                  targetMuscle: 'Chest',
                  targetSets: sets,
                  targetReps: '10-12',
                  restSeconds: 75,
                  notes: 'Rentang gerak lebih dalam dibandingkan barbel untuk regangan dada.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'one-arm-dumbbell-row',
                  exerciseName: 'Single-Arm Dumbbell Row',
                  targetMuscle: 'Back',
                  targetSets: sets,
                  targetReps: '10-12',
                  restSeconds: 75,
                  notes: 'Tarik dumbel ke pinggul tanpa merotasi badan berlebihan.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'pec-deck-fly-machine',
                  exerciseName: 'Pec Deck Machine Fly',
                  targetMuscle: 'Chest',
                  targetSets: sets,
                  targetReps: '12-15',
                  restSeconds: 60,
                  notes: 'Fokus isolasi jepitan dada di tengah.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'cable-seated-high-row',
                  exerciseName: 'Cable High Row',
                  targetMuscle: 'Back',
                  targetSets: sets,
                  targetReps: '12-15',
                  restSeconds: 60,
                  notes: 'Tarik ke dada atas untuk penebalan otot trapezius dan rhomboid.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'cable-lateral-raise',
                  exerciseName: 'Single-Arm Cable Lateral Raise',
                  targetMuscle: 'Shoulder',
                  targetSets: sets + 1,
                  targetReps: '12-15',
                  restSeconds: 45,
                  notes: 'Tegangan konstan sepanjang lintasan gerak bahu samping.',
                ),
              ],
            ),
          );
          break;

        case 5: // Day 6, 13, 20, 27: Lower Body & Abs
          days.add(
            ProgramDay(
              dayNumber: day,
              title: 'Hari $day: Lower Body Glutes & Core Strength',
              isRestDay: false,
              targetMuscles: ['Legs', 'Glutes', 'Abs & Core'],
              description:
                  'Penguatan paha, rantai posterior glutes, serta stabilitas dinding perut dan otot inti.',
              exercises: [
                ProgramExerciseItem(
                  exerciseId: 'barbell-hip-thrust',
                  exerciseName: 'Barbell Hip Thrust',
                  targetMuscle: 'Glutes',
                  targetSets: sets,
                  targetReps: '10-12',
                  restSeconds: 90,
                  notes: 'Kunci pinggul lurus di puncak dan tahan kontraksi 1-2 detik.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'goblet-squat-dumbbell',
                  exerciseName: 'Goblet Squat with Dumbbell',
                  targetMuscle: 'Legs',
                  targetSets: sets,
                  targetReps: '12-15',
                  restSeconds: 75,
                  notes: 'Pegang dumbel di dada, turunkan tubuh dengan posisi torso tegak.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'leg-extension-machine',
                  exerciseName: 'Seated Leg Extension Machine',
                  targetMuscle: 'Legs',
                  targetSets: sets,
                  targetReps: '12-15',
                  restSeconds: 60,
                  notes: 'Isolasi kontraksi paha depan quad di titik tertinggi.',
                ),
                ProgramExerciseItem(
                  exerciseId: 'hanging-leg-raise',
                  exerciseName: 'Hanging Leg Raise',
                  targetMuscle: 'Abs & Core',
                  targetSets: 3,
                  targetReps: '12-15',
                  restSeconds: 60,
                  notes: 'Angkat lutut atau kaki ke arah dada tanpa mengayunkan momentum.',
                ),
              ],
            ),
          );
          break;

        case 6: // Day 7, 14, 21, 28: Rest Day
        default:
          days.add(
            ProgramDay(
              dayNumber: day,
              title: 'Hari $day: Rest & Pemulihan Mingguan',
              isRestDay: true,
              targetMuscles: ['Rest'],
              description:
                  'Pemulihan total untuk mempersiapkan siklus minggu berikutnya. Lakukan stretching ringan dan catat evaluasi progres latihan.',
            ),
          );
          break;
      }
    }

    return WorkoutProgram(
      id: 'ppl-hypertrophy-30-days',
      title: '30-Day Hypertrophy Builder',
      description:
          'Program terstruktur sains Push-Pull-Legs 30 hari untuk memaksimalkan hipertrofi dan volume otot dengan pembagian hari istirahat optimal.',
      targetGoal: FitnessGoal.muscleBuilding,
      experienceLevel: level,
      durationDays: 30,
      days: days,
    );
  }

  // --- 2. WEIGHT LOSS / FAT LOSS CONDITIONING ---
  static WorkoutProgram _buildFatLossConditioning(ExperienceLevel level) {
    final sets = level == ExperienceLevel.advanced ? 4 : 3;
    final days = <ProgramDay>[];

    for (int day = 1; day <= 30; day++) {
      final cycleIndex = (day - 1) % 7;

      switch (cycleIndex) {
        case 0: // Day 1: Full Body Metabolic Burn
          days.add(
            ProgramDay(
              dayNumber: day,
              title: 'Hari $day: Full Body Metabolic Circuit',
              isRestDay: false,
              targetMuscles: ['Full Body', 'Legs', 'Chest'],
              description:
                  'Latihan sirkuit compound dengan istirahat singkat untuk memicu denyut jantung dan EPOC (afterburn effect).',
              exercises: [
                ProgramExerciseItem(
                  exerciseId: 'goblet-squat-dumbbell',
                  exerciseName: 'Goblet Squat with Dumbbell',
                  targetMuscle: 'Legs',
                  targetSets: sets,
                  targetReps: '15-20',
                  restSeconds: 45,
                ),
                ProgramExerciseItem(
                  exerciseId: 'standard-push-up',
                  exerciseName: 'Standard Push Up',
                  targetMuscle: 'Chest',
                  targetSets: sets,
                  targetReps: '12-15',
                  restSeconds: 45,
                ),
                ProgramExerciseItem(
                  exerciseId: 'lat-pulldown',
                  exerciseName: 'Wide Grip Lat Pulldown',
                  targetMuscle: 'Back',
                  targetSets: sets,
                  targetReps: '12-15',
                  restSeconds: 45,
                ),
                ProgramExerciseItem(
                  exerciseId: 'dumbbell-lateral-raise',
                  exerciseName: 'Dumbbell Lateral Raise',
                  targetMuscle: 'Shoulder',
                  targetSets: sets,
                  targetReps: '15-20',
                  restSeconds: 30,
                ),
              ],
            ),
          );
          break;

        case 1: // Day 2: Lower Body Fat Torch & Core
          days.add(
            ProgramDay(
              dayNumber: day,
              title: 'Hari $day: Lower Body & Core Burner',
              isRestDay: false,
              targetMuscles: ['Legs', 'Abs & Core'],
              description:
                  'Aktivasi massa otot paha dan bokong terbesar tubuh untuk pembakaran kalori maksimal.',
              exercises: [
                ProgramExerciseItem(
                  exerciseId: 'leg-press-45',
                  exerciseName: 'Leg Press 45°',
                  targetMuscle: 'Legs',
                  targetSets: sets,
                  targetReps: '15-18',
                  restSeconds: 60,
                ),
                ProgramExerciseItem(
                  exerciseId: 'walking-lunges-dumbbell',
                  exerciseName: 'Walking Dumbbell Lunges',
                  targetMuscle: 'Legs',
                  targetSets: sets,
                  targetReps: '12 per kaki',
                  restSeconds: 60,
                ),
                ProgramExerciseItem(
                  exerciseId: 'lying-leg-curl-machine',
                  exerciseName: 'Lying Leg Curl Machine',
                  targetMuscle: 'Legs',
                  targetSets: sets,
                  targetReps: '15',
                  restSeconds: 45,
                ),
                ProgramExerciseItem(
                  exerciseId: 'hanging-leg-raise',
                  exerciseName: 'Hanging Leg Raise',
                  targetMuscle: 'Abs & Core',
                  targetSets: 3,
                  targetReps: '15',
                  restSeconds: 45,
                ),
              ],
            ),
          );
          break;

        case 2: // Day 3: Rest
          days.add(
            ProgramDay(
              dayNumber: day,
              title: 'Hari $day: Istirahat & Defisit Nutrisi Terkontrol',
              isRestDay: true,
              targetMuscles: ['Rest'],
              description:
                  'Pertahankan defisit kalori harian dan pastikan asupan air minum mencukupi.',
            ),
          );
          break;

        case 3: // Day 4: Upper Body Sculpt
          days.add(
            ProgramDay(
              dayNumber: day,
              title: 'Hari $day: Upper Body Sculpt & Conditioning',
              isRestDay: false,
              targetMuscles: ['Chest', 'Back', 'Shoulder'],
              description:
                  'Menjaga retensi massa otot saat defisit kalori agar bentuk tubuh tetap padat dan kencang.',
              exercises: [
                ProgramExerciseItem(
                  exerciseId: 'incline-dumbbell-press',
                  exerciseName: 'Incline Dumbbell Press',
                  targetMuscle: 'Chest',
                  targetSets: sets,
                  targetReps: '12-15',
                  restSeconds: 60,
                ),
                ProgramExerciseItem(
                  exerciseId: 'seated-cable-row',
                  exerciseName: 'Seated Cable Row',
                  targetMuscle: 'Back',
                  targetSets: sets,
                  targetReps: '12-15',
                  restSeconds: 60,
                ),
                ProgramExerciseItem(
                  exerciseId: 'seated-dumbbell-shoulder-press',
                  exerciseName: 'Seated Dumbbell Shoulder Press',
                  targetMuscle: 'Shoulder',
                  targetSets: sets,
                  targetReps: '12-15',
                  restSeconds: 60,
                ),
                ProgramExerciseItem(
                  exerciseId: 'triceps-rope-pushdown',
                  exerciseName: 'Cable Triceps Rope Pushdown',
                  targetMuscle: 'Triceps',
                  targetSets: sets,
                  targetReps: '15-20',
                  restSeconds: 45,
                ),
              ],
            ),
          );
          break;

        case 4: // Day 5: Core Stability & HIIT
          days.add(
            ProgramDay(
              dayNumber: day,
              title: 'Hari $day: HIIT Conditioning & Core Torch',
              isRestDay: false,
              targetMuscles: ['Cardio', 'Abs & Core'],
              description:
                  'Latihan ketahanan kardiovaskular dan penguatan otot perut.',
              exercises: [
                ProgramExerciseItem(
                  exerciseId: 'goblet-squat-dumbbell',
                  exerciseName: 'Goblet Squat with Dumbbell',
                  targetMuscle: 'Legs',
                  targetSets: sets,
                  targetReps: '20 Reps',
                  restSeconds: 30,
                ),
                ProgramExerciseItem(
                  exerciseId: 'hanging-leg-raise',
                  exerciseName: 'Hanging Leg Raise',
                  targetMuscle: 'Abs & Core',
                  targetSets: 4,
                  targetReps: '15 Reps',
                  restSeconds: 45,
                ),
                ProgramExerciseItem(
                  exerciseId: 'standard-push-up',
                  exerciseName: 'Standard Push Up',
                  targetMuscle: 'Chest',
                  targetSets: 3,
                  targetReps: '15-20',
                  restSeconds: 30,
                ),
              ],
            ),
          );
          break;

        case 5: // Day 6: Total Body Finisher
          days.add(
            ProgramDay(
              dayNumber: day,
              title: 'Hari $day: Total Body Metabolic Shred',
              isRestDay: false,
              targetMuscles: ['Full Body'],
              description:
                  'Sesi pembakaran akhir pekan untuk menstimulasi metabolisme tanpa membebani persendian.',
              exercises: [
                ProgramExerciseItem(
                  exerciseId: 'romanian-deadlift',
                  exerciseName: 'Romanian Deadlift (Barbell RDL)',
                  targetMuscle: 'Legs',
                  targetSets: sets,
                  targetReps: '12-15',
                  restSeconds: 60,
                ),
                ProgramExerciseItem(
                  exerciseId: 'flat-dumbbell-bench-press',
                  exerciseName: 'Flat Dumbbell Press',
                  targetMuscle: 'Chest',
                  targetSets: sets,
                  targetReps: '12-15',
                  restSeconds: 60,
                ),
                ProgramExerciseItem(
                  exerciseId: 'one-arm-dumbbell-row',
                  exerciseName: 'Single-Arm Dumbbell Row',
                  targetMuscle: 'Back',
                  targetSets: sets,
                  targetReps: '12-15',
                  restSeconds: 45,
                ),
              ],
            ),
          );
          break;

        case 6: // Day 7: Rest
        default:
          days.add(
            ProgramDay(
              dayNumber: day,
              title: 'Hari $day: Pemulihan Aktif & Mindset',
              isRestDay: true,
              targetMuscles: ['Rest'],
              description:
                  'Hari istirahat penuh. Jalan kaki santai dan siapkan rencana makan seimbang untuk minggu depan.',
            ),
          );
          break;
      }
    }

    return WorkoutProgram(
      id: 'fat-loss-conditioning-30-days',
      title: '30-Day Shred & Conditioning',
      description:
          'Program terarah 30 hari untuk akselerasi pembakaran lemak, retensi massa otot bebas lemak, dan peningkatan ketahanan kardio-metabolik.',
      targetGoal: FitnessGoal.weightLoss,
      experienceLevel: level,
      durationDays: 30,
      days: days,
    );
  }

  // --- 3. RECOMPOSITION & STRENGTH ---
  static WorkoutProgram _buildStrengthRecomp(ExperienceLevel level) {
    return _buildHypertrophyPPL(level); // High quality balanced split
  }
}
