import 'package:cloud_firestore/cloud_firestore.dart';

class AITaskScheduler {
  static List<QueryDocumentSnapshot> scheduleTasks(
      List<QueryDocumentSnapshot> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<QueryDocumentSnapshot> high = [];
    List<QueryDocumentSnapshot> medium = [];
    List<QueryDocumentSnapshot> low = [];

    // Map<String, List<QueryDocumentSnapshot>> dueDateMap = {};

    for (var task in tasks) {
      var data = task.data() as Map<String, dynamic>;

      if ((data['status'] ?? '').toString().toLowerCase() == 'done') continue;

      DateTime? dueDate;
      try {
        dueDate = (data['dueDate'] as Timestamp).toDate();
      } catch (_) {
        continue;
      }

      final DateTime cleanDueDate =
          DateTime(dueDate.year, dueDate.month, dueDate.day);
      final int daysUntilDue = cleanDueDate.difference(today).inDays;

      if (cleanDueDate.isBefore(today)) continue;

      final String priority = (data['priority'] ?? 'medium').toLowerCase();

      if (priority == 'high' && daysUntilDue <= 2) {
        high.add(task);
      } else if (priority == 'medium' && daysUntilDue <= 2) {
        medium.add(task);
      }
    }

    high.sort((a, b) => _dueDateOf(a).compareTo(_dueDateOf(b)));
    medium.sort((a, b) => _dueDateOf(a).compareTo(_dueDateOf(b)));
    low.sort((a, b) => _dueDateOf(a).compareTo(_dueDateOf(b)));

    return [...high, ...medium, ...low];
  }

  static DateTime _dueDateOf(QueryDocumentSnapshot task) {
    return (task['dueDate'] as Timestamp).toDate();
  }
}
