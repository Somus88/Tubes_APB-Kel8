import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class BookingDetailsPage extends StatefulWidget {
  BookingDetailsPage({super.key, required this.bookingId});
  final String bookingId;

  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  @override
  void initState() {
    super.initState();
    fetchData(widget.bookingId);
  }

  Map<String, dynamic> bookingData = {};
  Map<String, dynamic> scheduleData = {};
  bool isLoading = true;
  String errorMessage = '';

  void fetchData(bookingId) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token not found');
      }
      final uri = Uri.https(
        'pegi-backend.vercel.app',
        '/api/booking/$bookingId',
      );
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          bookingData = data;
          scheduleData = data['schedule'] ?? {};
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load booking details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to fetch booking details: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: Colors.blue,
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading booking details...'),
                  ],
                ),
              )
              : errorMessage.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 60),
                    SizedBox(height: 16),
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => fetchData(widget.bookingId),
                      child: Text('Try Again'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(bookingData['status'] ?? 'Pending'),
                    const SizedBox(height: 20),
                    _buildDetailCard('Booking Information', [
                      DetailItem(
                        label: 'Booking ID',
                        value: bookingData['id'] ?? 'N/A',
                      ),
                      DetailItem(
                        label: 'Date',
                        value: _formatDate(scheduleData['departureAt']),
                      ),
                      DetailItem(
                        label: 'Time',
                        value: _formatTime(scheduleData['departureAt']),
                      ),
                      DetailItem(
                        label: 'Departure',
                        value: scheduleData['departure']?['name'] ?? 'N/A',
                      ),
                      DetailItem(
                        label: 'Arrival',
                        value: scheduleData['arrival']?['name'] ?? 'N/A',
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailCard('Service Details', [
                      DetailItem(
                        label: 'Service',
                        value: bookingData['type'] ?? 'N/A',
                      ),
                      DetailItem(
                        label: 'Price',
                        value: 'Rp ${scheduleData['price'] ?? '0'}',
                      ),
                      DetailItem(
                        label: 'Customer',
                        value: bookingData['namaLengkap'] ?? 'N/A',
                      ),
                    ]),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
    );
  }

  String _formatDate(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildStatusCard(String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'paid':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: statusColor),
          const SizedBox(width: 8),
          Text(
            'Status: $status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, List<DetailItem> details) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(thickness: 1),
            ...details.map(
              (detail) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      detail.label,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    Text(
                      detail.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailItem {
  final String label;
  final String value;

  DetailItem({required this.label, required this.value});
}
