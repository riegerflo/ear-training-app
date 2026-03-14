import 'package:freezed_annotation/freezed_annotation.dart';
import 'note.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

enum ExerciseType {
  singleTone,
  interval,
  chord,
  scale,
  melody,
  rhythm,
}

enum Difficulty {
  beginner,
  intermediate,
  advanced,
}

@freezed
class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required ExerciseType type,
    required Difficulty difficulty,
    required List<Note> questionNotes,
    required String correctAnswer,
    required List<String> answerOptions,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
}

@freezed
class SessionResult with _$SessionResult {
  const factory SessionResult({
    required String exerciseId,
    required String userAnswer,
    required String correctAnswer,
    required bool isCorrect,
    required DateTime timestamp,
  }) = _SessionResult;

  factory SessionResult.fromJson(Map<String, dynamic> json) =>
      _$SessionResultFromJson(json);
}

@freezed
class ExerciseSession with _$ExerciseSession {
  const ExerciseSession._();

  const factory ExerciseSession({
    required String id,
    required ExerciseType type,
    required DateTime startTime,
    DateTime? endTime,
    @Default([]) List<SessionResult> results,
  }) = _ExerciseSession;

  factory ExerciseSession.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSessionFromJson(json);

  int get score => results.where((r) => r.isCorrect).length;
  int get total => results.length;
  double get accuracy => total == 0 ? 0 : score / total;
}
