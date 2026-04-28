

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: HabitPage(),
    );
  }
}

class HabitPage extends StatefulWidget {
  @override
  _HabitPageState createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  List habits = [];

  final String baseUrl = "http://10.0.2.2:3000"; // for Android emulator

  @override
  void initState() {
    super.initState();
    fetchHabits();
  }

  // GET habits
  Future<void> fetchHabits() async {
    final response = await http.get(Uri.parse('$baseUrl/habits'));

    if (response.statusCode == 200) {
      setState(() {
        habits = json.decode(response.body);
      });
    }
  }

  // ADD habit
  Future<void> addHabit(String name) async {
    await http.post(
      Uri.parse('$baseUrl/habits'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"name": name}),
    );

    fetchHabits();
  }

  // COMPLETE habit
  Future<void> completeHabit(int id) async {
    await http.put(Uri.parse('$baseUrl/habits/$id'));
    fetchHabits();
  }

  // DELETE habit
  Future<void> deleteHabit(int id) async {
    await http.delete(Uri.parse('$baseUrl/habits/$id'));
    fetchHabits();
  }

  void showAddDialog() {
    String newHabit = "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Habit"),
        content: TextField(
          onChanged: (value) => newHabit = value,
          decoration: InputDecoration(hintText: "Enter habit"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              addHabit(newHabit);
              Navigator.pop(context);
            },
            child: Text("Add"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Habits 💜"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];

          return ListTile(
            title: Text(habit['name']),
            leading: IconButton(
              icon: Icon(
                habit['completed']
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
              ),
              onPressed: () => completeHabit(habit['id']),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => deleteHabit(habit['id']),
            ),
          );
        },
      ),
    );
  }
}