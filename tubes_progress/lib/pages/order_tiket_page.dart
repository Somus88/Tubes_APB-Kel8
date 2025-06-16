import 'package:flutter/material.dart';
import 'package:tubes_progress/components/button_comp.dart';
import 'package:tubes_progress/components/page_comp.dart';
import 'package:tubes_progress/pages/order_form_page.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tubes_progress/models/schedule.dart';
import 'package:tubes_progress/pages/payment_page.dart';

class OrderTiketPage extends StatefulWidget {
  const OrderTiketPage({
    super.key,
    required this.departureCityId,
    required this.arrivalCityId,
    required this.selectedDate,
    required this.type,
    this.pengirim,
    this.kontakPengirim,
    this.penerima,
    this.kontakPenerima,
    this.berat,
    this.email,
  });
  final String departureCityId;
  final String arrivalCityId;
  final DateTime selectedDate;
  final String type;
  final String? email;

  // paket
  final String? pengirim;
  final String? kontakPengirim;
  final String? penerima;
  final String? kontakPenerima;
  final double? berat;

  @override
  State<OrderTiketPage> createState() => _OrderTiketPageState();
}

class _OrderTiketPageState extends State<OrderTiketPage> {
  List<Schedule> schedules = [];

  Future<void> fetchSchedules() async {
    try {
      final Map<String, String> queryParameters = <String, String>{
        'departureCityId': widget.departureCityId,
        'arrivalCityId': widget.arrivalCityId,
        'date': widget.selectedDate.toIso8601String().split('T')[0],
        'vehicleType': widget.type == "Paket" ? "Travel" : widget.type,
      };
      final uri = Uri.https(
        'pegi-backend.vercel.app',
        '/api/schedule',
        queryParameters,
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          schedules =
              data.map((item) {
                return Schedule(
                  id: item['id'],
                  vehicleId: item['vehicleId'],
                  departureId: item['departureId'],
                  arrivalId: item['arrivalId'],
                  departureAt: DateTime.parse(item['departureAt']),
                  arrivalAt: DateTime.parse(item['arrivalAt']),
                  price: item['price'],
                  seats: item['seats'],
                  vehicle: Vehicle(
                    id: item['vehicle']['id'],
                    name: item['vehicle']['name'],
                    type: item['vehicle']['type'],
                    capacity: item['vehicle']['capacity'],
                    plate: item['vehicle']['plate'],
                  ),
                  departure: City(
                    id: item['departure']['id'],
                    name: item['departure']['name'],
                  ),
                  arrival: City(
                    id: item['arrival']['id'],
                    name: item['arrival']['name'],
                  ),
                );
              }).toList();
          schedules.sort((a, b) => a.departureAt.compareTo(b.departureAt));
        });
      } else {
        throw Exception('Failed to load schedules');
      }
    } catch (e) {
      print("Error fetching schedules: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return PageComp(
      child:
          schedules.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  ...schedules.map((schedule) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              schedule.vehicle.type == "Paket"
                                  ? Icons.inventory
                                  : schedule.vehicle.type == 'Travel'
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
                                const Text(
                                  "Jam Keberangkatan",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${schedule.departureAt.hour.toString().padLeft(2, '0')}:${schedule.departureAt.minute.toString().padLeft(2, '0')} WIB",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Tersedia ${schedule.seats} kursi",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.type == "Paket"
                                    ? ""
                                    : "Rp. ${schedule.price}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ButtonComp(
                                onPressed:
                                    schedule.seats > 0
                                        ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      widget.type == "Paket"
                                                          ? PaymentPage(
                                                            schedule: schedule,
                                                            namaLengkap:
                                                                widget
                                                                    .pengirim ??
                                                                "",
                                                            noHandphone:
                                                                widget
                                                                    .kontakPengirim ??
                                                                "",
                                                            email:
                                                                widget
                                                                    .penerima ??
                                                                "",
                                                            type: widget.type,
                                                          )
                                                          : OrderFormPage(
                                                            schedule: schedule,
                                                            type: widget.type,
                                                          ),
                                            ),
                                          );
                                        }
                                        : () {}, // Provide an empty function instead of null
                                text:
                                    schedule.seats > 0
                                        ? "Pilih"
                                        : "Habis", // Change the button text when no seats available
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
    );
  }
}
