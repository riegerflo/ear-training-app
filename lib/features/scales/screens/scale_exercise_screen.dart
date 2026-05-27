import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/audio_service.dart';
import '../../../shared/widgets/difficulty_selector.dart';
import '../../../shared/widgets/session_summary_dialog.dart';
import '../models/scale_model.dart';
import '../providers/scale_provider.dart';

class ScaleExerciseScreen extends ConsumerWidget {
  const ScaleExerciseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scaleExerciseProvider);
    final notifier = ref.read(scaleExerciseProvider.notifier);
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
          exerciseName: 'Skalen',
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
          title: const Text('Skalen-Übung'),
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
              Icon(Icons.queue_music,
                  size: 80,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7)),
              const SizedBox(height: 16),
              Text(
                'Welche Skala hörst du?',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Skala abspielen'),
                onPressed: () async {
                  try {
                    await audio.playScale(
                      state.rootMidi,
                      state.currentScale.semitonePattern,
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
              ...state.choices.map((scale) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AnswerButton(
                      scale: scale,
                      state: state,
                      onTap: state.answered
                          ? null
                          : () => notifier.answer(scale),
                    ),
                  )),
              const SizedBox(height: 16),
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
  final ScaleType scale;
  final ScaleExerciseState state;
  final VoidCallback? onTap;

  const _AnswerButton(
      {required this.scale, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? color;

    if (state.answered) {
      if (scale == state.currentScale) color = Colors.green;
      else if (scale == state.selectedAnswer) color = Colors.red;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: color != null ? Colors.white : null,
            padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16)),
        onPressed: onTap,
        child: Text(scale.name,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
      ),
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
