// lib/models/quiz_result.dart
class QuizResult {
  final String userId;
  final String userName;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;
  final Duration timeTaken;

  QuizResult({
    required this.userId,
    required this.userName,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
    required this.timeTaken,
  });

  double get percentage => (score / totalQuestions) * 100;
}
