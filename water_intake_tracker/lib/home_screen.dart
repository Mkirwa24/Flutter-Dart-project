import 'package:flutter/material.dart';
import 'package:water_intake_tracker/firebase_auth_service.dart'; // Import your FirebaseAuthService class
import 'summary_screen.dart';
import 'goal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required String userId});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _waterController = TextEditingController();
  double totalIntake = 0.0;
  double glassSize = 250; // Each glass is 250 ml
  int totalGlassesGoal = 8; // Default goal is 8 glasses
  bool isCustomGoal = false;
  int _selectedIndex = 0; // Track selected bottom navigation item
  String? userId; // Store user ID

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
    _getUserId(); // Fetch the user ID when the screen initializes
  }

  void _getUserId() async {
    // ignore: await_only_futures
    String? id = await _authService.getCurrentUserId(); // Get user ID from FirebaseAuthService
    setState(() {
      userId = id; // Set the user ID
    });
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
        ? 'Welcome!  Stay Hydrated, Stay Healthy!'
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
          content: const Text('The goal is 8 glasses of water today. Stay Hydrated, Stay Healthy!'),
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
          content: const Text('Are you sure you want to reset your water intake?'),
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
          title: const Text('Congratulations! 🎉'),
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

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      return; // No action if already on the selected screen
    }

    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryScreen(totalIntake: totalIntake, userId: userId!), // Pass user ID
        ),
      ).then((_) {
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GoalScreen(updateGoal: _updateGoal),
        ),
      ).then((_) {
        setState(() {
          _selectedIndex = 0;
        });
      });
    }
  }

  Future<void> _signOut() async {
    await _authService.logout();
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake Tracker'),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
              ElevatedButton(
                onPressed: _addWaterIntake,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 124, 171, 253),
                ),
                child: const Text('Add Water Intake'),
              ),
              const SizedBox(height: 20),
              Text(
                'Total Water Intake: ${totalIntake.toStringAsFixed(0)} ml',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Glasses Consumed: ${(totalIntake / glassSize).floor()} of $totalGlassesGoal',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: totalIntake / (totalGlassesGoal * glassSize),
                backgroundColor: Colors.grey[300],
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 20),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _resetIntake,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 110, 110),
                    ),
                    child: const Text('Reset Intake'),
                  ),
                ],
              ),
            ],
          ),
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
            icon: Icon(Icons.dashboard),
            label: 'Goals',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
