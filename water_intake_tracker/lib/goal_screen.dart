import 'package:flutter/material.dart';

class GoalScreen extends StatefulWidget {
  final Function(int) updateGoal;

  const GoalScreen({super.key, required this.updateGoal});

  @override
  // ignore: library_private_types_in_public_api
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final TextEditingController _goalController = TextEditingController();

  void _saveGoal() {
    int newGoal = int.tryParse(_goalController.text) ?? 8;
    widget.updateGoal(newGoal);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Custom Goal'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter your custom goal (in glasses)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent, // Button color
              ),
              child: const Text('Save Goal'),
            ),
          ],
        ),
      ),
    );
  }
}