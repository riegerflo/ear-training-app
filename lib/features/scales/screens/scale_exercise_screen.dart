import 'package:flutter/material.dart';

class ScaleExerciseScreen extends StatelessWidget {
  const ScaleExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skalen')),
      body: const Center(
        child: Text('Skalen-Übung – wird in Issue #6 implementiert'),
      ),
    );
  }
}
