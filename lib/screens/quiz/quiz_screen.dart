// lib/screens/quiz/quiz_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';

import '../../main.dart'; // <-- this imports models and DataService from main.dart
// If you later move models/DataService to their own file, update this import.
import '../../models/question.dart';
import '../../models/quiz_result.dart';
import '../../services/data_services.dart';

class QuizDashboard extends StatefulWidget {
  const QuizDashboard({Key? key}) : super(key: key);

  @override
  _QuizDashboardState createState() => _QuizDashboardState();
}

class _QuizDashboardState extends State<QuizDashboard> {
  final _dataService = DataService();
  final _nameController = TextEditingController();
  List<Question> _quizQuestions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  Timer? _timer;
  int _timeLeft = 30;
  bool _quizStarted = false;
  DateTime? _quizStartTime;

  @override
  Widget build(BuildContext context) {
    if (!_quizStarted) {
      return _buildQuizSetup();
    }

    if (_currentQuestionIndex >= _quizQuestions.length) {
      return _buildQuizComplete();
    }

    return _buildQuizQuestion();
  }

  Widget _buildQuizSetup() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Setup'),
        backgroundColor: Colors.green[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 80, color: Colors.green),
            const SizedBox(height: 30),
            const Text(
              'Enter Your Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _startQuiz,
                child: const Text(
                  'Start Quiz (5 Questions)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizQuestion() {
    final question = _quizQuestions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentQuestionIndex + 1}/${_quizQuestions.length}'),
        backgroundColor: Colors.blue[600],
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Timer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _timeLeft <= 10 ? Colors.red[100] : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _timeLeft <= 10 ? Colors.red : Colors.blue,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Time Left:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$_timeLeft seconds',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _timeLeft <= 10 ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Question
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(question.options.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _selectAnswer(index),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${String.fromCharCode(65 + index)}. ${question.options[index]}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedAnswer == index
                                  ? Colors.blue[600]
                                  : Colors.grey[200],
                              foregroundColor: _selectedAnswer == index
                                  ? Colors.white
                                  : Colors.black87,
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Next Button
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedAnswer != null ? _nextQuestion : null,
                child: Text(
                  _currentQuestionIndex == _quizQuestions.length - 1
                      ? 'Finish Quiz'
                      : 'Next Question',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizComplete() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Complete'),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 100, color: Colors.green),
              SizedBox(height: 30),
              Text(
                'Quiz Completed!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Calculating your results...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  void _startQuiz() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    _quizQuestions = _dataService.getRandomQuestions(5);
    _quizStarted = true;
    _quizStartTime = DateTime.now();
    _startTimer();
    setState(() {});
  }

  void _startTimer() {
    _timeLeft = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _nextQuestion(); // auto move when time runs out
        }
      });
    });
  }

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswer = index;
    });
  }

  void _nextQuestion() {
    _timer?.cancel();

    if (_selectedAnswer != null &&
        _selectedAnswer == _quizQuestions[_currentQuestionIndex].correctAnswer) {
      _score++;
    }

    _currentQuestionIndex++;
    _selectedAnswer = null;

    if (_currentQuestionIndex >= _quizQuestions.length) {
      _completeQuiz();
    } else {
      _startTimer();
    }

    setState(() {});
  }

  void _completeQuiz() {
    final result = QuizResult(
      userId: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: _nameController.text.trim(),
      score: _score,
      totalQuestions: _quizQuestions.length,
      completedAt: DateTime.now(),
      timeTaken: DateTime.now().difference(_quizStartTime!),
    );

    _dataService.addResult(result);

    // Navigate to results after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(
        context,
        '/results',
        arguments: result,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    super.dispose();
  }
}
