import 'package:ear_training_app/core/models/note.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteHelper.midiToFrequency', () {
    test('A4 (MIDI 69) = 440 Hz', () {
      expect(NoteHelper.midiToFrequency(69), closeTo(440.0, 0.01));
    });

    test('A3 (MIDI 57) = 220 Hz', () {
      expect(NoteHelper.midiToFrequency(57), closeTo(220.0, 0.01));
    });

    test('A5 (MIDI 81) = 880 Hz', () {
      expect(NoteHelper.midiToFrequency(81), closeTo(880.0, 0.01));
    });

    test('C4 (MIDI 60) ≈ 261.63 Hz', () {
      expect(NoteHelper.midiToFrequency(60), closeTo(261.63, 0.5));
    });

    test('C5 (MIDI 72) ≈ 523.25 Hz', () {
      expect(NoteHelper.midiToFrequency(72), closeTo(523.25, 0.5));
    });

    test('each octave doubles frequency', () {
      for (final midi in [48, 60, 72, 84]) {
        final f = NoteHelper.midiToFrequency(midi);
        final fOctave = NoteHelper.midiToFrequency(midi + 12);
        expect(fOctave, closeTo(f * 2, 0.01));
      }
    });
  });

  group('NoteHelper.midiToName', () {
    test('MIDI 60 = C4', () {
      expect(NoteHelper.midiToName(60), 'C4');
    });

    test('MIDI 69 = A4', () {
      expect(NoteHelper.midiToName(69), 'A4');
    });

    test('MIDI 61 = C#4', () {
      expect(NoteHelper.midiToName(61), 'C#4');
    });
  });

  group('NoteHelper.fromMidi', () {
    test('creates Note with correct fields', () {
      final note = NoteHelper.fromMidi(69);
      expect(note.midiNumber, 69);
      expect(note.name, 'A4');
      expect(note.frequency, closeTo(440.0, 0.01));
    });

    test('middleC is MIDI 60', () {
      expect(NoteHelper.middleC.midiNumber, 60);
    });

    test('a4 has frequency 440 Hz', () {
      expect(NoteHelper.a4.frequency, closeTo(440.0, 0.01));
    });
  });
}
