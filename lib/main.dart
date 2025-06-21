import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'screens/home_screen.dart'; // Ensure this file exists

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "--------------------------------------",
      authDomain: "---------------------------------------",
      projectId: "-------------------------------------",
      storageBucket: "----------------------------------",
      messagingSenderId: "-----------------------------------",
      appId: "--------------------------------------",
      measurementId: "-----------------------",
    ),
  );

  // Initialize timezone for reminders
  tz.initializeTimeZones();

  // Initialize local notifications
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
  InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const ToDoApp());
}

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  State<ToDoApp> createState() => _ToDoAppState();
}

class _ToDoAppState extends State<ToDoApp> {
  bool _isDark = false;

  void toggleTheme() {
    setState(() => _isDark = !_isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern To-Do',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: HomeScreen(
        toggleTheme: toggleTheme,
        isDarkMode: _isDark,
      ),
    );
  }
}
