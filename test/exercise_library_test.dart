import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitsync/models/exercise.dart';

void main() {
  group('Exercise Model & Repository Transformation Tests', () {
    const rawJson = '''
    {
      "id": "barbell-bench-press",
      "name": "Barbell Bench Press",
      "targetMuscle": "Chest",
      "secondaryMuscles": ["Triceps", "Front Delts"],
      "equipment": "Barbell",
      "difficulty": "Intermediate",
      "recommendedSets": 4,
      "recommendedReps": "8-10 Reps",
      "instructions": [
        "Berbaring di flat bench.",
        "Turunkan barbel ke dada tengah.",
        "Dorong kembali ke atas."
      ],
      "tips": [
        "Jaga punggung tetap stabil."
      ],
      "gifUrl": "https://pub-fitsync-r2.dev/exercises/barbell-bench-press.gif",
      "thumbnailUrl": "https://pub-fitsync-r2.dev/thumbnails/barbell-bench-press.jpg",
      "isActive": true
    }
    ''';

    test('Parses Exercise from JSON Map correctly', () {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      final exercise = Exercise.fromMap(map, map['id'] as String);

      expect(exercise.id, 'barbell-bench-press');
      expect(exercise.name, 'Barbell Bench Press');
      expect(exercise.targetMuscle, 'Chest');
      expect(exercise.equipment, 'Barbell');
      expect(exercise.difficulty, 'Intermediate');
      expect(exercise.recommendedSets, 4);
      expect(exercise.recommendedReps, '8-10 Reps');
      expect(exercise.secondaryMuscles.length, 2);
      expect(exercise.instructions.length, 3);
      expect(exercise.gifUrl, contains('pub-fitsync-r2.dev'));
      expect(exercise.isActive, isTrue);
    });

    test('Serializes Exercise back to Map correctly', () {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      final exercise = Exercise.fromMap(map, map['id'] as String);
      final serialized = exercise.toMap();

      expect(serialized['name'], 'Barbell Bench Press');
      expect(serialized['targetMuscle'], 'Chest');
      expect(serialized['equipment'], 'Barbell');
      expect(serialized['gifUrl'], contains('.gif'));
    });
  });
}
