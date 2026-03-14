import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/interval_model.dart';

/// State for the interval exercise.
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

/// Notifier for the interval exercise.
class IntervalExerciseNotifier extends StateNotifier<IntervalExerciseState> {
  final Random _random = Random();

  IntervalExerciseNotifier() : super(_generateQuestion(0, 0, const Random()));

  static IntervalExerciseState _generateQuestion(
      int score, int total, Random random) {
    final correctInterval =
        Interval.allIntervals[random.nextInt(Interval.allIntervals.length)];

    // Root note in C3–C5 range (MIDI 48–72)
    final rootMidi = 48 + random.nextInt(25);

    // Pick 3 wrong answers (no duplicates, no correct answer)
    final wrong = List<Interval>.from(Interval.allIntervals)
      ..remove(correctInterval)
      ..shuffle(random);
    final choices = [...wrong.take(3), correctInterval]..shuffle(random);

    return IntervalExerciseState(
      currentInterval: correctInterval,
      rootMidi: rootMidi,
      choices: choices,
      score: score,
      totalAnswered: total,
    );
  }

  /// Submit an answer.
  void answer(Interval chosen) {
    if (state.answered) return;
    final isCorrect = chosen == state.currentInterval;
    state = state.copyWith(
      selectedAnswer: () => chosen,
      answered: true,
      score: isCorrect ? state.score + 1 : state.score,
      totalAnswered: state.totalAnswered + 1,
    );
  }

  /// Advance to the next question.
  void next() {
    state =
        _generateQuestion(state.score, state.totalAnswered, _random);
  }
}

final intervalExerciseProvider =
    StateNotifierProvider<IntervalExerciseNotifier, IntervalExerciseState>(
  (ref) => IntervalExerciseNotifier(),
);
