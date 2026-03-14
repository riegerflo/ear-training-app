import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_service.dart';
import '../models/interval_model.dart';
import '../providers/interval_provider.dart';

class IntervalExerciseScreen extends ConsumerWidget {
  const IntervalExerciseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(intervalExerciseProvider);
    final notifier = ref.read(intervalExerciseProvider.notifier);
    final audio = ref.read(audioServiceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intervall-Übung'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${state.score} / ${state.totalAnswered}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Play button
            const Spacer(),
            Icon(
              Icons.music_note,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Welches Intervall hörst du?',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Töne abspielen'),
              onPressed: () async {
                await audio.playInterval(
                  state.rootMidi,
                  state.currentInterval.semitones,
                );
              },
            ),
            const Spacer(),
            // Answer feedback
            if (state.answered)
              _FeedbackBanner(isCorrect: state.isCorrect),
            const SizedBox(height: 16),
            // Answer choices
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: state.choices.map((interval) {
                return _AnswerButton(
                  interval: interval,
                  state: state,
                  onTap: state.answered
                      ? null
                      : () => notifier.answer(interval),
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
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final Interval interval;
  final IntervalExerciseState state;
  final VoidCallback? onTap;

  const _AnswerButton({
    required this.interval,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? color;

    if (state.answered) {
      if (interval == state.currentInterval) {
        color = Colors.green;
      } else if (interval == state.selectedAnswer) {
        color = Colors.red;
      }
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor:
            color != null ? Colors.white : null,
      ),
      onPressed: onTap,
      child: Text(
        interval.name,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
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
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? Colors.green : Colors.red,
          ),
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
