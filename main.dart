import 'package:flutter/material.dart';
import 'chatbot_screen.dart';
import 'userdetails.dart';
import 'input_screen.dart'; // Ensure this file defines InputScreen
import 'input_screen_diet.dart';
import 'cv_model_screen.dart';
import 'progress_tracker_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GymApp());
}

class GymApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: UserDetailsPage(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/progress': (context) => const ProgressTrackerPage(),
        '/chatbot': (context) => ChatbotScreen(),
        '/dietplan': (context) => InputScreendiet(plan: 'plan'),
        '/cvmodel': (context) => CVModelScreen(),
        '/workout': (context) => InputScreenWorkout(plan: 'plan'),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sapota FIT'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'), // Path to your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                const Text(
                  'Welcome to Sapota Fit!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, 
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildOptionCard(
                  context,
                  title: 'Get Workout Split',
                  subtitle: 'Generate a workout plan based on your fitness goal.',
                  icon: Icons.fitness_center,
                  onPressed: () {
                    Navigator.pushNamed(context, '/workout');
                  },
                ),
                _buildOptionCard(
                  context,
                  title: 'Progress Tracker',
                  subtitle: 'Track your fitness progress over time.',
                  icon: Icons.show_chart,
                  onPressed: () {
                    Navigator.pushNamed(context, '/progress');
                  },
                ),
                _buildOptionCard(
                  context,
                  title: 'Chat with Bot',
                  subtitle: 'Get assistance from our chatbot.',
                  icon: Icons.chat,
                  onPressed: () {
                    Navigator.pushNamed(context, '/chatbot');
                  },
                ),
                _buildOptionCard(
                  context,
                  title: 'Diet Plan',
                  subtitle: 'Get a personalized diet plan.',
                  icon: Icons.restaurant,
                  onPressed: () {
                    Navigator.pushNamed(context, '/dietplan');
                  },
                ),
                _buildOptionCard(
                  context,
                  title: 'CV Model',
                  subtitle: 'Check out our CV model.',
                  icon: Icons.model_training,
                  onPressed: () {
                    Navigator.pushNamed(context, '/cvmodel');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 8, // Increased elevation for shadow effect
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.deepPurple),
        title: Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        onTap: onPressed,
      ),
    );
  }
}