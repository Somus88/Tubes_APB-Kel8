import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tubes_progress/components/page_comp.dart';
import 'package:tubes_progress/pages/edit_profile_page.dart';
import 'package:tubes_progress/pages/login_page.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String name = "";
  String email = "";
  String userId = "";
  String _imagePath = "";
  File? _image;
  bool _isLoadingImage = false;

  Future<void> logout(BuildContext context) async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: 'token'); // Remove token from secure storage

    // Show a success message (optional)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Berhasil keluar'), backgroundColor: Colors.green),
    );

    // Navigate to login page and clear navigation stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  Future<void> _loadImage() async {
    if (_imagePath.isEmpty) return;

    setState(() {
      _isLoadingImage = true;
    });

    try {
      Uint8List imageBytes = await Supabase.instance.client.storage
          .from('images')
          .download(_imagePath);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${_imagePath.split('/').last}');
      await file.create(recursive: true);
      await file.writeAsBytes(imageBytes);

      if (mounted) {
        setState(() {
          _image = file;
          _isLoadingImage = false;
        });
      }
    } catch (e) {
      print('Error loading image: $e');
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }
    }
  }

  fetchUserData() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    debugPrint('Token: $token');
    if (token == null) {
      return null; // Token not found, user not logged in
    }
    final uri = Uri.https('pegi-backend.vercel.app', 'api/user');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('User data fetched: $data');
      return data; // Return user data
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  void initState() {
    super.initState();
    // Fetch user data when the page is initialized
    fetchUserData()
        .then((data) {
          if (data != null) {
            setState(() {
              name = data['name'] ?? "Nama Pengguna";
              email = data['email'] ?? "email@example.com";
              userId = data['id'] ?? "";
              _imagePath = data['image'] ?? "";

              // Load the image if path exists
              if (_imagePath.isNotEmpty) {
                _loadImage();
              }
            });
          } else {
            print('No user data found');
          }
        })
        .catchError((error) {
          print('Error fetching user data: $error');
        });
  }

  @override
  Widget build(BuildContext context) {
    return PageComp(
      selectedIndex: 2,
      showBottomNavbar: true,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Profile image with proper loading
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child:
                            _isLoadingImage
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : _image != null
                                ? Image.file(
                                  _image!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                                : Image.asset(
                                  'assets/images/profile.png',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Nama & email
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(),
                        ),
                      ).then((value) {
                        // Refresh user data when returning from edit profile page
                        fetchUserData()
                            .then((data) {
                              if (data != null) {
                                setState(() {
                                  name = data['name'] ?? "Nama Pengguna";
                                  email = data['email'] ?? "email@example.com";
                                  _imagePath = data['image'] ?? "";

                                  // Reload the image if path has changed
                                  if (_imagePath.isNotEmpty) {
                                    _loadImage();
                                  } else {
                                    _image = null;
                                  }
                                });
                              }
                            })
                            .catchError((error) {
                              print('Error fetching user data: $error');
                            });
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Perbarui Profile",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Versi Aplikasi",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Versi 1.0.0", // Ganti dengan versi dinamis jika mau
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Divider(height: 30),

                ListTile(
                  onTap: () {
                    // aksi untuk beri nilai aplikasi
                  },
                  leading: Icon(Icons.star, color: Colors.orange),
                  title: Text("Beri Nilai Aplikasi"),
                  trailing: Icon(Icons.chevron_right),
                ),
                Divider(height: 1),

                ListTile(
                  onTap: () {
                    // aksi untuk umpan balik pengguna
                  },
                  leading: Icon(Icons.feedback, color: Colors.blue),
                  title: Text("Umpan Balik Pengguna"),
                  trailing: Icon(Icons.chevron_right),
                ),
                Divider(height: 1),

                ListTile(
                  onTap: () {
                    // aksi untuk privasi pengguna
                  },
                  leading: Icon(Icons.verified_user, color: Colors.blue),
                  title: Text("Privasi Pengguna"),
                  trailing: Icon(Icons.chevron_right),
                ),
                Divider(height: 1),

                ListTile(
                  onTap: () {
                    // 🟢 Call logout function here!
                    logout(context);
                  },
                  leading: Icon(Icons.logout, color: Colors.red[300]),
                  title: Text(
                    "Keluar",
                    style: TextStyle(color: Colors.red[300]),
                  ),
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
