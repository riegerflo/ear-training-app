import 'exercise.dart';

class UserProgress {
  final ExerciseType exerciseType;
  final int totalAttempts;
  final int correctAttempts;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastPracticed;

  double get accuracy =>
      totalAttempts == 0 ? 0 : correctAttempts / totalAttempts;

  const UserProgress({
    required this.exerciseType,
    this.totalAttempts = 0,
    this.correctAttempts = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastPracticed,
  });

  UserProgress copyWith({
    int? totalAttempts,
    int? correctAttempts,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastPracticed,
  }) {
    return UserProgress(
      exerciseType: exerciseType,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctAttempts: correctAttempts ?? this.correctAttempts,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastPracticed: lastPracticed ?? this.lastPracticed,
    );
  }

  Map<String, dynamic> toJson() => {
        'exerciseType': exerciseType.name,
        'totalAttempts': totalAttempts,
        'correctAttempts': correctAttempts,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastPracticed': lastPracticed?.toIso8601String(),
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
        exerciseType: ExerciseType.values.byName(json['exerciseType'] as String),
        totalAttempts: json['totalAttempts'] as int? ?? 0,
        correctAttempts: json['correctAttempts'] as int? ?? 0,
        currentStreak: json['currentStreak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        lastPracticed: json['lastPracticed'] != null
            ? DateTime.parse(json['lastPracticed'] as String)
            : null,
      );
}
