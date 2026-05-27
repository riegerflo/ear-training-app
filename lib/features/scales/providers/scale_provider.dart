import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/exercise.dart';
import '../../../core/providers/difficulty_provider.dart';
import '../../../core/services/score_service.dart';
import '../models/scale_model.dart';

class ScaleExerciseState {
  final ScaleType currentScale;
  final int rootMidi;
  final List<ScaleType> choices;
  final ScaleType? selectedAnswer;
  final bool answered;
  final int score;
  final int totalAnswered;

  const ScaleExerciseState({
    required this.currentScale,
    required this.rootMidi,
    required this.choices,
    this.selectedAnswer,
    this.answered = false,
    this.score = 0,
    this.totalAnswered = 0,
  });

  bool get isCorrect =>
      selectedAnswer != null && selectedAnswer == currentScale;

  ScaleExerciseState copyWith({
    ScaleType? currentScale,
    int? rootMidi,
    List<ScaleType>? choices,
    ScaleType? Function()? selectedAnswer,
    bool? answered,
    int? score,
    int? totalAnswered,
  }) {
    return ScaleExerciseState(
      currentScale: currentScale ?? this.currentScale,
      rootMidi: rootMidi ?? this.rootMidi,
      choices: choices ?? this.choices,
      selectedAnswer:
          selectedAnswer != null ? selectedAnswer() : this.selectedAnswer,
      answered: answered ?? this.answered,
      score: score ?? this.score,
      totalAnswered: totalAnswered ?? this.totalAnswered,
    );
  }
}

class ScaleExerciseNotifier extends AutoDisposeNotifier<ScaleExerciseState> {
  final Random _random = Random();

  @override
  ScaleExerciseState build() => _generateQuestion(0, 0);

  static List<ScaleType> _scalesForDifficulty(Difficulty d) {
    return switch (d) {
      Difficulty.beginner => [ScaleType.major, ScaleType.naturalMinor],
      Difficulty.intermediate => [
          ScaleType.major,
          ScaleType.naturalMinor,
          ScaleType.majorPentatonic,
        ],
      Difficulty.advanced => ScaleType.allScales,
    };
  }

  static int _rootRangeForDifficulty(Difficulty d) => switch (d) {
        Difficulty.beginner => 5,      // C3–E3
        Difficulty.intermediate => 9,  // C3–A3
        Difficulty.advanced => 13,     // C3–C4
      };

  ScaleExerciseState _generateQuestion(int score, int total) {
    final difficulty = ref.read(difficultyProvider);
    final pool = _scalesForDifficulty(difficulty);
    final rootRange = _rootRangeForDifficulty(difficulty);

    final correct = pool[_random.nextInt(pool.length)];
    final rootMidi = 48 + _random.nextInt(rootRange);
    final choices = List<ScaleType>.from(pool)..shuffle(_random);

    return ScaleExerciseState(
      currentScale: correct,
      rootMidi: rootMidi,
      choices: choices,
      score: score,
      totalAnswered: total,
    );
  }

  void answer(ScaleType chosen) {
    if (state.answered) return;
    final isCorrect = chosen == state.currentScale;
    ref.read(scoreServiceProvider).recordAnswer(
          type: ExerciseType.scale,
          correct: isCorrect,
        );
    state = state.copyWith(
      selectedAnswer: () => chosen,
      answered: true,
      score: isCorrect ? state.score + 1 : state.score,
      totalAnswered: state.totalAnswered + 1,
    );
  }

  void next() => state = _generateQuestion(state.score, state.totalAnswered);

  void reset() => state = _generateQuestion(0, 0);
}

final scaleExerciseProvider =
    NotifierProvider.autoDispose<ScaleExerciseNotifier, ScaleExerciseState>(
  ScaleExerciseNotifier.new,
);
