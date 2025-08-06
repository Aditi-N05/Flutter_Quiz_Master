// lib/models/quiz_result.dart
class QuizResult {
  final String userId;
  final String userName;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;
  final Duration timeTaken;
  final String? category; // Optional category field

  QuizResult({
    required this.userId,
    required this.userName,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
    required this.timeTaken,
    this.category,
  });

  double get percentage => (score / totalQuestions) * 100;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'score': score,
    'totalQuestions': totalQuestions,
    'completedAt': completedAt.toIso8601String(),
    'timeTaken': timeTaken.inMilliseconds,
    'category': category,
  };

  static QuizResult fromJson(Map<String, dynamic> json) => QuizResult(
    userId: json['userId'] as String,
    userName: json['userName'] as String,
    score: json['score'] as int,
    totalQuestions: json['totalQuestions'] as int,
    completedAt: DateTime.parse(json['completedAt'] as String),
    timeTaken: Duration(milliseconds: json['timeTaken'] as int),
    category: json['category'] as String?,
  );
}
