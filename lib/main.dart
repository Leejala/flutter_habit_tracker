import 'package:flutter/material.dart';
import 'LoginPage.dart';

import 'homepage.dart';
import 'habittracker.dart'; // 👈 make sure this file name matches

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 👇 App starts from login page
      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginPage(),
        '/': (context) => const homePage(),
        '/habit': (context) => const HabitPage(),
      },
    );
  }
}