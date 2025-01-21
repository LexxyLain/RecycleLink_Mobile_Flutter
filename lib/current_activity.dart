import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrentActivity extends StatefulWidget {
  final int userId;

  const CurrentActivity({Key? key, required this.userId}) : super(key: key);

  @override
  _CurrentActivityState createState() => _CurrentActivityState();
}

class _CurrentActivityState extends State<CurrentActivity> {
  List<Map<String, dynamic>> pickups = [];
  String errorMessage = '';
  bool showCancelReason = false;
  final TextEditingController reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.userId != 0) {
      fetchCurrentSchedule(widget.userId);
    } else {
      setState(() {
        errorMessage = 'User is not logged in.';
      });
    }
  }

  Future<void> fetchCurrentSchedule(int userId) async {
  try {
    final response = await http.get(
      Uri.parse('https://kayemndjr11.helioho.st/api/current.php?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          pickups = List<Map<String, dynamic>>.from(data['pickup']);

          pickups.sort((a, b) {
            DateTime dateTimeA = DateTime.parse("${a['pickup_date']} ${a['pickup_time']}");
            DateTime dateTimeB = DateTime.parse("${b['pickup_date']} ${b['pickup_time']}");
            return dateTimeB.compareTo(dateTimeA); 
          });

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
  } catch (e) {
    setState(() {
      errorMessage = 'An error occurred: $e';
    });
  }
}



  Future<void> cancelPickup(String reason, int pickupId) async {
    try {
      final response = await http.post(
        Uri.parse('https://kayemndjr11.helioho.st/api/current.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pickup_id': pickupId.toString(),
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            pickups.removeWhere((pickup) => pickup['pickup_id'] == pickupId);
            reasonController.clear();
            showCancelReason = false;
            errorMessage = '';
          });
        } else {
          setState(() {
            errorMessage = data['message'];
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to cancel pick-up.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    }
  }

  Future<void> completePickup(int pickupId) async {
    try {
      final response = await http.post(
        Uri.parse('https://kayemndjr11.helioho.st/api/current.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pickup_id': pickupId.toString(),
          'status': 'Completed',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            pickups.removeWhere((pickup) => pickup['pickup_id'] == pickupId);
            errorMessage = 'Pick-up completed successfully.';
          });
        } else {
          setState(() {
            errorMessage = data['message'];
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to update pick-up status.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Pickup Schedule'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Your Current Pickup Schedule',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 20),
            errorMessage.isEmpty
                ? pickups.isEmpty
                    ? const Center(
                        child: Text(
                          'No upcoming pickups.',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: pickups.length,
                          itemBuilder: (context, index) {
                            final pickup = pickups[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date: ${pickup['pickup_date']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Time: ${pickup['pickup_time']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Weight: ${pickup['weight_kg']} kg',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Status: ${pickup['status']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Address: ${pickup['address']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Contact Number: ${pickup['phone_number']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => setState(() {
                                            showCancelReason = true;
                                          }),
                                          child: const Text('Cancel Pickup'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (showCancelReason)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextField(
                                            controller: reasonController,
                                            decoration: const InputDecoration(
                                              labelText: 'Cancellation Reason',
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              cancelPickup(
                                                  reasonController.text,
                                                  pickup['pickup_id']);
                                            },
                                            child: const Text('Confirm Cancel'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                : Center(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
