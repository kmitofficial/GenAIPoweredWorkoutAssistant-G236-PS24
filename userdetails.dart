// userdetails.dartx
import 'package:flutter/material.dart'; // Importing the screen where the diet plan will be used
import 'package:flutter/services.dart';

class UserDetailsPage extends StatefulWidget {
  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  int age = 18;
  double weight = 60.0;
  double height = 165.0;
  String selectedPlan = 'Fat Loss';
  double? bmi;
  String recommendation = '';

  void _calculateBmi() {
    if (height > 0 && weight > 0) {
      double heightInMeters = height / 100;
      setState(() {
        bmi = weight / (heightInMeters * heightInMeters);
        _generateRecommendation();
      });
    }
  }

  void _generateRecommendation() {
    if (bmi != null) {
      if (bmi! < 18.5) {
        recommendation = 'Underweight: Consider opting for Muscle Gain.';
      } else if (bmi! >= 18.5 && bmi! < 24.9) {
        recommendation = 'Normal: Maintain your current plan.';
      } else if (bmi! >= 25.0) {
        recommendation = 'Overweight: Consider opting for Weight Loss.';
      }
    } else {
      recommendation = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter Your Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Name Input
                _buildInputCard(
                  context,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      labelText: 'Name',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    onChanged: (value) => name = value,
                  ),
                ),
                // Age Input
                _buildInputCard(
                  context,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      icon: Icon(Icons.calendar_today),
                      labelText: 'Age',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || int.tryParse(value) == null) {
                        return 'Please enter a valid age';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        age = int.parse(value);
                      }
                    },
                  ),
                ),

                // Weight Input
                _buildInputCard(
                  context,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Allows only digits
                    ],
                    decoration: const InputDecoration(
                      icon: Icon(Icons.line_weight),
                      labelText: 'Weight (kg)',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || double.tryParse(value) == null) {
                        return 'Please enter a valid weight';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        weight = double.parse(value);
                        _calculateBmi();
                      }
                    },
                  ),
                ),

                // Height Input
                _buildInputCard(
                  context,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Allows only digits
                    ],
                    decoration: const InputDecoration(
                      icon: Icon(Icons.height),
                      labelText: 'Height (cm)',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || double.tryParse(value) == null) {
                        return 'Please enter a valid height';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        height = double.parse(value);
                        _calculateBmi();
                      }
                    },
                  ),
                ),

                // BMI Display
                _buildInputCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.line_weight),
                          const SizedBox(width: 15),
                          Text(
                            'BMI: ${bmi != null ? bmi!.toStringAsFixed(1) : 'Not Calculated'}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        recommendation,
                        style: TextStyle(
                          fontSize: 16,
                          color: bmi != null
                              ? (bmi! < 18.5
                                  ? Colors.blue
                                  : bmi! >= 25.0
                                      ? Colors.red
                                      : Colors.green)
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                // Plan Selection
                _buildInputCard(
                  context,
                  child: DropdownButtonFormField<String>(
                    value: selectedPlan,
                    items: ['Fat Loss', 'Build Muscle', 'Body Recomposition']
                        .map((plan) => DropdownMenuItem(
                              value: plan,
                              child: Text(plan),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => selectedPlan = value!),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.local_activity),
                      labelText: 'Plan',
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pushNamed(
                          context,
                          '/home', // Navigate to InputScreen
                          arguments: selectedPlan,
                        );
                      }
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(BuildContext context, {required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: child,
      ),
    );
  }
}
