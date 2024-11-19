import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CollectorTransactionHistory extends StatefulWidget {
  final int collectorId;

  const CollectorTransactionHistory({Key? key, required this.collectorId})
      : super(key: key);

  @override
  _CollectorTransactionHistoryState createState() =>
      _CollectorTransactionHistoryState();
}

class _CollectorTransactionHistoryState
    extends State<CollectorTransactionHistory> {
  List<Map<String, dynamic>> transactions = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchTransactionHistory(widget.collectorId);
  }

  Future<void> fetchTransactionHistory(int collectorId) async {
    final response = await http.get(
      Uri.parse(
          'https://kayemndjr11.helioho.st/api/collector_history.php?collector_id=$collectorId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          transactions = List<Map<String, dynamic>>.from(data['transactions']);
          errorMessage = ''; // Clear any previous error message
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collector Transaction History'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Transaction History:',
              style: TextStyle(
                fontSize: 20, // Reduced font size for better alignment
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 20), // Reduced spacing
            errorMessage.isEmpty
                ? Expanded(
                    child: transactions.isEmpty
                        ? const Center(
                            child: Text(
                              'No transactions found.',
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                          )
                        : ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];
                              final pickupDate = DateTime.parse(
                                  transaction['pickup_date']);
                              final pickupDateFormatted =
                                  '${pickupDate.month}/${pickupDate.day}/${pickupDate.year}';
                              final pickupTimeFormatted =
                                  transaction['pickup_time'];

                              return Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.9, // 90% screen width
                                  child: Card(
                                    elevation: 3,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 6), // Reduced vertical spacing
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'User ID: ${transaction['user_id']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14), // Slightly smaller font
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Waste Type: ${transaction['waste_type']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Weight: ${transaction['weight_kg']} kg',
                                            style: const TextStyle(
                                                fontSize: 14), // Consistent font size
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Address: ${transaction['address']}',
                                            style: const TextStyle(fontSize: 14),
                                            overflow: TextOverflow.visible, // Wrap text
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Contact: ${transaction['contact_num']}',
                                            style: const TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis, // Wrap text
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Date: $pickupDateFormatted at $pickupTimeFormatted',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Status: ${transaction['status']}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: transaction['status'] ==
                                                      'Cancelled'
                                                  ? Colors.red
                                                  : Colors.green[800],
                                            ),
                                          ),
                                          if (transaction['status'] ==
                                              'Cancelled')
                                            Text(
                                              'Reason: ${transaction['cancellation_reason']}',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.red),
                                            ),
                                        ],
                                      ),
                                    ),
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
