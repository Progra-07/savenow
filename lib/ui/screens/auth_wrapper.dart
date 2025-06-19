// lib/ui/screens/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_page.dart'; // Corrected import path
import 'login_page.dart'; // Corrected import path

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Note: The AuthProvider is not directly used in this widget as per the read file.
    // If state management via Provider is intended for user auth state,
    // this widget would typically consume AuthProvider.
    // For now, sticking to direct Supabase stream usage as in the original file.
    return StreamBuilder<User?>(
      stream: Supabase.instance.client.auth.onAuthStateChange.map(
        (event) => event.session?.user, // Corrected to use session
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            return HomePage(); // User is authenticated
          }
          return LoginPage(); // User is not authenticated
        }
        // Display a loading indicator while waiting for connection
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
