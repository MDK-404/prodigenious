import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prodigenious/services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _retypePasswordController =
      TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureRetype = true;
  bool _loading = false;

  String currentEmail = '';
  String currentUsername = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _loading = true);
    final userData = await UserService().fetchUserData();
    setState(() {
      currentEmail = userData['email']!;
      currentUsername = userData['username']!;
      _usernameController.text = currentUsername;
      _loading = false;
    });
  }

  Future<bool> _isUsernameAvailable(String username) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    return result.docs.isEmpty ||
        (result.docs.length == 1 && result.docs.first.id == currentUser!.uid);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("OK")),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    String newUsername = _usernameController.text.trim();
    String oldPass = _currentPasswordController.text.trim();
    String newPass = _newPasswordController.text.trim();
    String retypePass = _retypePasswordController.text.trim();

    bool usernameChanged = newUsername != currentUsername;
    bool passwordFieldsFilled =
        oldPass.isNotEmpty || newPass.isNotEmpty || retypePass.isNotEmpty;

    if (!usernameChanged && !passwordFieldsFilled) {
      _showErrorDialog("No changes detected.");
      return;
    }

    setState(() => _loading = true);

    try {
      if (usernameChanged) {
        bool isAvailable = await _isUsernameAvailable(newUsername);
        if (!isAvailable) {
          _showErrorDialog("This username is not available.");
          setState(() => _loading = false);
          return;
        }
        await UserService().updateUsername(newUsername);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Username updated successfully")),
        );
      }

      if (passwordFieldsFilled) {
        if (oldPass.isEmpty || newPass.isEmpty || retypePass.isEmpty) {
          _showErrorDialog("All password fields are required.");
          setState(() => _loading = false);
          return;
        }
        if (oldPass == newPass) {
          _showErrorDialog("You can't use your old password.");
          setState(() => _loading = false);
          return;
        }
        if (newPass != retypePass) {
          _showErrorDialog("Passwords don't match.");
          setState(() => _loading = false);
          return;
        }

        await UserService().changePassword(oldPass, newPass);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password changed successfully")),
        );
      }

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3D0087), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      Center(child: Image.asset('assets/logo.png', height: 80)),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Edit Profile",
                                  style: GoogleFonts.inter(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF9945FF),
                                  ),
                                ),
                                SizedBox(height: 15),
                                Text("Change Username",
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    )),
                                SizedBox(height: 8),
                                TextField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    hintText: "Enter Username",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text("Change Password",
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    )),
                                SizedBox(height: 8),
                                TextField(
                                  controller: _currentPasswordController,
                                  obscureText: _obscureCurrent,
                                  decoration: InputDecoration(
                                    hintText: "Enter Old Password",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: _newPasswordController,
                                  obscureText: _obscureNew,
                                  decoration: InputDecoration(
                                    hintText: "Enter New Password",
                                    border: OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscureNew
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () {
                                        setState(
                                            () => _obscureNew = !_obscureNew);
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: _retypePasswordController,
                                  obscureText: _obscureRetype,
                                  decoration: InputDecoration(
                                    hintText: "Confirm New Password",
                                    border: OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscureRetype
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () {
                                        setState(() =>
                                            _obscureRetype = !_obscureRetype);
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/forgot_password');
                                    },
                                    child: Text(
                                      "Forgot Password?",
                                      style: GoogleFonts.inter(
                                          fontSize: 16,
                                          color: Color(0xFF9C5AEC)),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: _handleSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF9C5AEC),
                                      minimumSize: Size(125, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(45),
                                      ),
                                    ),
                                    child: Text(
                                      "Submit",
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
