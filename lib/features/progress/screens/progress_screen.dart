import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fortschritt')),
      body: const Center(
        child: Text('Fortschrittsübersicht – wird in Issue #8 implementiert'),
      ),
    );
  }
}
