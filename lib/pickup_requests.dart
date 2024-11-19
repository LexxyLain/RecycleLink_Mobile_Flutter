import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PickupRequests extends StatefulWidget {
  final int collectorId;

  const PickupRequests({Key? key, required this.collectorId}) : super(key: key);

  @override
  _PickupRequestsState createState() => _PickupRequestsState();
}

class _PickupRequestsState extends State<PickupRequests> {
  late Future<List<PickupRequestItemData>> pickupRequests;

  @override
  void initState() {
    super.initState();
    pickupRequests = fetchPickupRequests();
  }

  Future<List<PickupRequestItemData>> fetchPickupRequests() async {
    try {
      final response = await http.post(
        Uri.parse('https://kayemndjr11.helioho.st/api/pickups.php'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'action': 'get_pickups', // Adjust the action to match the API
          'collector_id': widget.collectorId,  // Send collector ID
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final pickups = data['pickups'] as List;
          return pickups.map((item) => PickupRequestItemData.fromJson(item)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch pickup requests');
        }
      } else {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching pickup requests: $e');
    }
  }

  Future<void> updatePickupStatus(int pickupId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('https://kayemndjr11.helioho.st/api/pickups.php'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'action': 'update_status',
          'pickup_id': pickupId,
          'collector_id': widget.collectorId,
          'status': status,
        }),
      );

      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          pickupRequests = fetchPickupRequests();
        });
      } else {
        print("Error updating status: ${data['message']}");
      }
    } catch (e) {
      print('Error updating pickup status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick-up Requests'), backgroundColor: Colors.green[400]),
      body: FutureBuilder<List<PickupRequestItemData>>(
        future: pickupRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pickup requests found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final request = snapshot.data![index];
                return PickupRequestItem(
                  pickupId: request.pickupId,
                  wasteType: request.wasteType,
                  wasteSize: request.wasteSize,
                  address: request.address,
                  contactNum: request.contactNum,
                  date: request.date,
                  userId: request.userId,
                  onApprove: () => updatePickupStatus(request.pickupId, 'Approved'),
                  onDisapprove: () => updatePickupStatus(request.pickupId, 'Disapproved'),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class PickupRequestItem extends StatelessWidget {
  final int pickupId;
  final String wasteType;
  final String wasteSize;
  final String address;
  final String contactNum;
  final String date;
  final int userId;
  final VoidCallback onApprove;
  final VoidCallback onDisapprove;

  const PickupRequestItem({
    Key? key,
    required this.pickupId,
    required this.wasteType,
    required this.wasteSize,
    required this.address,
    required this.contactNum,
    required this.date,
    required this.userId,
    required this.onApprove,
    required this.onDisapprove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('$wasteType ($wasteSize)'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address: $address'),
            Text('Contact Number: $contactNum'),
            Text('Date: $date'),
            Text('User ID: $userId'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: onApprove),
            IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: onDisapprove),
          ],
        ),
      ),
    );
  }
}

class PickupRequestItemData {
  final int pickupId;
  final String wasteType;
  final String wasteSize;
  final String address;
  final String contactNum;
  final String date;
  final int userId;

  PickupRequestItemData({
    required this.pickupId,
    required this.wasteType,
    required this.wasteSize,
    required this.address,
    required this.contactNum,
    required this.date,
    required this.userId,
  });

  factory PickupRequestItemData.fromJson(Map<String, dynamic> json) {
    return PickupRequestItemData(
      pickupId: int.tryParse(json['pickup_id'].toString()) ?? 0,  // Safely parse pickup_id to int
      wasteType: json['e_waste_type'] ?? '',  // Default to empty string if null
      wasteSize: json['weight_kg'] ?? '',     // Default to empty string if null
      address: json['address'] ?? '',         // Default to empty string if null
      contactNum: json['phone_number'] ?? '', // Default to empty string if null
      date: json['pickup_date'] ?? '',        // Default to empty string if null
      userId: int.tryParse(json['user_id'].toString()) ?? 0,    // Safely parse user_id
    );
  }
}
