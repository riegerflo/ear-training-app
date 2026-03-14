import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../models/exercise.dart';
import '../models/user_progress.dart';

/// Provider for the Isar database instance (overridden in main.dart)
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider must be overridden in main()');
});

/// Service for UserProgress CRUD operations
class ProgressRepository {
  final Isar _isar;

  ProgressRepository(this._isar);

  Future<UserProgress?> getProgress(ExerciseType type) async {
    return _isar.userProgresss
        .filter()
        .exerciseTypeEqualTo(type)
        .findFirst();
  }

  Future<List<UserProgress>> getAllProgress() async {
    return _isar.userProgresss.where().findAll();
  }

  Future<void> updateProgress({
    required ExerciseType type,
    required bool correct,
  }) async {
    await _isar.writeTxn(() async {
      var progress = await _isar.userProgresss
          .filter()
          .exerciseTypeEqualTo(type)
          .findFirst();

      if (progress == null) {
        progress = UserProgress();
        progress.exerciseType = type;
      }

      progress.totalAttempts++;
      if (correct) {
        progress.correctAttempts++;
        progress.currentStreak++;
        if (progress.currentStreak > progress.longestStreak) {
          progress.longestStreak = progress.currentStreak;
        }
      } else {
        progress.currentStreak = 0;
      }
      progress.lastPracticed = DateTime.now();

      await _isar.userProgresss.put(progress);
    });
  }

  Future<void> resetProgress(ExerciseType type) async {
    await _isar.writeTxn(() async {
      final progress = await _isar.userProgresss
          .filter()
          .exerciseTypeEqualTo(type)
          .findFirst();
      if (progress != null) {
        await _isar.userProgresss.delete(progress.id);
      }
    });
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return ProgressRepository(isar);
});
