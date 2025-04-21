import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prodigenious/view/task_history.dart';
import 'package:prodigenious/widgets/add_task_dialog.dart';
import 'package:prodigenious/widgets/custom_appbar.dart';
import 'package:prodigenious/widgets/navigation_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String? userEmail;
  String? username;
  int unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'];
        });
      }
    }
  }

  Future<void> clearNotification(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  Future<void> clearAllNotifications() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('email', isEqualTo: userEmail)
        .where('isDelivered', isEqualTo: true)
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  void countUnreadNotifications() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('email', isEqualTo: userEmail)
        .where('isSeen', isEqualTo: false)
        .get();

    setState(() {
      unreadNotificationsCount = querySnapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: userEmail == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('email', isEqualTo: userEmail)
                  .where('isDelivered', isEqualTo: true)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final notifications = snapshot.data!.docs;

                if (notifications.isEmpty) {
                  return Center(child: Text('No notifications available.'));
                }

                countUnreadNotifications();

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Notifications",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await clearAllNotifications();
                                },
                                child: Text(
                                  "Clear All",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final data = notifications[index].data()
                              as Map<String, dynamic>;
                          final String title = data['title'];
                          final String body = data['body'];
                          final Timestamp timestamp = data['timestamp'];
                          final DateTime dateTime = timestamp.toDate();
                          final String notificationId = notifications[index].id;

                          return ListTile(
                            title: Text(title),
                            subtitle: Text(body),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(DateFormat('yyyy-MM-dd').format(dateTime)),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () async {
                                    await clearNotification(notificationId);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {},
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: Transform.translate(
        offset: Offset(0, 35),
        child: Container(
          height: 70,
          width: 70,
          child: FloatingActionButton(
            onPressed: () {
              if (username != null && userEmail != null) {
                showAddTaskDialog(context, username!, userEmail!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("User data is still loading...")),
                );
              }
            },
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
          activeScreen: 'notifications',
          onScheduledTap: () {
            Navigator.pushNamed(context, '/scheduled_task_screen');
          },
          onHistoryTap: () {
            if (userEmail != null && username != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(
                    userEmail: userEmail!,
                    username: username!,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('User data is still loading, please wait...')),
              );
            }
          },
          onHomeTap: () => {Navigator.pushNamed(context, '/home')},
          onNotificationTap: () =>
              {Navigator.pushNamed(context, '/notifications')}),
    );
  }
}
