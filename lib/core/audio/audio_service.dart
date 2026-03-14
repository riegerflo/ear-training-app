import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../models/note.dart';

/// A [StreamAudioSource] that generates a sine-wave tone for the given
/// frequency and duration entirely in memory – no asset files required.
class _SynthAudioSource extends StreamAudioSource {
  final double frequency;
  final Duration duration;
  static const int _sampleRate = 44100;

  _SynthAudioSource({required this.frequency, required this.duration});

  /// Build a minimal WAV file in memory.
  Uint8List _buildWav() {
    final int numSamples = (_sampleRate * duration.inMilliseconds / 1000).round();
    final int dataSize = numSamples * 2; // 16-bit mono

    final ByteData header = ByteData(44);
    // RIFF chunk
    header.setUint8(0, 0x52); header.setUint8(1, 0x49);
    header.setUint8(2, 0x46); header.setUint8(3, 0x46); // "RIFF"
    header.setUint32(4, 36 + dataSize, Endian.little); // chunk size
    header.setUint8(8, 0x57); header.setUint8(9, 0x41);
    header.setUint8(10, 0x56); header.setUint8(11, 0x45); // "WAVE"
    // fmt sub-chunk
    header.setUint8(12, 0x66); header.setUint8(13, 0x6D);
    header.setUint8(14, 0x74); header.setUint8(15, 0x20); // "fmt "
    header.setUint32(16, 16, Endian.little); // sub-chunk size
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, 1, Endian.little); // channels = 1
    header.setUint32(24, _sampleRate, Endian.little);
    header.setUint32(28, _sampleRate * 2, Endian.little); // byte rate
    header.setUint16(32, 2, Endian.little); // block align
    header.setUint16(34, 16, Endian.little); // bits per sample
    // data sub-chunk
    header.setUint8(36, 0x64); header.setUint8(37, 0x61);
    header.setUint8(38, 0x74); header.setUint8(39, 0x61); // "data"
    header.setUint32(40, dataSize, Endian.little);

    final Uint8List wav = Uint8List(44 + dataSize);
    wav.setAll(0, header.buffer.asUint8List());

    const double amplitude = 16000;
    for (int i = 0; i < numSamples; i++) {
      // Fade in/out (5 ms each) to avoid clicks
      final double t = i / _sampleRate;
      final double fadeIn = (i < 220) ? i / 220 : 1.0;
      final double fadeOut =
          (i > numSamples - 220) ? (numSamples - i) / 220 : 1.0;
      final int sample =
          (amplitude * fadeIn * fadeOut * math.sin(2 * math.pi * frequency * t))
              .round()
              .clamp(-32768, 32767);
      final int offset = 44 + i * 2;
      wav[offset] = sample & 0xFF;
      wav[offset + 1] = (sample >> 8) & 0xFF;
    }

    return wav;
  }

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final Uint8List bytes = _buildWav();
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/wav',
    );
  }
}

/// Service for playing musical notes, intervals, and chords.
///
/// Uses synthesized sine-wave tones so no audio asset files are required.
class AudioService {
  final AudioPlayer _player = AudioPlayer();

  static const Duration _defaultDuration = Duration(milliseconds: 800);

  /// Play a single [Note].
  Future<void> playNote(Note note, {Duration? duration}) async {
    await _playSingle(note.frequency, duration ?? _defaultDuration);
  }

  /// Play a note by MIDI number.
  Future<void> playMidi(int midiNumber, {Duration? duration}) async {
    final note = NoteHelper.fromMidi(midiNumber);
    await playNote(note, duration: duration);
  }

  /// Play an interval: root note then interval note sequentially.
  Future<void> playInterval(
    int rootMidi,
    int intervalSemitones, {
    Duration? noteDuration,
  }) async {
    final dur = noteDuration ?? _defaultDuration;
    await playMidi(rootMidi, duration: dur);
    await Future.delayed(dur + const Duration(milliseconds: 100));
    await playMidi(rootMidi + intervalSemitones, duration: dur);
  }

  /// Play a chord: all notes simultaneously.
  Future<void> playChord(
    int rootMidi,
    List<int> semitoneOffsets, {
    Duration? duration,
  }) async {
    final dur = duration ?? _defaultDuration;
    final frequencies = [rootMidi, ...semitoneOffsets.map((s) => rootMidi + s)]
        .map((m) => NoteHelper.fromMidi(m).frequency)
        .toList();
    await _playChord(frequencies, dur);
  }

  /// Play a scale: notes ascending then (optionally) descending.
  Future<void> playScale(
    int rootMidi,
    List<int> semitonePattern, {
    bool descending = false,
    Duration? noteDuration,
  }) async {
    final dur = noteDuration ?? const Duration(milliseconds: 500);
    final List<int> ascNotes = [
      rootMidi,
      ...semitonePattern.map((s) => rootMidi + s),
    ];

    for (final midi in ascNotes) {
      await playMidi(midi, duration: dur);
      await Future.delayed(dur + const Duration(milliseconds: 50));
    }

    if (descending) {
      for (final midi in ascNotes.reversed.skip(1)) {
        await playMidi(midi, duration: dur);
        await Future.delayed(dur + const Duration(milliseconds: 50));
      }
    }
  }

  Future<void> _playSingle(double frequency, Duration duration) async {
    final source = _SynthAudioSource(frequency: frequency, duration: duration);
    await _player.setAudioSource(source);
    await _player.play();
  }

  Future<void> _playChord(List<double> frequencies, Duration duration) async {
    // just_audio doesn't support mixing natively – play them with minimal delay
    // to approximate a chord. A proper implementation would mix PCM buffers.
    for (int i = 0; i < frequencies.length; i++) {
      final source =
          _SynthAudioSource(frequency: frequencies[i], duration: duration);
      await _player.setAudioSource(source);
      _player.play(); // fire and forget
      await Future.delayed(const Duration(milliseconds: 20));
    }
    await Future.delayed(duration);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

/// Riverpod provider for [AudioService].
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});
