import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MappingCollector extends StatefulWidget {
  const MappingCollector({Key? key, required userId}) : super(key: key);

  @override
  _MappingCollectorState createState() => _MappingCollectorState();
}

class _MappingCollectorState extends State<MappingCollector> {
  LatLng? _latestPosition;
  MapController? _mapController;
  String? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _fetchLatestLocation();
  }

  Future<void> _fetchLatestLocation() async {
  const String apiUrl = "https://kayemndjr11.helioho.st/api/collectorloc.php";

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data["success"]) {
        // Convert latitude and longitude to double
        final latitude = double.parse(data["data"]["latitude"].toString());
        final longitude = double.parse(data["data"]["longitude"].toString());
        final timestamp = data["data"]["timestamp"];

        setState(() {
          _latestPosition = LatLng(latitude, longitude);
          _lastUpdated = timestamp;
          _mapController?.move(_latestPosition!, 16.0);
        });
      } else {
        _showErrorSnackbar(data["message"] ?? "Failed to fetch location.");
      }
    } else {
      _showErrorSnackbar("Error: ${response.statusCode}");
    }
  } catch (e) {
    _showErrorSnackbar("An error occurred: $e");
  }
}

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Collector Map")),
      body: _buildMap(),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchLatestLocation,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController ??= MapController(),
      options: MapOptions(
        center: _latestPosition ?? LatLng(0, 0),
        zoom: 16.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        if (_latestPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _latestPosition!,
                builder: (_) => const Icon(
                  Icons.location_on,
                  color: Colors.red,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
