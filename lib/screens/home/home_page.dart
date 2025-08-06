// lib/screens/home/home_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Widget _buildMenuButton(
      BuildContext context,
      String text,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return Container(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Master'),
        centerTitle: true,
        backgroundColor: Colors.blue[600],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.quiz, size: 100, color: Colors.blue[600]),
              const SizedBox(height: 30),
              const Text(
                'Welcome to Quiz Master',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const SizedBox(height: 20),
              const Text(
                'Test your knowledge with our interactive quizzes',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 50),
              _buildMenuButton(context, 'Start Quiz', Icons.play_arrow, Colors.green, () => Navigator.pushNamed(context, '/quiz')),
              const SizedBox(height: 15),
              _buildMenuButton(context, 'Leaderboard', Icons.leaderboard, Colors.orange, () => Navigator.pushNamed(context, '/leaderboard')),
              const SizedBox(height: 15),
              _buildMenuButton(context, 'Admin Panel', Icons.admin_panel_settings, Colors.red, () => Navigator.pushNamed(context, '/admin')),
            ]),
          ),
        ),
      ),
    );
  }
}
