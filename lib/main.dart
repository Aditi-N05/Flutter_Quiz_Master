// main.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'screens/quiz/quiz_screen.dart';
import 'models/question.dart';
import 'models/quiz_result.dart';
import 'services/data_services.dart';
import 'screens/home/home_page.dart';
import 'screens/admin/admin_panel.dart';
import 'screens/result/result_page.dart';
import 'screens/leaderboard/leaderboard_page.dart';

void main() {
  runApp(QuizApp());
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Master',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      routes: {
        '/admin': (context) => AdminPanel(),
        '/quiz': (context) => QuizDashboard(),
        '/results': (context) => ResultPage(),
        '/leaderboard': (context) => LeaderboardPage(),
      },
    );
  }
}
