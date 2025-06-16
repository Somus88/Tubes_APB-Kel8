import 'package:flutter/material.dart';
import 'package:tubes_progress/components/button_comp.dart';
import 'package:tubes_progress/components/page_comp.dart';
import 'package:tubes_progress/components/text_button_comp.dart';
import 'package:tubes_progress/components/text_link_comp.dart';
import 'package:tubes_progress/pages/home_page.dart';
import 'package:tubes_progress/pages/register_page.dart';
import 'package:tubes_progress/theme.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final primaryColor = const Color(0xFF28CB8B);
  final secondaryColor = const Color(0xFF4A6572);
  bool _isLoading = false;
  void emailLogin() async {
    if (_isLoading) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email dan password harus diisi'),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final uri = Uri.https('pegi-backend.vercel.app', 'api/auth/login');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        // Save token to secure storage
        print(data['token']);
        final storage = FlutterSecureStorage();
        await storage.write(key: 'token', value: data['token']);

        // Go to dashboard
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } else {
        throw Exception(data['error'] ?? 'Login gagal');
      }
    } catch (e) {
      print('Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login gagal: ${e.toString()}'),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageComp(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Selamat Datang! Silahkan Login", style: textBoldXl),
            ),
            SizedBox(height: 40),
            TextFormField(
              controller: emailController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Masukkan email Anda",
                prefixIcon: Icon(Icons.email, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            TextFormField(
              controller: passwordController,
              enabled: !_isLoading,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                hintText: "Masukkan password Anda",
                prefixIcon: Icon(Icons.lock, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButtonComp(
                text: "Ada pertanyaan?",
                onPressed: () => {},
                color: Colors.white,
              ),
            ),
            Center(
              child:
                  _isLoading
                      ? CircularProgressIndicator(color: primaryColor)
                      : ButtonComp(onPressed: emailLogin, text: "LOGIN"),
            ),
            SizedBox(height: 20),

            TextLinkComp(
              normalText: "Don't have an account?",
              linkText: "Register Now",
              onTap: () {
                if (!_isLoading) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
