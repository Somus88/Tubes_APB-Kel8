class Vehicle {
  final String id;
  final String name;
  final String type;
  final int capacity;
  final String plate;

  Vehicle({
    required this.id,
    required this.name,
    required this.type,
    required this.capacity,
    required this.plate,
  });
}

class City {
  final String id;
  final String name;

  City({required this.id, required this.name});
}

class Schedule {
  final String id;
  final String vehicleId;
  final String departureId;
  final String arrivalId;
  final DateTime departureAt;
  final DateTime arrivalAt;
  final int price;
  final int seats;
  final Vehicle vehicle;
  final City departure;
  final City arrival;

  Schedule({
    required this.id,
    required this.vehicleId,
    required this.departureId,
    required this.arrivalId,
    required this.departureAt,
    required this.arrivalAt,
    required this.price,
    required this.seats,
    required this.vehicle,
    required this.departure,
    required this.arrival,
  });
}
