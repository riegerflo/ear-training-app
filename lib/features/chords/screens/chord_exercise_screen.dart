import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/audio_service.dart';
import '../../../shared/widgets/difficulty_selector.dart';
import '../../../shared/widgets/session_summary_dialog.dart';
import '../models/chord_model.dart';
import '../providers/chord_provider.dart';

class ChordExerciseScreen extends ConsumerWidget {
  const ChordExerciseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chordExerciseProvider);
    final notifier = ref.read(chordExerciseProvider.notifier);
    final audio = ref.read(audioServiceProvider);
    final theme = Theme.of(context);

    Future<void> handleBack() async {
      if (state.totalAnswered == 0) {
        if (context.mounted) context.pop();
        return;
      }
      if (!context.mounted) return;
      final shouldClose = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => SessionSummaryDialog(
          correct: state.score,
          total: state.totalAnswered,
          exerciseName: 'Akkorde',
          onRestart: () {
            notifier.reset();
            Navigator.of(ctx).pop(false);
          },
          onClose: () => Navigator.of(ctx).pop(true),
        ),
      );
      if ((shouldClose ?? false) && context.mounted) {
        context.pop();
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Akkord-Übung'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: handleBack,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${state.score} / ${state.totalAnswered}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const DifficultySelector(),
              const Spacer(),
              Icon(Icons.piano,
                  size: 80,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7)),
              const SizedBox(height: 16),
              Text(
                'Welchen Akkord hörst du?',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Akkord abspielen'),
                onPressed: () async {
                  try {
                    await audio.playChord(
                      state.rootMidi,
                      state.currentChord.semitoneOffsets,
                    );
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Audio konnte nicht abgespielt werden.')),
                      );
                    }
                  }
                },
              ),
              const Spacer(),
              if (state.answered)
                _FeedbackBanner(isCorrect: state.isCorrect),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3,
                children: state.choices.map((chord) {
                  return _AnswerButton(
                    chord: chord,
                    state: state,
                    onTap:
                        state.answered ? null : () => notifier.answer(chord),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              if (state.answered)
                FilledButton(
                  onPressed: notifier.next,
                  child: const Text('Nächste Frage'),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final ChordType chord;
  final ChordExerciseState state;
  final VoidCallback? onTap;

  const _AnswerButton(
      {required this.chord, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? color;

    if (state.answered) {
      if (chord == state.currentChord) color = Colors.green;
      else if (chord == state.selectedAnswer) color = Colors.red;
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: color != null ? Colors.white : null),
      onPressed: onTap,
      child: Text(chord.name,
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  final bool isCorrect;
  const _FeedbackBanner({required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red),
          const SizedBox(width: 8),
          Text(
            isCorrect ? 'Richtig! 🎉' : 'Falsch – versuch es nochmal!',
            style: TextStyle(
              color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
