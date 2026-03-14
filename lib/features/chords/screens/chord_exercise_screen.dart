import 'package:flutter/material.dart';

class ChordExerciseScreen extends StatelessWidget {
  const ChordExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akkorde')),
      body: const Center(
        child: Text('Akkord-Übung – wird in Issue #5 implementiert'),
      ),
    );
  }
}
