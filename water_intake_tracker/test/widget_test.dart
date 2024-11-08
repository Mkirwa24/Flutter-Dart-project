import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_intake_tracker/main.dart'; // Adjust if your main.dart path differs
// ignore: unused_import
import 'package:water_intake_tracker/home_screen.dart';
import 'package:water_intake_tracker/goal_screen.dart';
import 'package:water_intake_tracker/summary_screen.dart';

void main() {
  // Test for HomeScreen to verify initial state
  testWidgets('HomeScreen displays welcome message and handles water intake input', (WidgetTester tester) async {
    await tester.pumpWidget(const WaterIntakeTrackerApp());

    // Verify the initial welcome message
    expect(find.text('Welcome! The goal is 8 glasses of water today.'), findsOneWidget);

    // Input water intake and add it
    await tester.enterText(find.byType(TextField), '250'); // Entering 250ml
    await tester.tap(find.text('Add Water Intake'));
    await tester.pump();

    // Verify that total intake updates
    expect(find.text('Total Water Intake: 250 ml'), findsOneWidget);
    expect(find.text('Glasses Consumed: 1 of 8'), findsOneWidget);
  });

  // Test for GoalScreen to verify setting a custom goal
  testWidgets('GoalScreen allows setting custom water intake goal', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: GoalScreen(updateGoal: (int newGoal) {})));

    // Enter a custom goal of 10 glasses
    await tester.enterText(find.byType(TextField), '10');
    await tester.tap(find.text('Save Goal'));
    await tester.pumpAndSettle();

    // Verify that the custom goal was set (in the actual app, you'd use state management)
    expect(find.text('10'), findsNothing); // Custom goal is saved and the screen is popped
  });

  // Test for SummaryScreen to verify summary of total intake
  testWidgets('SummaryScreen displays correct total intake summary', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SummaryScreen(totalIntake: 2000, userId: '', goalIntake: 2500,)));

    // Verify the summary message for 2000 ml intake (8 glasses is the goal)
    expect(find.text('Total Water Intake: 2000 ml'), findsOneWidget);
    expect(find.text('Goal Intake: 2500 mL'), findsOneWidget);
    expect(find.text('Great job!'), findsOneWidget);
  });
}