import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  initializeDateFormatting().then((_) => runApp(Schedule(userId: '1')));
}

class Schedule extends StatelessWidget {
  final String userId;

  const Schedule({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalendarExample(userId: userId),
    );
  }
}

class CalendarExample extends StatefulWidget {
  final String userId;

  const CalendarExample({super.key, required this.userId});

  @override
  _CalendarExampleState createState() => _CalendarExampleState();
}

class _CalendarExampleState extends State<CalendarExample> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _events = {
      DateTime.now(): [Event('Today’s Event')],
      DateTime.utc(2024, 10, 17): [Event('Special Event')],
    };
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _showConfirmationDialog(BuildContext context, DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Appointment'),
          content: Text(
              'Do you want to schedule a pickup on ${DateFormat.yMMMd().format(selectedDate)}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WasteFormScreen(
                      selectedDate: selectedDate,
                      userId: widget.userId,
                    ),
                  ),
                );
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Schedule Pickup',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[900],
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

              _showConfirmationDialog(context, selectedDay);
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            enabledDayPredicate: (day) {
              // Disable all days before today
              return !day.isBefore(DateTime.now());
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: _getEventsForDay(_selectedDay ?? _focusedDay).length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _getEventsForDay(_selectedDay ?? _focusedDay)[index].title,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Event {
  final String title;

  Event(this.title);

  @override
  String toString() => title;
}

class WasteFormScreen extends StatefulWidget {
  final DateTime selectedDate;
  final String userId;

  const WasteFormScreen(
      {super.key, required this.selectedDate, required this.userId});

  @override
  _WasteFormScreenState createState() => _WasteFormScreenState();
}

class _WasteFormScreenState extends State<WasteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _wasteType;
  String? _wasteSize;
  String? _address;
  String? _contactNum;
  List<String> _sizes = [
    'Small (1-5kgs)',
    'Medium (6-20kgs)',
    'Large (21-45kgs)',
    'XL (46kgs++)'
  ];
  List<String> _wasteTypes = [
    'Type 1 – Home Appliances (Refrigerator, Washing Machine, Dryer etc.)',
    'Type 2 – Small Appliances (Vacuum Cleaners, Iron, Blender, Fryer etc.)',
    'Type 3 – Computer and Telecommunication Appliances (Laptop, PC, Telephone, Mobile Devices etc.)'
  ];
  Uint8List? _imageData;
  String? selectedSize;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String _mapSizeToEnum(String selectedSize) {
    switch (selectedSize) {
      case 'Small (1-5kgs)':
        return 'Small';
      case 'Medium (6-20kgs)':
        return 'Medium';
      case 'Large (21-45kgs)':
        return 'Large';
      case 'XL (46kgs++)':
        return 'XL';
      default:
        return '';
    }
  }

  String _mapWasteTypeToEnum(String selectedWasteType) {
    if (selectedWasteType.contains('Type 1')) return 'Type 1';
    if (selectedWasteType.contains('Type 2')) return 'Type 2';
    if (selectedWasteType.contains('Type 3')) return 'Type 3';
    return '';
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.first.bytes != null) {
        setState(() {
          _imageData = result.files.first.bytes;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Future<void> schedulePickup(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('https://kayemndjr11.helioho.st/api/pickups.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "action": "schedule",
          "user_id": data['user_id'],
          "weight_kg": data['weight_kg'],
          "pickup_date": data['pickup_date'],
          "pickup_time": data['pickup_time'],
          "e_waste_type": data['e_waste_type'],
          "address": data['address'],
          "phone_number": data['phone_number'],
        }),
      );

      print('Raw Response: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success']) {
          print('Pickup scheduled successfully');
        } else {
          print('Error: ${responseData['message']}');
        }
      } else {
        print('Failed to connect to the server');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void submitPickup() {
    if (_formKey.currentState?.validate() ?? false) {
      final pickupData = {
        'user_id': widget.userId,
        'weight_kg': _mapSizeToEnum(selectedSize!),
        'pickup_date': widget.selectedDate.toLocal().toString().split(' ')[0],
        'pickup_time': selectedTime?.format(context),
        'e_waste_type': _mapWasteTypeToEnum(_wasteType!),
        'address': _address,
        'phone_number': _contactNum,
      };

      schedulePickup(pickupData);
      Navigator.popUntil(context, ModalRoute.withName('/userDashboard'));
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Pick-up Schedule',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green[900],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Waste Type Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Waste Type',
                  border: OutlineInputBorder(), // Boxed border
                ),
                items: _wasteTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _wasteType = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a waste type' : null,
              ),
              const SizedBox(height: 16), // Improved spacing

              // Size Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Size',
                  border: OutlineInputBorder(),
                ),
                items: _sizes.map((String size) {
                  return DropdownMenuItem<String>(
                    value: size,
                    child: Text(size),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSize = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a size' : null,
              ),
              const SizedBox(height: 16),

              // Address Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _address = value;
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter an address'
                    : null,
              ),
              const SizedBox(height: 16),

              // Contact Number Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  _contactNum = value;
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a contact number'
                    : null,
              ),
              const SizedBox(height: 16),

              // Upload Image Button
              TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text('Upload Image'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromRGBO(33, 125, 37, 1),
                ),
              ),
              _imageData != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Image.memory(_imageData!),
                    )
                  : const SizedBox.shrink(),

              // Pickup Time Button
              TextButton(
                onPressed: () => _selectTime(context),
                child: Text('Select Pickup Time'),
              ),
              const SizedBox(height: 16),

              // Schedule Pickup Button
              ElevatedButton(
                onPressed: submitPickup,
                child: Text('Schedule Pickup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[900],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
