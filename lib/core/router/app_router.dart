import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/intervals/screens/interval_exercise_screen.dart';
import '../../features/chords/screens/chord_exercise_screen.dart';
import '../../features/scales/screens/scale_exercise_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../widgets/main_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/progress',
            name: 'progress',
            builder: (context, state) => const ProgressScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/intervals',
        name: 'intervals',
        builder: (context, state) => const IntervalExerciseScreen(),
      ),
      GoRoute(
        path: '/chords',
        name: 'chords',
        builder: (context, state) => const ChordExerciseScreen(),
      ),
      GoRoute(
        path: '/scales',
        name: 'scales',
        builder: (context, state) => const ScaleExerciseScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
