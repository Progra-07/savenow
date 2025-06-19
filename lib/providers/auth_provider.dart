import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign Up
  Future<void> register(String email, String password, String username) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      // Create user profile in Supabase's "profiles" table
      await _supabase.from('profiles').insert({
        'user_id': _supabase.auth.currentUser!.id,
        'username': username,
        'created_at': DateTime.now().toIso8601String(),
      });

      notifyListeners();
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Sign In
  Future<void> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      notifyListeners();
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      notifyListeners();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
}
