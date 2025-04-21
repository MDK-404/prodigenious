import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prodigenious/viewmodel/auth_view_model.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailCtrl = TextEditingController();

  final TextEditingController usernameCtrl = TextEditingController();

  final TextEditingController passwordCtrl = TextEditingController();

  final TextEditingController retypeCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureRetypePassword = true;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3D0087), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40),
                Image.asset('assets/logo.png', height: 80),
                SizedBox(height: 10),
                Text(
                  "Join Using Your Credentials",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Create Your Account",
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3D0087),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: emailCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: usernameCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Username',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: passwordCtrl,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: retypeCtrl,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Retype Password',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureRetypePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureRetypePassword =
                                        !_obscureRetypePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              String email = emailCtrl.text.trim();
                              String username = usernameCtrl.text.trim();
                              String password = passwordCtrl.text.trim();
                              String retypePassword = retypeCtrl.text.trim();

                              if (email.isEmpty ||
                                  username.isEmpty ||
                                  password.isEmpty ||
                                  retypePassword.isEmpty) {
                                _showDialog(context, "Error",
                                    "All fields are required.");
                                return;
                              }

                              if (password.length < 8) {
                                _showDialog(context, "Error",
                                    "Password must be at least 8 characters long.");
                                return;
                              }

                              if (password != retypePassword) {
                                _showDialog(context, "Error",
                                    "Passwords do not match.");
                                return;
                              }

                              await authViewModel.signUpWithEmail(
                                email: email,
                                username: username,
                                password: password,
                                retypePassword: retypePassword,
                                context: context,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF9333EA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 14),
                            ),
                            child: const Text('Sign up',
                                style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () =>
                                authViewModel.signInWithGoogle(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/google_logo.png',
                                    height: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  "Continue with Google",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/login');
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Color(0xFF9333EA),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
