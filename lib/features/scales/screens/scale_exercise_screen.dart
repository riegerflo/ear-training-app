import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_service.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skalen-Übung'),
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
            const Spacer(),
            Icon(Icons.queue_music,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.7)),
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
                await audio.playScale(
                  state.rootMidi,
                  state.currentScale.semitonePattern,
                );
              },
            ),
            const Spacer(),
            if (state.answered)
              _FeedbackBanner(isCorrect: state.isCorrect),
            const SizedBox(height: 16),
            // Answer choices as a column (names can be long)
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
