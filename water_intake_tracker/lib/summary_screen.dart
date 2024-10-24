import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  final double totalIntake;

  const SummaryScreen({super.key, required this.totalIntake});

  @override
  Widget build(BuildContext context) {
    const double glassSize = 250; // Glass size is 250 ml

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake Summary'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/glass_icon.png',
                height: 80,
                width: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                'Great job!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Total Water Intake: ${totalIntake.toStringAsFixed(0)} ml',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Glasses Consumed: ${(totalIntake / glassSize).floor()}',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Navigate back to the HomeScreen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}