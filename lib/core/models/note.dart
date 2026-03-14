import 'dart:math';

import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';
part 'note.g.dart';

@freezed
class Note with _$Note {
  const factory Note({
    required String name,
    required int midiNumber,
    required double frequency,
    Duration? duration,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}

/// Helper class for note calculations
class NoteHelper {
  static const List<String> noteNames = [
    'C', 'C#', 'D', 'D#', 'E', 'F',
    'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  /// Convert MIDI number to note name (e.g., 60 -> 'C4')
  static String midiToName(int midi) {
    final octave = (midi ~/ 12) - 1;
    final noteIndex = midi % 12;
    return '${noteNames[noteIndex]}$octave';
  }

  /// Convert MIDI number to frequency in Hz using equal temperament.
  /// Formula: 440.0 * 2^((midi - 69) / 12)
  static double midiToFrequency(int midiNote) {
    return pow(2.0, (midiNote - 69) / 12.0).toDouble() * 440.0;
  }

  /// Create a Note from MIDI number
  static Note fromMidi(int midi, {Duration? duration}) {
    return Note(
      name: midiToName(midi),
      midiNumber: midi,
      frequency: midiToFrequency(midi),
      duration: duration,
    );
  }

  /// Common notes
  static Note get middleC => fromMidi(60);
  static Note get a4 => fromMidi(69); // 440 Hz
}
