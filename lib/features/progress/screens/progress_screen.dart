import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/exercise.dart';
import '../../../core/services/score_service.dart';
import '../../../shared/widgets/streak_badge.dart';
import '../../home/providers/home_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(allProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fortschritt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allProgressProvider),
          ),
        ],
      ),
      body: summaries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (list) {
          final relevant = list
              .where((s) => [
                    ExerciseType.interval,
                    ExerciseType.chord,
                    ExerciseType.scale,
                  ].contains(s.exerciseType))
              .toList();

          final totalAttempts =
              relevant.fold<int>(0, (sum, s) => sum + s.totalAttempts);
          final totalCorrect =
              relevant.fold<int>(0, (sum, s) => sum + s.correctAttempts);
          final overallAccuracy =
              totalAttempts == 0 ? 0.0 : totalCorrect / totalAttempts;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Overall card
              _OverallCard(
                totalAttempts: totalAttempts,
                totalCorrect: totalCorrect,
                accuracy: overallAccuracy,
              ),
              const SizedBox(height: 24),
              Text(
                'Nach Kategorie',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...relevant.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ProgressCard(summary: s),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OverallCard extends StatelessWidget {
  final int totalAttempts;
  final int totalCorrect;
  final double accuracy;

  const _OverallCard({
    required this.totalAttempts,
    required this.totalCorrect,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (accuracy * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gesamtübersicht',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(label: 'Versuche', value: '$totalAttempts'),
                _Stat(label: 'Richtig', value: '$totalCorrect'),
                _Stat(label: '% Richtig', value: '$pct%'),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: accuracy,
                minHeight: 12,
                backgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  accuracy >= 0.7
                      ? Colors.green
                      : accuracy >= 0.5
                          ? Colors.orange
                          : theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final UserProgressSummary summary;

  const _ProgressCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (summary.exerciseType) {
      ExerciseType.interval => const Color(0xFF6C63FF),
      ExerciseType.chord => const Color(0xFF03DAC6),
      ExerciseType.scale => const Color(0xFFFF6584),
      _ => theme.colorScheme.primary,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(summary.exerciseName,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    StreakBadge(streak: summary.currentStreak),
                    const SizedBox(width: 8),
                    Text(summary.accuracyPercent,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('${summary.totalAttempts} Versuche',
                    style: theme.textTheme.bodySmall),
                const SizedBox(width: 12),
                Text('${summary.correctAttempts} richtig',
                    style: theme.textTheme.bodySmall),
                if (summary.longestStreak > 0) ...[
                  const SizedBox(width: 12),
                  Text('Beste Streak: ${summary.longestStreak}',
                      style: theme.textTheme.bodySmall),
                ],
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: summary.accuracy,
                minHeight: 8,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            if (summary.lastPracticed != null) ...[
              const SizedBox(height: 6),
              Text(
                'Zuletzt geübt: ${_formatDate(summary.lastPracticed!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
