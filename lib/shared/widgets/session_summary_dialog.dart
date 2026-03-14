import 'package:flutter/material.dart';

/// Displays a session summary (correct/total) at the end of an exercise session.
class SessionSummaryDialog extends StatelessWidget {
  final int correct;
  final int total;
  final String exerciseName;
  final VoidCallback onRestart;
  final VoidCallback onClose;

  const SessionSummaryDialog({
    super.key,
    required this.correct,
    required this.total,
    required this.exerciseName,
    required this.onRestart,
    required this.onClose,
  });

  double get _accuracy => total == 0 ? 0.0 : correct / total;

  String get _emoji {
    if (_accuracy >= 0.9) return '🏆';
    if (_accuracy >= 0.7) return '🎉';
    if (_accuracy >= 0.5) return '👍';
    return '💪';
  }

  String get _message {
    if (_accuracy >= 0.9) return 'Ausgezeichnet!';
    if (_accuracy >= 0.7) return 'Super Arbeit!';
    if (_accuracy >= 0.5) return 'Gute Leistung!';
    return 'Weiter üben!';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (_accuracy * 100).round();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              _message,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$exerciseName – Session abgeschlossen',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Score row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatBox(label: 'Richtig', value: '$correct / $total'),
                _StatBox(
                  label: 'Trefferquote',
                  value: '$pct%',
                  color: _accuracyColor(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _accuracy,
                minHeight: 12,
                backgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _accuracyColor(context),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClose,
                    child: const Text('Schließen'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onRestart,
                    child: const Text('Nochmal'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _accuracyColor(BuildContext context) {
    if (_accuracy >= 0.7) return Colors.green;
    if (_accuracy >= 0.5) return Colors.orange;
    return Colors.red;
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatBox({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
