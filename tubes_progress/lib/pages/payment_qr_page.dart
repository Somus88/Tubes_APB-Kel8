import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentQRPage extends StatelessWidget {
  PaymentQRPage({required this.bookingId, super.key}) {
    paymentData =
        "https://pegi-backend.vercel.app/api/booking/qr?bookingId=$bookingId";
  }
  late final String paymentData;
  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran QR'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Scan QR Code untuk pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: QrImageView(
                data: paymentData,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Show a dialog or navigate to a success page
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Konfirmasi Pembayaran'),
                        content: const Text(
                          'Apakah Anda yakin sudah melakukan pembayaran?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Tidak'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Navigate to success page or do other actions after payment confirmation
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Pembayaran Sedang Diverifikasi!',
                                  ),
                                ),
                              );
                              // back to main page
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            },
                            child: const Text('Ya'),
                          ),
                        ],
                      ),
                );
              },
              child: const Text('Sudah Bayar', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
