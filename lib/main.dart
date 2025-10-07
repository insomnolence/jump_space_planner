import 'package:flutter/material.dart';
import 'screens/planner_screen.dart';

void main() {
  runApp(const JumpSpacePlannerApp());
}

class JumpSpacePlannerApp extends StatelessWidget {
  const JumpSpacePlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jump Space Power Grid Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const PlannerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
