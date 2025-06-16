import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:tubes_progress/components/page_comp.dart';
import 'package:tubes_progress/pages/booking_detail.dart';
import 'package:tubes_progress/pages/payment_qr_page.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int selectedTabIndex = 1; // default ke 'Pembayaran'
  final List<String> tabLabels = ['Ticket', 'Pembayaran'];

  @override
  Widget build(BuildContext context) {
    return PageComp(
      showBottomNavbar: true,
      selectedIndex: 1,
      isScrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Tab Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(tabLabels.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTabIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color:
                        selectedTabIndex == index
                            ? Colors.white
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tabLabels[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          selectedTabIndex == index ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Ini harus di-Expanded agar tidak menyebabkan layout crash
          Expanded(
            child: IndexedStack(
              index: selectedTabIndex,
              children: [
                TicketList(),
                PaymentList(),
                const Center(child: Text("Riwayat Pesanan")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentList extends StatefulWidget {
  PaymentList({super.key});

  @override
  State<PaymentList> createState() => _PaymentListState();
}

class _PaymentListState extends State<PaymentList> {
  List<dynamic> bookedSchedules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookedSchedules();
  }

  Future<void> fetchBookedSchedules() async {
    try {
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');
      if (token == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final uri = Uri.https('pegi-backend.vercel.app', '/api/user/booking');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          bookedSchedules = data;
          isLoading = false;
        });
      } else {
        // Handle error
        setState(() {
          isLoading = false;
        });
        print('Failed to fetch: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  String formatDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy\nHH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookedSchedules.isEmpty) {
      return const Center(child: Text('Tidak ada data booking.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bookedSchedules.length,
      itemBuilder: (context, index) {
        final booking = bookedSchedules[index];
        final schedule = booking['schedule'];
        final departureName = schedule['departure']['name'];
        final arrivalName = schedule['arrival']['name'];
        final departureAt = formatDate(schedule['departureAt']);
        final price = schedule['price'];
        final status = booking['status'];
        if (status != 'pending') {
          return const SizedBox.shrink(); // Skip pending bookings
        }
        final namaLengkap = booking['namaLengkap'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      booking['type'] == 'Paket'
                          ? Icons.inventory
                          : booking['type'] == 'Travel'
                          ? Icons.directions_car
                          : Icons.directions_bus,
                      color: Colors.blue,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$departureName to $arrivalName",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text("a.n $namaLengkap"),
                        const SizedBox(height: 4),
                        Text(
                          "Transaction ID\n${booking['id']}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Rp ${NumberFormat("#,##0", "id_ID").format(booking['type'] == 'Paket' ? price * 0.3 : price)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color:
                              status == "confirmed"
                                  ? Colors.green
                                  : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        departureAt,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PaymentQRPage(bookingId: booking['id']),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code),
                label: const Text("Lihat QR Code Pembayaran"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TicketList extends StatefulWidget {
  TicketList({super.key});

  @override
  State<TicketList> createState() => _TicketListState();
}

class _TicketListState extends State<TicketList> {
  List<dynamic> bookedSchedules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookedSchedules();
  }

  Future<void> fetchBookedSchedules() async {
    try {
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');
      if (token == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final uri = Uri.https('pegi-backend.vercel.app', '/api/user/booking');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          bookedSchedules = data;
          isLoading = false;
        });
      } else {
        // Handle error
        setState(() {
          isLoading = false;
        });
        print('Failed to fetch: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  String formatDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy\nHH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookedSchedules.isEmpty) {
      return const Center(child: Text('Tidak ada data booking.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bookedSchedules.length,
      itemBuilder: (context, index) {
        final booking = bookedSchedules[index];
        final schedule = booking['schedule'];
        final departureName = schedule['departure']['name'];
        final arrivalName = schedule['arrival']['name'];
        final departureAt = formatDate(schedule['departureAt']);
        final price = schedule['price'];
        final status = booking['status'];
        if (status != 'paid') {
          return const SizedBox.shrink(); // Skip paid bookings
        }
        final namaLengkap = booking['namaLengkap'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      booking['type'] == 'Paket'
                          ? Icons.inventory
                          : booking['type'] == 'Travel'
                          ? Icons.directions_car
                          : Icons.directions_bus,
                      color: Colors.blue,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$departureName to $arrivalName",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text("a.n $namaLengkap"),
                        const SizedBox(height: 4),
                        Text(
                          "Transaction ID\n${booking['id']}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Rp ${NumberFormat("#,##0", "id_ID").format(booking['type'] == 'Paket' ? price * 0.3 : price)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color:
                              status == "paid" ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        departureAt,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              BookingDetailsPage(bookingId: booking['id']),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text("Lihat Detail Tiket"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
