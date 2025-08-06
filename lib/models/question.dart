// lib/models/question.dart
class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String category;
  final int timeLimit;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.category,
    this.timeLimit = 30,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'options': options,
    'correctAnswer': correctAnswer,
    'category': category,
    'timeLimit': timeLimit,
  };

  static Question fromJson(Map<String, dynamic> json) => Question(
    id: json['id'] as String,
    question: json['question'] as String,
    options: List<String>.from(json['options'] as List),
    correctAnswer: json['correctAnswer'] as int,
    category: json['category'] as String,
    timeLimit: json['timeLimit'] as int? ?? 30,
  );
}
