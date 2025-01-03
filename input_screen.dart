import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'workout_screen.dart'; // Assuming this screen handles displaying the workout plan.

class InputScreenWorkout extends StatefulWidget {
  final String plan;

  const InputScreenWorkout({Key? key, required this.plan}) : super(key: key);

  @override
  _InputScreenWorkoutState createState() => _InputScreenWorkoutState();
}

class _InputScreenWorkoutState extends State<InputScreenWorkout> {
  late Future<Map<String, dynamic>> _workoutPlan;
  int days = 7; 

  @override
  void initState() {
    super.initState();
    _workoutPlan = fetchWorkoutPlan(widget.plan, days);
  }

  Future<Map<String, dynamic>> fetchWorkoutPlan(String goal, int days) async {
    // Updated URL for workouts
    final url = Uri.parse('https://45d9-35-184-243-22.ngrok-free.app/workout');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'input': 'generate $goal workout plan for $days days',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          throw Exception('Unexpected response format.');
        }
      } else {
        throw Exception('Failed to fetch workout plan: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching workout plan: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plan Details'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _workoutPlan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.hasData) {
            // Pass the fetched data to WorkoutScreen
            return WorkoutScreen(plan: snapshot.data!);
          }

          return const Center(
            child: Text(
              'No data available. Please try again later.',
              style: TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}
