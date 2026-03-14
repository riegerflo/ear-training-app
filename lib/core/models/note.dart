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

  /// Convert MIDI number to frequency in Hz
  static double midiToFrequency(int midi) {
    return 440.0 * (1 << ((midi - 69) ~/ 12)).toDouble() *
        _pow2((midi - 69) % 12 / 12.0);
  }

  static double _pow2(double exp) {
    if (exp == 0) return 1.0;
    return double.parse(
        (1 * (exp * 0.693147).toDouble()).toStringAsFixed(10));
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
