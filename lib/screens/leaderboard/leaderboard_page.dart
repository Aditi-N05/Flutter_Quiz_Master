// lib/screens/leaderboard/leaderboard_page.dart
import 'package:flutter/material.dart';
import '../../services/data_services.dart';
import '../../models/quiz_result.dart';

class LeaderboardPage extends StatelessWidget {
  final _dataService = DataService();

  LeaderboardPage({Key? key}) : super(key: key);

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey[400]!;
      case 2:
        return Colors.brown[300]!;
      default:
        return Colors.blue[300]!;
    }
  }

  IconData _getRankIcon(int index) {
    switch (index) {
      case 0:
        return Icons.emoji_events;
      case 1:
        return Icons.military_tech;
      case 2:
        return Icons.workspace_premium;
      default:
        return Icons.stars;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  @override
  Widget build(BuildContext context) {
    final leaderboard = _dataService.getLeaderboard();

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard'), backgroundColor: Colors.orange[600]),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.orange[50]!, Colors.white]),
        ),
        child: leaderboard.isEmpty
            ? Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            const Text('No results yet!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            const Text('Take a quiz to see your score here', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ]),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final QuizResult result = leaderboard[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(backgroundColor: _getRankColor(index), child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                title: Text(result.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 4),
                  Text('Score: ${result.score}/${result.totalQuestions}'),
                  Text('Percentage: ${result.percentage.toInt()}%'),
                ]),
                trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_getRankIcon(index), color: _getRankColor(index), size: 28),
                  const SizedBox(height: 4),
                  Text(_formatDateTime(result.completedAt), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ]),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/quiz'),
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange[600],
        tooltip: 'Take Quiz',
      ),
    );
  }
}
