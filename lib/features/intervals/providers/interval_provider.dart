import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/exercise.dart';
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

  IntervalExerciseState _generateQuestion(int score, int total) {
    final correctInterval =
        Interval.allIntervals[_random.nextInt(Interval.allIntervals.length)];
    final rootMidi = 48 + _random.nextInt(25); // C3–C5
    final wrong = List<Interval>.from(Interval.allIntervals)
      ..remove(correctInterval)
      ..shuffle(_random);
    final choices = [...wrong.take(3), correctInterval]..shuffle(_random);
    return IntervalExerciseState(
      currentInterval: correctInterval,
      rootMidi: rootMidi,
      choices: choices,
      score: score,
      totalAnswered: total,
    );
  }

  void answer(Interval chosen) {
    if (state.answered) return;
    final isCorrect = chosen == state.currentInterval;
    // Fire-and-forget – UI updates immediately; DB write happens in background.
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
