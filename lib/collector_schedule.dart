import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CollectorSchedule extends StatefulWidget {
  final int collectorId;

  const CollectorSchedule({Key? key, required this.collectorId}) : super(key: key);

  @override
  _CollectorScheduleState createState() => _CollectorScheduleState();
}

class _CollectorScheduleState extends State<CollectorSchedule> {
  Map<String, dynamic>? pickup;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (widget.collectorId != 0) {
      fetchCurrentSchedule(widget.collectorId);
    } else {
      setState(() {
        errorMessage = 'Collector is not logged in.';
      });
    }
  }

  Future<void> fetchCurrentSchedule(int collectorId) async {
    final response = await http.get(
      Uri.parse('https://kayemndjr11.helioho.st/api/current.php?collector_id=$collectorId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('API Response: $data');
      if (data['status'] == 'success') {
        setState(() {
          pickup = data['pickup'];
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage = data['message'];
        });
      }
    } else {
      setState(() {
        errorMessage = 'Failed to load data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? pickupDate;
    String pickupDateStr = '';
    String pickupTimeStr = '';

    if (pickup != null && pickup!['pickup_date'] != null) {
      pickupDate = DateTime.parse(pickup!['pickup_date']);
      pickupDateStr = '${pickupDate.month}/${pickupDate.day}/${pickupDate.year}';
      pickupTimeStr = pickup!['pickup_time'];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Pickup Schedule'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Current Pickup Schedule',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 20),
            errorMessage.isEmpty
                ? pickup == null
                    ? const Text(
                        'No upcoming pickups.',
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      )
                    : Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date: $pickupDateStr',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Time: $pickupTimeStr',
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Weight: ${pickup?['weight_kg'] ?? 'Unknown'}',
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Status: ${pickup?['status'] ?? 'Unknown'}',
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Address: ${pickup?['address'] ?? 'Unknown'}',
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Contact Number: ${pickup?['phone_number'] ?? 'Unknown'}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      )
                : Text(
                    errorMessage,
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                  ),
          ],
        ),
      ),
    );
  }
}
