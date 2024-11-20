import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class SummaryScreen extends StatelessWidget {
  final double totalIntake;
  final double goalIntake; // The user's goal intake
  final String userId;

  const SummaryScreen({
    Key? key,
    required this.totalIntake,
    required this.userId,
    double? goalIntake,
  })  : goalIntake = goalIntake ?? 2000, // Default to 2000 if null
        super(key: key);

  @override
  Widget build(BuildContext context) {
    const double glassSize = 250;

    // Function to save daily intake to Firestore with duplicate check
    void saveDailyIntake() async {
      // Check if the user has met their goal
      if (totalIntake < goalIntake) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Goal Not Met'),
              content: Text(
                  'Please reach your goal of ${goalIntake.toStringAsFixed(0)} ml before saving.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        });
        return;
      }

      await Future.delayed(const Duration(seconds: 1));

      try {
        // Check if an entry already exists for today
        final today = DateTime.now();
        final existingIntake = await FirebaseFirestore.instance
            .collection('waterIntake')
            .where('userId', isEqualTo: userId)
            .where('date',
                isGreaterThanOrEqualTo: DateTime(today.year, today.month, today.day),
                isLessThan: DateTime(today.year, today.month, today.day + 1))
            .get();

        if (existingIntake.docs.isNotEmpty) {
          // Show duplicate entry message if intake has already been saved today
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Intake Already Saved'),
                content: const Text('Intake for today has already been saved. '),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          });
          return;
        }

        // Save intake if no duplicate found
        await FirebaseFirestore.instance.collection('waterIntake').add({
          'userId': userId,
          'totalIntake': totalIntake,
          'date': DateTime.now(),
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Success'),
              content: Text(
                  'Congratulations! You have reached your daily goal of ${goalIntake.toStringAsFixed(0)} ml.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        });
      } catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving intake: $e'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    }

        // Show reminder dialog after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return; // Check if the widget is still in the widget tree
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reminder'),
          content: const Text('Remember to save your daily intake!, Click the save intake icon once and view history'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });



    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake Summary'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.save,
                            size: 40, color: Colors.lightBlue),
                        onPressed: saveDailyIntake,
                      ),
                      const Text('Save Intake',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.history,
                            size: 40, color: Colors.blueAccent),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  IntakeHistoryScreen(userId: userId),
                            ),
                          );
                        },
                      ),
                      const Text('View History',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
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
              Text(
                'Goal Intake: ${goalIntake.toStringAsFixed(0)} ml',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
              DateTime date = (data['date'] as Timestamp).toDate();
              String formattedDate = DateFormat('MMM dd, yyyy – HH:mm')
                  .format(date); // Format the date

              return ListTile(
                title: Text('Intake: ${data['totalIntake']} ml'),
                subtitle: Text('Date: $formattedDate'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}