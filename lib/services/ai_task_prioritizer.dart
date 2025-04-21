import 'package:cloud_firestore/cloud_firestore.dart';

class AITaskPrioritizer {
  static List<QueryDocumentSnapshot> prioritizeTasks(
      List<QueryDocumentSnapshot> tasks) {
    List<QueryDocumentSnapshot> prioritizedTasks = [];
    List<QueryDocumentSnapshot> normalTasks = [];
    List<QueryDocumentSnapshot> doneTasks = [];

    for (var task in tasks) {
      var data = task.data() as Map<String, dynamic>;

      String status = (data['status'] ?? '').toString().toLowerCase();
      if (status == 'done') {
        doneTasks.add(task);
        continue;
      }

      String priority = (data['priority'] ?? 'medium').toLowerCase();
      DateTime? dueDate;
      try {
        dueDate = (data['dueDate'] as Timestamp).toDate();
      } catch (_) {
        normalTasks.add(task);
        continue;
      }

      int daysLeft = dueDate.difference(DateTime.now()).inDays;
      int urgencyScore = 0;

      if (priority == 'high') {
        urgencyScore += 3;
      } else if (priority == 'medium' && daysLeft <= 0) {
        urgencyScore += 3;
      } else if (priority == 'low' && daysLeft <= 0) {
        urgencyScore = 0;
      }

      if (daysLeft <= 0) {
        urgencyScore += 3;
      } else if (daysLeft == 1) {
        urgencyScore += 2;
      } else if (daysLeft <= 3) {
        urgencyScore += 1;
      }

      if (urgencyScore >= 4) {
        prioritizedTasks.add(task);
      } else {
        normalTasks.add(task);
      }
    }

    // Sort prioritizedTasks based on urgency: high priority + closer due date
    prioritizedTasks.sort((a, b) {
      var aData = a.data() as Map<String, dynamic>;
      var bData = b.data() as Map<String, dynamic>;
      DateTime aDue = (aData['dueDate'] as Timestamp).toDate();
      DateTime bDue = (bData['dueDate'] as Timestamp).toDate();

      String aPriority = (aData['priority'] ?? 'medium').toLowerCase();
      String bPriority = (bData['priority'] ?? 'medium').toLowerCase();

      int aScore = _priorityValue(aPriority);
      int bScore = _priorityValue(bPriority);

      if (aScore != bScore) {
        return bScore - aScore;
      } else {
        return aDue.compareTo(bDue);
      }
    });

    return [...prioritizedTasks, ...normalTasks, ...doneTasks];
  }

  static bool isTaskAIPrioritized(QueryDocumentSnapshot task) {
    var data = task.data() as Map<String, dynamic>;

    String status = (data['status'] ?? '').toString().toLowerCase();
    if (status == 'done') return false;

    String priority = (data['priority'] ?? 'medium').toLowerCase();
    DateTime? dueDate;
    try {
      dueDate = (data['dueDate'] as Timestamp).toDate();
    } catch (_) {
      return false;
    }

    int daysLeft = dueDate.difference(DateTime.now()).inDays;
    int urgencyScore = 0;

    if (priority == 'high') {
      urgencyScore += 3;
    } else if (priority == 'medium' && daysLeft <= 0) {
      urgencyScore += 3;
    } else if (priority == 'low' && daysLeft <= 0) {
      urgencyScore = 0;
    }

    if (daysLeft <= 0) {
      urgencyScore += 3;
    } else if (daysLeft == 1) {
      urgencyScore += 2;
    } else if (daysLeft <= 3) {
      urgencyScore += 1;
    }

    return urgencyScore >= 4;
  }

  static int _priorityValue(String priority) {
    switch (priority) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
      default:
        return 1;
    }
  }
}
