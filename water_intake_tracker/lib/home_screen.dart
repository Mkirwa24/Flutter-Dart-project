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
  final PageController _pageController = PageController();
  bool _isHomeScreen = true; // Variable to track if HomeScreen is active
  
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isHomeScreen) {
        _showWelcomeDialog();
      }
    });
    _getUserId(); // Fetch the user ID when the screen initializes
  }

  void _getUserId() async {
    String? id = _authService
        .getCurrentUserId(); // Get user ID from FirebaseAuthService
    setState(() {
      userId = id; // Set the user ID
    });
  }

  void _addWaterIntake() {
    final intake = double.tryParse(_waterController.text) ?? 0;

    if (intake < glassSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: A glass should be at least 250 ml.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      totalIntake += intake;
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
        ? 'Welcome! Stay Hydrated, Stay Healthy!'
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
    // Check if the widget is mounted
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Welcome!'),
            content: const Text(
                'The goal is 8 glasses of water today. Stay Hydrated, Stay Healthy!'),
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
  }

  void _showResetConfirmation() {
    // Ensure the widget is mounted before showing the dialog
  if (mounted) {
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
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetIntakeConfirmed();
              },
              child: const Text('Reset Water Intake'),
            ),
          ],
        );
      },
    );
  }
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
    // Check if the widget is mounted
    if (mounted) {
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
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isHomeScreen = index == 0; // Set to true when HomeScreen is selected
    });
    _pageController.jumpToPage(index); // Switch pages without animation
  }

  Future<void> _signOut() async {
    await _authService.logout();
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isHomeScreen // Only show AppBar on the Home Screen
        ? AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.water_drop, color: Colors.white),
            SizedBox(width: 8),
            Text('Water Intake Tracker'),
          ],
        ),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label:
                const Text('Sign Out', style: TextStyle(color: Colors.white)),
            onPressed: _signOut,
          ),
        ],
      )
      : null, // If not on the home screen, don't display AppBar
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildHomeContent(), // Home screen content
          SummaryScreen(
            totalIntake: totalIntake,
            userId: userId ?? '',
            goalIntake: totalGlassesGoal * glassSize,
          ), // Summary screen
          GoalScreen(updateGoal: _updateGoal), // Set Goal screen
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Summary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Set Goal',
          ),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
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
                  color: Colors.blueAccent),
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
                Image.asset('assets/images/glass_icon.png',
                    height: 40, width: 40),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addWaterIntake,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 124, 171, 253)),
              child: const Text('Add Water Intake'),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Water Intake: ${totalIntake.toStringAsFixed(0)} ml',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent),
            ),
            const SizedBox(height: 20),
            Text(
              'Glasses Consumed: ${(totalIntake / glassSize).floor()} of $totalGlassesGoal',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.orangeAccent),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: totalIntake / (totalGlassesGoal * glassSize),
              backgroundColor: Colors.grey[300],
              color: Colors.lightBlueAccent,
              minHeight: 10,
            ),
            const SizedBox(height: 20),
            Text(
              _getCongratulationsMessage(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: totalIntake >= totalGlassesGoal * glassSize
                    ? Colors.green
                    : Colors.redAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetIntake,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent),
              child: const Text('Reset Intake'),
            ),
          ],
        ),
      ),
    );
  }
}
