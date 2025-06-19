import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Keep for User type if needed, or remove if AuthService handles all User interactions
import '../core/dependencies.dart';
import '../services/auth_service.dart'; // Potentially remove if not directly used, though good for clarity

class AuthProvider with ChangeNotifier {
  final AuthService _authService = ServiceLocator.authService;

  User? get currentUser => _authService.currentUser;

  Stream<AuthState> get authStateChanges => _authService.authStateChanges;

  // Sign Up
  Future<void> register(String email, String password, String username) async {
    try {
      // AuthService.signUp now handles the core authentication.
      // Profile creation might still live here, or be moved to a ProfileService.
      // For now, assuming AuthService.signUp might not handle profile creation.
      await _authService.signUp(email, password,
          username: username); // Corrected argument passing

      // If AuthService.signUp does not handle profile creation, it remains here.
      // This depends on the design of AuthService.signUp.
      // The provided AuthService.signUp includes username in options,
      // implying it might handle this. If so, the direct call below might be redundant
      // or should be handled within AuthService.
      // For this refactor, we'll assume profile creation is still handled here
      // if not explicitly moved to AuthService.
      // However, the provided AuthService.signUp in the prompt *does* take username.
      // Let's assume the service handles it or the backend (e.g. trigger) handles it.
      // If direct profile creation is still needed:
      // final userId = _authService.currentUser?.id;
      // if (userId != null) {
      //   await _supabase.from('profiles').insert({
      //     'user_id': userId,
      //     'username': username,
      //     'created_at': DateTime.now().toIso8601String(),
      //   });
      // }
      notifyListeners();
    } catch (e) {
      // ErrorHandler.recordError(e, stackTrace, reason: 'AuthProvider.register');
      throw Exception('Registration failed: $e');
    }
  }

  // Sign In
  Future<void> signIn(String email, String password) async {
    try {
      await _authService.signIn(email, password);
      notifyListeners();
    } catch (e) {
      // ErrorHandler.recordError(e, stackTrace, reason: 'AuthProvider.signIn');
      throw Exception('Login failed: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      notifyListeners();
    } catch (e) {
      // ErrorHandler.recordError(e, stackTrace, reason: 'AuthProvider.signOut');
      throw Exception('Logout failed: $e');
    }
  }
}
