import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tubes_progress/components/button_back.dart';
import 'package:tubes_progress/components/button_comp.dart';
import 'package:tubes_progress/components/divider_comp.dart';
import 'package:tubes_progress/components/page_comp.dart';
import 'package:tubes_progress/components/text_button_comp.dart';
import 'package:tubes_progress/components/text_link_comp.dart';
import 'package:tubes_progress/pages/login_page.dart';
import 'package:tubes_progress/theme.dart';

import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final primaryColor = const Color(0xFF28CB8B);
  final secondaryColor = const Color(0xFF4A6572);

  void register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final fullName = fullNameController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    if (email.isEmpty ||
        password.isEmpty ||
        fullName.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Semua field harus diisi'),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password dan Konfirmasi Password tidak cocok'),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    final uri = Uri.https('pegi-backend.vercel.app', 'api/auth/register');
    try {
      // Add print statements for debugging
      print('Sending register request to: $uri');
      print(
        'Request body: ${jsonEncode({'email': email, 'password': password, 'namaLengkap': fullName})}',
      );

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'namaLengkap': fullName,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check if the status code is successful (both 200 and 201)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registrasi berhasil!'),
            backgroundColor: Colors.green[400],
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        // Add more detailed error message from the response if possible
        String errorMsg = 'Registrasi gagal, silakan coba lagi';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMsg = errorData['message'];
          }
        } catch (e) {
          // If we can't decode the error body, use the default message
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red[400]),
        );
      }
    } catch (e) {
      print('Exception during registration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red[400],
        ),
      );
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
            BackButtonSquare(),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Hallo, Silahkan Register Jika Bleum Punya Akun",
                style: textBoldXl,
              ),
            ),
            SizedBox(height: 40),

            TextFormField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                hintText: "Masukkan Nama Lengkap Anda",
                prefixIcon: Icon(Icons.person, color: primaryColor),
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
            SizedBox(height: 16),
            TextFormField(
              controller: emailController,
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
            SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
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
            SizedBox(height: 16),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                hintText: "Konfirmasi password Anda",
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
            SizedBox(height: 16),
            Center(
              child: TextButtonComp(
                text: "Ada pertanyaan?",
                onPressed: () => {},
                color: Colors.white,
              ),
            ),
            Center(
              child: ButtonComp(onPressed: () => register(), text: "REGISTER"),
            ),
            SizedBox(height: 20),
            DividerComp(text: "Or Register With"),
            SizedBox(height: 20),

            TextLinkComp(
              normalText: "Already have an account?",
              linkText: "Login Now",
              onTap:
                  () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    ),
                  },
            ),
          ],
        ),
      ),
    );
  }
}
