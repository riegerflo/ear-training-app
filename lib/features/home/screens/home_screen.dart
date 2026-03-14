import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/exercise.dart';
import '../../../core/services/score_service.dart';
import '../../../shared/widgets/streak_badge.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(allProgressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎵 Ear Training'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(allProgressProvider),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall stats header
                summaries.when(
                  data: (list) => _OverallStats(summaries: list),
                  loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Was möchtest du üben?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Wähle eine Übungskategorie',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                // Exercise cards with progress
                summaries.when(
                  data: (list) {
                    final byType = {
                      for (final s in list) s.exerciseType: s
                    };
                    return GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _ExerciseCard(
                          icon: Icons.timeline,
                          title: 'Intervalle',
                          subtitle: '8 Grundintervalle',
                          color: const Color(0xFF6C63FF),
                          onTap: () => context.push('/intervals'),
                          summary: byType[ExerciseType.interval],
                        ),
                        _ExerciseCard(
                          icon: Icons.queue_music,
                          title: 'Akkorde',
                          subtitle: 'Dur, Moll & Dom7',
                          color: const Color(0xFF03DAC6),
                          onTap: () => context.push('/chords'),
                          summary: byType[ExerciseType.chord],
                        ),
                        _ExerciseCard(
                          icon: Icons.piano,
                          title: 'Skalen',
                          subtitle: 'Dur & Moll',
                          color: const Color(0xFFFF6584),
                          onTap: () => context.push('/scales'),
                          summary: byType[ExerciseType.scale],
                        ),
                        _ExerciseCard(
                          icon: Icons.emoji_events,
                          title: 'Fortschritt',
                          subtitle: 'Deine Statistiken',
                          color: const Color(0xFFFFB830),
                          onTap: () => context.push('/progress'),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Fehler: $e')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverallStats extends StatelessWidget {
  final List<UserProgressSummary> summaries;

  const _OverallStats({required this.summaries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final relevant = summaries
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
    final maxStreak =
        relevant.fold<int>(0, (max, s) => s.currentStreak > max ? s.currentStreak : max);

    if (totalAttempts == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondaryContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Willkommen! 👋',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Starte deine erste Übung.',
                style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dein Fortschritt',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              StreakBadge(streak: maxStreak),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(
                label: 'Versuche',
                value: '$totalAttempts',
              ),
              _MiniStat(
                label: 'Richtig',
                value: '$totalCorrect',
              ),
              _MiniStat(
                label: 'Genauigkeit',
                value: '${(overallAccuracy * 100).round()}%',
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: overallAccuracy,
              minHeight: 8,
              backgroundColor:
                  theme.colorScheme.onPrimaryContainer.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final UserProgressSummary? summary;

  const _ExerciseCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = summary != null && summary!.totalAttempts > 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  if (hasData)
                    Text(
                      summary!.accuracyPercent,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    hasData
                        ? '${summary!.totalAttempts} Versuche'
                        : subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (hasData) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: summary!.accuracy,
                        minHeight: 4,
                        backgroundColor: color.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
