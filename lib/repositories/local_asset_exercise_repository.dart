import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';
import 'exercise_repository.dart';

class LocalAssetExerciseRepository implements ExerciseRepository {
  List<Exercise>? _cachedExercises;
  static const String _customKey = 'fitsync_custom_exercises';

  Future<List<Exercise>> _loadDataset() async {
    if (_cachedExercises != null) {
      return _cachedExercises!;
    }

    final list = <Exercise>[];

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/exercises_dataset.json');
      final List<dynamic> rawList = jsonDecode(jsonString);
      list.addAll(rawList.map((e) {
        final map = e as Map<String, dynamic>;
        return Exercise.fromMap(map, map['id'] as String? ?? 'ex');
      }));
    } catch (_) {}

    // Muat gerakan kustom yang disimpan di memori lokal
    try {
      final prefs = await SharedPreferences.getInstance();
      final customRaw = prefs.getStringList(_customKey) ?? [];
      for (final item in customRaw) {
        final map = jsonDecode(item) as Map<String, dynamic>;
        final customEx = Exercise.fromMap(map, map['id'] as String? ?? 'custom');
        // Jika ID sama, timpa gerakan lama (edit), jika baru tambahkan ke depan
        final existingIdx = list.indexWhere((e) => e.id == customEx.id);
        if (existingIdx != -1) {
          list[existingIdx] = customEx;
        } else {
          list.insert(0, customEx);
        }
      }
    } catch (_) {}

    _cachedExercises = list;
    return _cachedExercises!;
  }

  @override
  Future<List<Exercise>> getExercises({
    String? searchQuery,
    String? targetMuscle,
    String? equipment,
    String? difficulty,
    String? sortBy,
    int limit = 20,
    int offset = 0,
  }) async {
    final all = await _loadDataset();

    var filtered = all.where((item) {
      if (!item.isActive) return false;

      // Filter Search Nama
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.toLowerCase().trim();
        final matchesName = item.name.toLowerCase().contains(query);
        final matchesMuscle = item.targetMuscle.toLowerCase().contains(query);
        final matchesEquip = item.equipment.toLowerCase().contains(query);
        if (!matchesName && !matchesMuscle && !matchesEquip) return false;
      }

      // Filter Target Otot
      if (targetMuscle != null &&
          targetMuscle.isNotEmpty &&
          targetMuscle != 'Semua') {
        if (item.targetMuscle.toLowerCase() != targetMuscle.toLowerCase()) {
          return false;
        }
      }

      // Filter Alat
      if (equipment != null && equipment.isNotEmpty && equipment != 'Semua') {
        if (item.equipment.toLowerCase() != equipment.toLowerCase()) {
          return false;
        }
      }

      // Filter Difficulty
      if (difficulty != null &&
          difficulty.isNotEmpty &&
          difficulty != 'Semua') {
        if (item.difficulty.toLowerCase() != difficulty.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sorting
    if (sortBy == 'name_desc') {
      filtered.sort((a, b) => b.name.compareTo(a.name));
    } else {
      // Default: name_asc
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    // Pagination (limit & offset)
    if (offset >= filtered.length) {
      return [];
    }
    final end = (offset + limit < filtered.length) ? offset + limit : filtered.length;
    return filtered.sublist(offset, end);
  }

  @override
  Future<Exercise?> getExerciseById(String id) async {
    final all = await _loadDataset();
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<String>> getAllMuscleGroups() async {
    final all = await _loadDataset();
    final groups = all.map((e) => e.targetMuscle).toSet().toList();
    groups.sort();
    return ['Semua', ...groups];
  }

  @override
  Future<List<String>> getAllEquipments() async {
    final all = await _loadDataset();
    final equips = all.map((e) => e.equipment).toSet().toList();
    equips.sort();
    return ['Semua', ...equips];
  }

  @override
  Future<void> saveCustomExercise(Exercise exercise) async {
    final all = await _loadDataset();
    final idx = all.indexWhere((e) => e.id == exercise.id);
    if (idx != -1) {
      all[idx] = exercise;
    } else {
      all.insert(0, exercise);
    }
    _cachedExercises = all;

    try {
      final prefs = await SharedPreferences.getInstance();
      final customRaw = prefs.getStringList(_customKey) ?? [];
      final list = customRaw
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
      final cIdx = list.indexWhere((m) => m['id'] == exercise.id);
      if (cIdx != -1) {
        list[cIdx] = exercise.toMap();
      } else {
        list.insert(0, exercise.toMap());
      }
      await prefs.setStringList(
          _customKey, list.map((e) => jsonEncode(e)).toList());
    } catch (_) {}
  }

  @override
  Future<void> deleteCustomExercise(String id) async {
    final all = await _loadDataset();
    all.removeWhere((e) => e.id == id);
    _cachedExercises = all;

    try {
      final prefs = await SharedPreferences.getInstance();
      final customRaw = prefs.getStringList(_customKey) ?? [];
      final list = customRaw
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .where((m) => m['id'] != id)
          .toList();
      await prefs.setStringList(
          _customKey, list.map((e) => jsonEncode(e)).toList());
    } catch (_) {}
  }
}
