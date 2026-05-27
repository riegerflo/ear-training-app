import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercise.dart';
import '../models/user_progress.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

class ProgressRepository {
  final SharedPreferences _prefs;

  ProgressRepository(this._prefs);

  static String _key(ExerciseType type) => 'progress_${type.name}';

  Future<UserProgress?> getProgress(ExerciseType type) async {
    final raw = _prefs.getString(_key(type));
    if (raw == null) return null;
    return UserProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<List<UserProgress>> getAllProgress() async {
    final results = <UserProgress>[];
    for (final type in ExerciseType.values) {
      final p = await getProgress(type);
      if (p != null) results.add(p);
    }
    return results;
  }

  Future<void> updateProgress({
    required ExerciseType type,
    required bool correct,
  }) async {
    var progress =
        await getProgress(type) ?? UserProgress(exerciseType: type);

    final newStreak = correct ? progress.currentStreak + 1 : 0;
    progress = progress.copyWith(
      totalAttempts: progress.totalAttempts + 1,
      correctAttempts: correct ? progress.correctAttempts + 1 : null,
      currentStreak: newStreak,
      longestStreak: newStreak > progress.longestStreak
          ? newStreak
          : progress.longestStreak,
      lastPracticed: DateTime.now(),
    );

    await _prefs.setString(_key(type), jsonEncode(progress.toJson()));
  }

  Future<void> resetProgress(ExerciseType type) async {
    await _prefs.remove(_key(type));
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProgressRepository(prefs);
});
