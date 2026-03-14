import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/score_service.dart';

/// Provides all progress summaries for the home screen.
final allProgressProvider =
    FutureProvider<List<UserProgressSummary>>((ref) async {
  final service = ref.watch(scoreServiceProvider);
  return service.getAllSummaries();
});
