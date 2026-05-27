import 'dart:math' as math;

class Note {
  final String name;
  final int midiNumber;
  final double frequency;
  final Duration? duration;

  const Note({
    required this.name,
    required this.midiNumber,
    required this.frequency,
    this.duration,
  });

  Note copyWith({
    String? name,
    int? midiNumber,
    double? frequency,
    Duration? duration,
  }) {
    return Note(
      name: name ?? this.name,
      midiNumber: midiNumber ?? this.midiNumber,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
    );
  }
}

class NoteHelper {
  static const List<String> noteNames = [
    'C', 'C#', 'D', 'D#', 'E', 'F',
    'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  static String midiToName(int midi) {
    final octave = (midi ~/ 12) - 1;
    final noteIndex = midi % 12;
    return '${noteNames[noteIndex]}$octave';
  }

  static double midiToFrequency(int midiNote) {
    return (math.pow(2.0, (midiNote - 69) / 12.0) * 440.0).toDouble();
  }

  static Note fromMidi(int midi, {Duration? duration}) {
    return Note(
      name: midiToName(midi),
      midiNumber: midi,
      frequency: midiToFrequency(midi),
      duration: duration,
    );
  }

  static Note get middleC => fromMidi(60);
  static Note get a4 => fromMidi(69);
}
