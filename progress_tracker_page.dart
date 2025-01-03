import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressTrackerPage extends StatefulWidget {
  const ProgressTrackerPage({super.key});

  @override
  ProgressState createState() => ProgressState();
}

class ProgressState extends State<ProgressTrackerPage> {
  DateTime date = DateTime.now();
  List<bool> atten = [];

  @override
  void initState() {
    super.initState();
    startAttendanceTracking();
  }

  Future<void> startAttendanceTracking() async {
    int daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    atten = List.generate(daysInMonth, (_) => false); // Default attendance
    await loadAttendance();
    setState(() {});
  }

  Future<void> loadAttendance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String monthKey = '${date.year}_${date.month}';
    List<String>? storedAttendance = prefs.getStringList(monthKey);

    if (storedAttendance != null) {
      atten = storedAttendance.map((e) => e == 'true').toList();
    }
  }

  /// Save attendance to SharedPreferences
  Future<void> saveAttendance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String monthKey = '${date.year}_${date.month}';
    List<String> attendanceToStore = atten.map((e) => e.toString()).toList();
    await prefs.setStringList(monthKey, attendanceToStore);
  }

  int getFirstWeekdayOfMonth() {
    return DateTime(date.year, date.month, 1).weekday;
  }

  /// Navigate to the next month
  void goToNextMonth() {
    setState(() {
      date = DateTime(date.year, date.month + 1, 1);
      startAttendanceTracking();
    });
  }

  void goToPreviousMonth() {
    setState(() {
      date = DateTime(date.year, date.month - 1, 1);
      startAttendanceTracking();
    });
  }

  /// days attended
  int countAttendedDays() {
    return atten.where((marked) => marked).length;
  }
/// not attended
  int countAbsentDays() {
    return atten.where((marked) => !marked).length;
  }

  @override
  Widget build(BuildContext context) {
    String month = DateFormat('MMMM').format(date);
    String year = DateFormat('y').format(date);

    List<String> weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    int firstWeekday = getFirstWeekdayOfMonth();
    int daysInMonth = DateTime(date.year, date.month + 1, 0).day;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracker Calendar'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Attendance stats
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Attended: ${countAttendedDays()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Not Attended: ${countAbsentDays()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Month 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: goToPreviousMonth,
                ),
                Text(
                  "$month $year",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: goToNextMonth,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Weekday 
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: weekDays
                  .map(
                    (day) => Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 4),

            // Attendance days
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: daysInMonth + firstWeekday,
              itemBuilder: (context, index) {
                if (index < firstWeekday) {
                  return Container(); 
                }

                int day = index - firstWeekday + 1;

                return GestureDetector(
                  onTap: () {
                    final today = DateTime.now();
                    final isCurrentDay = day == today.day &&
                        date.month == today.month &&
                        date.year == today.year;

                    if (isCurrentDay) {
                      setState(() {
                        atten[day - 1] = !atten[day - 1];
                        saveAttendance();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "You can only mark attendance for the current day!",
                            style: TextStyle(fontSize: 14),
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: atten.isNotEmpty && atten[day - 1]
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}