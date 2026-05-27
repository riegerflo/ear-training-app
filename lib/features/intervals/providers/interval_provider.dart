import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/exercise.dart';
import '../../../core/providers/difficulty_provider.dart';
import '../../../core/services/score_service.dart';
import '../models/interval_model.dart';

class IntervalExerciseState {
  final Interval currentInterval;
  final int rootMidi;
  final List<Interval> choices;
  final Interval? selectedAnswer;
  final bool answered;
  final int score;
  final int totalAnswered;

  const IntervalExerciseState({
    required this.currentInterval,
    required this.rootMidi,
    required this.choices,
    this.selectedAnswer,
    this.answered = false,
    this.score = 0,
    this.totalAnswered = 0,
  });

  bool get isCorrect =>
      selectedAnswer != null && selectedAnswer == currentInterval;

  IntervalExerciseState copyWith({
    Interval? currentInterval,
    int? rootMidi,
    List<Interval>? choices,
    Interval? Function()? selectedAnswer,
    bool? answered,
    int? score,
    int? totalAnswered,
  }) {
    return IntervalExerciseState(
      currentInterval: currentInterval ?? this.currentInterval,
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

class IntervalExerciseNotifier
    extends AutoDisposeNotifier<IntervalExerciseState> {
  final Random _random = Random();

  @override
  IntervalExerciseState build() => _generateQuestion(0, 0);

  static List<Interval> _intervalsForDifficulty(Difficulty d) {
    return switch (d) {
      Difficulty.beginner => [
          Interval.allIntervals[0], // Prim
          Interval.allIntervals[3], // Quarte
          Interval.allIntervals[4], // Quinte
          Interval.allIntervals[7], // Oktave
        ],
      Difficulty.intermediate => [
          Interval.allIntervals[0], // Prim
          Interval.allIntervals[2], // Terz
          Interval.allIntervals[3], // Quarte
          Interval.allIntervals[4], // Quinte
          Interval.allIntervals[5], // Sexte
          Interval.allIntervals[7], // Oktave
        ],
      Difficulty.advanced => Interval.allIntervals,
    };
  }

  static int _rootRangeForDifficulty(Difficulty d) => switch (d) {
        Difficulty.beginner => 13,     // C3–C4
        Difficulty.intermediate => 19, // C3–G4
        Difficulty.advanced => 25,     // C3–C5
      };

  IntervalExerciseState _generateQuestion(int score, int total) {
    final difficulty = ref.read(difficultyProvider);
    final pool = _intervalsForDifficulty(difficulty);
    final rootRange = _rootRangeForDifficulty(difficulty);

    final correct = pool[_random.nextInt(pool.length)];
    final rootMidi = 48 + _random.nextInt(rootRange);
    final wrong = List<Interval>.from(pool)
      ..remove(correct)
      ..shuffle(_random);
    // Show all available choices for the current difficulty.
    final choices = [...wrong, correct]..shuffle(_random);

    return IntervalExerciseState(
      currentInterval: correct,
      rootMidi: rootMidi,
      choices: choices,
      score: score,
      totalAnswered: total,
    );
  }

  void answer(Interval chosen) {
    if (state.answered) return;
    final isCorrect = chosen == state.currentInterval;
    ref.read(scoreServiceProvider).recordAnswer(
          type: ExerciseType.interval,
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

final intervalExerciseProvider = NotifierProvider.autoDispose<
    IntervalExerciseNotifier, IntervalExerciseState>(
  IntervalExerciseNotifier.new,
);
