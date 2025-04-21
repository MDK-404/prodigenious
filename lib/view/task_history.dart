import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prodigenious/widgets/custom_appbar.dart';
import 'package:prodigenious/widgets/navigation_bar.dart';

class HistoryScreen extends StatefulWidget {
  final String userEmail;
  final String username;

  const HistoryScreen({
    Key? key,
    required this.userEmail,
    required this.username,
  }) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  void _onHomeTap() {
    Navigator.popAndPushNamed(context, '/home');
  }

  Future<void> clearHistory() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('history')
        .where('email', isEqualTo: widget.userEmail)
        .get();

    for (var doc in snapshot.docs) {
      await FirebaseFirestore.instance
          .collection('history')
          .doc(doc.id)
          .delete();
    }
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear History"),
        content: Text("Are you sure you want to clear all history tasks?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await clearHistory();
              Navigator.pop(context);
            },
            child: Text("Clear"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.history, size: 24, color: Color(0xFF2E3A59)),
                const SizedBox(width: 8),
                Text(
                  "Task History",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A59),
                  ),
                ),
                Spacer(),
                ElevatedButton.icon(
                  onPressed: _showClearHistoryDialog,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF945FD4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Clear History",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Previous Tasks can be found here",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _coloredDot(Color(0xff0CC302)),
                  SizedBox(width: 4),
                  Text("Completed Task"),
                  SizedBox(width: 20),
                  _coloredDot(Color(0xFFFE0B0B)),
                  SizedBox(width: 4),
                  Text("Terminated Task"),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('history')
                    .where('email', isEqualTo: widget.userEmail)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text("No history tasks found."),
                    );
                  }

                  return ListView(
                    children: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final String taskName = data['task'] ?? 'No Task';
                      final String status = data['status'] ?? 'unknown';
                      final String priority = data['priority'] ?? 'Low';

                      DateTime? assignedDate;
                      if (data['assignedDate'] != null) {
                        try {
                          assignedDate =
                              (data['assignedDate'] as Timestamp).toDate();
                        } catch (_) {}
                      }

                      final Color textColor = (status == 'Done')
                          ? Color(0xff0CC302)
                          : Color(0xFFFE0B0B);

                      IconData priorityIcon;
                      switch (priority.toLowerCase()) {
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

                      final assignedStr = (assignedDate == null)
                          ? 'N/A'
                          : DateFormat('dd/MM/yyyy').format(assignedDate);

                      return Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: Color(0xff3D0087), width: 2),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    taskName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Priority",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      priorityIcon,
                                      color: (priority.toLowerCase() == 'high')
                                          ? Colors.red
                                          : (priority.toLowerCase() == 'low'
                                              ? Colors.grey
                                              : Colors.orange),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Assigned Date : $assignedStr",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
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
            onPressed: () {},
            backgroundColor: Colors.purple,
            shape: CircleBorder(
              side: BorderSide(color: Colors.white, width: 5),
            ),
            child: Icon(Icons.add, size: 35, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavBar(
        activeScreen: "history",
        onHomeTap: _onHomeTap,
        onScheduledTap: () {
          Navigator.pushNamed(context, '/scheduled_task_screen');
        },
        onNotificationTap: () {
          Navigator.pushNamed(context, '/notifications');
        },
        onHistoryTap: () {},
      ),
    );
  }

  Widget _coloredDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
