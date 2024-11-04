import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registers a new user with email and password
  Future<String?> registerWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return 'Registration successful!';
    } catch (e) {
      return 'Registration failed: ${e.toString()}';
    }
  }

  // Logs in an existing user with email and password
  Future<String?> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return 'Login successful!';
    } catch (e) {
      return 'Login failed: ${e.toString()}';
    }
  }

  // Logs out the current user
  Future<void> logout() async {
    await _auth.signOut();
  }

  String getCurrentUserId() {
    return _auth.currentUser?.uid??'';
  }
}