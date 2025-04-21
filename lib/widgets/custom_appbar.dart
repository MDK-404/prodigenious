import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:prodigenious/view/dashboard_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  Future<void> signOut(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userEmail = currentUser?.email ?? 'unknown';

    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/logo.png',
            height: 50,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ],
      ),
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () async {
              final RenderBox overlay =
                  Overlay.of(context).context.findRenderObject() as RenderBox;
              final RenderBox button = context.findRenderObject() as RenderBox;

              final Offset offset =
                  button.localToGlobal(Offset.zero, ancestor: overlay);

              await showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  offset.dx,
                  offset.dy + button.size.height,
                  0,
                  0,
                ),
                items: [
                  PopupMenuItem(
                    padding: EdgeInsets.zero,
                    enabled: false,
                    child: Material(
                      color: Colors.purple.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            horizontalTitleGap: 12,
                            leading: Icon(Icons.person, color: Colors.white),
                            title: Text("Edit Profile",
                                style: TextStyle(color: Colors.white)),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/profile');
                            },
                          ),
                          ListTile(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            leading: Icon(Icons.dashboard, color: Colors.white),
                            title: Text("Dashboard",
                                style: TextStyle(color: Colors.white)),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TaskDashboardScreen(userEmail: userEmail),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            leading: Icon(Icons.insights, color: Colors.white),
                            title: Text("Insights",
                                style: TextStyle(color: Colors.white)),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                  context, '/productivity_screen');
                            },
                          ),
                          Divider(color: Colors.white54),
                          ListTile(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            leading: Icon(Icons.logout, color: Colors.white),
                            title: Text("Logout",
                                style: TextStyle(color: Colors.white)),
                            onTap: () {
                              Navigator.pop(context);
                              signOut(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
