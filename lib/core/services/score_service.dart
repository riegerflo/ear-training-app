import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise.dart';
import '../storage/isar_service.dart';

/// High-level service for recording exercise results and reading progress.
class ScoreService {
  final ProgressRepository _repo;

  ScoreService(this._repo);

  /// Record one answer for [type].
  Future<void> recordAnswer({
    required ExerciseType type,
    required bool correct,
  }) async {
    await _repo.updateProgress(type: type, correct: correct);
  }

  /// Returns progress for a specific [type], or a blank object if none.
  Future<UserProgressSummary> getSummary(ExerciseType type) async {
    final p = await _repo.getProgress(type);
    return UserProgressSummary(
      exerciseType: type,
      totalAttempts: p?.totalAttempts ?? 0,
      correctAttempts: p?.correctAttempts ?? 0,
      currentStreak: p?.currentStreak ?? 0,
      longestStreak: p?.longestStreak ?? 0,
      lastPracticed: p?.lastPracticed,
    );
  }

  /// Returns summaries for all exercise types.
  Future<List<UserProgressSummary>> getAllSummaries() async {
    final all = await _repo.getAllProgress();
    final byType = {for (final p in all) p.exerciseType: p};

    return [
      for (final type in ExerciseType.values)
        UserProgressSummary(
          exerciseType: type,
          totalAttempts: byType[type]?.totalAttempts ?? 0,
          correctAttempts: byType[type]?.correctAttempts ?? 0,
          currentStreak: byType[type]?.currentStreak ?? 0,
          longestStreak: byType[type]?.longestStreak ?? 0,
          lastPracticed: byType[type]?.lastPracticed,
        ),
    ];
  }
}

/// Immutable view model for progress display.
class UserProgressSummary {
  final ExerciseType exerciseType;
  final int totalAttempts;
  final int correctAttempts;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastPracticed;

  const UserProgressSummary({
    required this.exerciseType,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastPracticed,
  });

  double get accuracy =>
      totalAttempts == 0 ? 0.0 : correctAttempts / totalAttempts;

  String get accuracyPercent =>
      '${(accuracy * 100).toStringAsFixed(0)}%';

  String get exerciseName => switch (exerciseType) {
        ExerciseType.interval => 'Intervalle',
        ExerciseType.chord => 'Akkorde',
        ExerciseType.scale => 'Skalen',
        ExerciseType.singleTone => 'Einzeltöne',
        ExerciseType.melody => 'Melodien',
        ExerciseType.rhythm => 'Rhythmus',
      };
}

final scoreServiceProvider = Provider<ScoreService>((ref) {
  final repo = ref.watch(progressRepositoryProvider);
  return ScoreService(repo);
});
