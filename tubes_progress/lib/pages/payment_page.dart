import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tubes_progress/components/page_comp.dart';
import 'package:tubes_progress/models/schedule.dart';
import 'package:tubes_progress/pages/payment_qr_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class PaymentPage extends StatelessWidget {
  const PaymentPage({
    super.key,
    required this.schedule,
    required this.namaLengkap,
    required this.noHandphone,
    required this.email,
    required this.type,
  });
  final Schedule schedule;
  final String namaLengkap;
  final String noHandphone;
  final String email;
  final String type;

  void konfirmasiBooking(BuildContext context) {
    // Implementasi konfirmasi booking
    try {
      final uri = Uri.https('pegi-backend.vercel.app', '/api/booking');
      final storage = FlutterSecureStorage();
      storage
          .read(key: 'token')
          .then((token) {
            if (token == null) {
              throw Exception("Token tidak ditemukan");
            }
            http
                .post(
                  uri,
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode({
                    'scheduleId': schedule.id,
                    'namaLengkap': namaLengkap,
                    'phoneNumber': noHandphone,
                    'email': email,
                    'type': type,
                  }),
                )
                .then((response) {
                  if (response.statusCode == 201) {
                    // Booking berhasil
                    print("Booking berhasil");

                    // pindah page ke halaman bayar
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PaymentQRPage(
                              bookingId: jsonDecode(response.body)['id'],
                            ),
                      ),
                    );
                  } else {
                    throw Exception(
                      "Gagal melakukan booking: ${response.body}",
                    );
                  }
                })
                .catchError((error) {
                  // Tangani error dari http request
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal melakukan booking: $error'),
                      backgroundColor: Colors.red[400],
                    ),
                  );
                });
          })
          .catchError((error) {
            // Tangani error jika token tidak ditemukan
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal mendapatkan token: $error'),
                backgroundColor: Colors.red[400],
              ),
            );
          });
    } catch (e) {
      // Tangani error lainnya
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
      showAppBar: true,
      appBarTitle: 'Selesaikan Pembayaran',
      child: Column(
        children: [
          SizedBox(height: 40),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Customer name"),
                Text(
                  namaLengkap,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Text("Amount"),
                Text(
                  type == "Paket"
                      ? (schedule.price * 0.3).toString()
                      : schedule.price.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
          SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                konfirmasiBooking(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Bayar",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
