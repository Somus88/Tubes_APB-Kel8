import 'package:flutter/material.dart';
import 'package:tubes_progress/components/page_comp.dart';
import 'package:tubes_progress/pages/payment_page.dart';

import 'package:tubes_progress/models/schedule.dart';

class OrderFormPage extends StatelessWidget {
  OrderFormPage({super.key, required this.schedule, required this.type});
  final String type;

  final Schedule schedule;

  final namaLengkapController = TextEditingController();
  final noHandphoneController = TextEditingController();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PageComp(
      showAppBar: true,
      appBarTitle: 'Form Pemesanan',
      child: Column(
        children: [
          TextFormField(
            controller: namaLengkapController,
            decoration: InputDecoration(hintText: "Nama Lengkap"),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: noHandphoneController,
            decoration: InputDecoration(hintText: "Nomor Handphone"),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: "Alamat Email (untuk mengirim e-ticket)",
            ),
          ),
          SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Tambahkan validasi atau navigasi
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => PaymentPage(
                          schedule: schedule,
                          namaLengkap: namaLengkapController.text,
                          noHandphone: noHandphoneController.text,
                          email: emailController.text,
                          type: type,
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Simpan & Bayar",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
