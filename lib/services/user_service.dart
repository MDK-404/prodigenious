import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, String>> fetchUserData() async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();

    return {
      'email': user.email!,
      'username': doc['username'],
    };
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);

      if (currentPassword == newPassword) {
        throw Exception("You can't use your old password.");
      }

      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception("Incorrect current password");
    }
  }

  Future<void> updateUsername(String newUsername) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'username': newUsername,
      });
    } catch (e) {
      throw Exception("Error updating username: $e");
    }
  }
}
