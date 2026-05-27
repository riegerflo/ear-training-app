import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../models/note.dart';

/// Generates a single sine-wave tone as a WAV byte buffer.
class _SynthAudioSource extends StreamAudioSource {
  final double frequency;
  final Duration duration;
  static const int _sampleRate = 44100;

  _SynthAudioSource({required this.frequency, required this.duration});

  Uint8List _buildWav() {
    final int numSamples =
        (_sampleRate * duration.inMilliseconds / 1000).round();
    final int dataSize = numSamples * 2;
    final Uint8List wav = Uint8List(44 + dataSize);
    _writeWavHeader(wav, dataSize);

    const double amplitude = 16000;
    for (int i = 0; i < numSamples; i++) {
      final double t = i / _sampleRate;
      final double fadeIn = (i < 220) ? i / 220 : 1.0;
      final double fadeOut =
          (i > numSamples - 220) ? (numSamples - i) / 220 : 1.0;
      final int sample =
          (amplitude * fadeIn * fadeOut * math.sin(2 * math.pi * frequency * t))
              .round()
              .clamp(-32768, 32767);
      wav[44 + i * 2] = sample & 0xFF;
      wav[44 + i * 2 + 1] = (sample >> 8) & 0xFF;
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

/// Generates a true polyphonic chord by mixing multiple sine waves into one
/// WAV buffer, avoiding the arpeggio effect of sequential playback.
class _SynthChordAudioSource extends StreamAudioSource {
  final List<double> frequencies;
  final Duration duration;
  static const int _sampleRate = 44100;

  _SynthChordAudioSource({required this.frequencies, required this.duration});

  Uint8List _buildWav() {
    final int numSamples =
        (_sampleRate * duration.inMilliseconds / 1000).round();
    final int dataSize = numSamples * 2;
    final Uint8List wav = Uint8List(44 + dataSize);
    _writeWavHeader(wav, dataSize);

    // Divide amplitude by note count to prevent clipping when summed.
    final double ampPerNote = 16000 / frequencies.length;
    for (int i = 0; i < numSamples; i++) {
      final double t = i / _sampleRate;
      final double fadeIn = (i < 220) ? i / 220 : 1.0;
      final double fadeOut =
          (i > numSamples - 220) ? (numSamples - i) / 220 : 1.0;
      double sample = 0.0;
      for (final freq in frequencies) {
        sample +=
            ampPerNote * fadeIn * fadeOut * math.sin(2 * math.pi * freq * t);
      }
      final int sampleInt = sample.round().clamp(-32768, 32767);
      wav[44 + i * 2] = sampleInt & 0xFF;
      wav[44 + i * 2 + 1] = (sampleInt >> 8) & 0xFF;
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

void _writeWavHeader(Uint8List wav, int dataSize) {
  final ByteData h = ByteData.view(wav.buffer, 0, 44);
  const int sr = 44100;
  // RIFF
  h.setUint8(0, 0x52); h.setUint8(1, 0x49); h.setUint8(2, 0x46); h.setUint8(3, 0x46);
  h.setUint32(4, 36 + dataSize, Endian.little);
  h.setUint8(8, 0x57); h.setUint8(9, 0x41); h.setUint8(10, 0x56); h.setUint8(11, 0x45);
  // fmt
  h.setUint8(12, 0x66); h.setUint8(13, 0x6D); h.setUint8(14, 0x74); h.setUint8(15, 0x20);
  h.setUint32(16, 16, Endian.little);
  h.setUint16(20, 1, Endian.little); // PCM
  h.setUint16(22, 1, Endian.little); // mono
  h.setUint32(24, sr, Endian.little);
  h.setUint32(28, sr * 2, Endian.little);
  h.setUint16(32, 2, Endian.little);
  h.setUint16(34, 16, Endian.little);
  // data
  h.setUint8(36, 0x64); h.setUint8(37, 0x61); h.setUint8(38, 0x74); h.setUint8(39, 0x61);
  h.setUint32(40, dataSize, Endian.little);
}

/// Service for playing musical notes, intervals, chords, and scales.
class AudioService {
  final AudioPlayer _player = AudioPlayer();

  static const Duration _defaultDuration = Duration(milliseconds: 800);

  Future<void> playNote(Note note, {Duration? duration}) async {
    await _playSingle(note.frequency, duration ?? _defaultDuration);
  }

  Future<void> playMidi(int midiNumber, {Duration? duration}) async {
    final note = NoteHelper.fromMidi(midiNumber);
    await playNote(note, duration: duration);
  }

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

  /// Plays all notes simultaneously as a true polyphonic chord.
  Future<void> playChord(
    int rootMidi,
    List<int> semitoneOffsets, {
    Duration? duration,
  }) async {
    final dur = duration ?? _defaultDuration;
    final frequencies = [rootMidi, ...semitoneOffsets.map((s) => rootMidi + s)]
        .map((m) => NoteHelper.fromMidi(m).frequency)
        .toList();
    final source =
        _SynthChordAudioSource(frequencies: frequencies, duration: dur);
    await _player.setAudioSource(source);
    await _player.play();
  }

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

  Future<void> dispose() async {
    await _player.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});
