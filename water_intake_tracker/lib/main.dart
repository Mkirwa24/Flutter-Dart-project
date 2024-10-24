import 'package:flutter/material.dart';
import 'home_screen.dart';


void main() {
  runApp(const WaterIntakeTrackerApp());
}

class WaterIntakeTrackerApp extends StatelessWidget {
  const WaterIntakeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      title: 'Water Intake Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
      
    );
  }
}