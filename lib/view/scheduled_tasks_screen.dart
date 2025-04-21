import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prodigenious/services/ai_task_scheduler.dart';
import 'package:prodigenious/services/notificaiton_service.dart';
import 'package:prodigenious/services/task_estimator_service.dart';
import 'package:prodigenious/services/user_service.dart';
import 'package:prodigenious/view/task_history.dart';
import 'package:prodigenious/widgets/custom_appbar.dart';
import 'package:prodigenious/widgets/add_task_dialog.dart';
import 'package:prodigenious/widgets/navigation_bar.dart';

class ScheduledTasksScreen extends StatefulWidget {
  const ScheduledTasksScreen({super.key});

  @override
  _ScheduledTasksScreenState createState() => _ScheduledTasksScreenState();
}

class _ScheduledTasksScreenState extends State<ScheduledTasksScreen> {
  String username = '';
  String userEmail = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      final userData = await UserService().fetchUserData();
      setState(() {
        username = userData['username']!;
        userEmail = userData['email']!;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                "Scheduled Tasks",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E3A59),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .where('email', isEqualTo: userEmail)
                    .where('status',
                        whereIn: ["ToDo", "InProgress", "Done"]).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var rawTasks = snapshot.data!.docs;
                  var tasks = AITaskScheduler.scheduleTasks(rawTasks);

                  if (tasks.isEmpty) {
                    return Center(
                      child: Text(
                        "No Scheduled Tasks",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  return ListView(
                    children: tasks.map((task) {
                      var data = task.data() as Map<String, dynamic>;
                      String currentStatus = data['status'] ?? 'ToDo';

                      DateTime? assignedDt;
                      DateTime? dueDt;

                      try {
                        assignedDt =
                            (data['assignedDate'] as Timestamp).toDate();
                      } catch (_) {}
                      try {
                        dueDt = (data['dueDate'] as Timestamp).toDate();
                      } catch (_) {}

                      String assignedDateStr = assignedDt == null
                          ? 'N/A'
                          : DateFormat('dd/MM/yyyy').format(assignedDt);
                      String dueDateStr = dueDt == null
                          ? 'N/A'
                          : DateFormat('dd/MM/yyyy').format(dueDt);

                      IconData priorityIcon;
                      switch (
                          (data['priority'] ?? '').toString().toLowerCase()) {
                        case 'high':
                          priorityIcon = Icons.arrow_upward;
                          break;
                        case 'low':
                          priorityIcon = Icons.arrow_downward;
                          break;
                        default:
                          priorityIcon = Icons.drag_handle;
                          break;
                      }

                      Color statusColor;
                      switch (currentStatus) {
                        case 'InProgress':
                          statusColor = Colors.blue;
                          break;
                        case 'Done':
                          statusColor = Colors.green;
                          break;
                        case 'ToDo':
                        default:
                          statusColor = Colors.yellow;
                      }

                      final String taskName = data['task'] ?? 'No Task';
                      final int encodedTask = taskName.hashCode;
                      return FutureBuilder<double?>(
                        future: TaskEstimatorService.estimateDuration(
                          encodedTask,
                          data['priority'],
                        ),
                        builder: (context, snapshot) {
                          final estimatedText =
                              TaskEstimatorService.displayEstimation(
                            taskName,
                            snapshot.data,
                          );

                          return Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: Color(0xff3D0087), width: 2),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        taskName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Priority",
                                          style: TextStyle(
                                            color: Colors.purple.shade900,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Icon(priorityIcon,
                                            color: priorityIcon ==
                                                    Icons.arrow_upward
                                                ? Colors.red
                                                : (priorityIcon ==
                                                        Icons.arrow_downward
                                                    ? Colors.grey
                                                    : Colors.orange)),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Wrap(
                                  spacing: 20,
                                  runSpacing: 4,
                                  children: [
                                    Text("Assigned Date: $assignedDateStr",
                                        style: TextStyle(fontSize: 14)),
                                    Text("Due Date: $dueDateStr",
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Status: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    Text(currentStatus,
                                        style: TextStyle(
                                            fontSize: 14, color: statusColor)),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Text(
                                        "Estimated Time: $estimatedText",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.deepPurple),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: Offset(0, 35),
        child: Container(
          height: 70,
          width: 70,
          child: FloatingActionButton(
            onPressed: () {
              showAddTaskDialog(context, username, userEmail);
            },
            backgroundColor: Colors.purple,
            shape:
                CircleBorder(side: BorderSide(color: Colors.white, width: 5)),
            child: Icon(Icons.add, size: 35, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: StreamBuilder<int>(
        stream: NotificationService.getUnreadNotificationCount(userEmail),
        builder: (context, snapshot) {
          final unreadCount = snapshot.data ?? 0;

          return BottomNavBar(
            activeScreen: 'scheduled',
            unreadNotificationCount: unreadCount,
            onHomeTap: () {
              Navigator.popAndPushNamed(context, '/home');
            },
            onScheduledTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScheduledTasksScreen()),
              );
            },
            onHistoryTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(
                    userEmail: userEmail,
                    username: username,
                  ),
                ),
              );
            },
            onNotificationTap: () {
              Navigator.pushReplacementNamed(context, '/notifications');
            },
          );
        },
      ),
    );
  }
}
