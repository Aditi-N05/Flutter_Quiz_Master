// lib/services/data_services.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  List<Question> _questions = [];
  List<QuizResult> _results = [];
  List<String> _categories = [];
  SharedPreferences? _prefs;
  bool _initialized = false;

  List<Question> get questions => List.unmodifiable(_questions);
  List<QuizResult> get results => List.unmodifiable(_results);
  List<String> get categories => List.unmodifiable(_categories);

  // Initialize the service with persistent storage
  Future<void> initialize() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();
    await _loadData();

    _initialized = true;
  }

  // Load data from SharedPreferences
  Future<void> _loadData() async {
    try {
      // Load questions
      final questionsJson = _prefs?.getString('questions');
      if (questionsJson != null) {
        final List<dynamic> questionsList = json.decode(questionsJson);
        _questions = questionsList.map((q) => Question.fromJson(q)).toList();
      }

      // Load results
      final resultsJson = _prefs?.getString('results');
      if (resultsJson != null) {
        final List<dynamic> resultsList = json.decode(resultsJson);
        _results = resultsList.map((r) => QuizResult.fromJson(r)).toList();
      }

      // Load categories
      final categoriesJson = _prefs?.getString('categories');
      if (categoriesJson != null) {
        _categories = List<String>.from(json.decode(categoriesJson));
      }

      //Ensure default questions load only once
      final defaultsLoaded = _prefs?.getBool('defaultsLoaded') ?? false;
      if (_questions.isEmpty && !defaultsLoaded) {
        await _loadDefaultQuestions();
        await _prefs?.setBool('defaultsLoaded', true);
      }

      print(
          "✅ Loaded ${_questions.length} questions, ${_results.length} results");
    } catch (e) {
      print('❌ Error loading data: $e');
      await _loadDefaultQuestions();
    }
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    try {
      // Save questions
      final questionsJson = json.encode(
        _questions.map((q) => q.toJson()).toList(),
      );
      await _prefs?.setString('questions', questionsJson);

      // Save results
      final resultsJson = json.encode(_results.map((r) => r.toJson()).toList());
      await _prefs?.setString('results', resultsJson);

      // Save categories
      final categoriesJson = json.encode(_categories);
      await _prefs?.setString('categories', categoriesJson);

      print(
          "💾 Saved ${_questions.length} questions, ${_results.length} results");
    } catch (e) {
      print('❌ Error saving data: $e');
    }
  }

  // Load default questions if none exist
  Future<void> _loadDefaultQuestions() async {
    _questions = [
      Question(
        id: '1',
        question: 'What is the capital of France?',
        options: ['London', 'Berlin', 'Paris', 'Madrid'],
        correctAnswer: 2,
        category: 'Geography',
      ),
      Question(
        id: '2',
        question: 'Which planet is known as the Red Planet?',
        options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
        correctAnswer: 1,
        category: 'Science',
      ),
      Question(
        id: '3',
        question: 'What is 2 + 2?',
        options: ['3', '4', '5', '6'],
        correctAnswer: 1,
        category: 'Math',
      ),
      Question(
        id: '4',
        question: 'Who painted the Mona Lisa?',
        options: ['Van Gogh', 'Picasso', 'Da Vinci', 'Michelangelo'],
        correctAnswer: 2,
        category: 'Art',
      ),
      Question(
        id: '5',
        question: 'What is the largest ocean on Earth?',
        options: ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
        correctAnswer: 3,
        category: 'Geography',
      ),
      Question(
        id: '6',
        question: 'What is the chemical symbol for gold?',
        options: ['Go', 'Gd', 'Au', 'Ag'],
        correctAnswer: 2,
        category: 'Science',
      ),
      Question(
        id: '7',
        question: 'Which year did World War II end?',
        options: ['1944', '1945', '1946', '1947'],
        correctAnswer: 1,
        category: 'History',
      ),
      Question(
        id: '8',
        question: 'What is the square root of 64?',
        options: ['6', '7', '8', '9'],
        correctAnswer: 2,
        category: 'Math',
      ),
    ];

    // Extract unique categories
    _categories = _questions.map((q) => q.category).toSet().toList();
    _categories.sort();

    await _saveData();
  }

  // Add a new question
  Future<void> addQuestion(Question question) async {
    _questions.add(question);

    // Add category if it doesn't exist
    if (!_categories.contains(question.category)) {
      _categories.add(question.category);
      _categories.sort();
    }

    await _saveData();
  }

  // Remove a question
  Future<void> removeQuestion(String id) async {
    _questions.removeWhere((q) => q.id == id);

    // Update categories list - remove categories that no longer have questions
    _updateCategories();

    await _saveData();
  }

  // Add a new category
  Future<void> addCategory(String category) async {
    if (!_categories.contains(category)) {
      _categories.add(category);
      _categories.sort();
      await _saveData();
    }
  }

  // Remove a category and all its questions
  Future<void> removeCategory(String category) async {
    _questions.removeWhere((q) => q.category == category);
    _categories.remove(category);
    await _saveData();
  }

  // Update categories based on existing questions
  void _updateCategories() {
    final existingCategories =
        _questions.map((q) => q.category).toSet().toList();
    _categories = existingCategories;
    _categories.sort();
  }

  // Add quiz result
  Future<void> addResult(QuizResult result) async {
    _results.add(result);
    await _saveData();
  }

  // Get random questions from a specific category
  List<Question> getRandomQuestionsByCategory(String category, int count) {
    final categoryQuestions =
        _questions.where((q) => q.category == category).toList();
    categoryQuestions.shuffle();
    return categoryQuestions.take(count).toList();
  }

  // Get random questions from all categories
  List<Question> getRandomQuestions(int count) {
    final shuffled = List<Question>.from(_questions)..shuffle();
    return shuffled.take(count).toList();
  }

  // Get questions by category
  List<Question> getQuestionsByCategory(String category) {
    return _questions.where((q) => q.category == category).toList();
  }

  // Get leaderboard
  List<QuizResult> getLeaderboard() {
    final sorted = List<QuizResult>.from(_results);
    sorted.sort((a, b) {
      // First sort by score (descending)
      final scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) return scoreComparison;

      // If scores are equal, sort by percentage (descending)
      final percentageComparison = b.percentage.compareTo(a.percentage);
      if (percentageComparison != 0) return percentageComparison;

      // If percentages are equal, sort by time taken (ascending - faster is better)
      return a.timeTaken.compareTo(b.timeTaken);
    });
    return sorted;
  }

  // Clear all data (for testing purposes)
  Future<void> clearAllData() async {
    _questions.clear();
    _results.clear();
    _categories.clear();
    await _prefs?.clear();
    print("🗑️ Cleared all data");
  }

  // Get question count by category
  Map<String, int> getQuestionCountByCategory() {
    final Map<String, int> counts = {};
    for (final category in _categories) {
      counts[category] = _questions.where((q) => q.category == category).length;
    }
    return counts;
  }
}
