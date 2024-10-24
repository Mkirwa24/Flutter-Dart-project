import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import notifications package
import 'summary_screen.dart';
import 'goal_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _waterController = TextEditingController();
  double totalIntake = 0.0;
  double glassSize = 250; // Each glass is 250 ml
  int totalGlassesGoal = 8; // Default goal is 8 glasses
  bool isCustomGoal = false;
  int _selectedIndex = 0; // Track selected bottom navigation item

  // Declare notification plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Initialize timezones
    // Initialize local notifications
    _initializeNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }

  // Initialize notification settings
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Set reminder for 2 hours later
  Future<void> _setReminder() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Hydration Reminder',
      'It\'s time to drink water!',
      tz.TZDateTime.now(tz.local).add(const Duration(hours: 2)),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.time, // Schedule 2 hours later
    );

// Show reminder confirmation dialog
    _showReminderDialog();
  }

// Function to show reminder dialog
  void _showReminderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reminder Set'),
          content: const Text(
              'Your hydration reminder has been set for 2 hours later!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminder set for 2 hours later!')),
    );
  }

  void _addWaterIntake() {
    setState(() {
      totalIntake += double.tryParse(_waterController.text) ?? 0;
      _waterController.clear();
      _checkGoalStatus();
    });
  }

  void _updateGoal(int newGoal) {
    setState(() {
      totalGlassesGoal = newGoal;
      isCustomGoal = true;
    });
  }

  void _resetIntake() {
    _showResetConfirmation();
  }

  String _getWelcomeMessage() {
    return totalIntake == 0
        ? 'Welcome! The goal is $totalGlassesGoal glasses of water today. Stay Hydrated! Stay Healthy!'
        : 'Keep going! You\'re doing great!';
  }

  String _getCongratulationsMessage() {
    if (totalIntake >= totalGlassesGoal * glassSize) {
      return 'Congratulations! 🎉 You have reached your goal of $totalGlassesGoal glasses today!';
    } else {
      double remainingWater = totalGlassesGoal * glassSize - totalIntake;
      int remainingGlasses = (remainingWater / glassSize).ceil();
      return 'You are doing great! Only $remainingGlasses glass(es) left to reach your goal.';
    }
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Welcome!'),
          content: Text(_getWelcomeMessage()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Confirmation'),
          content:
              const Text('Are you sure you want to reset your water intake?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _resetIntakeConfirmed();
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _resetIntakeConfirmed() {
    setState(() {
      totalIntake = 0.0;
      isCustomGoal = false;
      _waterController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Water intake has been reset!'),
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  void _checkGoalStatus() {
    if (totalIntake >= totalGlassesGoal * glassSize) {
      _showCongratulationsMessage();
    }
  }

  void _showCongratulationsMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You have reached your water intake goal!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Handle Bottom Navigation Bar tap
  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      return; // No action if already on the selected screen
    }

    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // Navigate to Summary Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryScreen(totalIntake: totalIntake),
        ),
      );
    } else if (index == 2) {
      // Navigate to Goal Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GoalScreen(updateGoal: _updateGoal),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake Tracker'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Welcome message
            Text(
              _getWelcomeMessage(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Glass Icon next to Water input field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _waterController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter water intake (ml)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset(
                  'assets/images/glass_icon.png',
                  height: 40,
                  width: 40,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Add water intake button
            ElevatedButton(
              onPressed: _addWaterIntake,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 124, 171, 253), // Button color
              ),
              child: const Text('Add Water Intake'),
            ),
            const SizedBox(height: 20),

            // Total water intake display
            Text(
              'Total Water Intake: ${totalIntake.toStringAsFixed(0)} ml',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 20),

            // Display number of glasses consumed
            Text(
              'Glasses Consumed: ${(totalIntake / glassSize).floor()} of $totalGlassesGoal',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: 20),

            // Linear Progress Bar
            LinearProgressIndicator(
              value: totalIntake / (totalGlassesGoal * glassSize),
              backgroundColor: Colors.grey[300],
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),

            // Congratulations or encouragement message
            Text(
              _getCongratulationsMessage(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: totalIntake >= totalGlassesGoal * glassSize
                    ? Colors.green
                    : Colors.orangeAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),


         // Buttons in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            // Reset button
            ElevatedButton(
              onPressed: _resetIntake,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 110, 110), // Button color
              ),
              child: const Text('Reset Intake'),
            ),
            
            // Set Reminder button
            ElevatedButton(
              onPressed: _setReminder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent, // Button color
              ),
              child: const Text('Set Reminder'),
            ),
          ],
        ),
      ],
    ),
  ),


      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.summarize),
            label: 'Summary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Goal',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}
