import 'package:flutter/material.dart';

class WorkoutScreen extends StatelessWidget {
  final Map<String, dynamic> plan;

  const WorkoutScreen({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Generated'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Your Personalized Workout Plan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Here are the details of your plan:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Workout Plan 
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: plan.length,
                    itemBuilder: (context, index) {
                      String key = plan.keys.elementAt(index);
                      dynamic value = plan[key];

                      return ListTile(
                        leading: Icon(
                          _getIconForKey(key),
                          color: Colors.blue,
                        ),
                        title: Text(
                          key,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(value.toString()),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForKey(String key) {
    switch (key.toLowerCase()) {
      case 'day':
        return Icons.calendar_today;
      case 'exercise':
        return Icons.fitness_center;
      case 'reps':
      case 'sets':
        return Icons.repeat;
      case 'duration':
        return Icons.timer;
      case 'rest':
        return Icons.bedtime;
      default:
        return Icons.info;
    }
  }
}
