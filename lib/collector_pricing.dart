import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CollectorPricingPage extends StatefulWidget {
  const CollectorPricingPage({Key? key}) : super(key: key);

  @override
  _CollectorPricingPageState createState() => _CollectorPricingPageState();
}

class _CollectorPricingPageState extends State<CollectorPricingPage> {
  String? _pickupId;
  String? _errorMessage;
  String? _pricingDetails;
  String? _price;
  bool _isLoading = true;
  int? _collectorId;

  @override
  void initState() {
    super.initState();
    _loadCollectorId();
  }

  Future<void> _loadCollectorId() async {
    final prefs = await SharedPreferences.getInstance();
    final collectorId = prefs.getInt('collector_id');

    if (collectorId != null) {
      setState(() {
        _collectorId = collectorId;
      });
      _fetchLatestPickup(collectorId);
    } else {
      setState(() {
        _errorMessage = 'Error: Collector not logged in.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchLatestPickup(int collectorId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://kayemndjr11.helioho.st/api/collector_pricing.php?collector_id=$collectorId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            _pickupId = data['pickup']['pickup_id'].toString();
            _price = '₱${data['pickup']['price']}';
            _pricingDetails =
                'Weight: ${data['pickup']['weight_kg']}\nType: ${data['pickup']['e_waste_type']}\nStatus: ${data['pickup']['status']}';
            _errorMessage = null;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch the latest pickup.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collector Pricing'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Pricing Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 16, color: Colors.red),
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
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _price ?? '',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pickup ID: $_pickupId',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _pricingDetails ?? 'No details available.',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
