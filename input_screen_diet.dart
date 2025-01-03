import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'workout_screen.dart';

class InputScreendiet extends StatefulWidget {
  final String plan;

  InputScreendiet({required this.plan});

  @override
  _InputScreendietState createState() => _InputScreendietState();
}

class _InputScreendietState extends State<InputScreendiet> {
  late Future<Map<String, dynamic>> _dietPlan;
  int days = 7;  // default

  @override
  void initState() {
    super.initState();
    _dietPlan = fetchDietPlan(widget.plan, days);
  }

  Future<Map<String, dynamic>> fetchDietPlan(String goal, int days) async {
    final url = Uri.parse('https://45d9-35-184-243-22.ngrok-free.app/diet');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'input': 'generate $goal diet plan for $days days',
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch diet plan: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching diet plan: $error');
      throw Exception('Error fetching diet plan: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Plan Details'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dietPlan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.hasData) {
            return WorkoutScreen(plan: snapshot.data!);
          }

          return const Center(child: Text('No data available'));
        },
      ),
    );
  }
}
