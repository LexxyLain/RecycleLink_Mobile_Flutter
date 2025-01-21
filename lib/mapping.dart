import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Correct import for FlutterMap
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MappingScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String title;
  final int userId;
  final int collectorId;

  const MappingScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.userId,
    required this.collectorId,
  }) : super(key: key);

  @override
  _MappingScreenState createState() => _MappingScreenState();
}

class _MappingScreenState extends State<MappingScreen> {
  final MapController _mapController = MapController();
  LatLng? pinnedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _searchLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(10.6675, 122.9494), // Bacolod City coordinates
              zoom: 13,
              onTap: (tapPosition, latLng) => _onMapTap(latLng),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              if (pinnedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: pinnedLocation!,
                      builder: (ctx) => Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (pinnedLocation != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: _submitLocation,
                child: Text("Submit Location"),
              ),
            ),
        ],
      ),
    );
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      pinnedLocation = latLng;
    });
  }

  Future<void> _searchLocation() async {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController _controller = TextEditingController();
        return AlertDialog(
          title: Text("Search Location"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Enter location name'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String searchQuery = _controller.text.trim();
                if (searchQuery.isNotEmpty) {
                  await _fetchLocationFromOSM(searchQuery);
                }
                Navigator.pop(context);
              },
              child: Text("Search"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchLocationFromOSM(String query) async {
    final response = await http.get(
      Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final latitude = double.parse(data[0]['lat']);
        final longitude = double.parse(data[0]['lon']);

        setState(() {
          pinnedLocation = LatLng(latitude, longitude);
        });

        // Update map center without using Google Maps methods
        _mapController.move(LatLng(latitude, longitude), 13.0); // This works for flutter_map
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location not found")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching location")),
      );
    }
  }

  Future<void> _submitLocation() async {
    if (pinnedLocation == null) return;

    try {
      final response = await http.post(
        Uri.parse('https://kayemndjr11.helioho.st/api/location.php'),
        body: jsonEncode({
          'latitude': pinnedLocation!.latitude.toString(),
          'longitude': pinnedLocation!.longitude.toString(),
          'user_id': widget.userId,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Location submitted successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to submit location: ${result['message']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting location: $e")),
      );
    }
  }
}
