/// Represents a musical interval.
class Interval {
  final String name;
  final int semitones;

  const Interval({required this.name, required this.semitones});

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Interval &&
          name == other.name &&
          semitones == other.semitones;

  @override
  int get hashCode => Object.hash(name, semitones);

  /// All 8 basic intervals used in the exercise.
  static const List<Interval> allIntervals = [
    Interval(name: 'Prim (0)', semitones: 0),
    Interval(name: 'Sekunde (2)', semitones: 2),
    Interval(name: 'Terz (4)', semitones: 4),
    Interval(name: 'Quarte (5)', semitones: 5),
    Interval(name: 'Quinte (7)', semitones: 7),
    Interval(name: 'Sexte (9)', semitones: 9),
    Interval(name: 'Septime (11)', semitones: 11),
    Interval(name: 'Oktave (12)', semitones: 12),
  ];
}
