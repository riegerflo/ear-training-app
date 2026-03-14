/// Represents a chord type with its semitone offsets from the root.
class ChordType {
  final String name;
  final List<int> semitoneOffsets; // relative to root (root = 0)

  const ChordType({required this.name, required this.semitoneOffsets});

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ChordType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  /// Dur (Major): 1-3-5
  static const ChordType major = ChordType(
    name: 'Dur',
    semitoneOffsets: [4, 7],
  );

  /// Moll (Minor): 1-b3-5
  static const ChordType minor = ChordType(
    name: 'Moll',
    semitoneOffsets: [3, 7],
  );

  /// Dominantseptakkord (Dom7): 1-3-5-b7
  static const ChordType dominant7 = ChordType(
    name: 'Dom7',
    semitoneOffsets: [4, 7, 10],
  );

  /// Vermindert (Diminished): 1-b3-b5
  static const ChordType diminished = ChordType(
    name: 'Vermindert',
    semitoneOffsets: [3, 6],
  );

  static const List<ChordType> allChords = [
    major,
    minor,
    dominant7,
    diminished,
  ];
}
