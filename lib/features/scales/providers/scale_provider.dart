import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class ScaleExerciseNotifier extends StateNotifier<ScaleExerciseState> {
  final Random _random = Random();

  ScaleExerciseNotifier() : super(_generateQuestion(0, 0, const Random()));

  static ScaleExerciseState _generateQuestion(
      int score, int total, Random random) {
    final correct =
        ScaleType.allScales[random.nextInt(ScaleType.allScales.length)];
    final rootMidi = 48 + random.nextInt(13); // C3–C4

    final choices = List<ScaleType>.from(ScaleType.allScales)..shuffle(random);

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
    state = state.copyWith(
      selectedAnswer: () => chosen,
      answered: true,
      score: isCorrect ? state.score + 1 : state.score,
      totalAnswered: state.totalAnswered + 1,
    );
  }

  void next() {
    state = _generateQuestion(state.score, state.totalAnswered, _random);
  }
}

final scaleExerciseProvider =
    StateNotifierProvider<ScaleExerciseNotifier, ScaleExerciseState>(
  (ref) => ScaleExerciseNotifier(),
);
