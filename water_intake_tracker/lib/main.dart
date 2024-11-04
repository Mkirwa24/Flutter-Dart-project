import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:water_intake_tracker/home_screen.dart';
import 'package:timezone/data/latest.dart' as tz; // Add timezone import
// import 'firebase_options.dart'; // Import Firebase options
import 'login_screen.dart'; // Import LoginScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options:  const FirebaseOptions (
       apiKey: 'AIzaSyB9cy3t6M0UcG_BXEZHTSevcy99J52QOpE',               // from "current_key"
       authDomain:"water-intake-tracker-327a7.firebaseapp.com",
       appId: '1:597278146739:android:dbd67acba2e33fb191f0c6',         // from "mobilesdk_app_id"
       messagingSenderId: '597278146739',                              // from "project_number"
       projectId: 'water-intake-tracker-327a7',                        // from "project_id"
       storageBucket: 'water-intake-tracker-327a7.appspot.com',        // from "storage_bucket"
    )
  );

   // Initialize timezone data for scheduling notifications
  tz.initializeTimeZones();
  runApp(const WaterIntakeTrackerApp());
}

class WaterIntakeTrackerApp extends StatelessWidget {
  const WaterIntakeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Water Intake Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(), // Start with LoginScreen
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(userId: '',),
        // Add other routes as needed
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const LoginScreen(), // Fallback to LoginScreen
      ),
    );
  }
}