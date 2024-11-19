import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({Key? key}) : super(key: key);

  @override
  _TransactionHistoryState createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  List<Map<String, dynamic>> transactions = [];
  String errorMessage = '';
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });

    if (userId != null) {
      fetchTransactionHistory(userId!);
    } else {
      setState(() {
        errorMessage = 'User is not logged in.';
      });
    }
  }

  Future<void> fetchTransactionHistory(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('https://kayemndjr11.helioho.st/api/transaction_history.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            transactions = List<Map<String, dynamic>>.from(data['transactions']);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.green[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Transaction History:',
              style: TextStyle(
                fontSize: 20, // Reduced size
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
            const SizedBox(height: 20),
            errorMessage.isEmpty
                ? userId == null
                    ? const Center(child: CircularProgressIndicator())
                    : Expanded(
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
                                  final pickupDate = DateTime.parse(transaction['pickup_date']);
                                  final pickupDateFormatted = '${pickupDate.month}/${pickupDate.day}/${pickupDate.year}';
                                  final pickupTimeFormatted = transaction['pickup_time'];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Waste Type: ${transaction['waste_type']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14, // Reduced size
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Weight: ${transaction['weight_kg']} kg',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              'Address: ${transaction['address']}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              'Contact: ${transaction['contact_num']}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Date: $pickupDateFormatted at $pickupTimeFormatted',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            Text(
                                              'Status: ${transaction['status']}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (transaction['status'] == 'Cancelled' &&
                                                transaction['cancellation_reason'] != 'N/A')
                                              Text(
                                                'Cancelled Reason: ${transaction['cancellation_reason']}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red,
                                                ),
                                              ),
                                          ],
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
