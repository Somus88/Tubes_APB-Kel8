import 'package:tubes_progress/models/schedule.dart';

class Booking {
  final String id;
  final String userId;
  final String namaLengkap;
  final String email;
  final String? phoneNumber;
  final String scheduleId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Schedule schedule;
  final String type;

  Booking({
    required this.id,
    required this.userId,
    required this.namaLengkap,
    required this.email,
    this.phoneNumber,
    required this.scheduleId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.schedule,
    required this.type,
  });
}
