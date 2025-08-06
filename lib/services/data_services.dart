// lib/services/data_service.dart
import '../models/question.dart';
import '../models/quiz_result.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final List<Question> _questions = [
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
  ];

  final List<QuizResult> _results = [];

  List<Question> get questions => List.unmodifiable(_questions);
  List<QuizResult> get results => List.unmodifiable(_results);

  void addQuestion(Question question) => _questions.add(question);

  void removeQuestion(String id) => _questions.removeWhere((q) => q.id == id);

  void addResult(QuizResult result) => _results.add(result);

  List<Question> getRandomQuestions(int count) {
    final shuffled = List<Question>.from(_questions)..shuffle();
    return shuffled.take(count).toList();
  }

  List<QuizResult> getLeaderboard() {
    final sorted = List<QuizResult>.from(_results);
    sorted.sort((a, b) => b.score.compareTo(a.score));
    return sorted;
  }
}
