import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CollectorCurrentActivity extends StatefulWidget {
  final int collectorId;

  const CollectorCurrentActivity({Key? key, required this.collectorId})
      : super(key: key);

  @override
  _CollectorCurrentActivityState createState() =>
      _CollectorCurrentActivityState();
}

class _CollectorCurrentActivityState extends State<CollectorCurrentActivity> {
  List<dynamic>? approvedPickups; // List to store all approved pickups
  String errorMessage = '';
  bool showCancelReason = false; // To toggle visibility of the reason input
  final TextEditingController reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.collectorId != 0) {
      fetchAllApprovedPickups(widget.collectorId);
    } else {
      setState(() {
        errorMessage = 'Collector is not logged in.';
      });
    }
  }

  Future<void> fetchAllApprovedPickups(int collectorId) async {
  final response = await http.get(
    Uri.parse(
        'https://kayemndjr11.helioho.st/api/collectorcurrent.php?collector_id=$collectorId'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['status'] == 'success') {
      setState(() {
        // Cast the pickups as a list of maps
        approvedPickups = List<Map<String, dynamic>>.from(data['pickups']);
        errorMessage = '';
      });
    } else {
      setState(() {
        errorMessage = data['message'];
      });
    }
  } else {
    setState(() {
      errorMessage = 'Failed to load approved pickups.';
    });
  }
}


  Future<void> cancelPickup(int pickupId, String reason) async {
    final response = await http.post(
      Uri.parse('https://kayemndjr11.helioho.st/api/collectorcurrent.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'pickup_id': pickupId.toString(),
        'reason': reason,
        'action': 'cancel_pickup',
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          showCancelReason = false;
          errorMessage = 'Pick-up canceled successfully.';
        });
        fetchAllApprovedPickups(widget.collectorId); // Refresh pickups
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
  }

  Future<void> completePickup(int pickupId) async {
    final response = await http.post(
      Uri.parse('https://kayemndjr11.helioho.st/api/collectorcurrent.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'pickup_id': pickupId.toString(),
        'status': 'Completed',
        'action': 'update_status', // Specify action for status update
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          errorMessage = 'Pick-up completed successfully.';
        });
        fetchAllApprovedPickups(widget.collectorId); // Refresh pickups
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collector Activity'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: errorMessage.isNotEmpty
            ? Text(
                errorMessage,
                style: const TextStyle(fontSize: 18, color: Colors.red),
              )
            : approvedPickups == null
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: approvedPickups!.length,
                    itemBuilder: (context, index) {
                      final pickup = approvedPickups![index];
                      DateTime pickupDate = DateTime.parse(pickup['pickup_date']);
                      String pickupDateStr =
                          '${pickupDate.month}/${pickupDate.day}/${pickupDate.year}';
                      String pickupTimeStr = pickup['pickup_time'];

                      return Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8, // 80% width
                          child: Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pickup ID: ${pickup['pickup_id']}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Date: $pickupDateStr',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Time: $pickupTimeStr',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Weight: ${pickup['weight_kg']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Status: ${pickup['status']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Address: ${pickup['address']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Contact: ${pickup['phone_number']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 20),
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
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: reasonController,
                                      decoration: const InputDecoration(
                                        labelText: 'Reason for cancellation',
                                        border: OutlineInputBorder(),
                                      ),
                                      maxLines: 3,
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (reasonController.text.isNotEmpty) {
                                          cancelPickup(pickup['pickup_id'],
                                              reasonController.text);
                                        } else {
                                          setState(() {
                                            errorMessage =
                                                'Please provide a reason for cancellation.';
                                          });
                                        }
                                      },
                                      child: const Text('Submit'),
                                    ),
                                  ],
                                  ElevatedButton(
                                    onPressed: () {
                                      completePickup(pickup['pickup_id']);
                                    },
                                    child: const Text('Mark as Completed'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
