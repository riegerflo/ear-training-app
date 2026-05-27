import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/exercise.dart';
import '../../core/providers/difficulty_provider.dart';

/// A compact segmented button row for picking exercise difficulty.
class DifficultySelector extends ConsumerWidget {
  const DifficultySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(difficultyProvider);

    return SegmentedButton<Difficulty>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      segments: const [
        ButtonSegment(
          value: Difficulty.beginner,
          label: Text('Anfänger'),
        ),
        ButtonSegment(
          value: Difficulty.intermediate,
          label: Text('Mittel'),
        ),
        ButtonSegment(
          value: Difficulty.advanced,
          label: Text('Profi'),
        ),
      ],
      selected: {current},
      onSelectionChanged: (selection) {
        ref.read(difficultyProvider.notifier).state = selection.first;
      },
    );
  }
}
