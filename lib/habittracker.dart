import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const HabitTracker());
}

class HabitTracker extends StatelessWidget {
  const HabitTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF9F5FF),
      ),
      home: const HabitPage(),
    );
  }
}

class Habit {
  String title;
  bool done;

  Habit({required this.title, this.done = false});

  Map<String, dynamic> toJson() => {
    'title': title,
    'done': done,
  };

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      title: json['title'],
      done: json['done'],
    );
  }
}

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  State<HabitPage> createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  List<Habit> habits = [];
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadHabits();
  }

  Future<void> saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> habitList =
    habits.map((h) => jsonEncode(h.toJson())).toList();
    prefs.setStringList('habits', habitList);
  }

  Future<void> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? habitList = prefs.getStringList('habits');

    if (habitList != null) {
      setState(() {
        habits = habitList
            .map((h) => Habit.fromJson(jsonDecode(h)))
            .toList();
      });
    }
  }

  void addHabit() {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      habits.add(Habit(title: controller.text.trim()));
      controller.clear();
    });

    saveHabits();
  }

  void toggleHabit(int index) {
    setState(() {
      habits[index].done = !habits[index].done;
    });

    saveHabits();
  }

  void deleteHabit(int index) {
    setState(() {
      habits.removeAt(index);
    });

    saveHabits();
  }

  double get progress {
    if (habits.isEmpty) return 0;
    int doneCount = habits.where((h) => h.done).length;
    return doneCount / habits.length;
  }

  @override
  Widget build(BuildContext context) {
    int doneCount = habits.where((h) => h.done).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("🌸 My Habits"),
        centerTitle: true,
        backgroundColor: const Color(0xFFD8B4FE),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Progress 💖",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[400],
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.purple[100],
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 8),
                  Text("$doneCount / ${habits.length} completed"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Add Habit
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Add a habit ✨",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Habit List
            Expanded(
              child: habits.isEmpty
                  ? const Center(child: Text("No habits yet 😭"))
                  : ListView.builder(
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: habit.done
                          ? Colors.purple[100]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        habit.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: habit.done
                              ? TextDecoration.lineThrough
                              : null,
                          color: habit.done
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      leading: IconButton(
                        icon: Icon(
                          habit.done
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: habit.done
                              ? Colors.purple
                              : Colors.grey,
                        ),
                        onPressed: () => toggleHabit(index),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteHabit(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
