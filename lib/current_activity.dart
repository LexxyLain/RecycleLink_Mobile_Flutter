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
  Map<String, dynamic>? pickup;
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
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    }
  }

  Future<void> cancelPickup(String reason) async {
  try {
    final response = await http.post(
      Uri.parse('https://kayemndjr11.helioho.st/api/current.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'pickup_id': pickup?['pickup_id'].toString(),
        'reason': reason,
      }),
    );

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            pickup = null;
            reasonController.clear();
            showCancelReason = false;
            errorMessage = '';
          });
        } else {
          setState(() {
            errorMessage = data['message'];
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Invalid response format: ${e.toString()}';
        });
      }
    } else {
      setState(() {
        errorMessage = 'Failed to cancel pick-up. Server responded with status: ${response.statusCode}';
      });
    }
  } catch (e) {
    setState(() {
      errorMessage = 'An error occurred: $e';
    });
  }
}


  Future<void> completePickup() async {
    try {
      final response = await http.post(
        Uri.parse('https://kayemndjr11.helioho.st/api/current.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pickup_id': pickup?['pickup_id'].toString(),
          'status': 'Completed',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            pickup = null;
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
                ? pickup == null
                    ? const Center(
                        child: Text(
                          'No upcoming pickups.',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      )
                    : Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Card(
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
                                    'Date: $pickupDateStr',
                                    style: const TextStyle(
                                      fontSize: 14, 
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Time: $pickupTimeStr',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Weight: ${pickup?['weight_kg'] ?? 'Unknown'}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Status: ${pickup?['status'] ?? 'Unknown'}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Address: ${pickup?['address'] ?? 'Unknown'}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Contact Number: ${pickup?['phone_number'] ?? 'Unknown'}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showCancelReason = true;
                                      });
                                    },
                                    child: const Text('Cancel Pick-Up'),
                                  ),
                                  if (showCancelReason) ...[
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: reasonController,
                                      decoration: const InputDecoration(
                                        labelText: 'Reason for cancellation',
                                        border: OutlineInputBorder(),
                                      ),
                                      maxLines: 3,
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (reasonController.text.isNotEmpty) {
                                          cancelPickup(reasonController.text);
                                        } else {
                                          setState(() {
                                            errorMessage = 'Please provide a reason for cancellation.';
                                          });
                                        }
                                      },
                                      child: const Text('Submit'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
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
