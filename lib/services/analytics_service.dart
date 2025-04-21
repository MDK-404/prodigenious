import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  String userEmail = "";

  Future<String> generateProductivityInsight() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return 'User not logged in.';
      }

      final uid = currentUser.uid;
      final userData = await _userService.fetchUserData();
      userEmail = userData['email']!;

      //  Check for tasks with matching userId first
      QuerySnapshot tasksSnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: uid)
          .where('status', isEqualTo: 'Done')
          .get();

      //  If no uid-based tasks found, fallback to email-based matching (for older tasks)
      if (tasksSnapshot.docs.isEmpty) {
        tasksSnapshot = await _firestore
            .collection('tasks')
            .where('email', isEqualTo: userEmail)
            .where('status', isEqualTo: 'Done')
            .get();
      }

      if (tasksSnapshot.docs.isEmpty) {
        return 'No productivity data available yet.';
      }

      Map<String, int> weekdayCount = {
        'Monday': 0,
        'Tuesday': 0,
        'Wednesday': 0,
        'Thursday': 0,
        'Friday': 0,
        'Saturday': 0,
        'Sunday': 0,
      };

      for (var doc in tasksSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final completedDate = data['completedDate'];
        if (completedDate != null) {
          final dateTime = (completedDate as Timestamp).toDate();
          final weekday = _getWeekday(dateTime.weekday);
          weekdayCount[weekday] = (weekdayCount[weekday] ?? 0) + 1;
        }
      }

      final productiveDay =
          weekdayCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      final insight = 'You are most productive on $productiveDay.';

      await saveInsightToFirestore(uid, insight);

      return insight;
    } catch (e) {
      return 'Failed to generate insight: $e';
    }
  }

  String _getWeekday(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday - 1];
  }

  Future<void> saveInsightToFirestore(String userId, String insight) async {
    final insightRef = _firestore.collection('user_insights').doc(userId);

    await insightRef.set({
      'insight': insight,
      'email': userEmail,
      'generatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> getStoredInsight(String userId) async {
    final doc = await _firestore.collection('user_insights').doc(userId).get();
    if (doc.exists && doc.data()?['insight'] != null) {
      return doc.data()!['insight'];
    }
    return null;
  }
}
