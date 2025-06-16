import 'package:flutter/material.dart';

void main() {
  runApp(LintasShuttleApp());
}

class LintasShuttleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lintas Shuttle',
      home: ShuttleListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ShuttleListPage extends StatelessWidget {
  final List<ShuttleSchedule> schedules = [
    ShuttleSchedule(time: '11:30 WIB', available: 5),
    ShuttleSchedule(time: '13:45 WIB', available: 0),
    ShuttleSchedule(time: '15:45 WIB', available: 3),
    ShuttleSchedule(time: '18:00 WIB', available: 0),
    ShuttleSchedule(time: '19:00 WIB', available: 10),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Lintas Shuttle'),
        backgroundColor: Colors.blue[800],
      ),
      body: ListView.builder(
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jam Keberangkatan',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  SizedBox(height: 4),
                  Text(
                    schedule.time,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tersedia ${schedule.available} kursi',
                    style: TextStyle(
                        fontSize: 16,
                        color: schedule.available > 0 ? Colors.black : Colors.red),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp. 105,000',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      ElevatedButton(
                        onPressed:
                            schedule.available > 0 ? () {} : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: schedule.available > 0
                              ? Colors.blue
                              : Colors.grey[600],
                        ),
                        child: Text(schedule.available > 0 ? 'Pilih' : 'Habis'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ShuttleSchedule {
  final String time;
  final int available;

  ShuttleSchedule({required this.time, required this.available});
}
