/// Represents a musical scale type.
class ScaleType {
  final String name;
  /// Semitone offsets from root (not including root itself, not including octave)
  final List<int> semitonePattern;

  const ScaleType({required this.name, required this.semitonePattern});

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ScaleType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  /// Dur (Major): W-W-H-W-W-W-H
  static const ScaleType major = ScaleType(
    name: 'Dur',
    semitonePattern: [2, 4, 5, 7, 9, 11, 12],
  );

  /// Natürliches Moll (Natural Minor): W-H-W-W-H-W-W
  static const ScaleType naturalMinor = ScaleType(
    name: 'Natürliches Moll',
    semitonePattern: [2, 3, 5, 7, 8, 10, 12],
  );

  /// Pentatonik Dur (Major Pentatonic): W-W-WH-W-WH
  static const ScaleType majorPentatonic = ScaleType(
    name: 'Pentatonik Dur',
    semitonePattern: [2, 4, 7, 9, 12],
  );

  /// Pentatonik Moll (Minor Pentatonic): WH-W-W-WH-W
  static const ScaleType minorPentatonic = ScaleType(
    name: 'Pentatonik Moll',
    semitonePattern: [3, 5, 7, 10, 12],
  );

  static const List<ScaleType> allScales = [
    major,
    naturalMinor,
    majorPentatonic,
    minorPentatonic,
  ];
}
