import 'package:isar/isar.dart';
import 'exercise.dart';

part 'user_progress.g.dart';

@collection
class UserProgress {
  Id id = Isar.autoIncrement;

  @Enumerated(EnumType.name)
  late ExerciseType exerciseType;

  late int totalAttempts;
  late int correctAttempts;
  late int currentStreak;
  late int longestStreak;
  late DateTime lastPracticed;

  double get accuracy =>
      totalAttempts == 0 ? 0 : correctAttempts / totalAttempts;

  UserProgress({
    this.totalAttempts = 0,
    this.correctAttempts = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    DateTime? lastPracticed,
  }) : lastPracticed = lastPracticed ?? DateTime.now();
}
