// lib/screens/quiz/quiz_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';

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
  bool _categorySelected = false;
  bool _isLoading = false;
  DateTime? _quizStartTime;
  String? _selectedCategory;
  int _questionCount = 5;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    await _dataService.initialize();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Setup'),
          backgroundColor: Colors.green[600],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_categorySelected) {
      return _buildCategorySelection();
    }

    if (!_quizStarted) {
      return _buildQuizSetup();
    }

    if (_currentQuestionIndex >= _quizQuestions.length) {
      return _buildQuizComplete();
    }

    return _buildQuizQuestion();
  }

  Widget _buildCategorySelection() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Category'),
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.category, size: 80, color: Colors.blue),
              const SizedBox(height: 30),
              const Text(
                'Choose Quiz Category',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Select a category or choose "All Categories" for mixed questions',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),

              // Question count selector
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Number of Questions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [5, 10, 15, 20].map((count) {
                          return ChoiceChip(
                            label: Text('$count'),
                            selected: _questionCount == count,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _questionCount = count);
                              }
                            },
                            selectedColor: Colors.blue[300],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: _dataService.categories.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No categories available',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Please add some questions in the Admin Panel first',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        children: [
                          // All Categories option
                          Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.purple,
                                child: Icon(
                                  Icons.all_inclusive,
                                  color: Colors.white,
                                ),
                              ),
                              title: const Text(
                                'All Categories',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Mixed questions from all ${_dataService.categories.length} categories',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                setState(() {
                                  _selectedCategory =
                                      null; // null means all categories
                                  _categorySelected = true;
                                });
                              },
                            ),
                          ),

                          // Individual categories
                          ...(_dataService.categories.map((category) {
                            final questionCount = _dataService
                                .getQuestionsByCategory(category)
                                .length;
                            final hasEnoughQuestions =
                                questionCount >= _questionCount;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: hasEnoughQuestions
                                      ? Colors.green
                                      : Colors.grey,
                                  child: Text(
                                    category[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  category,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: hasEnoughQuestions
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                                subtitle: Text(
                                  '$questionCount questions available',
                                  style: TextStyle(
                                    color: hasEnoughQuestions
                                        ? Colors.grey[600]
                                        : Colors.grey,
                                  ),
                                ),
                                trailing: hasEnoughQuestions
                                    ? const Icon(Icons.arrow_forward_ios)
                                    : const Icon(
                                        Icons.warning,
                                        color: Colors.orange,
                                      ),
                                enabled: hasEnoughQuestions,
                                onTap: hasEnoughQuestions
                                    ? () {
                                        setState(() {
                                          _selectedCategory = category;
                                          _categorySelected = true;
                                        });
                                      }
                                    : null,
                              ),
                            );
                          }).toList()),
                        ],
                      ),
              ),

              if (_dataService.categories.isNotEmpty) ...[
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/admin'),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Add More Questions'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizSetup() {
    final categoryText = _selectedCategory ?? 'All Categories';
    final availableQuestions = _selectedCategory != null
        ? _dataService.getQuestionsByCategory(_selectedCategory!).length
        : _dataService.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Setup'),
        backgroundColor: Colors.green[600],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _categorySelected = false;
              _selectedCategory = null;
            });
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 80, color: Colors.green),
                const SizedBox(height: 30),

                // Category info card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedCategory != null
                                  ? Icons.category
                                  : Icons.all_inclusive,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Category: $categoryText',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Questions: $_questionCount (from $availableQuestions available)',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),

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
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _startQuiz,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      'Start Quiz ($_questionCount Questions)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
        ),
      ),
    );
  }

  Widget _buildQuizQuestion() {
    final question = _quizQuestions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${_currentQuestionIndex + 1}/${_quizQuestions.length}',
        ),
        backgroundColor: Colors.blue[600],
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Score: $_score',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _quizQuestions.length,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
              const SizedBox(height: 20),

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
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          color: _timeLeft <= 10 ? Colors.red : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Time Left:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _timeLeft <= 10 ? Colors.red : Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_timeLeft s',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Question
              Expanded(
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            question.category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Question text
                        Text(
                          question.question,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Options
                        Expanded(
                          child: ListView.builder(
                            itemCount: question.options.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _selectAnswer(index),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                _selectedAnswer == index
                                                    ? Colors.white
                                                    : Colors.grey[300],
                                            child: Text(
                                              String.fromCharCode(65 + index),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: _selectedAnswer == index
                                                    ? Colors.blue[600]
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              question.options[index],
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _selectedAnswer == index
                                          ? Colors.blue[600]
                                          : Colors.grey[100],
                                      foregroundColor: _selectedAnswer == index
                                          ? Colors.white
                                          : Colors.black87,
                                      elevation:
                                          _selectedAnswer == index ? 4 : 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: _selectedAnswer == index
                                              ? Colors.blue[600]!
                                              : Colors.grey[300]!,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Next Button
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _selectedAnswer != null ? _nextQuestion : null,
                  icon: Icon(
                    _currentQuestionIndex == _quizQuestions.length - 1
                        ? Icons.flag
                        : Icons.arrow_forward,
                  ),
                  label: Text(
                    _currentQuestionIndex == _quizQuestions.length - 1
                        ? 'Finish Quiz'
                        : 'Next Question',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
          ),
        ),
        child: const Center(
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
      ),
    );
  }

  void _startQuiz() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    // Get questions based on selected category
    if (_selectedCategory != null) {
      _quizQuestions = _dataService.getRandomQuestionsByCategory(
        _selectedCategory!,
        _questionCount,
      );
    } else {
      _quizQuestions = _dataService.getRandomQuestions(_questionCount);
    }

    if (_quizQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No questions available for the selected category'),
        ),
      );
      return;
    }

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
        _selectedAnswer ==
            _quizQuestions[_currentQuestionIndex].correctAnswer) {
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
      category: _selectedCategory,
    );

    _dataService.addResult(result);

    // Navigate to results after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/results', arguments: result);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    super.dispose();
  }
}
