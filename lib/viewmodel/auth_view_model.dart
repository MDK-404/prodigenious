import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:prodigenious/services/get_service_key.dart';
import '../services/auth_service.dart';

class AuthViewModel with ChangeNotifier {
  final AuthService _authService = AuthService();

  Future<void> signUpWithEmail({
    required String email,
    required String username,
    required String password,
    required String retypePassword,
    required BuildContext context,
  }) async {
    try {
      if (email.isEmpty ||
          username.isEmpty ||
          password.isEmpty ||
          retypePassword.isEmpty) {
        _showError(context, "All fields are required.");
        return;
      }

      if (password.length < 8) {
        _showError(context, "Password must be at least 8 characters long.");
        return;
      }

      if (password != retypePassword) {
        _showError(context, "Passwords do not match.");
        return;
      }

      final user = await _authService.signUpWithEmail(
        email: email,
        username: username,
        password: password,
        context: context,
      );

      if (user != null) {
        await saveUserToken();
        user.sendEmailVerification();
        _showMessage(
            context, "Verification email sent! Please verify your email.");
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    final user = await _authService.signInWithGoogle();
    if (user != null) {
      await saveUserToken();
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showError(context, 'Google Sign-in Failed!');
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final user = await _authService.signInWithEmail(email, password);
      if (user != null) {
        await saveUserToken();
        GetServerKey getServerKey = GetServerKey();
        String accessToken = await getServerKey.getServerKeyToken();
        print(accessToken);
        if (!user.emailVerified) {
          if (context.mounted) {
            _showError(context, 'Please verify your email first!');
          }
        } else {
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, e.toString());
      }
    }
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    if (email.isEmpty) {
      _showError(context, "Please enter your email.");
      return;
    }

    try {
      await _authService.resetPassword(email);
      _showMessage(context, "Password reset email sent! Check your inbox.");
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

Future<void> saveUserToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance.collection('users').doc(uid).update({
    'fcmToken': token,
  });
}
