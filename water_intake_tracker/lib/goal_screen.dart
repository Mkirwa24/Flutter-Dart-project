import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: unused_import
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class GoalScreen extends StatefulWidget {
  final Function(int) updateGoal;

  const GoalScreen({Key? key, required this.updateGoal}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final TextEditingController _goalController = TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  int _selectedInterval = 3; // Default interval for reminders (in hours)

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    // Initialization settings for Android and iOS
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _requestPermissions() async {
    // Request permissions for notifications (especially important for iOS)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> _scheduleIntervalReminder() async {
    // Schedule repeating reminder based on user preference, to run in the background
    await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      'Water Reminder',
      'Time to drink water!',
      RepeatInterval.everyMinute, // Set your desired interval (e.g., hourly)
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'Water Reminder Channel',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      // ignore: deprecated_member_use
      androidAllowWhileIdle: true,
    );
  }

  Future<void> _scheduleDailyGoalReminder(int goal) async {
    // Schedule daily reminder to encourage reaching the goal
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Daily Water Goal Reminder',
      'Remember to reach your goal of $goal glasses today!',
      _nextInstanceOfEvening(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'Goal Reminder Channel',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      // ignore: deprecated_member_use
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfEvening() {
    // Set reminder time to 8:00 PM in local timezone
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  void _saveGoal() {
    int newGoal = int.tryParse(_goalController.text) ?? 8;
    widget.updateGoal(newGoal);

    // Request permissions (especially for iOS)
    _requestPermissions();

    // Schedule notifications for reminders
    _scheduleIntervalReminder();
    _scheduleDailyGoalReminder(newGoal);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Remind me every:'),
                DropdownButton<int>(
                  value: _selectedInterval,
                  items: [3, 4, 5].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value hours'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedInterval = newValue!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent, // Button color
              ),
              child: const Text('Save Goal & Set Reminders'),
            ),
          ],
        ),
      ),
    );
  }
}