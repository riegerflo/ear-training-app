import 'package:flutter/material.dart';

class IntervalExerciseScreen extends StatelessWidget {
  const IntervalExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Intervalle')),
      body: const Center(
        child: Text('Intervall-Übung – wird in Issue #4 implementiert'),
      ),
    );
  }
}
