import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final GoTrueClient _auth = Supabase.instance.client.auth;

  User? get currentUser => _auth.currentUser;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      // Consider using the ErrorHandler here
      print('AuthService signIn error: $e'); // Simple error logging
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, {String? username}) async {
    try {
      // supabase_flutter v2 uses 'data' parameter for metadata
      await _auth.signUp(
        email: email,
        password: password,
        data: username != null ? {'username': username} : null,
      );
    } catch (e) {
      print('AuthService signUp error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('AuthService signOut error: $e');
      rethrow;
    }
  }

  // You might want to add other methods like password recovery, OTP, etc.
}
