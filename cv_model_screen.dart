import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CVModelScreen extends StatefulWidget {
  @override
  _CVModelScreenState createState() => _CVModelScreenState();
}

class _CVModelScreenState extends State<CVModelScreen> {
  // List of routes (e.g., squat, bicep, etc.)
  final List<String> routes = ['squat', 'bicep_curl', 'push_up', 'plank'];

  @override
  void initState() {
    super.initState();
  }

  // Method to redirect the user to the exercise selection screen
  void _navigateToExerciseSelection(String route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseSelectionScreen(route: route),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Selection'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple, // AppBar color
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpeg'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(child: CircularProgressIndicator()), // Show loading while redirecting
              const SizedBox(height: 20),
              // Buttons for each route with images
              for (var route in routes)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _navigateToExerciseSelection(route); // Navigate to the exercise selection screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent, // Button color
                      foregroundColor: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0), // Rounded button
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                      elevation: 5, // Button shadow
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/${route}.png', // Image for each route (e.g., squat.png, bicep.png)
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 10),
                        Text(route.capitalize(), style: const TextStyle(fontWeight: FontWeight.bold)), // Capitalize the route name for display
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Exercise Selection Screen
class ExerciseSelectionScreen extends StatelessWidget {
  final String route;

  const ExerciseSelectionScreen({required this.route});

  // Method to open the URL in the browser
  Future<void> _openUrl(String route) async {
    final baseUrl = 'http://192.168.240.244:7000/'; // Replace with your ngrok or server URL
    final url = '$baseUrl$route'; // Append the route to the base URL

    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not open the URL: $url';
      }
    } catch (error) {
      print('Error opening the URL: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select $route'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Center( // Center the entire content
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, // Vertically center the content
      crossAxisAlignment: CrossAxisAlignment.center, // Horizontally center the content
      children: [
        Text(
          'You selected $route! Now choose to start the exercise.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center, // Ensure text is centered
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _openUrl(route); // Open the URL for the selected exercise
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent, // Button color
            foregroundColor: Colors.white, // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0), // Rounded button
            ),
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
            elevation: 5, // Button shadow
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: const Text('Start Exercise'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Action for Stop button (navigate to home screen or stop exercise)
            Navigator.pop(context); // Navigate back to the previous screen (e.g., home)
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Stop button color
            foregroundColor: Colors.white, // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0), // Rounded button
            ),
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
            elevation: 5, // Button shadow
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: const Text('Stop'),
        ),
      ],
    ),
  ),
),

    );
  }
}

// Extension to capitalize the first letter of the route
extension StringCapitalize on String {
  String capitalize() {
    return this[0].toUpperCase() + this.substring(1);
  }
}
