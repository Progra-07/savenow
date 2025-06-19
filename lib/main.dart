import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'core/error_handler.dart'; // Added import
import 'ui/screens/auth_wrapper.dart';
import 'providers/auth_provider.dart';
import 'providers/bookmark_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorHandler.initialize(); // Initialize the error handler

  // Initialize Supabase with your project's URL and ANON KEY
  await Supabase.initialize(
    url: 'https://cowpfynejkjgxwdfsbgx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvd3BmeW5lamtqZ3h3ZGZzYmd4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAxNjEyMjMsImV4cCI6MjA2NTczNzIyM30.1e5C_Av3N6YB6EwuLIKoLYNSer27D_lNUYUb4F_fli0',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
      ],
      child: MaterialApp(
        title: 'Bookmark Pro',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthWrapper(),
      ),
    );
  }
}
