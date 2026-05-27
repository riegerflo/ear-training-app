import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/exercise.dart';
import '../../../core/services/score_service.dart';
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

class ChordExerciseNotifier extends AutoDisposeNotifier<ChordExerciseState> {
  final Random _random = Random();

  @override
  ChordExerciseState build() => _generateQuestion(0, 0);

  ChordExerciseState _generateQuestion(int score, int total) {
    final correct =
        ChordType.allChords[_random.nextInt(ChordType.allChords.length)];
    final rootMidi = 48 + _random.nextInt(13); // C3–C4
    final choices = List<ChordType>.from(ChordType.allChords)
      ..shuffle(_random);
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
    ref.read(scoreServiceProvider).recordAnswer(
          type: ExerciseType.chord,
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

final chordExerciseProvider =
    NotifierProvider.autoDispose<ChordExerciseNotifier, ChordExerciseState>(
  ChordExerciseNotifier.new,
);
