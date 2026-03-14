import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chord_model.dart';

class ChordExerciseState {
  final ChordType currentChord;
  final int rootMidi;
  final List<ChordType> choices;
  final ChordType? selectedAnswer;
  final bool answered;
  final int score;
  final int totalAnswered;

  const ChordExerciseState({
    required this.currentChord,
    required this.rootMidi,
    required this.choices,
    this.selectedAnswer,
    this.answered = false,
    this.score = 0,
    this.totalAnswered = 0,
  });

  bool get isCorrect =>
      selectedAnswer != null && selectedAnswer == currentChord;

  ChordExerciseState copyWith({
    ChordType? currentChord,
    int? rootMidi,
    List<ChordType>? choices,
    ChordType? Function()? selectedAnswer,
    bool? answered,
    int? score,
    int? totalAnswered,
  }) {
    return ChordExerciseState(
      currentChord: currentChord ?? this.currentChord,
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

class ChordExerciseNotifier extends StateNotifier<ChordExerciseState> {
  final Random _random = Random();

  ChordExerciseNotifier()
      : super(_generateQuestion(0, 0, const Random()));

  static ChordExerciseState _generateQuestion(
      int score, int total, Random random) {
    final correct =
        ChordType.allChords[random.nextInt(ChordType.allChords.length)];
    final rootMidi = 48 + random.nextInt(13); // C3–C4

    final choices = List<ChordType>.from(ChordType.allChords)..shuffle(random);

    return ChordExerciseState(
      currentChord: correct,
      rootMidi: rootMidi,
      choices: choices,
      score: score,
      totalAnswered: total,
    );
  }

  void answer(ChordType chosen) {
    if (state.answered) return;
    final isCorrect = chosen == state.currentChord;
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

final chordExerciseProvider =
    StateNotifierProvider<ChordExerciseNotifier, ChordExerciseState>(
  (ref) => ChordExerciseNotifier(),
);
