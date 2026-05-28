import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise.dart';

/// Global difficulty setting shared across all exercises.
/// Not autoDispose — persists for the lifetime of the app session.
final difficultyProvider = StateProvider<Difficulty>((ref) => Difficulty.beginner);
