// lib/ui/screens/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../home_page.dart';
import '../login_page.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Supabase.instance.client.auth.onAuthStateChange.map(
        (event) => event.currentSession?.user,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            return HomePage(); // User is authenticated
          }
          return LoginPage(); // User is not authenticated
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
