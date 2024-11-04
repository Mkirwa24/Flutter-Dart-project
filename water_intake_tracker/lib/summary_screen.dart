import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
// Ensure you have your FirebaseAuthService imported

class SummaryScreen extends StatelessWidget {
  final double totalIntake;
  final String userId; // Pass the user ID to fetch records for that user

  const SummaryScreen({super.key, required this.totalIntake, required this.userId});

  @override
  Widget build(BuildContext context) {
    const double glassSize = 250; // Glass size is 250 ml

    // Function to save daily intake to Firestore
    void saveDailyIntake() async {
      try {
        await FirebaseFirestore.instance.collection('waterIntake').add({
          'userId': userId,
          'totalIntake': totalIntake,
          'date': DateTime.now(),
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Daily intake saved successfully!')),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving intake: $e')),
        );
      }
    }

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
                  saveDailyIntake(); // Call function to save daily intake
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                ),
                child: const Text('Save Daily Intake'),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to a new screen that shows the history
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IntakeHistoryScreen(userId: userId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text('View History'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// New screen to display the intake history
class IntakeHistoryScreen extends StatelessWidget {
  final String userId;

  const IntakeHistoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intake History'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('waterIntake')
            .where('userId', isEqualTo: userId)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No intake records found.'));
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Intake: ${data['totalIntake']} ml'),
                subtitle: Text('Date: ${data['date'].toDate()}'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

