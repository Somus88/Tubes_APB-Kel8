import 'package:flutter/material.dart';
import 'package:tubes_progress/pages/login_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tubes_progress/pages/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://bhdlbvkuqibwalurqjpg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJoZGxidmt1cWlid2FsdXJxanBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAwMTYyODMsImV4cCI6MjA2NTU5MjI4M30.XigszFitUUts0oKqvL-fVETRXizn7jjjVyxrJm5l2zc',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: FlutterSecureStorage().read(key: 'token'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          // If token exists, navigate to home page
          return MaterialApp(home: HomePage());
        } else {
          // If no token, navigate to login page
          return MaterialApp(home: LoginPage());
        }
      },
    );
  }
}
